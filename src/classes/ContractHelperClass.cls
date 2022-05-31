public class ContractHelperClass {
    @AuraEnabled
    public static void loadObjectInfoById(Id recordId) {
        set<ID> Ids = new set<Id>{recordId};
        DescribeSObjectResult objectType = recordId.getSobjectType().getDescribe();
        String sObjectName = objectType.getName();
        ERPAPIIntegration.contractTermination(Ids, sObjectName);
    }

}