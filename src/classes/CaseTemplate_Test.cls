@isTest
public class CaseTemplate_Test {
    
   @isTest
    public static void testCaseTemplate(){
        List<case> contractList = TestDataFactory.createCase(1);
        CaseTemplate ct = new CaseTemplate();
        
        ct.getServiceRequest();
    }

}