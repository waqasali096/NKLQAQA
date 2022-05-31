/**
* Created by Mamta Gupta on 4 Feb 2022
  Name CloneJointOwnersCtrl
  Purpose Clone joint Buyers as Requested Joint Buyers
  Usage  Clone Joint Buyers button on Case
*/

public class CloneJointOwnersCtrl {
//@InvocableMethod(label='CloneJoint_Owners' description='Clone Joint Owners' category='')
    
    public static void cloneJointOwners(List<ID> caseIDS){
        Case cs =[select id,Clone_Joint_Owners__c, Deal__c from Case WHERE ID=:caseIDS[0]];
        
        Opportunity  opp = [select id ,(select id,Primary_Account__c ,Relationship_with_Owner__c ,Secondary_Account__c ,
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
            reqJointOwner_Lst.add(rq_jOwner);
        }
        
        if(reqJointOwner_Lst.size()>0){
            try{
               insert reqJointOwner_Lst ;
                cs.Clone_Joint_Owners__c = false;
                update cs;
            }
            catch(Exception ex){
                system.debug('errror is '+ ex.getMessage());
            }
        }
        
        
    }
    
    

}