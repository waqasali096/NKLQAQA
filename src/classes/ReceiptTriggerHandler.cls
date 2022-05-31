public class ReceiptTriggerHandler {
    
    List<Receipt__c> recordNewList = new List<Receipt__c>();
    List<Receipt__c> recordOldList = new List<Receipt__c>();
    Map<Id, Receipt__c> recordNewMap = new Map<Id, Receipt__c>();
    Map<Id, Receipt__c> recordOldMap = new Map<Id, Receipt__c>();
    Boolean isInsert, isUpdate, isDelete, isUndelete, isBefore, isAfter = false;
    public static boolean recursionController = false;
    public ReceiptTriggerHandler(List<Receipt__c> newList, List<Receipt__c> oldList, Map<Id, Receipt__c> newMap, Map<Id, Receipt__c> oldMap, 
                                 boolean isInsert, boolean isUpdate, Boolean isDelete, Boolean isUndelete, Boolean isBefore, Boolean isAfter){
                                     this.recordNewList = newList;
                                     this.recordOldList = oldList;
                                     this.recordNewMap = newMap;
                                     this.recordOldMap = oldMap;
                                     this.isInsert = isInsert;
                                     this.isUpdate = isUpdate;
                                     this.isDelete = isDelete;
                                     this.isUndelete = isUndelete;
                                     this.isBefore = isBefore;
                                     this.isAfter = isAfter;        
                                 }


    public void BeforeInsertEvent() {
        for(Receipt__c receipt : recordNewList){
            receipt.Send_Receipt_to_ERP__c = true;
        }
    }

    public void BeforeUpdateEvent(List<Receipt__c> newOppList,Map<Id, Receipt__c> recordOldMap,Map<Id, Receipt__c> recordNewMap) {
        createReceiptsReversalERP();
        createRefundERP();
    }
    
    public void AfterInsertEvent(List<Receipt__c> newList) {
        attachReceiptToMilestone();
        attachReceiptToInvoice();
        attachReceiptToCharges();
        handleCCAvenueCallout( newList );
        updateDealAmountChecksPaid( recordNewList, null );
        leasingAutomationsForMoneyRealisation(recordNewList, null);
        createReceiptsERP();
        updateSequenceNumber(recordNewList);
        propertyPaidCalculation(recordNewList, null);
        calculatePaidAmountOnMilestone(recordNewList);
        calculatePaidAmountOnInvoice(recordNewList);
        mortgageRegistrationReceiptReceived(recordNewList);
        mortgageManagersChequeCleared(recordNewList);
        UpdateTotalReceiptAmount.calculateTotalReceiptAmount(recordNewList);
    }

    public void AfterUpdateEvent() {
        updateDealAmountChecksPaid( recordNewList, recordOldMap );
        leasingAutomationsForMoneyRealisation(recordNewList, recordOldMap);
        createReceiptsERP();
        propertyPaidCalculation(recordNewList, recordOldMap);
        calculatePaidAmountOnMilestone(recordNewList);
        calculatePaidAmountOnInvoice(recordNewList);
        mortgageRegistrationReceiptReceived(recordNewList);
        mortgageManagersChequeCleared(recordNewList);
        checkReceiptCreated(recordNewList, recordOldMap);
        UpdateTotalReceiptAmount.calculateTotalReceiptAmount(recordNewList);
        sendReceiptClearedMailtoCustomer();//Added By Mamta
    }

    public void BeforeDeleteEvent() {
    }

    public void AfterDeleteEvent() {
        calculatePaidAmountOnMilestone(recordOldList);
        calculatePaidAmountOnInvoice(recordOldList);
        UpdateTotalReceiptAmount.calculateTotalReceiptAmount(recordNewList);
    }

    public void AfterUndeleteEvent() {
        calculatePaidAmountOnMilestone(recordNewList);
        calculatePaidAmountOnInvoice(recordNewList);
        UpdateTotalReceiptAmount.calculateTotalReceiptAmount(recordNewList);
    }

    public static void handleCCAvenueCallout(List<Receipt__c> records){
        for(Receipt__c onlinepay : records){
            System.debug('Inside Receipt trigger handle Callout');
            if(onlinepay.Payment_Link_Sent__c == false && onlinepay.Payment_Mode__c =='Online'){
               CCAvenueCallout.calloutPrepration(onlinepay.id);   
            }
        }
    } 


    /**********************************************************************************************
    * @Description  : Method to update opportunity token amount paid, DLD paid, Down Payment received
    * @Params       : List< Receipt__c > newList
    * @Param        : Map< Id, Receipt__c > oldMap
    * @Return       : void
    **********************************************************************************************/
    public static void updateDealAmountChecksPaid( List< Receipt__c > newList, Map< Id, Receipt__c > oldMap ){
        
        Map< Id, Opportunity> OppMap = new Map< Id, Opportunity>();

        for( Receipt__c op : newList ){
            if( op.Opportunity__c != null && ( oldMap == null || op.Payment_Status__c != oldMap.get(op.Id).Payment_Status__c ) && op.Payment_Status__c == 'Cleared'){
                
                if ( !OppMap.containsKey(op.Opportunity__c) ) {
                    Opportunity opp = new Opportunity();
                    opp.Id = op.Opportunity__c;
                    if(op.Received_For__c == 'Token Amount'){
                        opp.Token_Amount_Paid__c = true;
                    }
                    else if(op.Received_For__c == 'Deposit'){
                        opp.Down_Payment_Received__c = true;
                    }
                    else if(op.Received_For__c == 'DLD_FEE'){
                        opp.DLD_Paid__c = true;
                    }
                    OppMap.put(op.Opportunity__c , opp);
                } else {
                    Opportunity opp = OppMap.get(op.Opportunity__c);
                    if(op.Received_For__c == 'Token Amount'){
                        opp.Token_Amount_Paid__c = true;
                    }
                    else if(op.Received_For__c == 'Deposit'){
                        opp.Down_Payment_Received__c = true;
                    }
                    else if(op.Received_For__c == 'DLD_FEE'){
                        opp.DLD_Paid__c = true;
                    }
                    OppMap.put(op.Opportunity__c, opp );
                }
            }
        }
        if(!OppMap.isEmpty()){
            update OppMap.values();
        }
    }
    /**********************************************************************************************
    * @Description  : Method to update property % paid filed on Deal
    * @Return       : void
    **********************************************************************************************/
    public static void propertyPaidCalculation(List< Receipt__c > newList, Map< Id, Receipt__c > oldMap){
        List<Opportunity> oppList = new List<Opportunity>();
        Set<Id> oppIdSet = new Set<Id>();
        for( Receipt__c op : newList ){
            if( op.Opportunity__c != null && ( oldMap == null || op.Payment_Status__c != oldMap.get(op.Id).Payment_Status__c ) && op.Payment_Status__c == 'Cleared'){
                oppIdSet.add(op.Opportunity__c); 
            }
        }

        if(!oppIdSet.isEmpty()){
            for(Opportunity opp : [SELECT Id,Net_Selling_Price__c, (SELECT Id,Payment_Status__c,Amount__c FROM OnlinePayments__r WHERE Payment_Status__c = 'Cleared') FROM Opportunity WHERE Id IN: oppIdSet AND Net_Selling_Price__c != 0]){
                Double totalAmount = 0;
                for(Receipt__c rep : opp.OnlinePayments__r){
                    if(rep.Amount__c != null){
                        totalAmount += rep.Amount__c;
                    }
                }
                Opportunity op = new Opportunity();
                op.Id = opp.Id;
                op.Property_Paid__c = (totalAmount / opp.Net_Selling_Price__c)*100;
                oppList.add(op);
            }
        }
        if(!oppList.isEmpty()){
            update oppList;
        }
    }

    /**********************************************************************************************
    * @Description  : Method to create receipts in ERP system
    * @Params       : List< Receipt__c > newList
    * @Param        : Map< Id, Receipt__c > oldMap
    * @Return       : void
    * @Author       : Karishma Kotian
    **********************************************************************************************/
    public void createReceiptsERP(){
        Set<Id> receiptId = new Set<Id>();
        
        for(Receipt__c receipt : recordNewList){
            if(receipt.Send_Receipt_to_ERP__c && (recordOldMap == null || receipt.Send_Receipt_to_ERP__c != recordOldMap.get(receipt.Id).Send_Receipt_to_ERP__c)){
                receiptId.add(receipt.Id);
            }
        }
        if(!receiptId.isEmpty()){
            ERPIntegrationHelper.createReceipt(receiptId);
        }
    }

    /**********************************************************************************************
    * @Description  : Method to create reversal receipts in ERP system
    * @Params       : List< Receipt__c > newList
    * @Param        : Map< Id, Receipt__c > oldMap
    * @Return       : void
    * @Author       : Vishal A
    **********************************************************************************************/
    public void createReceiptsReversalERP(){
        Set<Id> receiptId = new Set<Id>();
        
        for(Receipt__c receipt : recordNewList){
            if(receipt.Send_Receipt_Reversal_ERP__c && (recordOldMap == null || receipt.Send_Receipt_Reversal_ERP__c != recordOldMap.get(receipt.Id).Send_Receipt_Reversal_ERP__c)){
                receiptId.add(receipt.Id);
                receipt.Send_Receipt_Reversal_ERP__c = false;
            }
        }
        if(!receiptId.isEmpty()){
            ERPIntegrationHelper.createReceiptReversal(receiptId);
        }
    }
    
    /**********************************************************************************************
    * @Description  : Method to create Refund in ERP system
    * @Params       : List< Receipt__c > newList
    * @Param        : Map< Id, Receipt__c > oldMap
    * @Return       : void
    * @Author       : Vishal A
    **********************************************************************************************/
    public void createRefundERP(){
        Set<Id> receiptId = new Set<Id>();
        
        for(Receipt__c receipt : recordNewList){
            if(receipt.Send_Refund_to_ERP__c && (recordOldMap == null || receipt.Send_Refund_to_ERP__c != recordOldMap.get(receipt.Id).Send_Refund_to_ERP__c)){
                receiptId.add(receipt.Id);
                receipt.Send_Refund_to_ERP__c = false;
            }
        }
        if(!receiptId.isEmpty()){
            //ERPIntegrationHelper.createRefundERP(receiptId);
        }
    }
    
    /********************************************************************************************** 
    * @Description  : Method to create reversal receipt in ERP system
    * @Params       : Receipt - Set of Receipt Ids
    * @Return       : void
    * @Author       : Vishal A
    **********************************************************************************************/
    public Static void createReceiptReversalCall(Set<Id> receiptIds) {
        createReverseReceiptQueue createReceipt = new createReverseReceiptQueue(receiptIds);
        system.enqueueJob(createReceipt);
    }
    
    /********************************************************************************************** 
    * @Description  : Method to create refund in ERP system
    * @Params       : Receipt - Set of Receipt Ids
    * @Return       : void
    * @Author       : Vishal A
    **********************************************************************************************/
    // commented by Vishal
   /* public Static void createRefundCall(Set<Id> receiptIds) {
        createRefundQueue createReceipt = new createRefundQueue(receiptIds);
        system.enqueueJob(createReceipt);
    } */
    
    /********************************************************************************************** 
    * @Description  : Queueable class to for callout to ERP system
    * @Params       : Receipt - Set of Receipt Ids
    * @Return       : void
    * @Author       : Vishal A
    **********************************************************************************************/
    public class createReverseReceiptQueue implements system.Queueable, Database.AllowsCallouts{
        Private  Set<Id> receiptIds;
        public createReverseReceiptQueue(set<Id> receiptIds){
            this.receiptIds=receiptIds;
        }
        public void execute(QueueableContext content){
            //ERPAPIIntegration.createReceiptReversal(receiptIds);
        }
    }
    
    /********************************************************************************************** 
    * @Description  : Queueable class to for callout to ERP system Refund
    * @Params       : Receipt - Set of Receipt Ids
    * @Return       : void
    * @Author       : Vishal A
    **********************************************************************************************/
    //commented by vishal k
   /* public class createRefundQueue implements system.Queueable, Database.AllowsCallouts{
        Private  Set<Id> receiptIds;
        public createRefundQueue(set<Id> receiptIds){
            this.receiptIds=receiptIds;
        }
        public void execute(QueueableContext content){
            //ERPAPIIntegration.createRefundERP(receiptIds);
        }
    } */
    
    /********************************************************************************************** 
    * @Description  : Update Sequence number field in A5 doc gen
    * @Params       : List<Receipt__c>
    * @Return       : void
    * @Author       : Karishma Kotian
    **********************************************************************************************/
    public static void updateSequenceNumber(List<Receipt__c> recordNewList ){
        Set<Id> opptyId = new set<Id>();
        Map<Id,List<Receipt__c>> receiptMapToOppty = new Map<Id,List<Receipt__c>>();
        List<Receipt__c> receiptList = new List<Receipt__c>();
        for(Receipt__c rcpt : recordNewList){
            opptyId.add(rcpt.Opportunity__c);
        }
        
        List<Receipt__c> receiptL = [SELECT Id, Sequence_Number__c, Opportunity__c FROM Receipt__c WHERE Opportunity__c =: opptyId];
        for(Receipt__c receipt : receiptL){
            if(receiptMapToOppty.containsKey(receipt.Opportunity__c)){
                receiptMapToOppty.get(receipt.Opportunity__c).add(receipt);
            }else{
                receiptMapToOppty.put(receipt.Opportunity__c, new List<Receipt__c>{receipt});
            }
        }

        for(Id key : receiptMapToOppty.keySet()){
            Integer counter = 1;
           for(Receipt__c recpt : receiptMapToOppty.get(key)){
                recpt.Sequence_Number__c = counter;
                receiptList.add(recpt);
                counter++;
           } 
        }

        if(!receiptList.isEmpty()){

            update receiptList;
        }
    }

    
    /**********************************************************************************************
    * @Description  : Method to update holding deposits and security deposits recevied status in deal
    * @Params       : List< Receipt__c > newList
    * @Param        : Map< Id, Receipt__c > oldMap
    * @Return       : void
    * @Author       : Karishma Kotian
    **********************************************************************************************/
    public static void leasingAutomationsForMoneyRealisation( List< Receipt__c > newList, Map< Id, Receipt__c > oldMap ){
        Set<Id> setOpptyIds = new Set<Id>();
        List<Opportunity> lstOpportunityToUpdate = new List<Opportunity>();
        Map<Id,Boolean> SecurityDepositRecevied = new Map<Id,Boolean>();
        Map<Id,Boolean> holdingDepositRecevied = new Map<Id,Boolean>();
        List<Unit__c> unitStatusUpdate = new List<Unit__c>();
        List<Unit_Plan__c> opptyUnits  =  new List<Unit_Plan__c>();

        for( Receipt__c op : newList ){
            if( ( oldMap == null || op.Payment_Status__c != oldMap.get(op.Id).Payment_Status__c || op.Payment_Mode__c != oldMap.get(op.Id).Payment_Mode__c) && op.Received_For__c != null){
                if(op.Received_For__c.containsIgnoreCase('Holding Deposit')){
                    if(op.Payment_Status__c != null && (op.Payment_Status__c == 'Paid' || op.Payment_Status__c == 'Cleared')){
                        holdingDepositRecevied.put(op.opportunity__c,true);
                        setOpptyIds.add(op.opportunity__c);
                    }  
                }else if(op.ReceivedForMapping__c!=null && op.ReceivedForMapping__c.containsIgnoreCase('SEC')){
                    if(op.Payment_Status__c != null && (op.Payment_Status__c == 'Paid' || op.Payment_Status__c == 'Cleared')){
                        SecurityDepositRecevied.put(op.opportunity__c,true);
                             setOpptyIds.add(op.opportunity__c);
                    }
                }
            }
        }

        if(setOpptyIds.size() > 0){
            //Added Code to bypass Lease Renewal - hitesh
            List<Opportunity> lstOpp=[select id,RecordTypeId, StageName from Opportunity where id in:setOpptyIds];
            Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Lease_Renewal').getRecordTypeId();
        	Id oppCommRenewRcdTyp= Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Commercial Lease Renewal').getRecordTypeId();

            Map<Id,Opportunity> mapOppIDtoOpp=new Map<Id,Opportunity>();
            for(Opportunity o:lstOpp){
                if(o.RecordTypeId==oppRecordTypeId ||o.RecordTypeId==oppCommRenewRcdTyp){
                   mapOppIDtoOpp.put(o.id,o); 
                }
                
            }
            for(Id oppId :setOpptyIds ){
                if(!mapOppIDtoOpp.containsKey(oppId)){
                Opportunity oppty = new Opportunity();
                oppty.Id = oppId;
                if(holdingDepositRecevied.containsKey(oppId)){
                oppty.Booking_Fee_gets_collected__c =holdingDepositRecevied.get(oppId);
                }
                if(SecurityDepositRecevied.containsKey(oppId)){
                oppty.Security_Deposit_Recevied__c =SecurityDepositRecevied.get(oppId);
                    oppty.StageName = 'Booking';
                }
                lstOpportunityToUpdate.add(oppty);
                
            }
            }
        }

        if(!lstOpportunityToUpdate.isEmpty()){
            update lstOpportunityToUpdate;
            opptyUnits = [SELECT Id, Opportunity__c, Opportunity__r.Booking_Fee_gets_collected__c,
                          Opportunity__r.Security_Deposit_Recevied__c,Unit__c,Renewal_new_unit__c
                          FROM Unit_Plan__c WHERE Opportunity__c =: setOpptyIds];
            
        }
        if(!opptyUnits.isEmpty()){
            for(Unit_Plan__c opptyUnit : opptyUnits){
                if(opptyUnit.Unit__c != null && (opptyUnit.Opportunity__r.Security_Deposit_Recevied__c)  && opptyUnit.Renewal_new_unit__c==True){
                    Unit__c unit = new Unit__c(Id = opptyUnit.Unit__c, Unit_Status__c = 'Booked');
                    unitStatusUpdate.add(unit);
                }
            }
        }

        if(!unitStatusUpdate.isEmpty()){
            update unitStatusUpdate;
        }
    }


    /********************************************************************************************** 
    * @Description  : Calculate Total Paid Amount for Payment Milestone
    * @Return       : void
    * @Author       : Rohit Sharma
    **********************************************************************************************/
        
    public void calculatePaidAmountOnMilestone(List<Receipt__c> newList){
        List<Id> pmId = new List<Id>();
        for(Receipt__c rec :newList){
            if(rec.Payment_Milestone__c != null){
                if(isAfter && isUpdate){
                    if(rec.Payment_Status__c != recordOldMap.get(rec.Id).Payment_Status__c){
                        pmId.add(rec.Payment_Milestone__c);
                    }
                }else{
                    pmId.add(rec.Payment_Milestone__c);
                }
            }
        }
        if(!pmId.isEmpty()){
            List<Payment_Milestone__c> pmList = new List<Payment_Milestone__c>();
            for(AggregateResult ag : [SELECT Payment_Milestone__c ,SUM(Amount__c)amt FROM Receipt__c WHERE Payment_Milestone__c IN: pmId AND Payment_Status__c = 'Cleared' GROUP BY Payment_Milestone__c]){
                Payment_Milestone__c pm = new Payment_Milestone__c();
                pm.Paid_Amount__c = (Decimal)ag.get('amt');
                pm.Id = (Id)ag.get('Payment_Milestone__c');
                pmList.add(pm);
            }
            if(!pmList.isEmpty()){
                Database.update(pmList, false);
            }
        }
    }
    /********************************************************************************************** 
    * @Description  : Calculate Paid Amount for Invoice
    * @Return       : void
    * @Author       : Rohit Sharma
    **********************************************************************************************/
        
    public void calculatePaidAmountOnInvoice(List<Receipt__c> newList){
        List<Id> invId = new List<Id>();
        for(Receipt__c rec :newList){
            if(rec.Invoice__c != null){
                if(isAfter && isUpdate){
                    if(rec.Payment_Status__c != recordOldMap.get(rec.Id).Payment_Status__c){
                        invId.add(rec.Invoice__c);
                    }
                }else{
                    invId.add(rec.Invoice__c);
                } 
            }   
        }
        if(!invId.isEmpty()){
            List<Invoice__c> invList = new List<Invoice__c>();
            for(AggregateResult ag : [SELECT Invoice__c ,SUM(Amount__c)amt FROM Receipt__c WHERE Invoice__c IN: invId AND Payment_Status__c = 'Cleared' GROUP BY Invoice__c]){
                Invoice__c inv = new Invoice__c();
                inv.Paid_Amount__c = (Decimal)ag.get('amt');
                inv.Id = (Id)ag.get('Invoice__c');
                invList.add(inv);
            }
            if(!invList.isEmpty()){
                Database.update(invList, false);
            }
        }
    }

    /********************************************************************************************** 
    * @Description  : Attach Receipt to Payment Milestone
    * @Return       : void
    * @Author       : Rohit Sharma
    **********************************************************************************************/
        
    public void attachReceiptToMilestone(){
        Set<Id> receitIdSet = new Set<Id>();
        Map< Id, Map< String, Id >> mapOppIdToMapInstallmentToMilestoneId = new Map< Id, Map< String, Id >>();
        Set<Id> oppIdSet = new Set<Id>();
        for(Receipt__c rec :recordNewList){
            if(rec.Opportunity__c != null && rec.Received_For__c != null && rec.Received_For__c != 'DLD_FEE'){
                oppIdSet.add(rec.Opportunity__c);
                receitIdSet.add(rec.Id);
            } 
        }
        if(!oppIdSet.isEmpty()){
            for(Payment_Milestone__c milestone : [SELECT Id,Installment__c,Opportunity__c FROM Payment_Milestone__c WHERE Opportunity__c IN: oppIdSet AND Installment__c != null]){
                if ( !mapOppIdToMapInstallmentToMilestoneId.containsKey(milestone.Opportunity__c )) {
                    mapOppIdToMapInstallmentToMilestoneId.put(milestone.Opportunity__c , new Map< String, Id >{milestone.Installment__c => milestone.Id});
                } else {
                    Map< String, Id >  tempMap = mapOppIdToMapInstallmentToMilestoneId.get(milestone.Opportunity__c);
                    tempMap.put(milestone.Installment__c, milestone.Id);
                    mapOppIdToMapInstallmentToMilestoneId.put(milestone.Opportunity__c , tempMap );
                }    
            }
            if(!mapOppIdToMapInstallmentToMilestoneId.isEmpty()){
                List<Receipt__c> lstReceiptToUpdate = new List<Receipt__c>();
                for( Id recId : receitIdSet){
                    for( String installment : mapOppIdToMapInstallmentToMilestoneId.get( recordNewMap.get(recId).Opportunity__c).keySet()){
                        String receivedFor = recordNewMap.get(recId).Received_For__c;
                        if(receivedFor == 'Token Amount'){
                            receivedFor = 'Deposit';
                        }//Added by ashams to match down payment receipt with down payment milestone
                        if(receivedFor == 'Deposit'){
                            receivedFor = 'ADV';
                        }
                        if(installment == receivedFor){
                            Receipt__c receipt = new Receipt__c();
                            receipt.Id = recId;
                            receipt.Payment_Milestone__c = mapOppIdToMapInstallmentToMilestoneId.get( recordNewMap.get(recId).Opportunity__c).get(installment);
                            lstReceiptToUpdate.add( receipt );
                        }
                    }
                }
                if(!lstReceiptToUpdate.isEmpty()){
                    update lstReceiptToUpdate;
                }
            } 
        }
    }

    /********************************************************************************************** 
    * @Description  : Attach Receipt Charges
    * @Return       : void
    * @Author       : Rohit Sharma
    **********************************************************************************************/
        
    public void attachReceiptToCharges(){
        Set<Id> receitIdSet = new Set<Id>();
        Map< Id, Map< String, Id >> mapOppIdToMapChargeTypeToChargeId = new Map< Id, Map< String, Id >>();
        Set<Id> oppIdSet = new Set<Id>();
        for(Receipt__c rec :recordNewList){
            if(rec.Opportunity__c != null && rec.Received_For__c != null && rec.Received_For__c == 'DLD_FEE'){
                oppIdSet.add(rec.Opportunity__c);
                receitIdSet.add(rec.Id);
            } 
        }
        if(!oppIdSet.isEmpty()){
            for(Opportunity_Charges__c oppCharge : [SELECT Id,Charge_Type__c,Opportunity__c FROM Opportunity_Charges__c WHERE Opportunity__c IN: oppIdSet AND Charge_Type__c = 'DLD_FEE']){
                if ( !mapOppIdToMapChargeTypeToChargeId.containsKey(oppCharge.Opportunity__c )) {
                    mapOppIdToMapChargeTypeToChargeId.put(oppCharge.Opportunity__c , new Map< String, Id >{oppCharge.Charge_Type__c => oppCharge.Id});
                } else {
                    Map< String, Id >  tempMap = mapOppIdToMapChargeTypeToChargeId.get(oppCharge.Opportunity__c);
                    tempMap.put(oppCharge.Charge_Type__c, oppCharge.Id);
                    mapOppIdToMapChargeTypeToChargeId.put(oppCharge.Opportunity__c , tempMap );
                }    
            }
            List<Receipt__c> lstReceiptToUpdate = new List<Receipt__c>();
            for( Id recId : receitIdSet){
                for( String chargeType : mapOppIdToMapChargeTypeToChargeId.get( recordNewMap.get(recId).Opportunity__c).keySet()){
                    if(chargeType == recordNewMap.get(recId).Received_For__c){
                        Receipt__c receipt = new Receipt__c();
                        receipt.Id = recId;
                        receipt.Additional_Charges__c = mapOppIdToMapChargeTypeToChargeId.get( recordNewMap.get(recId).Opportunity__c).get(chargeType);
                        lstReceiptToUpdate.add( receipt );
                    }
                }
            }
            if(!lstReceiptToUpdate.isEmpty()){
                update lstReceiptToUpdate;
            }
        }
    }
    
    /********************************************************************************************** 
    * @Description  : Attach Receipt to Invoice
    * @Return       : void
    * @Author       : Rohit Sharma
    **********************************************************************************************/
        
    public void attachReceiptToInvoice(){
        Set<Id> receitIdSet = new Set<Id>();
        Map< Id, Map< String, Id >> mapOppIdToMapReceivedForInvoiceId = new Map< Id, Map< String, Id >>();
        Set<Id> oppIdSet = new Set<Id>();
        for(Receipt__c rec :recordNewList){
            if(rec.Opportunity__c != null && rec.Received_For__c != null && rec.Invoice__c == null){
                oppIdSet.add(rec.Opportunity__c);
                receitIdSet.add(rec.Id);
            } 
        }
        if(!oppIdSet.isEmpty()){
            for(Invoice__c inv : [SELECT Id,Received_For__c,Opportunity__c FROM Invoice__c WHERE Opportunity__c IN: oppIdSet AND Received_For__c != null]){
                if ( !mapOppIdToMapReceivedForInvoiceId.containsKey(inv.Opportunity__c )) {
                    mapOppIdToMapReceivedForInvoiceId.put(inv.Opportunity__c , new Map< String, Id >{inv.Received_For__c => inv.Id});
                } else {
                    Map< String, Id >  tempMap = mapOppIdToMapReceivedForInvoiceId.get(inv.Opportunity__c);
                    tempMap.put(inv.Received_For__c, inv.Id);
                    mapOppIdToMapReceivedForInvoiceId.put(inv.Opportunity__c , tempMap );
                }    
            }
            if(!mapOppIdToMapReceivedForInvoiceId.isEmpty()){
                List<Receipt__c> lstReceiptToUpdate = new List<Receipt__c>();
                for( Id recId : receitIdSet){
                    for( String invReceivedFor : mapOppIdToMapReceivedForInvoiceId.get( recordNewMap.get(recId).Opportunity__c).keySet()){
                        if(invReceivedFor == recordNewMap.get(recId).Received_For__c){
                            Receipt__c receipt = new Receipt__c();
                            receipt.Id = recId;
                            receipt.Invoice__c = mapOppIdToMapReceivedForInvoiceId.get( recordNewMap.get(recId).Opportunity__c).get(invReceivedFor);
                            lstReceiptToUpdate.add( receipt );
                        }
                    }
                }
                if(!lstReceiptToUpdate.isEmpty()){
                    update lstReceiptToUpdate;
                }
            }
        }
    }

    /********************************************************************************************** 
    * @Description  : Update Registration Receipt Uploaded Check on Mortgage Registration
    * @Return       : void
    * @Author       : Rohit Sharma
    **********************************************************************************************/
        
    public void mortgageRegistrationReceiptReceived(List<Receipt__c> newList){
        Set<Id> oppIdSet = new Set<Id>();
        for(Receipt__c rec :newList){
            if(rec.Opportunity__c != null && rec.Received_For__c == 'Mortgage Registration' && rec.Payment_Status__c == 'Cleared' && (recordOldMap == null || rec.Payment_Status__c != recordOldMap.get(rec.Id).Payment_Status__c)){
                oppIdSet.add(rec.Opportunity__c);
            } 
        }
        if(!oppIdSet.isEmpty()){
            List<Registration__c> regList = [SELECT Id,Mortgage_Registration_Receipt_Uploaded__c FROM Registration__c WHERE Opportunity__c IN: oppIdSet AND Agreement__c != null];
            for(Registration__c reg : regList){
                reg.Mortgage_Registration_Receipt_Uploaded__c = true;
            }
            if(!regList.isEmpty()){
                update regList;
            }
        }
    }
    /********************************************************************************************** 
    * @Description  : Update Registration manager's cheque is cleared on Mortgage Registration
    * @Return       : void
    * @Author       : Rohit Sharma
    **********************************************************************************************/
        
    public void mortgageManagersChequeCleared(List<Receipt__c> newList){
        Set<Id> oppIdSet = new Set<Id>();
        for(Receipt__c rec :newList){
            if(rec.Opportunity__c != null && rec.Received_For__c == 'Managers Cheque' && rec.Payment_Status__c == 'Cleared' && (recordOldMap == null || rec.Payment_Status__c != recordOldMap.get(rec.Id).Payment_Status__c)){
                oppIdSet.add(rec.Opportunity__c);
            } 
        }
        if(!oppIdSet.isEmpty()){
            List<Registration__c> regList = [SELECT Id,Manager_Cheque_Uploaded__c FROM Registration__c WHERE Opportunity__c IN: oppIdSet AND Agreement__c != null];
            for(Registration__c reg : regList){
                reg.Manager_Cheque_Uploaded__c = true;
            }
            if(!regList.isEmpty()){
                update regList;
            }
        }
    }
    
  //Added the below field- for Lease Renewal- Hitesh
    public static map<Id,List<Payment_Milestone__c>> mapOppIdToPM= new map<Id,List<Payment_Milestone__c>>();
    public static set<Id> setPMId=new set<Id>();
    public static Map<Id,Id> mapPMidToOppId=new  Map<Id,Id>();
    //Methhod - Lease Renewal to check if all the receipts created,Ifyes then create contract.- Hitesh
    public static void checkReceiptCreated(List<Receipt__c> newReceiptLst,Map<Id,Receipt__c> oldReceipt){
       
        Set<Id> setOppIdPayModOther=new Set<Id>();
        List<Payment_Milestone__c> listOppCompletePMChq=new List<Payment_Milestone__c>();
        Set<Id> setOppIdContrGen=new set<Id>();
        Set<Id> tempOppIdSet;
        List<Receipt_Milestone__c> listRecieptMS=new List<Receipt_Milestone__c>();
        Set<Id> setReceiptid=new  Set<Id>();
        
        Map<Id,Id> mapRecptIdToRecptMSId=new Map<Id,Id>();
        Map<Id,Id> mapPMIdToReceiptMSId=new Map<Id,Id>();
        List<Receipt__c> listReceipt=new List<Receipt__c>();
        Map<Id,Receipt__c> mapPaidReceipt =new Map<Id,Receipt__c>();
        Map<Id,Receipt__c> mapOppIdToUnpaidReceipt =new Map<Id,Receipt__c>();
        List<Lease_Contract__c> contractList=new List<Lease_Contract__c>();
        List<Opportunity> listOpp=new List<Opportunity>();
        Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Lease_Renewal').getRecordTypeId();
        Id oppCommRcdTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Commercial_Lease_Renewal').getRecordTypeId();
        Map<id,Opportunity_Charges__c> mapOppIdToOCReceiptCrt=new Map<id,Opportunity_Charges__c>();
        Map<id,Opportunity_Charges__c> mapOppIdToOCReceiptNoCrt=new Map<id,Opportunity_Charges__c>();
        set<Id> OppChargesReceiptCrtSet= new set<Id>();
        
        List<Opportunity> listOppRenewalLease=new List<Opportunity>();
        Set<Id> setOppIdRenewalLease=new Set<Id>();
        Map<Id,Opportunity> mapOpp =new Map<Id,Opportunity>();
        
        for(Receipt__c pm:newReceiptLst){
            system.debug('Payment Mode>>>'+ pm.Payment_Status__c);
            
            if(pm.Payment_Status__c !=oldReceipt.get(pm.Id).Payment_Status__c && pm.Payment_Status__c=='Paid' /*&& pm.Opportunity_Record_Type__c=='Lease_Renewal' && pm.Payment_Mode__c !='Cheque'*/){
                system.debug('Reciept checkbox updated Inside Payment Mode Other');
                setOppIdPayModOther.add(pm.Opportunity__c);
            }
        }
        
        listOppRenewalLease=[Select id,AccountId, Lease_Start_Date__c, Lease_End_Date__c,stageName,RecordTypeId from Opportunity where id in: setOppIdPayModOther and( RecordTypeId =:oppRecordTypeId or RecordTypeId =:oppCommRcdTypeId)];
        
        if(!listOppRenewalLease.isEmpty()){
            for(Opportunity o:listOppRenewalLease){
                //if(o.RecordTypeId==oppRecordTypeId || o.RecordTypeId==oppCommRcdTypeId){
                   setOppIdRenewalLease.add(o.id);
                mapOpp.put(o.id,o); 
               // }                
            }
            tempOppIdSet= new Set<Id>();
            getMapOppIdToPMList(setOppIdRenewalLease);
            system.debug('mapOppIdToPM'+mapOppIdToPM);
            system.debug('setPMId'+setPMId);
            
            if(!setPMId.isEmpty()){
                
                listRecieptMS=[select Id, Name, Receipt__c, Additional_Charges__c, Installments__c from Receipt_Milestone__c where Installments__c in:setPMId /*OR Additional_Charges__c in:OppChargesReceiptCrtSet*/];
                system.debug('listRecieptMS>>>>>'+listRecieptMS);
                if(!listRecieptMS.isEmpty()){
                    for(Receipt_Milestone__c rms:listRecieptMS){
                        setReceiptid.add(rms.Receipt__c);
                        mapRecptIdToRecptMSId.put(rms.Receipt__c,rms.Id);
                        
                    }
                    system.debug('setReceiptid Size>>>>'+setReceiptid);
                    
                    if(!setReceiptid.isEmpty()){
                        listReceipt=[select id,Payment_Status__c,Opportunity__c,Payment_Mode__c  from Receipt__c where id in:setReceiptid];
                        system.debug('listReceipt Size>>>>'+listReceipt);
                        for(Receipt__c r:listReceipt){
                            if(r.Payment_Status__c=='Paid' && mapOpp.containsKey(r.Opportunity__c) && mapOpp.get(r.Opportunity__c).stageName == 'In Progress'){
                                mapPaidReceipt.put(r.id,r);
                                setOppIdContrGen.add(r.Opportunity__c);                                    
                            }
                            else if(r.Payment_Status__c!='Paid' /*&& r.Payment_Mode__c == 'Cash'*/){
                                
                                mapOppIdToUnpaidReceipt.put(r.Opportunity__c,r);
                            }
                            
                            
                        }
                        for(Id o:setOppIdContrGen){
                            if(mapOppIdToUnpaidReceipt.containskey(o)){
                                setOppIdContrGen.remove(o);
                            }
                        }
                        system.debug('mapPaidReceipt Size>>>>'+setOppIdContrGen);
                        
                    }
                    
                }
            }
            
        }
        if(!setOppIdContrGen.isEmpty()){
            List<Opportunity> listOppContract=[select id,opportunity__c,AccountId,Lease_Start_Date__c,Lease_End_Date__c,Leasing_Type__c,Account_Email__c,(select id,Renewal_new_unit__c, Unit__r.Unit_Status__c,Unit__c from Unit_Plans__r) from Opportunity where id in:setOppIdContrGen];
            Id contRecordTypeId = Schema.SObjectType.Lease_Contract__c.getRecordTypeInfosByDeveloperName().get('Renewal_Contract').getRecordTypeId();
            set<Id> setOldOppId=new Set<Id>();
            Map<Id,Lease_Contract__c> mapOldOppIdToOldContract=new Map<Id,Lease_Contract__c>();
            
            List<unit_Plan__c> lstUnitPlan=new  List<unit_Plan__c>();
            List<unit__c> lstUnitUpdate=new  List<unit__c>();
            system.debug('@@@inserting contract@@@');
             for(Opportunity o:listOppContract){
                setOldOppId.add(o.Opportunity__c);
                 for(unit_plan__c up:o.Unit_Plans__r){
                     if(up.Renewal_new_unit__c==true){
                         lstUnitPlan.add(up);
                     }
                     
                 }
                 
            }
            //code added for the new Unit status update to Booked
            //for(unit_plan)
            List<Lease_Contract__c> listOldContract=[select id,Contract_Number__c,Opportunity__c from Lease_Contract__c where Opportunity__c in:setOldOppId];
            for(Lease_Contract__c lc:listOldContract){
                mapOldOppIdToOldContract.put(lc.Opportunity__c,lc);
            }
            for(Opportunity deal:listOppContract){
                system.debug('');
                Opportunity opp=new Opportunity();
                opp.Id=deal.id;
                opp.StageName='Contract Generation';
                listOpp.add(opp);
                //deal.StageName='Contract Generation';
                Lease_Contract__c contract = new Lease_Contract__c();
                contract.Account__c = deal.AccountId;
                contract.Opportunity__c = deal.Id;
                contract.Contract_Start__c = deal.Lease_Start_Date__c;
                contract.Contract_End__c =  deal.Lease_End_Date__c;
                contract.Contract_Stages__c = 'Draft';
                contract.LeasingType__c =  deal.Leasing_Type__c;
                contract.Account_Email__c = deal.Account_Email__c;
                contract.Trigger_Renew_Ejari_Contract__c=true;//added for Ejari Contract call
                contract.RecordTypeId= contRecordTypeId;
                 if(mapOldOppIdToOldContract.containsKey(deal.Opportunity__c)==true){
                   contract.Contract_Number__c= mapOldOppIdToOldContract.get(deal.Opportunity__c).Contract_Number__c;
                }
                
                contractList.add(contract);
            }
            try{
                insert contractList;
                update listOpp;
                if(!lstUnitPlan.isEmpty()){
                    for(Unit_Plan__c up:lstUnitPlan){
                        Unit__c u=new Unit__c();
                        u.id=up.Unit__c;
                        u.Unit_Status__c='Booked';
                        lstUnitUpdate.add(u);
                    }
                    update lstUnitUpdate;
                }
            }
            catch(Exception e){
                System.debug('Error Line number>>>'+e.getLineNumber());
                System.debug('Error Message>>>'+e.getMessage());
            }
            
        }
        
    }
    
   //Method for - Lease Renewal, to set the Opportunity set for which the receipts are created-Hitesh 
    public static Set<Id> getMapOppIdToPMList(Set<Id> setOppId){
        Map<Id,List<Payment_Milestone__c>> mapOppIdToPMList = new Map<Id,List<Payment_Milestone__c>>();
        Map<Id,Id> mapOppIdToPMId = new Map<Id,Id>();
        Set<Id> setOppIdNotReady = new set<Id>();
        List<Payment_Milestone__c> listOppAllPayMstn=new List<Payment_Milestone__c>();
        system.debug('setOppId>>>>>'+setOppId);
        Set<Id> setOppIdRemove=new Set<Id>();
        //Get Complete Payment mileston list for the OpPortunity
        listOppAllPayMstn=[select id,Receipt__c, Is_Reciept_Created__c,Opportunity_Record_Type__c,Opportunity__c,Installment__c from Payment_Milestone__c where Opportunity__c in:setOppId and (Installment__c='01-JGE' OR Installment__c='SEC')];
        system.debug('Payment milestones on opportunity>>>>'+listOppAllPayMstn.size());    
        if(!listOppAllPayMstn.isEmpty()){
            for(Payment_Milestone__c pm:listOppAllPayMstn){
                //Check for any payment milestone receipt is not created
                if(pm.Is_Reciept_Created__c == false ){
                    system.debug('Is_Reciept_Created__c false');
                    if(setOppId.contains(pm.Opportunity__c)){
                        setOppId.remove(pm.Opportunity__c); 
                    }
                    
                    setOppIdRemove.add(pm.Opportunity__c);
                    system.debug('setOppIdRemove>>>>'+setOppIdRemove);
                }
                //check if receipt is created and oppSet contains the oppId 
                if(pm.Is_Reciept_Created__c == true && setOppId.contains(pm.Opportunity__c) && setOppIdRemove.contains(pm.Opportunity__c)==false){
                    if(setOppIdRemove.contains(pm.Opportunity__c)){
                        setOppIdRemove.remove(pm.Opportunity__c);
                    }
                    system.debug('Is_Reciept_Created__c true');
                    system.debug('If check >>');
                    if(mapOppIdToPMlist.containsKey(pm.Opportunity__c)){
                        List<Payment_Milestone__c> tempPMlist= new List<Payment_Milestone__c>();
                        tempPMlist=mapOppIdToPMlist.get(pm.Opportunity__c);
                        tempPMlist.add(pm);
                    }
                    else{
                        system.debug('Inside else');
                        List<Payment_Milestone__c> tempPMlist= new List<Payment_Milestone__c>();
                        tempPMlist.add(pm);
                        mapOppIdToPMlist.put(pm.Opportunity__c,tempPMlist);
                    }
                    setPMId.add(pm.id);  
                    mapPMidToOppId.put(pm.Id,pm.Opportunity__c);
                    mapOppIdToPMId.put(pm.Opportunity__c,pm.Id);
                }
                
                system.debug('mapOppIdToPMId >>>'+mapOppIdToPMId);
                system.debug('removeset contains>>>'+setOppIdRemove.contains(pm.Opportunity__c));
                if(setOppIdRemove.contains(pm.Opportunity__c) ){
                    system.debug('Inside remove');
                    setPMId.remove(mapOppIdToPMId.get(pm.Opportunity__c));
                    
                }
                
                
            }
            for(Id i:setPMId){
                system.debug('Inside final remove3');
                if(setOppIdRemove.contains(mapPMidToOppId.get(i))){
                    system.debug('Inside final remove2');
                    setPMId.remove(i);
                }
            }
            
        }
        return setOppId;
    }

    /**********************************************************************************************
* @Description  : Send Email to customer on receipt cleared
* @Params       : List< Receipt__c > newList
* @Param        : Map< Id, Receipt__c > oldMap
* @Return       : void
* @Author       : Mamta Gupta
**********************************************************************************************/
    public  void sendReceiptClearedMailtoCustomer(){
    Set<ID> rcs = new Set<ID>();    
        for(Receipt__c rc :recordNewList){
            if(rc.Account__c!=null && rc.Payment_Status__c =='Cleared' && recordOldMap.get(rc.Id).Payment_Status__c!='Cleared'){
                rcs.add(rc.ID);
            }
        }
        
        OrgWideEmailAddress orgWideEmailAddress = new OrgWideEmailAddress();
        orgWideEmailAddress = [select id, Address, DisplayName from OrgWideEmailAddress Where DisplayName=:system.label.Org_Wide_Default_Address LIMIT 1 ];
        EmailTemplate temp =[select id from EmailTemplate WHERE developername='Receipt_cleared_collections'];
        List<Receipt__c> receipts =[select id, Account__r.Primary_Email__C from Receipt__c WHERE ID IN:rcs];
        List<Messaging.SingleEmailMessage> messageList = new List<Messaging.SingleEmailMessage>();
        for(Receipt__c rc : receipts ){
            Messaging.SingleEmailMessage rmail = Messaging.renderStoredEmailTemplate(temp.ID, null, rc.ID);
            Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
            emailToSend.setToAddresses(new List<String>{rc.Account__r.Primary_Email__C});
            emailToSend.setHTMLBody(rmail.getHTMLBody());
            emailToSend.setSubject(rmail.getSubject());
            emailToSend.setWhatID(rc.ID);
           
            emailToSend.setSaveAsActivity(true);
            if(orgWideEmailAddress!=null){
                emailToSend.setOrgWideEmailAddressId(orgWideEmailAddress.Id);
                messageList.add(emailToSend);
                try{
                   Messaging.sendEmail(messageList);
                }
                catch(Exception ex ){
                    system.debug('error is '+ ex.getMessage() + ' at '+ ex.getLineNumber());
                   
                }        
            }   
        }     
    }   
}