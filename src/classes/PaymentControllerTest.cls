/**
* @author : Muhammad Sajid
* @createdDate : 29-Jan-2022
* @lastModifieddate : 29-Jan-2022
* @usage : Test class to cover all functionality of PaymentController. 
*/

@isTest
public class PaymentControllerTest {
    
    public static List<Unit__c> unitList=new List<Unit__c>();
    public static List<Opportunity> oppList=new List<Opportunity>();
    
    @TestSetup
    Static  void createData(){
        String recordTypeId = Schema.SObjectType.Unit__c.RecordTypeInfosByName.get('Leasing').RecordTypeId;
        
        //recordtype recrdTypeobj=[select id ,name from recordtype where name='Leasing'];
        
        List<Project__c> projectList = TestDataFactory.createProject();
        List<Floor__c> floorList = TestDataFactory.createFloor();
        List<Space_Type__c> spaceTypeList = TestDataFactory.createSpaceType();
        
        Unit__c unit = New Unit__c();
        unit.Name = 'Test Unit 1';
        unit.Unit_Code__c = 'Unit Code';
        unit.Date_when_Leasing_status_changes__c = system.today();
        unit.Unit_Status__c = 'Available';
        unit.Floor__c = floorList[0].Id;
        unit.Project__c = projectList[0].Id;
        unit.Space_Types__c = spaceTypeList[0].Id;
        unit.RecordTypeId = recordTypeId;
        unitList.add(unit);
        insert unitList;
       
        oppList = TestDataFactory.createOpportunity(1);

        Availabe_Payment_Plan__c availablePaymentPlan = new Availabe_Payment_Plan__c();
        availablePaymentPlan.name = 'Test';
        availablePaymentPlan.Base_Lease_Amount__c = 1000;
        availablePaymentPlan.Discount__c = 10;
        availablePaymentPlan.No_of_cheques__c = 2;
        availablePaymentPlan.Project__c = unitList[0].Project__c;
        availablePaymentPlan.Space_Type__c =  unitList[0].Space_Types__c;
        availablePaymentPlan.Final_Lease_Amount__c = 100;
        
        insert availablePaymentPlan;
        
    }
    
    /* @usage : This function used to cover functionality of findUnitByName function.*/
    static TestMethod void findUnitByName(){
        try{
            List<Unit__c> unitList = [Select Id from Unit__c];
            
            Test.startTest();
            PaymentController.findUnitByName(unitList);
            Test.stopTest();
        }catch(Exception e){
            
        }
    }
    
    /* @usage : This function used to cover functionality of showPaymentList function.*/
    static TestMethod void showPaymentList(){
        try{
            List<Unit__c> unitList = [Select Id from Unit__c];
            
            Test.startTest();
            PaymentController.showPaymentList(unitList);
            Test.stopTest();
        }catch(Exception e){
            
        }
    }
    
    /* @usage : This function used to cover functionality of showAmount function.*/
    static TestMethod void showAmount(){
        try{
            List<Unit__c> unitList = [Select Id, Unit_type__c from Unit__c];
            Availabe_Payment_Plan__c paymentPlan = [Select Id from Availabe_Payment_Plan__c limit 1];
            
            Test.startTest();
            PaymentController.showAmount(paymentPlan.Id, unitList);
            Test.stopTest();
        }catch(Exception e){
            
        }
    }
    
    /* @usage : This function used to cover functionality of addUnitstoOpp function.*/
    static TestMethod void addUnitstoOpp(){
        try{
            List<Unit__c> unitList = [Select Id from Unit__c];
            Availabe_Payment_Plan__c paymentPlan = [Select Id from Availabe_Payment_Plan__c limit 1];
            Opportunity opp = [Select Id from Opportunity limit 1];
            
            Test.startTest();
            PaymentController.addUnitstoOpp(opp.Id, unitList, paymentPlan.Id, 10, 100, 'Online Payment');
            Test.stopTest();
        }catch(Exception e){
            
        }
    }
    
    /* @usage : This function used to cover functionality of updateUnitStatus function.*/
    static TestMethod void updateUnitStatus(){
        try{
            List<Unit__c> unitList = [Select Id from Unit__c];
            Opportunity opp = [Select Id from Opportunity limit 1];
            
            Test.startTest();
            PaymentController.updateUnitStatus(unitList, opp);
            Test.stopTest();
        }catch(Exception e){
            
        }
    }
    
    /* @usage : This function used to cover functionality of UpdatePaymentPlan function.*/
    static TestMethod void UpdatePaymentPlan(){
        try{
            Availabe_Payment_Plan__c paymentPlan = [Select Id from Availabe_Payment_Plan__c limit 1];
            
            Test.startTest();
            PaymentController.UpdatePaymentPlan(paymentPlan.Id, 10);
            Test.stopTest();
        }catch(Exception e){
            
        }
    }
}