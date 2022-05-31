/*
* Author - Huzefa Tarwala
* Date - 20 Oct 2019
* Description - Batch class where the magic happens, this class first check if engine is running in mode 1 and assigns in simple round robin fashion. Else it forwards
* the records to child class for Mode 2 and 3.
*/
public class AssignmentEngineInstance implements Database.Batchable<SObject> {

    String query;
 
    public Id engineInstanceID;
    public Engine_Instance__c engineInstance;

    public AssignmentEngineInstance(Id engineInstanceID) {
        this.engineInstanceID = engineInstanceID;
        system.debug(engineInstanceID);
        engineInstance = [Select id,Assign_To_Custom_Field__c,Closing_Criteria_Field__c,Filter_Query__c,Active__c,Closing_Criteria_Field_Value__c,Assignment_Field_Name__c,Capacity_Treshold__c,MATCHING_RULE__c,Skill_Fields_API__c,SObject__c,Assignment_Field_API__c,Enable_Logging__c from Engine_Instance__c where id=:this.engineInstanceID];
        query = 'Select id,OwnerID,Assignment_Time__c,Matching_Rule__c,'+engineInstance.Skill_Fields_API__c +','+engineInstance.Assignment_Field_API__c +' from ' + engineInstance.SObject__c  +' where '+engineInstance.Assignment_Field_API__c+'=null AND Skip_Autoassign__c = FALSE';
        if(!String.isBlank(engineInstance.Filter_Query__c)){
        query = query + ' and '+engineInstance.Filter_Query__c;
        }
        System.debug(query);
    }
    
    // Query leads which are unassigned
    /*public List<SObject> start(Database.BatchableContext BC) {
        try{
        return Database.query(query); 
        }
        catch(Exception e){
            if(Test.isRunningTest())
            return Database.query('Select id,Assigned_Resource__c,Matching_Rule__c,LeadSource,Industry from Lead');
        }
       // if(Test.isRunningTest())
        return Database.query('Select id,Assigned_Resource__c,Matching_Rule__c,LeadSource,Industry from Lead');*/
    public List<SObject> start(Database.BatchableContext BC) {
        List<SObject> unaasignedRecords = new List<SObject>();
        system.debug('Exxecute query'+query);
        try{
            unaasignedRecords = Database.query(query);
        }
        catch(Exception e){
            system.debug('Exception'+e);
        }
        system.debug('unaasignedRecords'+unaasignedRecords);
        return unaasignedRecords;
}
    
    
    /* Author : Huzefa
    * Date : 20 Oct 2019
    * Description: Check for all records where workitem is pending and decrease capacity and 
    * increase workload of assigned resource and assign.
    */
    public void execute(Database.BatchableContext BC, List<Sobject> scope) {
        try{
            system.debug('scope'+scope);
            List<SObject> unassignedRecords = new List<SObject>();  
            String resourceQuery =   'Select id,Skill_Mapping__c,user__c,user__r.id,isOn_Leave__c,Workload__c,Utilization__c, Capacity__c from Assignment_Resource__c where isOn_Leave__c = false and isActive__c = true and Engine_Instance__c =:engineInstanceID and User__r.isActive=true'; 
            if(engineInstance.Capacity_Treshold__c != null){ 
                Decimal treshold = engineInstance.Capacity_Treshold__c;
                resourceQuery = resourceQuery + ' and Utilization__c < :treshold';
            } 
            resourceQuery = resourceQuery + ' ORDER BY Utilization__c ASC';
            List<Assignment_Resource__c> listSalesResources = Database.query(resourceQuery);
            system.debug(listSalesResources);
            List<Sobject> listassignedRR = new List<SObject>();
            Iterator<Assignment_Resource__c> iter = listSalesResources.iterator();
            
            for(SObject objLoop : scope){
                if((objLoop.get('MATCHING_RULE__c') == '1' && engineInstance.MATCHING_RULE__c == 1)){
                    listassignedRR.add(objLoop);
                    system.debug('objLoop'+objLoop);
 //               if((objLoop.get('MATCHING_RULE__c') == 'NONE' && AssignmentEngineSettings__c.getInstance(userinfo.getUserId()).MATCHING_RULE__c == 'NONE')){    
                    if(iter.hasNext()){
                        Assignment_Resource__c res = iter.next();
                        res.Workload__c++;
                        objLoop.put('Assigned_Resource__c', res.id);
                        //objLoop.put('OwnerID',res.User__r.id);
                        if(String.IsBlank(engineInstance.Assign_To_Custom_Field__c)){
                            objLoop.put('OwnerID',res.User__c);
                        }
                        else{
                            objLoop.put(engineInstance.Assign_To_Custom_Field__c,res.User__c); 
                        }
                        objLoop.put('Assignment_Time__c',System.now());
                    }
                    else{
                        iter = listSalesResources.iterator();
                        Assignment_Resource__c res = iter.next();
                        res.Workload__c++;
                        objLoop.put('Assigned_Resource__c', res.id);
                        //objLoop.put('OwnerID',res.User__r.id);
                        if(String.IsBlank(engineInstance.Assign_To_Custom_Field__c)){
                            objLoop.put('OwnerID',res.User__c);
                        }
                        else{
                            objLoop.put(engineInstance.Assign_To_Custom_Field__c,res.User__c); 
                        }
                        objLoop.put('Assignment_Time__c',System.now());
                    }
                }
                else{
                    unassignedRecords.add(objLoop);
                }  
            }
            system.debug(scope);
            update scope;
            update listSalesResources;

            //Check if logging enabled on engine instance if true then log as attachement.
            if(engineInstance.Enable_Logging__c){
                JSONGenerator gen;
                gen = JSON.createGenerator(true);
                String jsonString = JSON.serialize(listassignedRR);
                System.debug(jsonString);
               // jsonString.replaceAll('[', '*');
               // jsonString.replaceAll(']', '*');
                ContentVersion conVer = new ContentVersion();
                conVer.ContentLocation = 'S'; // S specify this document is in SF, use E for external files
                DateTime currenttime = DateTime.now();
                String formattedTime = currenttime.formatGMT('yyMMddHHmmss');
                conVer.PathOnClient = formattedTime+'.txt'; // The files name, extension is very important here which will help the file in preview.
                conVer.Title = formattedTime+' Log'; // Display name of the files
                //conVer.VersionData = EncodingUtil.base64Decode(jsonString); // converting your binary string to Blog
                conVer.VersionData = Blob.valueOf(jsonString);
                insert conVer;
                Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
                //Create ContentDocumentLink
                ContentDocumentLink cDe = new ContentDocumentLink();
                cDe.ContentDocumentId = conDoc;
                cDe.LinkedEntityId = engineInstance.Id; // you can use objectId,GroupId etc
                cDe.ShareType = 'V'; // Inferred permission, checkout description of ContentDocumentLink object for more details
                cDe.Visibility = 'AllUsers';
                insert cDe;
             }
             system.debug('unassignedRecords==>'+unassignedRecords);
            if(unassignedRecords.size()>0){
                AssigmentSkillMatch.matchRecordtoSkill(unassignedRecords,engineInstance);
            }
        }
        
        catch(Exception e){
            DebugUtility.logError(e);
        }
    }
    
