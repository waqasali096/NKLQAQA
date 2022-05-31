/**************************************************************************************************
* Name               : RevisedPaymentPlanCtrl                                                      
* Description        : Controller class for Revised Payment Plan aura component
* Created Date       : 09/01/2022                                                                 
* Created By         : Cloudworks                                                                     
* -------------------------------------------------------------------------------------------------
* VERSION  AUTHOR    DATE            COMMENTS                                                    
* 1.0      Rohit     09/01/2022      Initial Draft.                                               
**************************************************************************************************/
public class RevisedPaymentPlanCtrl {
    
    public static final Map<String, String> INSTALLMENT_MAP = new Map<String, String>{
        'Down Payment' => '1', 
        '1st Installment' => '2',
        '2nd Installment' => '3',
        '3rd Installment' => '4',
        '4th Installment' => '5',
        '5th Installment' => '6',
        '6th Installment' => '7',
        '7th Installment' => '8',
        '8th Installment' => '9',
        '9th Installment' => '10',
        '10th Installment' => '11',
        '11th Installment' => '12',
        '12th Installment' => '13',
        '13th Installment' => '14',
        '14th Installment' => '15',
        '15th Installment' => '16',
        '16th Installment' => '17',
        '17th Installment' => '18',
        '18th Installment' => '19',
        '19th Installment' => '20',
        '20th Installment' => '21'
        };
    /******************************************************************************************************
    * @Description        : Function to get unit info to show on component 
    * @Param              : String oppId => opportunity 
    * @Return             : ResultWrapper 
    *******************************************************************************************************/
    @AuraEnabled
    public static ResultWrapper getUnitInfo(String oppId){
        ResultWrapper wrap = new ResultWrapper();
        List<Opportunity> oppList = [SELECT Id,Unit__c,Discount_Amount__c,Discount_Approval_Status__c,Booking_Reservation_Date__c,Unit__r.Name,Unit__r.Master_Payment_Plan__c,Selling_Price__c,Net_Selling_Price__c,Discount_Percentage__c,
                                     (SELECT Id,Name,Installment__c,Milestone_Trigger_Point__c,Due_Date__c,Due_In_Days__c,Amount_Percentage__c,Amount__c FROM Payment_Milestones__r),
                                     (SELECT Id,Name,Installment__c,Milestone_Trigger_Point__c,Due_Date__c,Due_In_Days__c,Amount_Percentage__c,Amount__c FROM Original_Milestones__r) 
                                     FROM Opportunity WHERE Id =:oppId AND Unit__c != null];
        if(!oppList.isEmpty()){
            wrap.unitExist = true;
            List<OpportunityResult> oppWrapList = new List<OpportunityResult>();
            List<MilestoneResult> pmWrapList = new List<MilestoneResult>();
            List<OriginalMilestoneResult> omWrapList = new List<OriginalMilestoneResult>();
            Map<String, String> installmentMap = new Map<String, String>();
            installmentMap = CommonUtility.getPicklistValues('Payment_Milestone__c','Installment__c'); 
            for(Opportunity opp : oppList){
                if(opp.Discount_Approval_Status__c != null && opp.Discount_Approval_Status__c.contains('Pending')){
                    wrap.discountApproved = false;
                }else{
                    wrap.discountApproved = true;
                    for(Payment_Milestone__c pm : opp.Payment_Milestones__r){
                        MilestoneResult pmWrap = new MilestoneResult();
                        pmWrap.Id = pm.Id;
                        pmWrap.Name = pm.Name;
                        pmWrap.milestone = pm.Milestone_Trigger_Point__c;
                        pmWrap.installment = pm.Installment__c;
                        pmWrap.dueDate = pm.Due_Date__c;
                        pmWrap.dueInDays = pm.Due_In_Days__c;
                        pmWrap.amountPercent = pm.Amount_Percentage__c;
                        pmWrap.amount = pm.Amount__c;
                        pmWrap.maxDate = false;
                        pmWrapList.add(pmWrap);
                    }
                    for(Original_Milestone__c om : opp.Original_Milestones__r){
                        OriginalMilestoneResult omWrap = new OriginalMilestoneResult();
                        omWrap.Id = om.Id;
                        omWrap.Name = om.Name;
                        omWrap.milestone = om.Milestone_Trigger_Point__c;
                        omWrap.installment = installmentMap.get(om.Installment__c);
                        omWrap.dueDate = om.Due_Date__c;
                        omWrap.dueInDays = om.Due_In_Days__c;
                        omWrap.amountPercent = om.Amount_Percentage__c;
                        omWrap.amount = om.Amount__c;
                        omWrapList.add(omWrap);
                    }
                    OpportunityResult oppWrap = new OpportunityResult();
                    oppWrap.Id = opp.Id;
                    oppWrap.unitName = opp.Unit__r.Name;
                    oppWrap.bookingReservationDate = opp.Booking_Reservation_Date__c;
                    oppWrap.sellingPrice = opp.Selling_Price__c;
                    oppWrap.netSellingPrice = opp.Net_Selling_Price__c;
                    if(opp.Discount_Amount__c != null){
                        oppWrap.discountAmount = opp.Discount_Amount__c; 
                    }else{
                        oppWrap.discountAmount = 0;
                    }
                    
                    oppWrapList.add(oppWrap);
                }
            }
            wrap.pmResult = pmWrapList;
            wrap.omResult = omWrapList;
            wrap.oppResult = oppWrapList;
            try{
                Document__c doc;
                /*for( Document__c docObj : [SELECT Id from Document__c WHERE Opportunity__c =: oppId AND Document_Type__c = 'Revised Payment Plan Document'] ){
                    doc = docObj;
                }*/
                if( doc == null ){
                    Document__c docObj = new Document__c();
                    docObj.Opportunity__c = oppId;
                    docObj.Document_Type__c = 'Revised Payment Plan Document';
                    insert docObj;
                    // store document object
                    doc = docObj;
                }
                wrap.documentId = doc.Id;
            }catch(Exception ex) {
                System.debug('Error: '+ex.getMessage()+' Please contact your system admin.');  
                wrap.Message = ex.getMessage();
            }
        }else{
            wrap.unitExist = false;
        }
        return wrap;
    }
    
    
    /******************************************************************************************************
* @Description        : Function to save requested milestones
* @Param              : String oppId => opportunity 
* @Param              : List<Original_Milestone__c> originalMilestoneList => original milstone list
* @Param              : List<Payment_Milestone__c> requestedPaymentMilestoneList => payment milstone list 
* @Param              : List<String> deleteList => Ids to be deleted 
* @Return             : ResultWrapper 
*******************************************************************************************************/
    @AuraEnabled
    public static ResultWrapper saveRequestedMilestones(String oppId,List<Original_Milestone__c> originalMilestoneList, List<Payment_Milestone__c> requestedPaymentMilestoneList,List<String> deleteList, Id documentId){
        Boolean customizedPM = RevisedPaymentPlanCtrl.checkPaymentMilestoneChanges(originalMilestoneList,requestedPaymentMilestoneList);
        Opportunity opp = [SELECT Id,Unit__c,Unit__r.Name,Unit__r.Master_Payment_Plan__c,Selling_Price__c,Net_Selling_Price__c,Discount_Percentage__c FROM Opportunity WHERE Id =:oppId];
        ResultWrapper wrap = new ResultWrapper();
        List<Payment_Milestone__c> pmList = new List<Payment_Milestone__c>();
        Map<String, String> installmentMap = new Map<String, String>();
        installmentMap = CommonUtility.getPicklistValues('Payment_Milestone__c','Installment__c'); 
        for(Payment_Milestone__c pmLc : requestedPaymentMilestoneList){
            Payment_Milestone__c pm = new Payment_Milestone__c();
            pm.Opportunity__c = oppId;
            pm.CurrencyIsoCode = 'AED';
            pm.Name = installmentMap.get(pmLc.Installment__c);
            pm.Installment__c = pmLc.Installment__c;
            pm.Milestone_Trigger_Point__c = pmLc.Milestone_Trigger_Point__c;
            pm.Due_Date__c = pmLc.Due_Date__c;
            pm.Due_In_Days__c = pmLc.Due_In_Days__c;
            pm.Amount_Percentage__c = pmLc.Amount_Percentage__c;
            pm.Amount__c = pmLc.Amount__c;
            pm.Unit__c = opp.Unit__c;
            if(installmentMap.get(pm.Installment__c) == 'Final Installment'){
                pm.Installment_No__c = requestedPaymentMilestoneList.size();
            }else{
                pm.Installment_No__c = INSTALLMENT_MAP.get(installmentMap.get(pm.Installment__c)) != null ?  Decimal.valueOf(INSTALLMENT_MAP.get(installmentMap.get(pm.Installment__c))): null;
            }
            if(pmLc.Id != null){
                pm.Id = pmLc.Id;
            }else{
                pm.Master_Payment_Plan__c = opp.Unit__r.Master_Payment_Plan__c;
            }
            pmList.add(pm);
        }
        Savepoint sp = Database.setSavepoint();
        try{
            if(!pmList.isEmpty()){
                upsert pmList;
                wrap.pmUpdate = true;
            }
            List<Payment_Milestone__c> pmDelList = new List<Payment_Milestone__c>();
            for(String st : deleteList){
                Payment_Milestone__c pm = new Payment_Milestone__c();
                pm.Id = st;
                pmDelList.add(pm);
            }
            if(!pmDelList.isEmpty()){
                delete pmDelList;
                wrap.pmUpdate = true;
            }
            if(customizedPM){
                opp.Payment_Milestone_Customized__c = true;
                update opp;

                List<ProcessInstanceWorkitem> approvalReq = [Select p.Id, p.ProcessInstanceId from ProcessInstanceWorkitem p where p.ProcessInstance.TargetObjectId =: oppId order by createdDate Desc LIMIT 1];

                if(!approvalReq.isEmpty()){
                    List<Document__c> ddList = [SELECT Id,Is_Document_Uploaded__c FROM Document__c WHERE Id =:documentId];
                    if(ddList != null && ddList[0].Is_Document_Uploaded__c){
                        Document__c dd = new Document__c();
                        dd.Id = documentId;
                        dd.Approval_Request_Id__c = approvalReq[0].ProcessInstanceId;
                        update dd;
                    }
                }
            }
        }Catch(Exception ex){
            system.debug('error==  + ' + ex);
            wrap.Message = ex.getMessage();
            Database.rollback( sp );
            wrap.pmUpdate = false;
        }
        return wrap;  
    }
    
