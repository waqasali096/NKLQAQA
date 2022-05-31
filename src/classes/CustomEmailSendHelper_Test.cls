@isTest
public class CustomEmailSendHelper_Test {
    
    
    @isTest
    public static void testgetQuickOppDefaultValue_Tests(){
        Profile p = [SELECT Id,name FROM Profile WHERE Name='Sales Executive']; 
       Set<Id> userIds=new Set<Id>();
        List<User> u = new List<User>();
       // u= TestDataFactory.createUsers(1, p.Id);
        system.debug('userr********'+ u);
        userIds.add(Userinfo.getUserId());
        List<UserRole> ur =  new List<UserRole>();
        ur=TestDataFactory.createRoles();
        
                String responseJSON = '{ "field": "Name", "recipient": "test", "type_Z": owner } ';
		//		List<SK_EmailAlertJSONParser.Recipients> rras=new List<SK_EmailAlertJSONParser.Recipients>();//
    //    rras.add(u[0]);
       // rras
        //
        CustomEmailSendHelper.getUserEmails(userIds);
      //  CustomEmailSendHelper.FetchUserEmails();
        
        //CreateQuickOppController.getSortedFieldSetFields('Opportunity', 'Quick_Book_Fields');
    }
    
     @isTest
    public static void testgetQuickOppDefaultValue2_Tests(){
        Profile p = [SELECT Id,name FROM Profile WHERE Name='Sales Executive']; 
       Set<Id> userIds=new Set<Id>();
        List<User> u = new List<User>();
       // u= TestDataFactory.createUsers(1, p.Id);
     //   system.debug('userr********'+ u);
       // userIds.add(Userinfo.getUserId());
        List<UserRole> ur =  new List<UserRole>();
        ur=TestDataFactory.createRoles();
          userIds.add(ur[0].id);
                String responseJSON = '{ "field": "Name", "recipient": "test", "type_Z": owner } ';
		//		List<SK_EmailAlertJSONParser.Recipients> rras=new List<SK_EmailAlertJSONParser.Recipients>();//
    //    rras.add(u[0]);
       // rras
        //
        CustomEmailSendHelper.getRoleSubordinateUsers(userIds);
        CustomEmailSendHelper.getAllSubRoleIds(userIds);
      //  CustomEmailSendHelper.FetchUserEmails();
        
        //CreateQuickOppController.getSortedFieldSetFields('Opportunity', 'Quick_Book_Fields');
    }
}