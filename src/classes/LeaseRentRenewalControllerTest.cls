/****************************************************************************************************************************
* @Name         LeaseRentRenewalControllerTest 
* @Author       Hitesh Patel
* @Date         16-Mar-2022
* @Description  Test Class for LeaseRentRenewalController
****************************************************************************************************************************/
@isTest
public class LeaseRentRenewalControllerTest {
    public static List<Account> accList = new List<Account>();
    public static List<Unit__c> unitList=new List<Unit__c>();
    public static List<Opportunity> oppList=new List<Opportunity>();
    public static List<Unit_Plan__c> unitPlanList=new List<Unit_Plan__c>();
    
    /***********************************************************************************************************************
    * @Description  This method is used to create dummy data for test methods
    * @Param		NA
    * @Return       NA
    ***********************************************************************************************************************/    
    @TestSetup
    static void createData(){   
        AppSettings__c  cs = new AppSettings__c();
        cs.Name='OrgWideEmailAddressForSR ';
        cs.TextValue__c = 'Info@brokers.nakheel.com';
        insert cs;
        
        //Create Unit records
        unitList = TestDataFactory.createUnit();
        
        //Create Account records        
        accList = TestDataFactory.createAccounts(1);
        
        List<Contact> conList = TestDataFactory.createContacts(1,accList);
        
        accList[0].Primary_Email__c = 'test@test.com';
        update accList;
        
        String recordTypeId = Schema.SObjectType.Opportunity.RecordTypeInfosByName.get('Residential Units Leasing').RecordTypeId;
                
        //Create Opportunity
        Opportunity opp = new Opportunity();
        opp.Name = 'Test-Opp';
        opp.AccountId = accList[0].Id;
        opp.StageName = 'New';
        opp.CloseDate = System.today();
        opp.Booking_Amount__c = 100;
        opp.Booking_Mode__c = 'Reservation with token amount';
        opp.Booking_Form_Generated__c = false;
        opp.RecordTypeId = recordTypeId;
        opp.Lease_End_Date__c = Date.today() + 5;
        oppList.add(opp); 
        insert oppList;
        
        //update necessary fields on Project
        Project__c objProject = [SELECT Id, Active__c FROM Project__c LIMIT 1];
        objProject.Active__c = true;
        update objProject;
                
        RERA_Rent_Index__c objRERARentIndex = new RERA_Rent_Index__c();
        objRERARentIndex.Project__c = objProject.Id;
        objRERARentIndex.No_of_Bedrooms__c = '2';
        objRERARentIndex.Property_Type__c = 'Apartment';
        objRERARentIndex.Start_Date__c = Date.today();
        objRERARentIndex.End_Date__c = Date.today() + 60;
        objRERARentIndex.RERA_Rent_From__c = 10000;
        objRERARentIndex.RERA_Rent_To__c = 30000;
        insert objRERARentIndex; 
        
        for(Unit__c objUnit : unitList){
            objUnit.Opportunity__c = oppList[0].Id;
        }
        update unitList;
        
        //Create Opportunity Unit records
        for(Unit__c objUnit : unitList){
            system.debug('****** => '+objUnit.Current_Rent__c);
            Unit_Plan__c unitPlan = new Unit_Plan__c();
            unitPlan.Name = 'Test Unit Plan';
            unitPlan.Unit__c = objUnit.Id;
            unitPlan.Project__c = objProject.Id;
            unitPlan.Opportunity__c = oppList[0].Id;
            unitPlan.Final_Lease_Amount__c = 10000;
            unitPlanList.add(unitPlan);
        }        
        insert unitPlanList;  
        
        for(Unit_Plan__c objUnitPlan : [SELECT Id, Unit__r.Current_Rent__c FROM Unit_Plan__c WHERE Id IN: unitPlanList]){
            system.debug('****** => '+objUnitPlan.Unit__r.Current_Rent__c);
        }
        
        //update Oppty Stage to Closed Won
        opp.StageName = 'Leased';
        opp.Handover_Date__c = Date.today();
        update opp; 
    }
    
    /***********************************************************************************************************************
    * @Description  Test method to cover LeaseRentRenewalController class
    * @Param		NA
    * @Return       NA
    ***********************************************************************************************************************/ 
    static testMethod void leaseRentRenewalTestMethod(){
        List<Lease_Renewal_Setting__mdt> listLeaseRenewalSetting = [SELECT Id, Page_Size__c, Notify_Flag_Email_Alert__c 
                                                                    FROM Lease_Renewal_Setting__mdt 
                                                                    WHERE DeveloperName = 'Lease_Renewal_Setting'
                                                                    LIMIT 1];
        
        //create EmailAlertsMetadata
        Email_Alerts_Metadata__c objEmailAlertsMetadata = new Email_Alerts_Metadata__c();
        objEmailAlertsMetadata.Name = listLeaseRenewalSetting[0].Notify_Flag_Email_Alert__c;
        objEmailAlertsMetadata.Email_Alert_Developer_Name__c = listLeaseRenewalSetting[0].Notify_Flag_Email_Alert__c;
        objEmailAlertsMetadata.From_Address__c = 'info@brokers.nakheel.com';
        objEmailAlertsMetadata.To_Address__c = 'test@test.com';
        objEmailAlertsMetadata.Query_Field_Data__c = 'Account_Primary_Email__c';
        objEmailAlertsMetadata.Email_Template__c = [SELECT Id, Name, Subject,HtmlValue, Body FROM EmailTemplate WHERE DeveloperName = 'Rent_Renewal_Email_Template'].Id;
        insert objEmailAlertsMetadata;
        
        Project__c objProject = [SELECT Id FROM Project__c LIMIT 1];
        Building__c objBuilding = [SELECT Id FROM Building__c LIMIT 1];
        
        Test.startTest();
        LeaseRentRenewalController.getProjects();
        LeaseRentRenewalController.getBuildings(objProject.Id);
        LeaseRentRenewalController.getFloors(objProject.Id, objBuilding.Id);
        LeaseRentRenewalController.getPageSize();
        LeaseRentRenewalController.getRentUpdateReasonValues();
        List<LeaseRentRenewalController.UnitPlansWrapper> listUnitPlansWrapper = LeaseRentRenewalController.getUnitPlans(objProject.Id, String.valueOf(Date.today()), String.valueOf(Date.today() + 60), '', '');
        
        for(LeaseRentRenewalController.UnitPlansWrapper objUnitPlansWrapper : listUnitPlansWrapper){
            objUnitPlansWrapper.blnNotifyFlag = true;
            objUnitPlansWrapper.strComments = 'Test Comment';
            objUnitPlansWrapper.dcmRenewalRent = 20000;
        }
        
        LeaseRentRenewalController.ResponseWrapper objResponseWrapper = LeaseRentRenewalController.saveUnits(JSON.serialize(listUnitPlansWrapper));
        
        Test.stopTest();
        
        system.assertEquals(objResponseWrapper.strMessage, 'success');
        
        List<Unit__c> listUnits = [SELECT Id, Renewal_Comments__c, Renewal_Rent__c FROM Unit__c];
        
        for(Unit__c objUnit : listUnits){
            system.assertEquals(objUnit.Renewal_Comments__c, 'Test Comment');
            system.assertEquals(objUnit.Renewal_Rent__c, 20000);
        }
    }
}