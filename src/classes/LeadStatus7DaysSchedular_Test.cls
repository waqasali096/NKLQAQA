/**
* Class Name: LeadStatus7DaysSchedular_Test
* Class Description: test class for the LeadStatus7DaysSchedular class                                          
*/
@isTest
public class LeadStatus7DaysSchedular_Test {
	@isTest
    public static void testSchedule(){
        System.Test.StartTest();
		LeadStatus7DaysSchedular sh1 = new LeadStatus7DaysSchedular();

		String sch = '0 0 23 * * ?'; 
        system.schedule('Test Territory Check', sch, sh1); 
        System.Test.stopTest();
    }
}