    /******************************************************************************************************
* @Description        : Function to check if there is any change in the payment milestones
* @Param              : List<Original_Milestone__c> originalMilestoneList => original milstone list
* @Param              : List<Payment_Milestone__c> requestedPaymentMilestoneList => payment milstone list 
* @Return             : Boolean 
*******************************************************************************************************/
    public static Boolean checkPaymentMilestoneChanges(List<Original_Milestone__c> originalMilestoneList, List<Payment_Milestone__c> requestedPaymentMilestoneList){
        Boolean customizedPM = false;
        system.debug(originalMilestoneList);
        system.debug(requestedPaymentMilestoneList);
        if(requestedPaymentMilestoneList.size() > originalMilestoneList.size() || requestedPaymentMilestoneList.size() < originalMilestoneList.size()){
            customizedPM = true;
        }else{
            for(Integer i=0; i< requestedPaymentMilestoneList.size(); i++ ){
                if(requestedPaymentMilestoneList[i].Installment__c != originalMilestoneList[i].Installment__c){
                    customizedPM = true;
                    break;
                }
                else if(requestedPaymentMilestoneList[i].Milestone_Trigger_Point__c != originalMilestoneList[i].Milestone_Trigger_Point__c){
                    customizedPM = true;
                    break;
                }
                else if(requestedPaymentMilestoneList[i].Due_Date__c != originalMilestoneList[i].Due_Date__c){
                    customizedPM = true;
                    break;
                }
                else if(requestedPaymentMilestoneList[i].Due_In_Days__c != originalMilestoneList[i].Due_In_Days__c){
                    customizedPM = true;
                    break;
                }
                else if(requestedPaymentMilestoneList[i].Amount_Percentage__c != originalMilestoneList[i].Amount_Percentage__c){
                    customizedPM = true;
                    break;
                }
                else if(requestedPaymentMilestoneList[i].Amount__c != originalMilestoneList[i].Amount__c){
                    customizedPM = true;
                    break;
                }
                else{
                    customizedPM = false;
                }
            }
        }
        return customizedPM;
    }
    