    /* Author : Huzefa
    * Date : 27 Oct 2019
    * Description: Check for all records where workitem is completed and increase capacity and 
    * decrease workload of assigned resource and unassign.
    */
    public void finish(Database.BatchableContext BC) {        
        try{
            if(engineInstance.Active__c){
            //    database.executebatch(new AssignmentEngineInstance());
            }
            String assignmentField = engineInstance.Assignment_Field_API__c;
            String closingQuery = 'Select id,'+assignmentField+','+engineInstance.Closing_Criteria_Field__c+ ' from '+engineInstance.SObject__c+' where '+engineInstance.Closing_Criteria_Field__c+ '=\''+engineInstance.Closing_Criteria_Field_Value__c +'\' and '+engineInstance.Assignment_Field_API__c+' !=null';
            System.debug('closing query' + closingQuery);
            Map<id,Integer> mapAssignedResource = new Map<id,Integer>();
            List<Assignment_Resource__c> listUpdatedResource;
            List<Sobject> listCommpletedItems = Database.query(closingQuery);
            if(listCommpletedItems.size()>0){
            System.debug('Work closed');
            Integer i =0;
            for(SObject objectLoop : listCommpletedItems){
                if(mapAssignedResource.containsKey((Id)objectLoop.get(assignmentField))){

                    i= mapAssignedResource.get((Id)objectLoop.get(assignmentField));
                    i++;
                    mapAssignedResource.put((Id)objectLoop.get(assignmentField), i);
                }
                else{
                    i=1;
                    mapAssignedResource.put((Id)objectLoop.get(assignmentField), i);
                }
                objectLoop.put(assignmentField,'');    
            }
            listUpdatedResource = [Select id,Workload__c,Capacity__c from Assignment_Resource__c where id in :mapAssignedResource.keySet()];
            for(Assignment_Resource__c resource:listUpdatedResource){
                resource.Workload__c =  resource.Workload__c-mapAssignedResource.get(resource.id);   
            }
            update listUpdatedResource;
            update listCommpletedItems;
            }
        }
        catch(Exception e){
            DebugUtility.logError(e);
        }    
    }   
}