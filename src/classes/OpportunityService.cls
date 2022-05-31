public class OpportunityService {
    
    public static List<Account> getAccountDetails(Set<ID> setAccId){
        return [SELECT Id,Name FROM Account WHERE Id IN:setAccId ];
    }
     public static List<Unit_Plan__c> getUnitPlanDetails(Set<ID> setOppId){
        return [SELECT Id ,Unit__c, Opportunity__r.AccountId,
                                                               Opportunity__r.Lease_Start_Date__c,Final_Lease_Amount__c,
                                                               Opportunity__r.Lease_End_Date__c,Opportunity__c, Name FROM Unit_Plan__c  
                                                               WHERE Opportunity__c IN :setOppId];
    }
     public static List<Opportunity> getOppDetails(Set<ID> setOppId){
        return [Select Unit_Status__c,Id,Unit__r.name,Unit__c, AccountId, Account.name,RecordTypeId,StageName,Name,Quick_Book_Opportunity__c,Booking_Reservation_Date__c,
                          (select id,opportunity__c,Primary_Account__c,Secondary_Account__c from joint_buyers__r) from Opportunity where id in :setOppId];
    }
    public static List<ContentDocumentLink> getCDLDetails(Set<ID> setId){
        return [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId in :setId];
    }
    public static List<ContentVersion> getCVDetails(Set<ID> setId){
        return [Select Id,ContentDocumentId, ContentUrl,VersionData,Title,PathOnClient from ContentVersion where ContentDocumentId in :setId ];
    }
    public static List<Object_Document__c> getObjDocDetails(Set<ID> setOppId){
        return [Select id, Opportunity__c, Document__c from Object_Document__c where Opportunity__c in :setOppId];
    }
    public static List<Document__c> getDocumentDetails(List<ID> setId){
        return [Select id, Opportunity__c, Document_Type__c from Document__c where id in :setId];
    }
    
    public static List<Unit__c> getUnitDetails(Set<ID> setUnitId){
        return [SELECT Id,Name,Unit_Theme__c,Master_Payment_Plan__c,DLD_Customer_Share__c,No_of_Bedrooms__c,project__c,Cluster__c,Unit_Status__c FROM Unit__c WHERE Id IN:setUnitId ];
    }
    
    public static List<Project__c> getProjectDetails(Set<ID> setProjectIds){
        return [Select Id,Business_Unit__r.ERP_Business_Unit_Id__c,Business_Unit__r.sequence__c,Business_Unit__c FROM Project__c where ID IN: setProjectIds];
    }
    public static List<Master_Payment_Milestone__c> getMPaymentMileStoneDetails(List<ID> listMPPId){
        return [SELECT Id, Name,Installment__c, CurrencyIsoCode, Installment_No__c, Master_Payment_Plan__c, 
                                                       Amount_Percentage__c, Milestone_Trigger_Point__c, Due_In_Days__c 
                                                       FROM Master_Payment_Milestone__c 
                                                       WHERE Master_Payment_Plan__c IN: listMPPId ];
    }
     public static List<Additional_Charges__c> getAddChargeDetails(Set<ID> setUnitId){
        return [SELECT Id,Name,VAT__c,VAT_Amount__c,VAT_Code__c,Type__c,Utility_Charges__c,Unit__c
                                            FROM Additional_Charges__c 
                                            WHERE Unit__c IN:setUnitId  AND Default_Sales_Charge__c = true];
    }
     public static List<Agreement__c> getAgreementDetails(Set<ID> setOppId){
        return [SELECT Id FROM Agreement__c WHERE Opportunity__c IN: setOppId];
    }
    public static List<Contributor__c> getContributorDetails(Set<ID> setOppId,List<ID> listUserId){
        return [SELECT Id FROM Contributor__c WHERE Opportunity__c IN:setOppId AND User__c IN:listUserId];
    }
    public static List<Payment_Milestone__c> getPaymentMileStnDetails(Set<ID> setOppId){
        return [SELECT Id,Opportunity__c, Amount__c,Amount_Percentage__c,Installment__c FROM Payment_Milestone__c WHERE Opportunity__c IN:setOppId];
    }
    public static List<Original_Milestone__c> getOriginalMileStnDetails(Set<ID> setOppId){
        return [SELECT Id,Name, Installment_No__c, Installment__c, CurrencyIsoCode, Master_Payment_Milestone__c, 
                                        Master_Payment_Plan__c, Amount_Percentage__c, Opportunity__c, Milestone_Trigger_Point__c, 
                                        Due_In_Days__c, Due_Date__c, Amount__c 
                                        FROM Original_Milestone__c WHERE Opportunity__c IN: setOppId];
    }
    
    public static List<Opportunity> getOppSubDetails(Set<ID> setOppId){
        return [Select Id,Unit__r.name,Unit__c, AccountId, Account.name,RecordTypeId,StageName,Name,Quick_Book_Opportunity__c,
                       Booking_Reservation_Date__c,Master_Payment_Plan__c, Project__c,No_of_Bedrooms__c, Cluster__c, Opportunity__r.AccountId,Opportunity__r.Account.Name,
                       (select id,opportunity__c,Primary_Account__c,First_Name__c, Last_Name__c, Relationship_with_Owner__c,
                        Unit__c,Email__c,Mobile__c, Share_Percentage__c,Secondary_Account__c  from joint_buyers__r),
                       (select id,Name,Installment_No__c,Amount_Percentage__c,Milestone_Trigger_Point__c,Due_Date__c,Installment__c,
                        Master_Payment_Plan__c,Master_Payment_Milestone__c,Opportunity__c,Amount__c,Due_In_Days__c from Original_Milestones__r),
                       (select id,Name,Installment_No__c,Amount_Percentage__c,Milestone_Trigger_Point__c,Due_Date__c,Installment__c,
                        Master_Payment_Plan__c,Master_Payment_Milestone__c,Opportunity__c,Amount__c,Due_In_Days__c from Payment_milestones__r),
                       (select id,ContentDocumentId,LinkedEntityId from ContentDocumentLinks)
                       from Opportunity where Id IN:setOppId and Opportunity__c!=null];
    }
//[SELECT Id,Name, Installment_No__c, 

}