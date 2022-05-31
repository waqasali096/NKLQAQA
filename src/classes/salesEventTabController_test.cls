/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-28-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class salesEventTabController_test {
    
    /** 
       	* @createdDate : 17 March 2022  
		* @author : Ashok Kumar Nayak
		* @Version : V1
		* @usage : This function testify the code coverage for the below methods of salesEventTabController
                   getUnitOptionsAndMasterOptionData
                   createUnitOptionsData
	**/
    @isTest
    public static void testgetAndCreateUnitOptionsAndMasterOptionData(){
          
        //List<User> adminUserList = TestDataFactory.createUsers(1,userinfo.getProfileId());
        List<String> selectedUnitIdList = new List<String>();
        Map<String,Integer> typeAndNumOfRecordsToCreateMap = new Map<String,Integer>();
        System.runAs(new user(ID = UserInfo.getUserID())) {
                Test.startTest();
                    //creating sample units
                    List<Unit__c> unitDataList = TestDataFactory.createUnit();
                    system.assertNotEquals(unitDataList, null);

                    for(Unit__c unit : unitDataList) {
                        selectedUnitIdList.add(unit.Id);
                    }
                    system.assertNotEquals(selectedUnitIdList, null);

                    //creating master options
                    typeAndNumOfRecordsToCreateMap.put('Free',10);
                    typeAndNumOfRecordsToCreateMap.put('Paid',10);
                    List<Master_Option__c> masterOptionDataList = TestDataFactory.createBulkMasterOption(typeAndNumOfRecordsToCreateMap,true);
                    system.assertEquals(20, masterOptionDataList.size());

                    //calling the controller method to get the Master Options
                    salesEventTabController.UnitOptionWrapperDataList optionsData = salesEventTabController.getUnitOptionsAndMasterOptionData('fromInventoryWizard');
                    system.assertNotEquals(optionsData.columnList, null);
                    system.assertNotEquals(optionsData.masterOptionsDataWrapper, null);

                    //calling the controller method to create unit options
                    String status = salesEventTabController.createUnitOptionsData(JSON.serialize(optionsData.masterOptionsDataWrapper),selectedUnitIdList);
                    system.assertEquals('SUCCESS', status);

                Test.stopTest();
        }
    }
    
}