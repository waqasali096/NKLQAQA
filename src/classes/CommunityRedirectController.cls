public class CommunityRedirectController {
    @AuraEnabled
    public static User getLoggedInUser(){
        return [SELECT Id,Account_Id__c FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1];
    }
}