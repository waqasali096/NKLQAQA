@isTest
public class TaskTriggerHandler_Test {
    /**
    * Method Name: testInsertEvent
    * Method Description: Using TestDataFactory class create the Lead
      matches with the Name and Campaign Number of inserted Campaign,
    * @param: TaskList - List of Taskords that was inserted with the help of TestDataFactory Classs
    * @return: TaskList                                   
    */
 
    @isTest
    public static void testInsertEvent(){
        List<Lead> leadlist =new list<Lead>();
        List<Task> TaskList = new List<Task>();
        leadlist=TestDataFactory.createLead(1);
        TaskList = TestDataFactory.createTask(2,leadlist[0].id);
    }
    
    @isTest
    public static void testUpdateEvent(){
        List<Lead> leadlist =new list<Lead>();
        List<Task> TaskList = new List<Task>();
       
      
        leadlist=TestDataFactory.createLead(1);
       TaskList = TestDataFactory.createTask(2,leadlist[0].id);
       
        for(Task t : TaskList){
            t.Status='Completed';
            t.Parent_Flag_API_Name__c='Follow_Up_Done__c';
            
        }
        
        
        update TaskList ;
    }
    /**
    * Method Name: testDeleteEvent
    * Method Description: Using TestDataFactory class insert Lead records then delete those records to invoke Delete events
    * @param: TaskList - List of Lead records that was inserted with the help of TestDataFactory Classs
    * @return: Void                                           
    */
      @isTest
    public static void testDeleteEvent(){
        List<Lead> leadlist =new list<Lead>();
         leadlist=TestDataFactory.createLead(1);
        
        List<Task> TaskList = new List<Task>();
       TaskList = TestDataFactory.createTask(2,leadlist[0].id);
        delete TaskList;
    }
    /**
    * Method Name: testunDeleteEvent
    * Method Description: Using TestDataFactory class insert Lead records then delete those records after that undelete those records to invoke unDelete events.
    * @param: leadList - List of Lead records that was inserted with the help of TestDataFactory Classs
    * @return: Void                                           
    */
    @isTest
    public static void testunDeleteEvent(){
        List<Lead> leadlist =new list<Lead>();
        List<Task> TaskList = new List<Task>();
         leadlist=TestDataFactory.createLead(1);
       TaskList = TestDataFactory.createTask(2,leadlist[0].id);
        delete TaskList;
        undelete TaskList;
    }
}