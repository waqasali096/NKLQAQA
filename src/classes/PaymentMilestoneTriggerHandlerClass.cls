/*********************************
* Purpose :- To modify installments and due date if modified by user
* Created By :- Jaskiran
* Date :- 26/01/2022
* Version : v1
* 
* ********************************/
public class PaymentMilestoneTriggerHandlerClass {
    public static boolean avoidrecussion = false;
    List<Payment_Milestone__c> recordNewList = new List<Payment_Milestone__c>();
    List<Payment_Milestone__c> recordOldList = new List<Payment_Milestone__c>();
    Map<Id, Payment_Milestone__c> recordNewMap = new Map<Id, Payment_Milestone__c>();
    Map<Id, Payment_Milestone__c> recordOldMap = new Map<Id, Payment_Milestone__c>();
    Boolean isInsert, isUpdate, isDelete, isUndelete, isBefore, isAfter = false;
    public static boolean recursionController = false;
    public PaymentMilestoneTriggerHandlerClass(List<Payment_Milestone__c> newList, List<Payment_Milestone__c> oldList, Map<Id, Payment_Milestone__c> newMap, Map<Id, Payment_Milestone__c> oldMap, boolean isInsert, boolean isUpdate, Boolean isDelete, Boolean isUndelete,Boolean isBefore,Boolean isAfter) {
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
        attachMilestonetoAgreement(recordNewList);
        setBillingConfig(recordNewList, recordOldMap);
        paymentStatusUpdate(recordNewList);
    }
    public void BeforeUpdateEvent() {
        paymentStatusUpdate(recordNewList);
    }
    public void BeforeDeleteEvent() {
    }
    public void AfterInsertEvent() {
        calculateSellingPriceWithVAT(recordNewList);
    }
    public void AfterUpdateEvent() {
        sendBillingLinesToERP(recordNewList, recordOldMap);
        checkReceiptCreated(recordNewList, recordOldMap);
        calculateSellingPriceWithVAT(recordNewList);
        updateCallingListLineItems(recordNewList); //Added By Jayesh, Dated 20 April, Desc : Update Calling List Line Items to Paid.
    }
    public void AfterDeleteEvent() {
        calculateSellingPriceWithVAT(recordOldList); 
    }
    public void AfterUndeleteEvent() {
        calculateSellingPriceWithVAT(recordNewList);
    }
    
