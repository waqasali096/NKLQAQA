public class AssignmentEngineController {
    /**
* Method Name: assignOnwer
* Method Description: Assign lead owner in round robin and nationality and language
* @param: instanceList - List of engine instance  records to pass instance id to batch class
* * @return: Void                                           
*/
    public static void assignOnwer(Id engineInstanceID,List<Lead> leadList){
        Savepoint sp = Database.setSavepoint();
        List<Lead> leadListUpdate = new List<Lead>();
        List<Lead_Assignment_Engine__c> LeadCustomList = new List<Lead_Assignment_Engine__c>();
        List<Lead_Assignment_Engine__c> LeadCustomvaluesList = Lead_Assignment_Engine__c.getall().values();
        Set<String> nationalityName = new  Set<String>();
        Set<String> languageName = new  Set<String>();
        Map<String,String> leadNL = new Map<string,String>();
        Map<String,List<String>> assignedResourceNL = new Map<string,List<String>>();
        List<String> userId = new List<String>();
        Map<Id,Integer> mapCapId = new Map<Id,Integer>();
        Map<Id,Integer> mapDevCapId = new Map<Id,Integer>();
        Map<Id,Id> UserIdVsAssgId = new Map<Id,Id>();
        Map<Id,Integer> mapCapIdskill = new Map<Id,Integer>();
        Map<Id,Integer> mapDevCapIdskill = new Map<Id,Integer>();
        Map<Id,Id> UserIdVsAssgIdskill = new Map<Id,Id>();
        List<String> userlistLead = new List<String>();
        List<Assignment_Resource__c> assignedResorceListUpdate = new List<Assignment_Resource__c>();
        List<String> langValues = new List<String>();
        Map<Id,List<String>> assignedIdVsLang = new Map<Id,List<String>>();
        List<Assignment_Resource__c> assignedResorceListSkills = new List<Assignment_Resource__c>();
        List<Assignment_Resource__c> assignedResorceListc = [select id,Dev_Capacity__c,Capacity__c,Engine_Instance__c,user__c,Nationality__c,Language__c from Assignment_Resource__c where   isOn_Leave__c = false and isActive__c = true and Engine_Instance__c =:engineInstanceID and User__r.isActive=true];
        
        List<Assignment_Resource__c> assignedResorceList = new List<Assignment_Resource__c>();
        for(Assignment_Resource__c asg : assignedResorceListc){
            if(asg.Dev_Capacity__c <> asg.Capacity__c){
                assignedResorceList.add(asg);
            }
        }
        
        if(assignedResorceList <> null && assignedResorceList.size() > 0){
            String skillLead = '';
            String skillAssigned = '';
            
            for(Lead lObj : leadList){
                if(lObj.Nationality__c <> null && lObj.Language__c <> null){
                    nationalityName.add(lObj.Nationality__c);
                    languageName.add(lObj.Language__c);
                    skillLead = lObj.Nationality__c+ '-' +lObj.Language__c;
                    leadNL.put(skillLead,lObj.Id);
                }
            }
            
            for(Assignment_Resource__c assigned : assignedResorceList){
                mapCapId.put(assigned.User__c,Integer.valueOf(assigned.Capacity__c));
                mapDevCapId.put(assigned.User__c,Integer.valueOf(assigned.Dev_Capacity__c));
                UserIdVsAssgId.put(assigned.User__c,assigned.Id);
                if(assigned.Language__c <> null){
                    if(assigned.Language__c.contains(';')){
                        langValues = assigned.Language__c.split(';'); 
                    }else{
                        langValues.add(assigned.Language__c); 
                    }
                }
                assignedIdVsLang.put(assigned.User__c,langValues);
                
            } 
            
            
            if(nationalityName <> null && languageName <> null){
                // assignedResorceListSkills = [select id,Dev_Capacity__c,Capacity__c,Engine_Instance__c,user__c,Nationality__c,Language__c from Assignment_Resource__c where id IN: assignedResorceList AND Language__c IN:languageName AND Nationality__c IN: nationalityName];
                
            }
            //If Lead with nationality and language
            if(!nationalityName.isEmpty()  && !languageName.isEmpty()){
                
                for(Assignment_Resource__c assigned : assignedResorceList){
                    mapCapIdskill.put(assigned.User__c,Integer.valueOf(assigned.Capacity__c));
                    mapDevCapIdskill.put(assigned.User__c,Integer.valueOf(assigned.Dev_Capacity__c));
                    UserIdVsAssgIdskill.put(assigned.User__c,assigned.Id);  
                }
                List<String> lanList = new List<String>(); 
                String  skillAssigned1;
                String skillAssigned2;
                String skillAssigned3;
                for(Assignment_Resource__c assigned : assignedResorceList){
                    if(assigned.Language__c <> null){
                    if(assigned.Language__c.contains(';')){
                        lanList = assigned.Language__c.split(';'); 
                        skillAssigned = assigned.Nationality__c+ '-' +lanList[0];
                        skillAssigned1 = assigned.Nationality__c+ '-' +lanList[1];
                        
                        if(lanList.size() >= 3){
                            skillAssigned2 = assigned.Nationality__c+ '-' +lanList[2];
                        }
                        if(lanList.size() >= 4){
                            skillAssigned3 = assigned.Nationality__c+ '-' +lanList[3];
                        }
                        assignedResourceNL.put(skillAssigned, new List<String>{assigned.User__c});
                        assignedResourceNL.put(skillAssigned1, new List<String>{assigned.User__c});
                        assignedResourceNL.put(skillAssigned2, new List<String>{assigned.User__c});
                    }else{
                        skillAssigned = assigned.Nationality__c+ '-' +assigned.Language__c;
                        if(!assignedResourceNL.containsKey(skillAssigned)){
                            
                            assignedResourceNL.put(skillAssigned, new List<String>{assigned.User__c});
                            
                            
                        }else{
                            
                            assignedResourceNL.get(skillAssigned).add(assigned.User__c);
                            
                        }
                    }
                    }
                    
                }
                
                
                for(Lead ledObj : leadList){
                    Assignment_Resource__c assigne = new Assignment_Resource__c();
                    String   skillLAssigned = ledObj.Nationality__c+ '-' +ledObj.Language__c;
                    if(assignedResourceNL.containsKey(skillLAssigned)){
                        userlistLead = assignedResourceNL.get(skillLAssigned);
                        Lead leadUpdate = new Lead();
                        
                        if(userlistLead.size() > 0){
                            
                            Integer userIndex;
                            Integer groupMemberSize;
                            groupMemberSize = userlistLead.size();
                            userIndex = (LeadCustomvaluesList[0].get('User_Index__c') == null || Integer.valueOf(LeadCustomvaluesList[0].get('User_Index__c')) < -1)
                                ? -1 : Integer.valueOf(LeadCustomvaluesList[0].get('User_Index__c'));
                            Integer LeadUserIndex = (userIndex + 1) >= groupMemberSize ? 0 : userIndex + 1;
                            if(mapCapIdskill.containsKey(userlistLead[LeadUserIndex]) && mapDevCapIdskill.containsKey(userlistLead[LeadUserIndex]) &&  UserIdVsAssgIdskill.containsKey(userlistLead[LeadUserIndex])){
                                Integer cap = mapCapIdskill.get(userlistLead[LeadUserIndex]);
                                Integer devcap = mapDevCapIdskill.get(userlistLead[LeadUserIndex]);
                                if(devcap < cap){
                                    
                                    assigne.Dev_Capacity__c =  devcap + 1; 
                                    assigne.Id = UserIdVsAssgIdskill.get(userlistLead[LeadUserIndex]);
                                    leadUpdate.OwnerId = userlistLead[LeadUserIndex];
                                    leadUpdate.Id = ledObj.Id;
                                    userIndex = LeadUserIndex;
                                    LeadCustomvaluesList[0].User_Index__c= userIndex;
                                    leadListUpdate.add(leadUpdate);
                                    LeadCustomList.add(LeadCustomvaluesList[0]);
                                    assignedResorceListUpdate.add(assigne);
                                }
                            }
                        }
                    }else{
                        //Round Robin Logic
                        Assignment_Resource__c assigner = new Assignment_Resource__c();
                        Lead led = new Lead();
                        Integer userIndex;
                        Integer groupMemberSize;
                        groupMemberSize = assignedResorceList.size();
                        
                        userIndex = (LeadCustomvaluesList[0].get('User_Index__c') == null || Integer.valueOf(LeadCustomvaluesList[0].get('User_Index__c')) < -1)
                            ? -1 : Integer.valueOf(LeadCustomvaluesList[0].get('User_Index__c'));
                        Integer LeadUserIndex = (userIndex + 1) >= groupMemberSize ? 0 : userIndex + 1;
                        system.debug('c'+assignedResorceList[LeadUserIndex].User__c);
                        if(mapCapId.containsKey(assignedResorceList[LeadUserIndex].User__c) && mapDevCapId.containsKey(assignedResorceList[LeadUserIndex].User__c) &&  UserIdVsAssgId.containsKey(assignedResorceList[LeadUserIndex].User__c)){
                            Integer cap = mapCapId.get(assignedResorceList[LeadUserIndex].User__c);
                            Integer devcap = mapDevCapId.get(assignedResorceList[LeadUserIndex].User__c);
                            if(devcap < cap){
                                
                                assigner.Dev_Capacity__c =  devcap + 1; 
                                assigner.Id = UserIdVsAssgId.get(assignedResorceList[LeadUserIndex].User__c);
                                led.OwnerId = assignedResorceList[LeadUserIndex].User__c;
                                led.Id = ledObj.Id;
                                userIndex = LeadUserIndex;
                                LeadCustomvaluesList[0].User_Index__c= userIndex;
                                leadListUpdate.add(led);
                                LeadCustomList.add(LeadCustomvaluesList[0]);
                                assignedResorceListUpdate.add(assigner);
                            }
                        }
                    }
                }
            }else{
                for(Lead ledObj : leadList){
                    
                    Assignment_Resource__c assigner = new Assignment_Resource__c();
                    Lead led = new Lead();
                    Integer userIndex;
                    Integer groupMemberSize;
                    groupMemberSize = assignedResorceList.size();
                    
                    userIndex = (LeadCustomvaluesList[0].get('User_Index__c') == null || Integer.valueOf(LeadCustomvaluesList[0].get('User_Index__c')) < -1)
                        ? -1 : Integer.valueOf(LeadCustomvaluesList[0].get('User_Index__c'));
                    Integer LeadUserIndex = (userIndex + 1) >= groupMemberSize ? 0 : userIndex + 1;
                    system.debug('c'+assignedResorceList[LeadUserIndex].User__c);
                    if(mapCapId.containsKey(assignedResorceList[LeadUserIndex].User__c) && mapDevCapId.containsKey(assignedResorceList[LeadUserIndex].User__c) &&  UserIdVsAssgId.containsKey(assignedResorceList[LeadUserIndex].User__c)){
                        Integer cap = mapCapId.get(assignedResorceList[LeadUserIndex].User__c);
                        Integer devcap = mapDevCapId.get(assignedResorceList[LeadUserIndex].User__c);
                        if(devcap < cap){
                            system.debug('1 insert');
                            assigner.Dev_Capacity__c =  devcap + 1; 
                            assigner.Id = UserIdVsAssgId.get(assignedResorceList[LeadUserIndex].User__c);
                            led.OwnerId = assignedResorceList[LeadUserIndex].User__c;
                            led.Id = ledObj.Id;
                            userIndex = LeadUserIndex;
                            LeadCustomvaluesList[0].User_Index__c= userIndex;
                            leadListUpdate.add(led);
                            LeadCustomList.add(LeadCustomvaluesList[0]);
                            assignedResorceListUpdate.add(assigner);
                        }
                    }
                }
            }
            try
            {
                if(leadListUpdate <> null && leadListUpdate.size() > 0){
                    update leadListUpdate;
                    system.debug('leadListUpdate'+leadListUpdate);
                }
                if(LeadCustomList <> null && LeadCustomList.size() > 0){
                    update LeadCustomList;
                }
                if(assignedResorceListUpdate <> null && assignedResorceListUpdate.size() > 0){
                    update assignedResorceListUpdate;
                }
            }catch(Exception e)
            {
                system.debug('e'+e.getLineNumber());
                system.debug('e'+e.getMessage());
                Database.RollBack(sp);
            }
          }
    }
    
}