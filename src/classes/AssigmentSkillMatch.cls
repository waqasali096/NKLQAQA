/*
Author - Huzefa - CW
Date - 15 Oct 2019
Description - Class to assign leads to sales resources in BEST and all skill match fashion while cheking their leaves 
*/
public class AssigmentSkillMatch {

    public AssigmentSkillMatch() {
        
    }
    
    public static void matchRecordtoSkill(List<SObject> unassignedRecords, Engine_Instance__c engineInstance){
        System.debug('In matching engine');
        Id engineInstanceID = engineInstance.id;
        String bestResourceDebug = '';
        String resourceQuery =   'Select id,Skill_Mapping__c,user__c,isOn_Leave__c,Workload__c, Capacity__c,Utilization__c,Utilization_Score__c from Assignment_Resource__c where isOn_Leave__c = false and isActive__c = true and Engine_Instance__c =:engineInstanceID and User__r.isActive=true';
        if(engineInstance != null){
            Decimal treshold = engineInstance.Capacity_Treshold__c;
            resourceQuery = resourceQuery + ' and Utilization__c < :treshold';
        } 
        resourceQuery = resourceQuery + ' ORDER BY Utilization__c ASC';
        List<Assignment_Resource__c> listAvailResources = Database.query(resourceQuery);
        system.debug(listAvailResources);
        List<ScoreWrapper> listAssignedResourceWrapper = new List<ScoreWrapper>();
        for(Assignment_Resource__c res: listAvailResources){
            listAssignedResourceWrapper.add(new ScoreWrapper(res));
        }
        
        ScoreWrapper wrapper;
        for(SObject record : unassignedRecords){
            system.debug('Before sort' + listAssignedResourceWrapper);  
            listAssignedResourceWrapper.sort();
            system.debug('after sort' + listAssignedResourceWrapper);
            String runningMode = String.valueOf(engineInstance.MATCHING_RULE__c);
           
            if(Integer.valueOf(runningMode) < Integer.valueOf(record.get('Matching_Rule__c'))){

                runningMode = (String)record.get('Matching_Rule__c');

            }
           /*
            if(runningMode !='NONE' || runningMode!=(String)record.get('Matching_Rule__c')){

                runningMode = (String)record.get('Matching_Rule__c');

            } 
             System.debug(runningMode +'runningMode'); */
            switch on runningMode {
                when '2'  {
                    System.debug('running mode' + ' BEST_FIT');
                    Decimal bestScore = 0;
                    Assignment_Resource__c bestResource = listAssignedResourceWrapper[0].resource;
                    system.debug('bestResource'+bestResource);
                    for(ScoreWrapper resourceLoop : listAssignedResourceWrapper){
                        wrapper = resourceLoop;
                        wrapper.score = 0;
                        wrapper.score = wrapper.resource.Utilization_Score__c + wrapper.score;
                        Map<String,String> skills = (Map<String,String>)JSON.Deserialize(resourceLoop.resource.Skill_Mapping__c, Map<String,String>.class);
                        System.debug(skills +' '+ record.get('id') +'   '+ wrapper.resource.id);
                        for(String skillField:skills.keySet()){
                            if(null!=record.get(skillField)){
                            if(String.valueOf(record.get(skillField)).contains(skills.get(skillField))){
                                wrapper.score++;
                            }
                            }
                            system.debug('required score'+wrapper.score);
                            if(bestScore <wrapper.score){
                                bestScore = wrapper.score;
                                bestResource = wrapper.resource;
                                system.debug('best score'+wrapper.score);
                            }
                        }      
                    }
                    
                    record.put('Assigned_Resource__c' ,bestResource.id);
                    if(String.IsBlank(engineInstance.Assign_To_Custom_Field__c)){
                        record.put('OwnerID',bestResource.User__c);
                    }
                    else{
                        record.put(engineInstance.Assign_To_Custom_Field__c,bestResource.User__c); 
                    }
                    
                    record.put('Assignment_Time__c',System.now());
                    bestResource.workload__c++;
                    bestResource.recalculateFormulas();
                }
                when '3'{
                    System.debug('running mode' + ' ALL');
                    Assignment_Resource__c bestResource = listAssignedResourceWrapper[0].resource;
                    for(ScoreWrapper resourceLoop : listAssignedResourceWrapper){
                        wrapper = resourceLoop;
                        wrapper.score = 0;
                        Integer requiredScore = 0;
                        Map<String,String> skills = (Map<String,String>)JSON.Deserialize(resourceLoop.resource.Skill_Mapping__c, Map<String,String>.class);
                        for(String skillField:skills.keySet())
                        {
                            system.debug('skillField'+skillField);
                            if(!String.isBlank((String)record.get(skillField))){
                                bestResourceDebug = bestResourceDebug + ' 1 record value' + (String)record.get(skillField);
                                requiredScore++;
                            }
                            system.debug('required score'+requiredScore);
//                            if(null!=record.get(skillField) && String.valueOf(record.get(skillField)).contains(skills.get(skillField))){
                             if(null!=record.get(skillField) && skills.get(skillField).contains(String.valueOf(record.get(skillField)))){
                                 bestResourceDebug = bestResourceDebug + ' 2 skill value' + skills.get(skillField); 
                                wrapper.score++;
                                
                            }
                        }
                        if(requiredScore <= wrapper.score){
                            bestResource = wrapper.resource;
                            record.put('Assigned_Resource__c' ,bestResource.id);
                            if(String.IsBlank(engineInstance.Assign_To_Custom_Field__c)){
                                record.put('OwnerID',bestResource.User__c);
                            }
                            else{
                                record.put(engineInstance.Assign_To_Custom_Field__c,bestResource.User__c); 
                            }
                            record.put('Assignment_Time__c',System.now());
                            bestResource.workload__c++;
                            bestResource.recalculateFormulas();
                            break;
                        }      
                    }
                }
            }   
        }
        update listAvailResources;
        update unassignedRecords;
        //Check if logging enabled on engine instance if true then log as attachement.
        if(engineInstance.Enable_Logging__c){
            JSONGenerator gen;
            gen = JSON.createGenerator(true);
            String jsonString = JSON.serialize(unassignedRecords);
           // jsonString.replaceAll('[', '(');
           // jsonString.replaceAll(']', ')');
            ContentVersion conVer = new ContentVersion();
            conVer.ContentLocation = 'S'; // S specify this document is in SF, use E for external files
            DateTime currenttime = DateTime.now();
            String formattedTime = currenttime.formatGMT('yyMMddHHmmss');
            conVer.PathOnClient = formattedTime+'.txt'; // The files name, extension is very important here which will help the file in preview.
            conVer.Title = formattedTime+' Log'; // Display name of the files
            //conVer.VersionData = EncodingUtil.base64Decode(jsonString); // converting your binary string to Blog

            conVer.VersionData = Blob.valueOf(jsonString  + '  resource'+bestResourceDebug );
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
    }
    /*
    * Author - Huzefa Tarwala
    * Date - 20 Oct 2019
    * Description - Comparable class to compare and sort during round robin assignment based on utilization.
    */
    public class ScoreWrapper implements Comparable{
        public Decimal score;
        public Assignment_Resource__c resource;
        
        public ScoreWrapper(Assignment_Resource__c res){
            resource = res;
        }
              
        public Integer compareTo(Object compareTo) {
            // Cast argument to OpportunityWrapper
            ScoreWrapper compareToResource = (ScoreWrapper)compareTo;
            
            // The return value of 0 indicates that both elements are equal.
            Integer returnValue = 0;
            if (resource.Utilization__c > compareToResource.resource.Utilization__c) {
                // Set return value to a positive value.
                returnValue = 1;
            } else if (resource.Utilization__c < compareToResource.resource.Utilization__c) {
                // Set return value to a negative value.
                returnValue = -1;
            }
            return returnValue;       
        }
    }
 
}