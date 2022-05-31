/**************************************************************************************************
* Name               : AddReceipts_onSRCtrl                                                      
* Description        : Add receipts on "Sales Cancellation SRs"
* Created Date       : 02/03/2022                                                                 
* Created By         : Cloudworks                                                                    
* -------------------------------------------------------------------------------------------------
* VERSION  AUTHOR    DATE            COMMENTS                                                    
* 1.0      Mamta      02/03/2022      Initial Draft.                                               
**************************************************************************************************/
public class AddReceipts_onSRCtrl {
    
    @AuraEnabled
    public static AddReceiptsLstWrapper getAllReceiptsonOpp(String recID){
        AddReceiptsLstWrapper wrpper = new AddReceiptsLstWrapper();
        
        Case cs =[select id, Deal__c , Total_Forfeit_Amount__c ,Total_Recoverable_Amount__c ,Total_Refund_Amount__c ,
                  Total_Reversal_Amount__c   from Case where ID=:recID LIMIT 1 ]  ; 
        List<Recoverables__c> recList = [Select Id, Name,Name__c, Amount__c from Recoverables__c WHERE Service_Request__C=:recID];
        
        system.debug('recList is '+ recList);
        
        List<SRReceiptsWrpprCls>  rcptsLst = new List<SRReceiptsWrpprCls> ();
        List<Receipt__c> receipts =[select id, name,Receipt_Number__c ,Status__c , Amount__c,
                                    toLabel(Received_For__c) ,CurrencyIsoCode from Receipt__c WHERE Opportunity__C=:cs.Deal__c];
        
        system.debug('size is '+ receipts.size());
        
        List<Service_Request_Receipt__c> existing_SRRecipts =[select id,Receipt__c,Forfeit_Type__c,Receipt_Action_Type__c,Refund_Amount__c,Forfeit_Amount__c,
                                                              Reversal_Amount__c,Receipt_Name__c,Receipt_Status1__c,Recoverable_Amount__c,Receipt_Number__c,
                                                              Received_For__c,Receipt_Amount1__c,CurrencyIsoCode,Recoverables__c,Receipt_Date__c,Payment_Mode__c,
                                                              Receipt_Status__c,Receipt__r.Opportunity__c,Service_Request__r.Unit__c,
                                                              Service_Request__r.Deal__c from Service_Request_Receipt__c WHERE Service_Request__c=:recID];
        
        Map<ID, Service_Request_Receipt__c> recptID_SRReciptMap = new Map<ID, Service_Request_Receipt__c>();//Map of receipt ID and Service Req Receipt Record
        
        for(Service_Request_Receipt__c rc: existing_SRRecipts){
            recptID_SRReciptMap.put(rc.Receipt__c , rc);
        }
        
        List<Service_Request_Receipt__c> SR_Receipts = new  List<Service_Request_Receipt__c>();
        Decimal totalReceiptAmt =0.000;
        for(Receipt__c rc : receipts){ 
            if(rc.Amount__c!=null){ totalReceiptAmt+= rc.Amount__c;}
            SRReceiptsWrpprCls wrp = new SRReceiptsWrpprCls();
            
            if(recptID_SRReciptMap.containsKey(rc.ID) && recptID_SRReciptMap.get(rc.ID) != null){ //Added null check 25 Apr 2022
                wrp.SR_Receipt = recptID_SRReciptMap.get(rc.ID);
                wrp.isChecked = true;
            }
            else{
                
                Service_Request_Receipt__c  src = new Service_Request_Receipt__c();
                src.Service_Request__c = recID;
                src.Receipt__c = rc.ID;
                src.Forfeit_Type__c= '';
                src.Receipt_Action_Type__c='';
                src.Refund_Amount__c =NULL;
                src.Forfeit_Amount__c=NULL;
                src.Reversal_Amount__c =NULL;
                src.Receipt_Name__c = rc.name;
                src.Receipt_Status1__c =  rc.Status__c;
                src.Recoverable_Amount__c =NULL;
                //src.Receipt_Number__c = rc.Receipt_Number__c;
                //src.Received_For__c = (rc.Received_For__c) ;
                src.Receipt_Amount1__c  = rc.Amount__c;
                src.CurrencyIsoCode = rc.CurrencyIsoCode;
                //src.Recoverables__c = null;
                SR_Receipts.add(src); 
                wrp.SR_Receipt = src;
                wrp.isChecked = false;
            }
            
            rcptsLst.add(wrp);
            system.debug('rcptsLst  is '+ rcptsLst);
            
        }
        
        wrpper.rcpWrppr = rcptsLst;
        wrpper.sRequest =  cs;
        wrpper.receiptActionValues =  getPicklistvalues('Service_Request_Receipt__c' , 'Receipt_Action_Type__c');
        wrpper.forfeitTypeValues =   getPicklistvalues('Service_Request_Receipt__c' , 'Forfeit_Type__c');
        wrpper.totalReceiptAmt = totalReceiptAmt; 
        wrpper.recList =recList;
        return wrpper;
        
        
    }
    
