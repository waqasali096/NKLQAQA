/****************************************************************************************************************************
* @Name         CreateQuickOppControllerTest
* @Author       Kaustubh Abhyankar
* @Date         27-April-2022
* @Description  Test Class for CreateQuickOppController
****************************************************************************************************************************/

@isTest
public class CreateQuickOppControllerTest {
    //Testing Method - getQuickOppDefaultValue
    @isTest
    public static void getQuickOppDefaultValueTest(){
        Map<String,Object> oppMap = CreateQuickOppController.getQuickOppDefaultValue();
    }
    
    //Testing Method - fetchProjects
    @isTest
    public static void fetchProjectsTest(){
        List<Project__c> pList = CreateQuickOppController.fetchProjects();
    }
    
    //Testing Method - createOpps
    @isTest
    static void createOppsTest() {
        String strJson1 = '{"Name":"Opportunity 2 Name","CloseDate":"03122020","Amount":3000},{"Name": "Opportunity 3 Name","CloseDate":"12062020","Amount":800}';
        CreateQuickOppController.ResultWrapper rWrap = CreateQuickOppController.createOpps(strJson1);
    }
}