    public static void updateInstallments(Map<Id,Payment_Milestone__c> oldpaymentMap,List<Payment_Milestone__c> newpaymentLst){
        if(avoidrecussion==false){
            Map<String,Payment_Milestone__c> mapofOpptyMilestone = new Map<String,Payment_Milestone__c>();
            Map<String,Payment_Milestone__c> mapofOldMilestone = new Map<String,Payment_Milestone__c>();
            Set<String> paymentMilestoneIDs = new Set<String>();
            for(Payment_Milestone__c pm : newpaymentLst){
                system.debug('oldpaymentMap.get(pm.Id).Amount__c'+oldpaymentMap.get(pm.Id).Amount__c );
                if(oldpaymentMap.get(pm.Id).Amount__c  != pm.Amount__c){
                    mapofOpptyMilestone.put(pm.Opportunity__c,pm);
                    mapofOldMilestone.put(pm.Opportunity__c,oldpaymentMap.get(pm.Id));
                    paymentMilestoneIDs.add(pm.Id);
                }
            }
            system.debug('mapofOpptyMilestone'+mapofOpptyMilestone);
            Map<String,Double> mapOfRemainingAmount = new Map<String,Double>();
            for(Payment_Milestone__c pm : [Select ID,Amount__c,Opportunity__c,Opportunity__r.Final_Lease_Amount__c FROM Payment_Milestone__c where Opportunity__c IN: mapofOpptyMilestone.Keyset() and ID IN: paymentMilestoneIDs]){
                system.debug('pm'+pm.Opportunity__r.Final_Lease_Amount__c);
                Double remainingAmount = Double.valueOf(double.valueOf(pm.Opportunity__r.Final_Lease_Amount__c) - Double.valueOf(mapofOpptyMilestone.get(pm.Opportunity__c).Amount__c));
                system.debug('remainingAmount'+remainingAmount);
                mapOfRemainingAmount.put(pm.Opportunity__c,remainingAmount);
                
            }
            Map<String,List<Payment_Milestone__c>> mapOfOpptypayment = new Map<String,List<Payment_Milestone__c>>();
            Map<String,Integer> mapOfPaymentSize = new Map<String,Integer>();       
            for(Payment_Milestone__c pm : [Select ID,Amount__c,Opportunity__c,Opportunity__r.Final_Lease_Amount__c FROM Payment_Milestone__c where Opportunity__c IN: mapofOpptyMilestone.Keyset() and ID NOT IN: paymentMilestoneIDs]){
                if(mapOfOpptypayment.containsKey(pm.Opportunity__c)){
                    mapOfOpptypayment.get(pm.Opportunity__c).add(pm);
                } else {
                    mapOfOpptypayment.put(pm.Opportunity__c,new List<Payment_Milestone__c> {pm});
                }
            }
            for(String opty : mapOfOpptypayment.keyset()){
                mapOfPaymentSize.put(opty,mapOfOpptypayment.get(opty).size()); 
                system.debug('mapOfPaymentSize'+mapOfPaymentSize);
            }
            List<Payment_Milestone__c> updatePaymentList = new List<Payment_Milestone__c>();
            for(Payment_Milestone__c pm : [Select ID,Amount__c,Opportunity__c,Opportunity__r.Final_Lease_Amount__c FROM Payment_Milestone__c where Opportunity__c IN: mapofOpptyMilestone.Keyset() and ID NOT IN: paymentMilestoneIDs]){
                Payment_Milestone__c pm1 = new Payment_Milestone__c();
                pm1.Id = pm.Id;
                pm1.Amount__c  = Double.valueOf(mapOfRemainingAmount.get(pm.Opportunity__c)/mapOfPaymentSize.get(pm.Opportunity__c));
                system.debug('pm1'+pm1);
                updatePaymentList.add(pm1);
            }
            if(updatePaymentList.size() > 0){
                avoidrecussion = true;
                update updatePaymentList;
            }
        }
        
        sendBillingLinesToERP(newpaymentLst,oldpaymentMap);
    }
    
    public static void attachMilestonetoAgreement(List<Payment_Milestone__c> newpaymentLst){
        Set<Id> setOppId = new Set<Id>();
        Map<Id, Id> mapOppAgreementId = new Map<Id, Id>();
        
        for(Payment_Milestone__c PM: newpaymentLst){
            setOppId.add(PM.Opportunity__c);
        }
        
        for(Agreement__c ag: [Select Id, Opportunity__c from Agreement__c where Opportunity__c IN: setOppId])
        {
            mapOppAgreementId.put(ag.Opportunity__c, ag.Id);
        }
        
        if(!mapOppAgreementId.isEmpty()){
            for(Payment_Milestone__c PM: newpaymentLst){
                PM.Agreement__c = mapOppAgreementId.get(PM.Opportunity__c);   
            }  
        }
    }
    
