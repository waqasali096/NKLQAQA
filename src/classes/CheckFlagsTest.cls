/**
* @author : Muhammad Sajid
* @createdDate : 03-Feb-2022
* @lastModifieddate : 03-Feb-2022
* @usage : Test class to cover all functionality of CheckFlagsTest. 
*/

@isTest
public class CheckFlagsTest {

    public static List<Master_Flag__c> masterFlagList = new List<Master_Flag__c>();
    public static List<Account> accList = new List<Account>();
    public static List<Unit__c> unitList = new List<Unit__c>();
    public static List<Contact> contactList = new List<Contact>();
    public static List<Flag__c> flagList = new List<Flag__c>();
    
    @TestSetup
    Static  void createData(){
        TestDataFactory.createAppSettings();
        Master_Flag__c masterFlag = new Master_Flag__c();
        masterFlag.Name = 'DEFAULTER';
        masterFlag.Flag_Type__c = 'DEFAULTER';
        masterFlag.Dimension__c = 'OWNER';
        masterFlag.Description__c = 'The selected customer is flagged for construction default. Please refer to Nakheel CR team.';
        masterFlagList.add(masterFlag);
        
        Master_Flag__c masterFlag1 = new Master_Flag__c();
        masterFlag1.Name = 'L_BOUNCED_CHEQUE';
        masterFlag1.Dimension__c = 'LOCATION';
        masterFlag1.Flag_Type__c = 'Location Bounced Cheque';
        masterFlag1.Description__c = 'The property is flagged due to outstanding clubhouse fees. Please refer to the Clubhouse management team before processing requests related to this property';
        masterFlagList.add(masterFlag1);
        
        Master_Flag__c masterFlag2 = new Master_Flag__c();
        masterFlag2.Name = 'RESIDENTIAL_BOUNCE_CHEQUE';
        masterFlag2.Flag_Type__c = 'Residential Bounce Cheque';
        masterFlag2.Dimension__c = 'TENANT';
        masterFlag2.Description__c = 'Customer is flagged due to Residential Bounce Cheque. Please contact administrator';
        masterFlagList.add(masterFlag2);
        
        insert masterFlagList;
        
        
       
        accList = TestDataFactory.createAccounts(1);
        contactList = TestDataFactory.createContacts(1, accList);
        unitList = TestDataFactory.createUnit();

        
		
        Flag__c flag = new Flag__c();
        flag.Master_Flag__c = masterFlagList[0].Id;
        flag.Active__c = true;
        flag.Start_Date__c = System.today() - 5;
        flag.End_Date__c = System.today() + 5;
        flag.Customer__c = accList[0].Id;
        flagList.add(flag);
        
        
        Flag__c flag1 = new Flag__c();
        flag1.Unit_Master_Flag__c = masterFlagList[1].Id;
        flag1.Active__c = true;
        flag1.Start_Date__c = System.today() - 5;
        flag1.End_Date__c = System.today() + 5;
        flag1.Unit__c = unitList[0].Id;
        flagList.add(flag1);
        
        Flag__c flag2 = new Flag__c();
        flag2.Unit_Master_Flag__c = masterFlagList[1].Id;
        flag2.Active__c = true;
        flag2.Start_Date__c = System.today() - 5;
        flag2.End_Date__c = System.today() + 5;
        flag2.Unit__c = unitList[0].Id;
        flagList.add(flag2);

        Flag__c flag3 = new Flag__c();
        flag3.Master_Flag__c = masterFlagList[2].Id;
        flag3.Active__c = true;
        flag3.Start_Date__c = System.today() - 5;
        flag3.End_Date__c = System.today() + 5;
        flag3.Customer__c = accList[0].Id;
        flagList.add(flag3);
        
        
        Flag__c flag4 = new Flag__c();
        flag4.Unit_Master_Flag__c = masterFlagList[1].Id;
        flag4.Active__c = true;
        flag4.Start_Date__c = System.today() - 5;
        flag4.End_Date__c = System.today() + 5;
        flag4.Building__c = unitList[0].Building__c;
        flagList.add(flag4);
        
        Flag__c flag5 = new Flag__c();
        flag5.Unit_Master_Flag__c = masterFlagList[1].Id;
        flag5.Active__c = true;
        flag5.Start_Date__c = System.today() - 5;
        flag5.End_Date__c = System.today() + 5;
        flag5.Project__c = unitList[0].Project__c;
        flagList.add(flag5);
        
        insert flagList;
  
    }
    
    
    /* @usage : This function used to cover functionality of checkFlagsRecord on account.*/
    static TestMethod void FlagRecordsOnAcc(){
        try{
           
            
            List<Account> accountList = [Select Id from Account];

            Set<Id> accId = new Set<Id>();
           
            
            for(Account acc: accountList){
                accId.add(acc.Id);
            }
            
          
            Test.startTest();
            CheckFlags.checkAccountFlags(accId, true, false, false);
            CheckFlags.checkAccountFlags(accId, false, true, false);
            CheckFlags.checkAccountFlags(accId, false, false, true);
            Test.stopTest();
            
        }catch(Exception e){
            
        }
    }
    
    /* @usage : This function used to cover functionality of checkFlagsRecord on unit.*/
    static TestMethod void FlagRecordsOnUnit(){
        try{
            
            List<Unit__c> unitList = [Select Id, Building__c , Project__c  from Unit__c];
            
            List<Id> unitId = new List<Id>();
            for(Unit__c unit: unitList){
                unitId.add(unit.Id);
            }
            
            Test.startTest();
            CheckFlags.checkUnitFlags(unitId);
            Test.stopTest();
            
        }catch(Exception e){
            
        }
    }
    
    /* @usage : This function used to cover functionality of checkFlagsRecord on Building.*/
    static TestMethod void FlagRecordsOnBuilding(){
        try{
            
            List<Unit__c> unitList = [Select Id, Building__c , Project__c  from Unit__c];
            
            
            List<Id> buildingId = new List<Id>();
            
            for(Unit__c unit: unitList){
                
                buildingId.add(unit.Building__c);
                
            }
            
            Test.startTest();
            CheckFlags.checkBuildingFlags(buildingId);
            Test.stopTest();
            
        }catch(Exception e){
            
        }
    }
    
    /* @usage : This function used to cover functionality of checkFlagsRecord on project.*/
    static TestMethod void FlagRecordsOnProject(){
        try{
            
            List<Unit__c> unitList = [Select Id, Building__c , Project__c  from Unit__c];
            List<Id> projectId = new List<Id>();
            
            for(Unit__c unit: unitList){
                projectId.add(unit.Project__c);
            }
            
            Test.startTest();
            CheckFlags.checkProjectFlags(projectId);
            Test.stopTest();
            
        }catch(Exception e){
            
        }
    }
}