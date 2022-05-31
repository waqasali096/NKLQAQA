public without sharing class RedirectToListViewCtrl {
    
    @AuraEnabled
    public static Boolean getCurrentUserState(String recordId){
        Boolean showRecord = true;
        Profile p = [Select Name,Id FROM Profile where Id =: UserInfo.getProfileId()];
        Lead led = [Select Id,Status FROM Lead where Id =: recordId ];
        if(led.Status == 'Qualified' && p.Name == 'Lead Qualifier'){
            showRecord = false;
        }

        return showRecord;
    }
    
    @AuraEnabled
    public static ListView getSObjectList(String ObjectApi){
        String sObjectName = ObjectApi;
        String defaultList = '%'+ 'Recently' + '%';
        ListView lv = [Select Id,Name FROM ListView where SobjectType =: sObjectName and Name LIKE : defaultList limit 1];
        
        return lv;
    }

}