    // Set Billing Configuration Lookup in Milestone
    public static void setBillingConfig(List<Payment_Milestone__c> newpaymentLst,Map<Id,Payment_Milestone__c> oldPayMileStone) {
        Map<String,List<Payment_Milestone__c>> instBUMileStone = new Map<String,List<Payment_Milestone__c>>();
        Set<String> installmentSet = new Set<String>();
        Set<String> businessUnitSet = new Set<String>();
        
        for(Payment_Milestone__c payMileSt : newpaymentLst) {
            if(String.isNotBlank(payMileSt.Installment__c) && String.isNotBlank(payMileSt.Business_Unit_Id__c) && 
               (payMileSt.Opportunity_Record_Type__c == 'Deal_Unit_Sold' || payMileSt.Opportunity_Record_Type__c == 'Deal_Read_Only' || payMileSt.Opportunity_Record_Type__c == 'Sales_Opportunity')) {
                   List<Payment_Milestone__c> paMiles = instBUMileStone.get(payMileSt.Installment__c + payMileSt.Business_Unit_Id__c);
                   if(paMiles == null) {
                       instBUMileStone.put(payMileSt.Installment__c + payMileSt.Business_Unit_Id__c, new List<Payment_Milestone__c>());
                   }
                   instBUMileStone.get(payMileSt.Installment__c + payMileSt.Business_Unit_Id__c).add(payMileSt);
                   installmentSet.add(payMileSt.Installment__c);
                   businessUnitSet.add(payMileSt.Business_Unit_Id__c);
               }
        }
        
        if(!instBUMileStone.isEmpty()) {
            for(Billing_Configuration__c billConf : [Select Id,Payment_Term_Type_Code__c,Business_Unit__c FROM Billing_Configuration__c WHERE Payment_Term_Type_Code__c In :installmentSet AND Business_Unit__c In :businessUnitSet AND Payment_Purpose_Code__c = 'SALE']) {
                if(String.isNotBlank(billConf.Payment_Term_Type_Code__c) && String.isNotBlank(billConf.Business_Unit__c)) {
                    String concatPayTermBusUnit = billConf.Payment_Term_Type_Code__c + billConf.Business_Unit__c;
                    if(instBUMileStone.containsKey(concatPayTermBusUnit)) {
                        for(Payment_Milestone__c payMileSt : instBUMileStone.get(concatPayTermBusUnit)) {
                            payMileSt.Billing_Configuration__c = billConf.Id;
                        }
                    }
                }
            }
        }
    }
    
    /*Method: sendBillingLinesToERP
* Desc: Handler Method for API criteria and call
* Param: newpaymentLst - List of New payment Milestones
* Param: oldPayMileStone - Map of Old payment Milestones 
* Return: None
* @Author       : Vishal Agrawal
*/ 
    public static void sendBillingLinesToERP(List<Payment_Milestone__c> newpaymentLst,Map<Id,Payment_Milestone__c> oldPayMileStone) {
        Set<Id> paymentMilestoneId = new Set<Id>();
        for(Payment_Milestone__c pm : newpaymentLst){
            if(pm.Send_Billing_Line_to_ERP__c && pm.ERP_Billing_Line_Id__c == null && (oldPayMileStone == null || pm.Send_Billing_Line_to_ERP__c != oldPayMileStone.get(pm.Id).Send_Billing_Line_to_ERP__c)){
                paymentMilestoneId.add(pm.Id);
            }
        }
        if(!paymentMilestoneId.isEmpty()){
            ERPIntegrationHelper.createBillingLine(paymentMilestoneId);
        }
    }
    public static map<Id,List<Payment_Milestone__c>> mapOppIdToPM= new map<Id,List<Payment_Milestone__c>>();
    public static set<Id> setPMId=new set<Id>();
    public static Map<Id,Id> mapPMidToOppId=new  Map<Id,Id>();
    
