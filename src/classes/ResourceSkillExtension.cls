/*
* Author - Huzefa Tarwala
* Date - 20 Oct 2019
* Description - Extension class for ResourceSkill page, this controller assigns skills to resources against fields that will be matched on target object.
*/

public class ResourceSkillExtension {
    
    
    public ResourceSkillExtension(ApexPages.StandardController controller) {
        try{
        skills = new Map<String,String>();
        salesResource = (Assignment_Resource__c)controller.getRecord();
        salesResourceController = [Select id,Engine_Instance__c from Assignment_Resource__c where id=:salesResource.id];
        if(null != salesResourceController.Engine_Instance__c)
        engineInstance = [Select id,name,Skill_Fields_API__c,SObject__c from Engine_Instance__c where id=:salesResourceController.Engine_Instance__c];
        
        if(null != engineInstance){
        JSONGenerator gen;

        gen = JSON.createGenerator(true);
        if(String.isBlank(salesResource.Skill_Mapping__c)){
            gen.writeStartObject();

            for(String fieldName : engineInstance.Skill_Fields_API__c.split(',')){
                gen.writeStringField(fieldName,'');
            }
            gen.writeEndObject();
            salesResource.Skill_Mapping__c = gen.getAsString();
            System.debug(salesResource.Skill_Mapping__c+ '1');
            skills = (Map<String,String>)JSON.Deserialize(salesResource.Skill_Mapping__c, Map<String,String>.class);
        }
        else{
            System.debug(salesResource.Skill_Mapping__c + '2');
            skills = (Map<String,String>)JSON.Deserialize(salesResource.Skill_Mapping__c, Map<String,String>.class);
        }
        }
        else{
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,'Please update skill fields on the Engine Instance for this resource'));

        }
        }
        catch(Exception e){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,e.getMessage()));
            DebugUtility.logError(e);
        }
        
    }
    
    public void save(){
        try{
        if(null != engineInstance){    
        JSONGenerator gen;
        gen = JSON.createGenerator(true);
        gen.writeStartObject();
        System.debug(skills);
        Map<String, Schema.SobjectField> fieldMap = Schema.getGlobalDescribe().get(engineInstance.SObject__c).getDescribe().fields.getMap();
        for(String skillField : engineInstance.Skill_Fields_API__c.split(',')){
            
            if(!String.isBlank(skills.get(skillField))){
                if(fieldMap.get(skillField).getDescribe().getType() == DisplayType.Currency){
                    gen.writeNumberField(skillField, Decimal.valueOf(skills.get(skillField)));
                }
                else if(fieldMap.get(skillField).getDescribe().getType() == DisplayType.Double){
                    gen.writeNumberField(skillField, Decimal.valueOf(skills.get(skillField)));
                }
                else if(fieldMap.get(skillField).getDescribe().getType() == DisplayType.Date){
                    gen.writeDateField(skillField, Date.valueOf(skills.get(skillField) ));
                }
                else{
                    gen.writeStringField(skillField, (String)skills.get(skillField) );
                }
            }
            else{
                gen.writeStringField(skillField,'');
            }         
            
        }
        gen.writeEndObject();
        salesResource.Skill_Mapping__c = gen.getAsString();
        update salesResource;
        System.debug(salesResource.Skill_Mapping__c);
        }
        else{
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,'Please update skill fields on the Engine Instance for this resource'));              
        }
        }
        catch(Exception e){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,e.getMessage()));
            DebugUtility.logError(e);
        }
    }
    public Engine_Instance__c engineInstance{get;set;}
    public Assignment_Resource__c salesResource{get;set;}
    public Assignment_Resource__c salesResourceController;
    public Map<String,String> skills{get;set;}
    public String skillJSON;
    
}