    @AuraEnabled
    public static void saveReceipts(List<Service_Request_Receipt__c> SR_Receipts, ID recID){
        system.debug('SR_Receipts are '+ SR_Receipts);
        System.debug(LoggingLevel.INFO, '===recID=====> '+ recID);
        
        //Getting the existing Record Ids before saveing the list 
        Set<Id> receiptIdSet = new Set<Id>();
        if(SR_Receipts != null && !SR_Receipts.isEmpty()){
            for (Service_Request_Receipt__c srrInstance : SR_Receipts){
                if(srrInstance != null && srrInstance.Id != null){
                	receiptIdSet.add(srrInstance.Id);    
                }    
            }    
        }
        System.debug(LoggingLevel.INFO, '===receiptIdSet=====> '+ JSON.serialize(receiptIdSet));
        
        Case caseData =[Select id,Deal__c,Unit__c,Unit__r.Business_Unit__c,AccountId,Unit__r.Master_payment_plan__r.Credit_Memo_Transaction_Type__c,Unit__r.Master_payment_plan__r.Forfeit_Invoice_Transaction_Type__c from case where Id =:recID];
        Set<Id> serviceRequestReceiptId = new Set<Id>();
        list<Receipt_Refund__c> receiptRefundList = new list<Receipt_Refund__c>();
        List<Invoice__c> invoiceList = new List<Invoice__c>();
        List<Receipt__c> receiptList = new List<Receipt__c>();
        List<Credit_Memo__c> creditMemoList = new List<Credit_Memo__c>();
        List<sObject> recordListToDelete = new List<sObject>();
        List<sObject> recordListToUpdate = new List<sObject>(); 
        
        //Map to check the Action Type previous value before save of list
        Map<Id, Service_Request_Receipt__c> srReceiptsMap = new Map<Id, Service_Request_Receipt__c>();
        for (Service_Request_Receipt__c srrInstance: [SELECT Id, Receipt_Action_Type__c FROM Service_Request_Receipt__c 
                                                   WHERE Id IN :receiptIdSet AND Service_Request__c = :recID]) {
        	srReceiptsMap.put(srrInstance.Id, srrInstance);    
        }
        
        List<Service_Request_Receipt__c> SrReceipts_toDelete = [select Id from Service_Request_Receipt__c WHERE ID NOT IN :receiptIdSet 
                                                                AND Service_Request__c=:recID ];
        try{
             upsert SR_Receipts;
            for(Service_Request_Receipt__c serviceRece : SrReceipts_toDelete){
                serviceRequestReceiptId.add(serviceRece.Id);
            }
            List<Service_Request_Receipt__c> SObject_toDelete =[select Id,(select id from Receipt_Refund__r),(select id from Invoices__r), 
                                                                (SELECT Id FROM Receipts__r),(SELECT Id FROM Credit_Memos__r)
                                                                from Service_Request_Receipt__c Where Id IN: serviceRequestReceiptId];
            
           // List<Receipt_Refund__c> SrReceiptsRefund_toDelete = [select id from Receipt_Refund__c WHERE Service_Request_Receipt__c IN :serviceRequestReceiptId];
            //List<Invoice__c> SrInvoice_toDelete = [select id from Invoice__c WHERE Service_Request_Receipt__c IN:serviceRequestReceiptId];
            //List<Receipt__c> Receipt_toDelete = [select id from Receipt__c Where Service_Request_Receipt__c  IN:serviceRequestReceiptId ];
            
            List<Receipt__c> Receipt_toDelete = new List<Receipt__c>();
            if (SObject_toDelete != null && !SObject_toDelete.isEmpty()) {
                for(Service_Request_Receipt__c srrInstance : SObject_toDelete) {
                    if(srrInstance.Receipts__r != null){
                    	Receipt_toDelete.addAll(srrInstance.Receipts__r);    
                    }    
                }     
            }
            System.debug('SR_Receipts-->'+SR_Receipts);
            //System.debug('SrReceiptsRefund_toDelete-->'+JSON.serialize(SrReceiptsRefund_toDelete));
            System.debug('SR_Receipts-->'+JSON.serialize(SR_Receipts));
            Set<Id> modifiedActionTypeIdSet = new Set<Id>();
            
            Map<Id,Receipt__c> receiptsMap = new Map<Id,Receipt__c>([Select Invoice__c,Amount__c FROM Receipt__c WHERE Opportunity__c = :caseData.Deal__c]);
            for(Service_Request_Receipt__c serviceRece : SR_Receipts){
                //Collecting updated Service request Receipt Ids  as a set
                if(!srReceiptsMap.isEmpty() && srReceiptsMap.containsKey(serviceRece.Id) && 
                   srReceiptsMap.get(serviceRece.Id) != null && 
                   String.isNotBlank(srReceiptsMap.get(serviceRece.Id).Receipt_Action_Type__c) && 
                   srReceiptsMap.get(serviceRece.Id).Receipt_Action_Type__c != serviceRece.Receipt_Action_Type__c) {
                   modifiedActionTypeIdSet.add(serviceRece.Id);   
                }
                System.debug('====modifiedActionTypeIdSet===>'+JSON.serialize(modifiedActionTypeIdSet));
                
               // if(serviceRece.Receipt_Action_Type__c == 'Full Refund' || serviceRece.Receipt_Action_Type__c == 'Partial Refund'){
               if(serviceRece.Refund_Amount__c!=null){
                    Receipt_Refund__c recRefund = new Receipt_Refund__c();  
                    recRefund.Receipt__c = serviceRece.Receipt__c ;
                    recRefund.Unit__c= caseData.Unit__c;
                    recRefund.Opportunity__c= caseData.Deal__c;
                    recRefund.Service_Request__c = recID;
                    recRefund.Service_Request_Receipt__c = serviceRece.Id;
                    recRefund.Unique_Key__c = serviceRece.Id +'-' +recID;
                    recRefund.Refund_Amount__c = serviceRece.Refund_Amount__c;
                    receiptRefundList.add(recRefund);
                    System.debug('receiptRefundList-->'+receiptRefundList);
                    
                    if(receiptsMap.containsKey(serviceRece.Receipt__c) && receiptsMap.get(serviceRece.Receipt__c).Invoice__c != null) {
                        Credit_Memo__c credMemo = new Credit_Memo__c();
                        credMemo.Service_Request__c = recID;
                        credMemo.Service_Request_Receipt__c = serviceRece.Id;
                        credMemo.Unit__c = caseData.Unit__c;
                        credMemo.Business_Unit__c = caseData.Unit__r.Business_Unit__c;
                        credMemo.Account__c = caseData.AccountId;
                        credMemo.Credit_Memo_Date__c = System.Today();
                        credMemo.Invoice_Description__c = serviceRece.Receipt_Action_Type__c != 'Partial' ? serviceRece.Receipt_Action_Type__c : 'Partial Refund';
                        //credMemo.Unique_Key__c = serviceRece.Id +'-' +recID;
                        credMemo.Unique_Key__c = serviceRece.Id +'-' +Integer.valueof((Math.random() * 100));
                        credMemo.Invoice__c = receiptsMap.get(serviceRece.Receipt__c).Invoice__c;
                        if(caseData.Unit__r.Master_payment_plan__r.Credit_Memo_Transaction_Type__c !=null) {
                            credMemo.Transaction_Type__c = caseData.Unit__r.Master_payment_plan__r.Credit_Memo_Transaction_Type__c;
                        }
                        /*if(serviceRece.Receipt_Action_Type__c == 'Full Refund') {
                            credMemo.Amount__c = serviceRece.Refund_Amount__c;
                        } else if(serviceRece.Receipt_Action_Type__c == 'Partial') {
                            credMemo.Amount__c = receiptsMap.get(serviceRece.Receipt__c).Amount__c - serviceRece.Refund_Amount__c;
                        }*/
                        credMemo.Amount__c = serviceRece.Refund_Amount__c;
                        creditMemoList.add(credMemo);
                    }
                    
                }
                //if(serviceRece.Receipt_Action_Type__c == 'Full Forfeit' || serviceRece.Receipt_Action_Type__c == 'Partial Forfeit'){
                if(serviceRece.Forfeit_Amount__c!=null){    
                    Invoice__c inv = new Invoice__c();
                    inv.opportunity__c = caseData.Deal__c;
                    inv.Payment_Date__c = system.today();
                    inv.Amount__c = serviceRece.Forfeit_Amount__c;
                    inv.Service_Request__c = recID;
                    inv.Service_Request_Receipt__c= serviceRece.Id;
                    inv.Unique_Key__c = serviceRece.Id +'-' +recID;
                    inv.Description__c = 'Forefeit';
                    if(caseData.Unit__r.Master_payment_plan__r.Forfeit_Invoice_Transaction_Type__c !=null)
                        	inv.Transaction_Type__c = caseData.Unit__r.Master_payment_plan__r.Forfeit_Invoice_Transaction_Type__c;
                    invoiceList.add(inv);
                    system.debug('invoiceList--->'+invoiceList);
                    
                    if(serviceRece.Receipt_Action_Type__c == 'Full Forfeit' && receiptsMap.containsKey(serviceRece.Receipt__c) && receiptsMap.get(serviceRece.Receipt__c).Invoice__c != null) {
                        Credit_Memo__c credMemo = new Credit_Memo__c();
                        credMemo.Service_Request__c = recID;
                        credMemo.Service_Request_Receipt__c = serviceRece.Id;
                        credMemo.Unit__c = caseData.Unit__c;
                        credMemo.Business_Unit__c = caseData.Unit__r.Business_Unit__c;
                        credMemo.Invoice_Description__c = serviceRece.Receipt_Action_Type__c != 'Partial' ? serviceRece.Receipt_Action_Type__c : 'Partial Refund';
                        credMemo.Account__c = caseData.AccountId;
                        credMemo.Credit_Memo_Date__c = System.Today();
                        //credMemo.Unique_Key__c = serviceRece.Id +'-' +recID;
                        credMemo.Unique_Key__c = serviceRece.Id +'-' +Integer.valueof((Math.random() * 100));
                        credMemo.Invoice__c = receiptsMap.get(serviceRece.Receipt__c).Invoice__c;
                        if(caseData.Unit__r.Master_payment_plan__r.Credit_Memo_Transaction_Type__c !=null) {
                            credMemo.Transaction_Type__c = caseData.Unit__r.Master_payment_plan__r.Credit_Memo_Transaction_Type__c;
                        }
                        /*if(serviceRece.Receipt_Action_Type__c == 'Full Forfeit') {
                            credMemo.Amount__c = serviceRece.Forfeit_Amount__c;
                        } else if(serviceRece.Receipt_Action_Type__c == 'Partial') {
                            credMemo.Amount__c = receiptsMap.get(serviceRece.Receipt__c).Amount__c - serviceRece.Forfeit_Amount__c;
                        }*/
                        credMemo.Amount__c = serviceRece.Forfeit_Amount__c;
                        creditMemoList.add(credMemo);
                    }
                     system.debug('creditMemoList--->'+creditMemoList);                   
                }
                if(serviceRece.Receipt_Action_Type__c == 'Reversal'){
                    Receipt__c receipt = new Receipt__c();
                    receipt.Initiatae_Receipt_Reversal__c = true;
                    receipt.Id =  serviceRece.Receipt__c;
                    receipt.Case__c =recID;
                    receipt.Service_Request_Receipt__c = serviceRece.Id;
                    receipt.Unique_Key__c = serviceRece.Id +'-' +recID;
                   	receiptList.add(receipt);
                    System.debug('receiptList-->'+receiptList);
                    //recordListToUpdate.add(receipt);
                    //System.debug('receiptList-->'+recordListToUpdate);
                    if(receiptsMap.containsKey(serviceRece.Receipt__c) && receiptsMap.get(serviceRece.Receipt__c).Invoice__c != null) {
                        Credit_Memo__c credMemo = new Credit_Memo__c();
                        credMemo.Service_Request__c = recID;
                        credMemo.Service_Request_Receipt__c = serviceRece.Id;
                        credMemo.Unit__c = caseData.Unit__c;
                        credMemo.Business_Unit__c = caseData.Unit__r.Business_Unit__c;
                        credMemo.Invoice_Description__c = serviceRece.Receipt_Action_Type__c != 'Partial' ? serviceRece.Receipt_Action_Type__c : 'Partial Refund';
                        credMemo.Account__c = caseData.AccountId;
                        credMemo.Credit_Memo_Date__c = System.Today();
                        //credMemo.Unique_Key__c = serviceRece.Id +'-' +recID;
                        credMemo.Unique_Key__c = serviceRece.Id +'-' + Integer.valueof((Math.random() * 100));
                        credMemo.Invoice__c = receiptsMap.get(serviceRece.Receipt__c).Invoice__c;
                        if(caseData.Unit__r.Master_payment_plan__r.Credit_Memo_Transaction_Type__c !=null)
                        	credMemo.Transaction_Type__c = caseData.Unit__r.Master_payment_plan__r.Credit_Memo_Transaction_Type__c;
                        credMemo.Amount__c = receiptsMap.get(serviceRece.Receipt__c).Amount__c;
                        creditMemoList.add(credMemo);
                    }
                }
            }
            
            //Code to delete the child Record if the service request action type is changed
            Map<Id, Service_Request_Receipt__c> srrUpdatedMap = new Map<Id, Service_Request_Receipt__c>();
            if(modifiedActionTypeIdSet != null && !modifiedActionTypeIdSet.isEmpty()){
                for (Service_Request_Receipt__c srrInstance : [SELECT Id, Receipt_Action_Type__c, (SELECT Id FROM Receipt_Refund__r), (SELECT Id FROM Invoices__r), 
                                                                (SELECT Id, Initiatae_Receipt_Reversal__c, Case__c FROM Receipts__r) 
                                                                FROM Service_Request_Receipt__c WHERE Id IN :modifiedActionTypeIdSet]) {
                	srrUpdatedMap.put(srrInstance.Id, srrInstance);    
                }    
            }
            
            for(Service_Request_Receipt__c serviceRece : SR_Receipts){
                if(!srReceiptsMap.isEmpty() && srReceiptsMap.containsKey(serviceRece.Id) && 
                   srReceiptsMap.get(serviceRece.Id) != null && 
                   String.isNotBlank(srReceiptsMap.get(serviceRece.Id).Receipt_Action_Type__c) && 
                   srReceiptsMap.get(serviceRece.Id).Receipt_Action_Type__c != serviceRece.Receipt_Action_Type__c && 
                   modifiedActionTypeIdSet.contains(serviceRece.Id)) {
                   if (srReceiptsMap.get(serviceRece.Id).Receipt_Action_Type__c == 'Reversal' && 
                       srrUpdatedMap.containsKey(serviceRece.Id) && srrUpdatedMap.get(serviceRece.Id) != null && 
                       srrUpdatedMap.get(serviceRece.Id).Receipts__r != null){
                        for (Receipt__c rec : srrUpdatedMap.get(serviceRece.Id).Receipts__r){
                            rec.Case__c = null;
                            rec.Initiatae_Receipt_Reversal__c = false;
                            rec.Id = rec.Id;
                            recordListToUpdate.add(rec);
                        }
                   }
                   
                   //if ((srReceiptsMap.get(serviceRece.Id).Receipt_Action_Type__c == 'Full Refund' || 
                      // srReceiptsMap.get(serviceRece.Id).Receipt_Action_Type__c == 'Partial Refund') &&
                    if (srReceiptsMap.get(serviceRece.Id).Refund_Amount__c!=null 
                       &&    
                       srrUpdatedMap.containsKey(serviceRece.Id) && srrUpdatedMap.get(serviceRece.Id) != null && 
                       srrUpdatedMap.get(serviceRece.Id).Receipt_Refund__r != null) {
                   	   recordListToDelete.addAll(srrUpdatedMap.get(serviceRece.Id).Receipt_Refund__r);        	    
                   } //else if ((srReceiptsMap.get(serviceRece.Id).Receipt_Action_Type__c == 'Full Forfeit' || 
                       //srReceiptsMap.get(serviceRece.Id).Receipt_Action_Type__c == 'Partial Forfeit') && 
                     else if (srReceiptsMap.get(serviceRece.Id).Forfeit_Amount__c !=null && 
                       srrUpdatedMap.containsKey(serviceRece.Id) && srrUpdatedMap.get(serviceRece.Id) != null && 
                       srrUpdatedMap.get(serviceRece.Id).Invoices__r != null) {
                   	   recordListToDelete.addAll(srrUpdatedMap.get(serviceRece.Id).Invoices__r);        	    
                   }
                }
            }
            recordListToDelete.addAll(new List<Credit_Memo__c>([Select Id FROM Credit_Memo__c WHERE Service_Request__c = :recID]));
            if(receiptRefundList.size()>0){
                Upsert receiptRefundList Unique_Key__c;
            }
            if(invoiceList.size()>0){
                Upsert invoiceList Unique_Key__c;
            }
            if(creditMemoList.size()>0){
                Upsert creditMemoList Unique_Key__c;
            }
            if(receiptList.size()>0){
                Update receiptList;
            }
            
            if (SrReceipts_toDelete != null && !SrReceipts_toDelete.isEmpty()){
                recordListToDelete.addAll(SrReceipts_toDelete);//delete receipts which are unchecked
            }
            
            if(SObject_toDelete != null && !SObject_toDelete.isEmpty()){
                for (Service_Request_Receipt__c srrInstance : SObject_toDelete) {
                    if(srrInstance.Receipt_Refund__r != null){
                    	recordListToDelete.addAll(srrInstance.Receipt_Refund__r);    
                    }
                    /*if(srrInstance.Invoices__r != null){
                        recordListToDelete.addAll(srrInstance.Invoices__r);    
                    }*/
                    if(srrInstance.Credit_Memos__r != null){
                        recordListToDelete.addAll(srrInstance.Credit_Memos__r);    
                    }
                }
                //System.debug('SrReceiptsRefund_toDelete--->'+SrReceiptsRefund_toDelete);
            }
            
            /*if(SObject_toDelete != null && !SObject_toDelete.isEmpty()){
                for (Service_Request_Receipt__c srrInstance : SObject_toDelete) {
                    if(srrInstance.Invoices__r != null){
                    	recordListToDelete.addAll(srrInstance.Invoices__r);    
                    }
                }
                //System.debug('SrInvoice_toDelete--->'+SrInvoice_toDelete);
            }*/
            
            if(Receipt_toDelete.size()>0){
                for(Receipt__c rec : Receipt_toDelete){
                    //Receipt__c recInstance = new Receipt__c();
                    rec.Case__c =null;
                    rec.Initiatae_Receipt_Reversal__c = false;
                    rec.Id = rec.Id;
                    recordListToUpdate.add(rec);
                }
                //UPDATE Receipt_toDelete;
                //system.debug('Receipt_toDelete--->'+Receipt_toDelete);
                system.debug('Receipt_toDelete--->'+recordListToUpdate);
                
            }
            
            if(recordListToUpdate != null && !recordListToUpdate.isEmpty()){
            	UPDATE recordListToUpdate;    
            }
            
            if(recordListToDelete != null && !recordListToDelete.isEmpty()){
            	DELETE recordListToDelete;    
            }
        }
        catch(Exception ex){
            System.debug('error is '+ ex.getMessage() + ' at Line '+ ex.getLineNumber());
            
        }
        
    } 
    
    
    //get picklist values dynamically based on object name and field name
    @AuraEnabled
    public static Map<String, String> getPicklistvalues(String objectName, String field_apiname){
        Map<String, String> options = new Map<String, String>();
        Map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
        Map<String, Schema.SObjectField> field_map = gd.get(objectName.toLowerCase()).getDescribe().fields.getMap(); 
        List<Schema.PicklistEntry> picklistValues = field_map.get(field_apiname).getDescribe().getPickListValues();
        
        for (Schema.PicklistEntry p: picklistValues) {
            options.put(p.getValue(), p.getLabel());
        }
        return options;
    } 
    @AuraEnabled
    public static void saveRecoverablesData(List<Recoverables__c> recList){
               
        try{
        Upsert recList;
        }
        
        catch(Exception ex){
            system.debug('error is '+ ex.getMessage() + ' at '+ ex.getLineNumber());
            
        }
        
    }
    @AuraEnabled
    public static void deleteRecoverablesData(Id recovRecordId){
        List<Recoverables__c> recList =[Select Id, Name,Name__c, Amount__c from Recoverables__c where Id =:recovRecordId];        
        Delete recList;
    }
    @AuraEnabled
    public static list<Recoverables__c> getRecoverablesData(String recID){
        List<Recoverables__c> recList =[Select Id, Name,Name__c, Amount__c from Recoverables__c WHERE Service_Request__c=:recID];
        return recList;
    }
    
    
    