    public static void checkReceiptCreated(List<Payment_Milestone__c> newpaymentLst,Map<Id,Payment_Milestone__c> oldPayMileStone){
        Set<Id> setOppIdPayModCheque=new Set<Id>();
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
        List<Lease_Contract__c> contractList=new List<Lease_Contract__c>();
        List<Opportunity> listOpp=new List<Opportunity>();
        
        for(Payment_Milestone__c pm:newpaymentLst){
            system.debug('Payment Mode>>>'+ pm.Payment_Mode__c);
            /*if(pm.Is_Reciept_Created__c !=oldPayMileStone.get(pm.Id).Is_Reciept_Created__c && pm.Is_Reciept_Created__c==True && pm.Opportunity_Record_Type__c=='Lease_Renewal' && pm.Payment_Mode__c=='Cheque'){
system.debug('Reciept checkbox updated Inside Payment Mode cheque');
setOppIdPayModCheque.add(pm.Opportunity__c);
}
else*/ if(pm.Is_Reciept_Created__c !=oldPayMileStone.get(pm.Id).Is_Reciept_Created__c && pm.Is_Reciept_Created__c==True && (pm.Opportunity_Record_Type__c=='Lease_Renewal'|| pm.Opportunity_Record_Type__c=='Commercial_Lease_Renewal') && pm.Payment_Mode__c!='Cheque'){
    system.debug('Reciept checkbox updated Inside Payment Mode Other');
    setOppIdPayModOther.add(pm.Opportunity__c);
}
        }
        
        if(!setOppIdPayModCheque.isEmpty()){
            tempOppIdSet= new Set<Id>();
            tempOppIdSet=getMapOppIdToPMList(setOppIdPayModCheque);
            if(!tempOppIdSet.isEmpty()){
                setOppIdContrGen.addAll(tempOppIdSet);
            }
        }
        if(!setOppIdPayModOther.isEmpty()){
            tempOppIdSet= new Set<Id>();
            getMapOppIdToPMList(setOppIdPayModOther);
            system.debug('mapOppIdToPM'+mapOppIdToPM);
            system.debug('setPMId'+setPMId);
            
            if(/*!mapOppIdToPM.isEmpty() &&*/ !setPMId.isEmpty()){
                listRecieptMS=[select Id, Name, Receipt__c, Additional_Charges__c, Installments__c from Receipt_Milestone__c where Installments__c in:setPMId];
                system.debug('listRecieptMS>>>>>'+listRecieptMS);
                if(!listRecieptMS.isEmpty()){
                    for(Receipt_Milestone__c rms:listRecieptMS){
                        setReceiptid.add(rms.Receipt__c);
                        mapRecptIdToRecptMSId.put(rms.Receipt__c,rms.Id);
                        mapPMIdToReceiptMSId.put(rms.Installments__c,rms.Id);
                    }
                    system.debug('setReceiptid Size>>>>'+setReceiptid);
                    
                    if(!setReceiptid.isEmpty()){
                        listReceipt=[select id,Payment_Status__c from Receipt__c where id in:setReceiptid];
                        system.debug('listReceipt Size>>>>'+listReceipt);
                        for(Receipt__c r:listReceipt){
                            if(r.Payment_Status__c=='Paid'){
                                mapPaidReceipt.put(r.id,r);
                            }
                            
                        }
                        system.debug('mapPaidReceipt Size>>>>'+mapPaidReceipt);
                        if(!mapPaidReceipt.isEmpty()){
                            for(Receipt_Milestone__c e:listRecieptMS){
                                if(mapPaidReceipt.containsKey(e.Receipt__c) && mapPMidToOppId.containsKey(e.Installments__c)){
                                    tempOppIdSet.add(mapPMidToOppId.get(e.Installments__c));
                                }
                            }
                            
                            if(!tempOppIdSet.isEmpty()){
                                setOppIdContrGen.addAll(tempOppIdSet); 
                            }
                        }
                    }
                    
                }
            }
            
        }
        if(!setOppIdContrGen.isEmpty()){
            List<Opportunity> listOppContract=[select id,Opportunity__c,AccountId,Lease_Start_Date__c,Lease_End_Date__c,Leasing_Type__c,Account_Email__c from Opportunity where id in:setOppIdContrGen];
            Id contRecordTypeId = Schema.SObjectType.Lease_Contract__c.getRecordTypeInfosByDeveloperName().get('Renewal_Contract').getRecordTypeId();
            set<Id> setOldOppId=new Set<Id>();
            Map<Id,Lease_Contract__c> mapOldOppIdToOldContract=new Map<Id,Lease_Contract__c>();
            system.debug('@@@inserting contract@@@');
            for(Opportunity o:listOppContract){
                setOldOppId.add(o.Opportunity__c);
            }
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
                contract.RecordTypeId= contRecordTypeId;
                if(mapOldOppIdToOldContract.containsKey(deal.Opportunity__c)==true){
                   contract.Contract_Number__c= mapOldOppIdToOldContract.get(deal.Opportunity__c).Contract_Number__c;
                }
                contractList.add(contract);
            }
            
            insert contractList;
            update listOpp;
        }
        
    }
    
    public static Set<Id> getMapOppIdToPMList(Set<Id> setOppId){
        Map<Id,List<Payment_Milestone__c>> mapOppIdToPMList = new Map<Id,List<Payment_Milestone__c>>();
        Map<Id,Id> mapOppIdToPMId = new Map<Id,Id>();
        Set<Id> setOppIdNotReady = new set<Id>();
        List<Payment_Milestone__c> listOppAllPayMstn=new List<Payment_Milestone__c>();
        system.debug('setOppId>>>>>'+setOppId);
        Set<Id> setOppIdRemove=new Set<Id>();
        //Get Complete Payment mileston list for the OpPortunity
        listOppAllPayMstn=[select id,Receipt__c, Is_Reciept_Created__c,Opportunity_Record_Type__c,Opportunity__c from Payment_Milestone__c where Opportunity__c in:setOppId];
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
    
    
    /******************************************************************************************************
* @Description        : Function to set Payment Status
* @Params             : List< Payment_Milestone__c > newList                                                                                             
* @Return             : void       
* @Author             : Rohit Sharma                                                                  
*******************************************************************************************************/
    public static void paymentStatusUpdate(List<Payment_Milestone__c> newList){
        for(Payment_Milestone__c pm : newList){
            if(pm.Outstanding_Amount__c == 0){
                pm.Payment_Status__c = 'Paid';
            }else{
                pm.Payment_Status__c = 'Pending';
            }
        }
    }
    
    /******************************************************************************************************
* @Description        : Function to set Selling Priice with VAT on Deal
* @Params             : List< Payment_Milestone__c > newList                                                                                             
* @Return             : void       
* @Author             : Rohit Sharma                                                                  
*******************************************************************************************************/
    
    public void calculateSellingPriceWithVAT(List<Payment_Milestone__c> newList){
        List<Id> oppId = new List<Id>();
        for(Payment_Milestone__c pm :newList){
            if(isAfter && isUpdate){
                if(pm.Total_Amount__c != recordOldMap.get(pm.Id).Total_Amount__c){
                    oppId.add(pm.Opportunity__c);
                }
            }else{
                oppId.add(pm.Opportunity__c);
            }
            
        }
        if(!oppId.isEmpty()){
            List<Opportunity> oppList = new List<Opportunity>();
            if(oppId.size() > 0){
                 // added condition for null check - swapnil 25/05/2022
                for(AggregateResult ag : [SELECT Opportunity__c ,SUM(Total_Amount__c)amt FROM Payment_Milestone__c WHERE Opportunity__c IN: oppId and Opportunity__r.Leasing_type__c =null group by Opportunity__c]){
                    
                    Opportunity opp = new Opportunity();
                    opp.Selling_Price_with_VAT__c = (Decimal)ag.get('amt');
                    opp.Id = (Id)ag.get('Opportunity__c');
                    
                    oppList.add(opp);
                    
                }
                if(!oppList.isEmpty()){
                    Database.update(oppList, false);
                }
            }
        }
    }
    
    /*********************************
* Purpose :- To Automate the functionlity Related to Calling List Line Item Object for collections.
* Created By :- Jayesh
* Date :- 20/04/2022
* Version : v1
* 
* ********************************/
    public void updateCallingListLineItems(List<Payment_Milestone__c> newList){
        try{
            Set<Id> paidPMIds = new Set<Id>();
            for(Payment_Milestone__c pm : newList){
                if(pm.Payment_Status__c != recordOldMap.get(pm.Id).Payment_Status__c && pm.Payment_Status__c == 'Paid'){
                    paidPMIds.add(pm.Id);
                }
               
            }
            
            if(paidPMIds.size()>0 && paidPMIds != null){
                List<Calling_List_Line_Item__c> cliList = [SELECT Id,Outstanding_Amount__c,Paid_Amount__c,Payment_Milestone__r.Outstanding_Amount__c,
                                                           Payment_Milestone__r.Paid_Amount__c,
                                                           Payment_Status__c FROM Calling_List_Line_Item__c 
                                                           WHERE Payment_Milestone__c IN: paidPMIds];
                if(cliList.size() > 0 && !cliList.isEmpty()){
                    for(Calling_List_Line_Item__c cli : cliList){
                        cli.Payment_Status__c = 'Paid';
                        cli.Outstanding_Amount__c = cli.Payment_Milestone__r.Outstanding_Amount__c;
                        cli.Paid_Amount__c =  cli.Payment_Milestone__r.Paid_Amount__c;
                        
                    }
                }
                
                Database.update(cliList, false);
            }
            
        }catch(Exception e){
            System.debug('Exception Occured : '+ e.getCause());
        }
        
        
    }
}