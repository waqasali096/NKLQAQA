@isTest
public class ResourceSkillExtensionTest {

    @isTest static void ResourceSkillExtensiontest(){
        
        Engine_Instance__c EngineInstance = new Engine_Instance__c();
        EngineInstance.Closing_Criteria_Field_Value__c='Qualified';
        EngineInstance.Closing_Criteria_Field__c='Status';
        EngineInstance.SObject__c='Lead';
        EngineInstance.MATCHING_RULE__c =3;
        EngineInstance.Assignment_Field_API__c = 'Assigned_Resource__c';
        EngineInstance.Enable_Logging__c=true;
        EngineInstance.Error_Log__c='test';
        EngineInstance.Skill_Fields_API__c='Industry,LeadSource';
        insert EngineInstance;
        
        
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User u = new User(
                username = 'testkk@tst.com.emaar.cloudworks',
                Email = 'test@test.com',
                FirstName = 'test',
                LastName = 'tets',
                Alias = 'test',
                EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US', ProfileId = p.Id,
                TimeZoneSidKey = 'America/Los_Angeles');
        insert u; 
        
        Assignment_Resource__c ar1 = new Assignment_Resource__c();
        ar1.User__c = u.id;
        ar1.Engine_Instance__c = EngineInstance.id;
        ar1.Workload__c=0;
        //ar1.Skill_Mapping__c='{"Industry" : "Agriculture","LeadSource" : "Web"}';
        insert ar1;
        
        Lead NewLead = new Lead();
        NewLead.LastName = 'TestLead';
        //NewLead.Matching_Rule__c = '3';
        NewLead.Industry='Agriculture';
        NewLead.LeadSource='Web';
        NewLead.COmpany = 'TEST';
        NewLead.Assigned_Resource__c=ar1.id;
        NewLead.email = 'huzefa@cloudworks.ae';
        insert NewLead;
        
        PageReference pageRef = Page.ResourceSkill;
    Test.setCurrentPage(pageRef);
        
    pageRef.getParameters().put('Id', String.valueOf(ar1.Id));
    ApexPages.StandardController sc = new ApexPages.StandardController(ar1);
        
        Test.startTest();
        
    ResourceSkillExtension rs = new ResourceSkillExtension(sc);
        rs.save();
        
        ar1.Skill_Mapping__c='{"Industry" : "Agriculture","LeadSource" : "Web"}';
        update ar1;
        ResourceSkillExtension rs1 = new ResourceSkillExtension(sc);
        rs1.save();
        
        ar1.Engine_Instance__c = null;
        update ar1;
        ResourceSkillExtension rs2 = new ResourceSkillExtension(sc);
        rs2.save();
        
        ApexPages.StandardController sc1 = new ApexPages.StandardController(NewLead);
        ResourceSkillExtension rs3 = new ResourceSkillExtension(sc1);
        rs3.save();
        
        Test.stopTest();
    }
}