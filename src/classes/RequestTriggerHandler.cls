public class RequestTriggerHandler { /*
    List<Requested_Payment_Plan__c> reqPayment = new List<Requested_Payment_Plan__c>();
    List<Requested_Payment_Plan__c> recordOldList = new List<Requested_Payment_Plan__c>();
    Map<Id, Requested_Payment_Plan__c> recordNewMap = new Map<Id, Requested_Payment_Plan__c>();
    Map<Id, Requested_Payment_Plan__c> recordOldMap = new Map<Id, Requested_Payment_Plan__c>();
    Boolean isInsert, isUpdate, isDelete, isUndelete = false;
   
    
    public RequestTriggerHandler(List<Requested_Payment_Plan__c> newList, List<Requested_Payment_Plan__c> oldList, Map<Id, Requested_Payment_Plan__c> newMap, Map<Id, Requested_Payment_Plan__c> oldMap, boolean isInsert, boolean isUpdate, Boolean isDelete, Boolean isUndelete) {
        this.reqPayment = newList;
        this.recordOldList = oldList;
        this.recordNewMap = newMap;
        this.recordOldMap = oldMap;
        this.isInsert = isInsert;
        this.isUpdate = isUpdate;
        this.isDelete = isDelete;
        this.isUndelete = isUndelete;
    }
    
    public void BeforeInsertEvent() {
        
       
    }
    public void BeforeUpdateEvent() {
        
    }
    public void BeforeDeleteEvent() {
    }
    public void AfterInsertEvent() {
        updateOpportunity();
    }
    public void AfterUpdateEvent() {
        updatePaymentPlan();
    }
    public void AfterDeleteEvent() {
    }
    public void AfterUndeleteEvent() {
    }
    
    public  void updatePaymentPlan(){
        Map<String,String> oppidVsCheque = new Map<String,String>();
        Set<Id> oppId = new Set<Id>();
        List<Payment_Plan__c> paymentPlanupdateList = new List<Payment_Plan__c>();
        List<Payment_Milestone__c> payMileList = new List<Payment_Milestone__c>();
        Map<String,Decimal> oppVsAmount = new Map<String,Decimal>();
        Boolean flag = false;
        for(Requested_Payment_Plan__c req : reqPayment){
            if(req.status__c == 'Approved'){
                flag = true;
                oppId.add(req.Opportunity__c);
                oppidVsCheque.put(req.Opportunity__c,req.No_of_cheques_Leasing__c);
                oppVsAmount.put(req.Opportunity__c,req.Leasing_Selling_Price__c);
            }
        }
        system.debug('oppidVsCheque'+oppidVsCheque);
        if(flag == true){
        List<Payment_Plan__c> paymentPlanList = [select id,Name,Opportunity__c,Master_Payment_Plan__c from Payment_Plan__c where Opportunity__c =:oppId];
        List<Payment_Milestone__c> paymentMileList = [select id,Opportunity__c,Master_Payment_Plan__c from Payment_Milestone__c where Opportunity__c =:oppId];
       delete paymentMileList;
        system.debug('paymentPlanList'+paymentPlanList);
        for(Payment_Plan__c pay : paymentPlanList){
            Payment_Plan__c payObj = new Payment_Plan__c();
            if(oppidVsCheque.containsKey(pay.Opportunity__c)){
                payObj.Name = oppidVsCheque.get(pay.Opportunity__c)+'-'+'Cheque';
                payObj.No_of_cheques_Leasing__c = oppidVsCheque.get(pay.Opportunity__c);
                payObj.Id = pay.Id;
                paymentPlanupdateList.add(payObj);
            }
        }
        update paymentPlanupdateList;
        system.debug('paymentPlanupdateList'+paymentPlanupdateList);
        System.debug('m'+oppidVsCheque.values());
        Integer k = Integer.valueOf(reqPayment[0].No_of_cheques_Leasing__c);
        for(Integer j = 0; j < k;j++){
                Payment_Milestone__c payMile = new Payment_Milestone__c();
                //payMile.Name = paymentPlanList[0].Name;
                //payMile.Master_Payment_Plan__c = paymentPlanList[0].Master_Payment_Plan__c;
                payMile.Opportunity__c = paymentPlanList[0].Opportunity__c;
            if(oppVsAmount.containsKey(paymentPlanList[0].Opportunity__c)){
                Integer num = Integer.valueOf(oppVsAmount.get(paymentPlanList[0].Opportunity__c))/Integer.valueOf(oppidVsCheque.get(paymentPlanList[0].Opportunity__c));
                payMile.Amount__c = num;
            }
               payMileList.add(payMile);
                
            }
            insert payMileList;
        }
    }
    public void updateOpportunity(){
        Set<Id> oppId = new Set<Id>();
        List<Requested_Payment_Plan__c> reqList = new List<Requested_Payment_Plan__c>();
        Map<String,String> oppVsUnit = new Map<String,String>();
         Map<String,String> oppVsUnitPrice = new Map<String,String>();
        Map<String,String> oppVsProject = new Map<String,String>();
         for(Requested_Payment_Plan__c req : reqPayment){
             oppId.add(req.Opportunity__c);
         }
     List<Unit_Plan__c> unitplanList = [select unit__c,project__c,unit__r.Leasing_Selling_Price__c,Opportunity__c from Unit_Plan__c where Opportunity__c  IN: oppId];
      List<Payment_Plan__c> payPlan = [select id,No_of_cheques_Leasing__c from Payment_Plan__c where Opportunity__c  IN: oppId]; 
        Map<String,Unit_Plan__c> oppVsUnitPlan = new Map<String,Unit_Plan__c>();
        for(Unit_Plan__c plan : unitplanList){
          oppVsUnit.put(plan.Opportunity__c, plan.unit__c); 
            oppVsUnitPrice.put(plan.Opportunity__c, String.valueOf(plan.unit__r.Leasing_Selling_Price__c));
            oppVsProject.put(plan.Opportunity__c,plan.Project__c);
            oppVsUnitPlan.put(plan.Opportunity__c,plan);
        }
        for(Requested_Payment_Plan__c req : reqPayment){
            Requested_Payment_Plan__c reqObj = new Requested_Payment_Plan__c();
            if(oppVsUnit.containsKey(req.Opportunity__c) && oppVsUnitPrice.containsKey(req.Opportunity__c)){
                Unit_Plan__c plan = oppVsUnitPlan.get(req.Opportunity__c);
                reqObj.Unit__c = oppVsUnit.get(req.Opportunity__c);
                reqObj.Leasing_Selling_Price__c = Decimal.valueOf(oppVsUnitPrice.get(req.Opportunity__c));
                reqObj.Project_Name__c = oppVsProject.get(req.Opportunity__c);
                reqObj.Default_No_Of_Cheque__c = payPlan[0].No_of_cheques_Leasing__c;
               // reqObj.Master_Payment_Plan__c = plan.unit__r.Master_Payment_Plan__c;
                 Integer num = Integer.valueOf(oppVsUnitPrice.get(req.Opportunity__c))/Integer.valueOf(req.No_of_cheques_Leasing__c);
                 reqObj.Amount__c = num;
                reqObj.Id = req.Id;
                reqList.add(reqObj);
            }
        }
        if(reqList <> null && reqList.size() > 0){
            update reqList;
        }
    }
*/
}