    public class SRReceiptsWrpprCls{
        @AuraEnabled
        public Service_Request_Receipt__c SR_Receipt;
        @AuraEnabled
        public Boolean isChecked;
        @AuraEnabled
        public String auraID;
        @AuraEnabled
        public Boolean isActionReq;//used for validation of action type if checkbox is true
        @AuraEnabled
        public Boolean isFrfeitTypeReq;//used for validation of Forfeit type if Action type is Refund
        @AuraEnabled
        public Boolean isFrfeitAmtReq ;//used for validation of Forfeit Amount if Action type is Refund
        @AuraEnabled
        public Boolean isRecoverAmtReq;//used for validation of Recover Amount if Action type is Recover
        @AuraEnabled
        public Boolean isRefundAmtReq;//used for validation of Refund Amount if Action type is Refund
        @AuraEnabled
        public Boolean isReversalAmtReq;//used for validation of Reversal Amount  if Action type is Reversal
        @AuraEnabled
        public String selectedRecoverable;
        @AuraEnabled
        public String selectedRecoverableId;
        @AuraEnabled
        public Boolean isAmtInvalid;
        
    }
    public class AddReceiptsLstWrapper{
        @AuraEnabled
        public List< SRReceiptsWrpprCls> rcpWrppr;
        @AuraEnabled
        public Case sRequest;
        @AuraEnabled
        public Map<String, String> receiptActionValues;
        @AuraEnabled
        public Map<String, String> forfeitTypeValues;
        @AuraEnabled
        public Decimal totalReceiptAmt;
        @AuraEnabled
        public List<Recoverables__c> recList;
        
        
        
    }
    
    
    
}