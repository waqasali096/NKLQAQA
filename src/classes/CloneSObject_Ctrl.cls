/**************************************************************************************************
* Name               : CloneSObject_Ctrl                                                      
* Description        : Custom Clone Aura
* Created Date       : 16/02/2022                                                                 
* Created By         : Cloudworks                                                                     
* -------------------------------------------------------------------------------------------------
* VERSION  AUTHOR    DATE            COMMENTS                                                    
* 1.0      Mamta      16/02/2022      Initial Draft.                                               
**************************************************************************************************/
public class CloneSObject_Ctrl {
    
    @AuraEnabled
    public static boolean clone(ID recordID){
     String sobjectType = recordID.getSObjectType().getDescribe().getName();
     boolean isSuccess= false;   
        if(sobjectType=='Case'){
           isSuccess = cloneOnCase(recordID ,isSuccess); 
        }
        
        return isSuccess;
    }
    
    
   public static boolean cloneOnCase(ID recordID ,boolean isSuccess){
   Case cs =[select id,Clone_Joint_Owners__c, Deal__c,recordType.Developername from Case WHERE ID=:recordID];
       if(cs.recordType.Developername=='Add_Remove_Joint_Owner'){
           isSuccess = cloneReqJointOwners(recordID, isSuccess);
       }  
       return isSuccess;
       
   }
    

    public static boolean cloneReqJointOwners(ID recordID ,boolean isSuccess){
        Case cs =[select id,Clone_Joint_Owners__c, Deal__c from Case WHERE ID=:recordID];
        
        Opportunity  opp = [select id ,(select id,first_Name__c,Last_name__c,Primary_Account__c ,Relationship_with_Owner__c ,Secondary_Account__c ,
                                             Share_Percentage__c ,Unit__c  from Joint_Buyers__r ) from opportunity where ID =: cs.Deal__c];
        
        List<Requested_Joint_Owner__c> reqJointOwner_Lst = new List<Requested_Joint_Owner__c>();
        for(Joint_Buyer__c jb : opp.Joint_Buyers__r){
            Requested_Joint_Owner__c rq_jOwner = new Requested_Joint_Owner__c();
            rq_jOwner.Primary_Account__c = jb.Primary_Account__c;
            rq_jOwner.Relationship_with_Owner__c = jb.Relationship_with_Owner__c;
            rq_jOwner.Secondary_Account__c = jb.Secondary_Account__c;
            rq_jOwner.Share_Percentage__c =jb.Share_Percentage__c;
            rq_jOwner.Unit__c =    jb.Unit__c; 
            rq_jOwner.Case__c = cs.ID;
            rq_jOwner.first_Name__c = jb.first_Name__c;
            rq_jOwner.Last_name__c =  jb.Last_name__c;   
            reqJointOwner_Lst.add(rq_jOwner);
        }
        
        if(reqJointOwner_Lst.size()>0){
            try{
               insert reqJointOwner_Lst ;
                cs.Clone_Joint_Owners__c = false;
                update cs;
                isSuccess= true;
            }
            catch(Exception ex){
                system.debug('errror is '+ ex.getMessage());
                 isSuccess= false;
            }
        }
        
        return isSuccess;
        
    }

}