    /******************************************************************************************************
* @Description        : Function to get ContentDocument
* @Param              : None
* @Return             : void
*******************************************************************************************************/
    @AuraEnabled 
    public static void deleteContentDoc(Id conDocId){
        delete [SELECT Id FROM ContentDocument WHERE Id =: conDocId];
    }
    /******************************************************************************************************
* @Description        : Function to get milestone points
* @Param              : None
* @Return             : Map<String, String> 
*******************************************************************************************************/
    @AuraEnabled 
    public static Map<String, String> getMilestonePoint(){
        Map<String, String> options = new Map<String, String>();
        options = CommonUtility.getPicklistValues('Payment_Milestone__c','Milestone_Trigger_Point__c'); 
        return options;
    }
    
    /******************************************************************************************************
* @Description        : Function to get Installments
* @Param              : None
* @Return             : Map<String, String> 
*******************************************************************************************************/
    @AuraEnabled 
    public static Map<String, String> getInstallments(){
        Map<String, String> options = new Map<String, String>();
        options = CommonUtility.getPicklistValues('Payment_Milestone__c','Installment__c'); 
        return options;
    }
    
    // Wrapper Classes
    public class ResultWrapper{
        @AuraEnabled public List<OpportunityResult> oppResult;
        @AuraEnabled public List<MilestoneResult> pmResult;
        @AuraEnabled public List<OriginalMilestoneResult> omResult;
        @AuraEnabled public Boolean unitExist;
        @AuraEnabled public Boolean discountApproved;
        @AuraEnabled public Boolean pmUpdate;
        @AuraEnabled public String Message;
        @AuraEnabled public String documentId;
    }
    
    public class OpportunityResult{
        @AuraEnabled public String Id;
        @AuraEnabled public String unitName;
        @AuraEnabled public Date bookingReservationDate;
        @AuraEnabled public Decimal sellingPrice;
        @AuraEnabled public Decimal netSellingPrice;
        @AuraEnabled public Decimal discountAmount;
    }
    
    public class MilestoneResult{
        @AuraEnabled public String Id;
        @AuraEnabled public String Name;
        @AuraEnabled public String milestone;
        @AuraEnabled public String installment;
        @AuraEnabled public Date dueDate;
        @AuraEnabled public Boolean maxDate;
        @AuraEnabled public Decimal dueInDays;
        @AuraEnabled public Decimal amountPercent;
        @AuraEnabled public Decimal amount;
    }
    public class OriginalMilestoneResult{
        @AuraEnabled public String Id;
        @AuraEnabled public String Name;
        @AuraEnabled public String milestone;
        @AuraEnabled public String installment;
        @AuraEnabled public Date dueDate;
        @AuraEnabled public Decimal dueInDays;
        @AuraEnabled public Decimal amountPercent;
        @AuraEnabled public Decimal amount;
    }
}