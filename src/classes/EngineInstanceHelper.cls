/*
* Author - Huzefa Tarwala
* Date - 20 Oct 2019
* Description - Class to create fields on target object, it is called when and engine instance is created.
*/
public class EngineInstanceHelper implements Queueable,Database.AllowsCallouts{
    public EngineInstanceHelper() {
        listEIID = new List<ID>();
    }
    public List<Id> listEIID;
    public List<Engine_Instance__c> listEI;
    public void execute(QueueableContext context) {
        try{
        listEI = [Select Assignment_Field_Name__c,Capacity_Treshold__c,Error_Log__c,Id,Matching_Rule_Field__c,MATCHING_RULE__c,SObject__c FROM Engine_Instance__c where id in:listEIID];
        for(Engine_Instance__c eiLoop : listEI){   
        String objectapiname = eiLoop.SObject__c;//replace with your object name
        String fieldapiname = eiLoop.Assignment_Field_Name__c.replace(' ','_');//replace with your field name
        String fieldlabel = eiLoop.Assignment_Field_Name__c;//replace with your field label
        String fielddescription = 'DO NOT DELETE OR EDIT, Created by Assignment Engine';//replace with your field label

        HttpRequest requestinside = new HttpRequest();
        requestinside.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
        requestinside.setHeader('Content-Type', 'application/json');
        requestinside.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm()+'/services/data/v41.0/tooling/sobjects/CustomField/');
        requestinside.setMethod('POST');
        String fieldDef = '{"Metadata" : ';
        String metadef = '"type" : "Lookup","description" : "'+fielddescription+'", "inlineHelpText" : "","label" : "'+fieldlabel+'","required" : false,"referenceTo":"Assignment_Resource__c","relationshipName":"'+objectapiname+'s1","deleteConstraint":"SetNull"';
        fieldDef += '{'+metadef+'},';
        fieldDef += '"FullName" : "'+objectapiname+'.'+fieldapiname+'__c"}';
        system.debug(fieldDef);
        requestinside.setBody(fieldDef);
        Http h = new Http();
        HTTPResponse res;
        if(!Test.isRunningTest()){
        res = h.send(requestinside);
        eiLoop.Error_Log__c =( eiLoop.Error_Log__c == null ? '': eiLoop.Error_Log__c) + ' \n'+Date.today()+': '+res.getBody();
        eiLoop.Assignment_Field_API__c = fieldapiname+'__c';
        System.debug(res.getBody());
        }

        //Assignment Time
        fieldapiname = 'Assignment_Time';
        fieldlabel = 'Assignment Time';//replace with your field label
        fieldDef = '{"Metadata" : ';
        metadef = '"type" : "DateTime","description" : "'+fielddescription+'", "inlineHelpText" : "","label" : "'+fieldlabel+'","required" : false';
        System.debug(metadef);
        fieldDef += '{'+metadef+'},';
        fieldDef += '"FullName" : "'+objectapiname+'.'+fieldapiname+'__c"}';
        system.debug(fieldDef);
        requestinside.setBody(fieldDef);
        if(!Test.isRunningTest()){
        res = h.send(requestinside);
        eiLoop.Error_Log__c = ( eiLoop.Error_Log__c == null ? '': eiLoop.Error_Log__c) + ' \n'+Date.today()+': '+res.getBody();
        }

        //Matching_Rule__c
        fieldapiname = eiLoop.Matching_Rule_Field__c.replace(' ','_');//replace with your field name
        fieldlabel = eiLoop.Matching_Rule_Field__c;//replace with your field label
        fieldDef = '{"Metadata" : ';
        metadef = '"type" : "Picklist","description" : "'+fielddescription+'", "inlineHelpText" : "","label" : "'+fieldlabel+'","required" : false,';
        String valueSet  = '"valueSet":{"restricted":"true","valueSetDefinition":{"value":[{"default":"true","label":"BEST_FIT","valueName":"2"},{"default":"false","label":"NONE","valueName":"1"},{"default":"false","label":"ALL","valueName":"3"}]}}';
        metadef = metadef + valueSet;
        System.debug(metadef);
        fieldDef += '{'+metadef+'},';
        fieldDef += '"FullName" : "'+objectapiname+'.'+fieldapiname+'__c"}';
        system.debug(fieldDef);
        requestinside.setBody(fieldDef);
        if(!Test.isRunningTest()){
        res = h.send(requestinside);
        System.debug(res.getBody());
        eiLoop.Error_Log__c = ( eiLoop.Error_Log__c == null ? '': eiLoop.Error_Log__c) + ' \n'+Date.today()+': '+res.getBody();
        }

        //Skip Assignment
        fieldapiname = 'Skip_Autoassign';//replace with your field name
        fieldlabel = 'Skip Autoassign';//replace with your field label
        fieldDef = '{"Metadata" : ';
        metadef = '"type" : "Checkbox","description" : "'+fielddescription+'", "inlineHelpText" : "","label" : "'+fieldlabel+'"';
        System.debug(metadef);
        fieldDef += '{'+metadef+'},';
        fieldDef += '"FullName" : "'+objectapiname+'.'+fieldapiname+'__c"}';
        system.debug(fieldDef);
        requestinside.setBody(fieldDef);
        if(!Test.isRunningTest()){
        res = h.send(requestinside);
        System.debug(res.getBody());
        eiLoop.Error_Log__c = ( eiLoop.Error_Log__c == null ? '': eiLoop.Error_Log__c) + ' \n'+Date.today()+': '+res.getBody();
        }


        
        }
        update listEI;
        }
        catch(Exception e){
            DebugUtility.logError(e);
        } 
    }
}