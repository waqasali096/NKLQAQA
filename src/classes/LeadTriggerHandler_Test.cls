@isTest
public class LeadTriggerHandler_Test {
    /**
    * Method Name: testInsertEvent
    * Method Description: Using TestDataFactory class insert a Campaign then insert Leads with the Campaign Name and Campaign Number that
							matches with the Name and Campaign Number of inserted Campaign,
    * @param: leadList - List of Lead records that was inserted with the help of TestDataFactory Classs
    * @return: Void                                           
    */
 
    @isTest
    public static void testInsertEvent(){
        List<Lead> leadList = new List<Lead>();
        List<CampaignMember> campMemList = new List<CampaignMember>();
        leadList = TestDataFactory.createLead(5);
        campMemList = TestDataFactory.CreateCampMember();
        
    }
    /**
    * Method Name: testUpdateEvent
    * Method Description: Using TestDataFactory class insert Lead records and after that update those records to invoke Update events.
    * @param: leadList - List of Lead records that was inserted with the help of TestDataFactory Classs
    * @return: Void                                           
    */
    @isTest
    public static void testUpdateEvent(){
        List<Lead> leadList = new List<Lead>();
        List<CampaignMember> campMemList = new List<CampaignMember>();
       leadList = TestDataFactory.createLead(5);
       
        for(Lead l : leadList){
            l.firstName = 'New';
            l.Campaign__c = Null;
             campMemList = TestDataFactory.CreateCampMember();
        }
        update leadList;
    }
    /**
    * Method Name: testDeleteEvent
    * Method Description: Using TestDataFactory class insert Lead records then delete those records to invoke Delete events
    * @param: leadList - List of Lead records that was inserted with the help of TestDataFactory Classs
    * @return: Void                                           
    */
      @isTest
    public static void testDeleteEvent(){
        List<Lead> leadList = new List<Lead>();
       leadList = TestDataFactory.createLead(5);
        delete leadList;
    }
    /**
    * Method Name: testunDeleteEvent
    * Method Description: Using TestDataFactory class insert Lead records then delete those records after that undelete those records to invoke unDelete events.
    * @param: leadList - List of Lead records that was inserted with the help of TestDataFactory Classs
    * @return: Void                                           
    */
    @isTest
    public static void testunDeleteEvent(){
        List<Lead> leadList = new List<Lead>();
       leadList = TestDataFactory.createLead(5);
        delete leadList;
        undelete leadList;
    }
}