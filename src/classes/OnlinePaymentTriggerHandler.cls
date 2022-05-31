public class OnlinePaymentTriggerHandler {
    List<Online_Payment__c> recordNewList = new List<Online_Payment__c>();
    List<Online_Payment__c> recordOldList = new List<Online_Payment__c>();
    Map<Id, Online_Payment__c> recordNewMap = new Map<Id, Online_Payment__c>();
    Map<Id, Online_Payment__c> recordOldMap = new Map<Id, Online_Payment__c>();
    Boolean isInsert, isUpdate, isDelete, isUndelete = false;
    public static boolean recursionController = false;
    public OnlinePaymentTriggerHandler(List<Online_Payment__c> newList, List<Online_Payment__c> oldList, Map<Id, Online_Payment__c> newMap, Map<Id, Online_Payment__c> oldMap, boolean isInsert, boolean isUpdate, Boolean isDelete, Boolean isUndelete) {
        this.recordNewList = newList;
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

    public void BeforeUpdateEvent(List<Online_Payment__c> newOppList,Map<Id, Online_Payment__c> recordOldMap,Map<Id, Online_Payment__c> recordNewMap) {
    }
    
    public void AfterInsertEvent(List<Online_Payment__c> newList) {
        handleCCAvenueCallout( newList );
        updateOptyTokenAmountPaid( recordNewList, null );
    }

    public void AfterUpdateEvent() {
        updateOptyTokenAmountPaid( recordNewList, recordOldMap );
    }

    public void BeforeDeleteEvent() {
    }

    public void AfterDeleteEvent() {
    }

    public void AfterUndeleteEvent() {
    }

    public static void handleCCAvenueCallout(List<Online_Payment__c> records){
        for(Online_Payment__c onlinepay : records){
            CCAvenueCallout.calloutPrepration(onlinepay.id);
        }
    }


    /**********************************************************************************************
    * @Description  : Method to update opportunity token amount paid
    * @Params       : List< Online_Payment__c > newList
    * @Param        : Map< Id, Online_Payment__c > oldMap
    * @Return       : void
    **********************************************************************************************/
    public static void updateOptyTokenAmountPaid( List< Online_Payment__c > newList, Map< Id, Online_Payment__c > oldMap ){
        
        Set< Id > setOpptyIds = new Set< Id >();
        List< Opportunity > lstOpportunityToUpdate = new List< Opportunity >();

        for( Online_Payment__c op : newList ){
            if( ( oldMap == null || op.Payment_Status__c != oldMap.get(op.Id).Payment_Status__c ) && op.Payment_Status__c == 'Paid'){
                setOpptyIds.add( op.Opportunity__c );
            }
        }

        if( !setOpptyIds.isEmpty() ){
            for( Id oppId : setOpptyIds ){
                Opportunity opp = new Opportunity( Id = oppId );
                opp.Token_Amount_Paid__c = true;
                lstOpportunityToUpdate.add( opp );
            }
        }

        if( !lstOpportunityToUpdate.isEmpty() ){
            update lstOpportunityToUpdate;
        }
        
    }
}