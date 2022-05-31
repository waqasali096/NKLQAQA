/**
* Created by Mamta Gupta on 4 Feb 2022
  Name CreateAgreementCaseCtrl
  Purpose Create Agreement Record on case
  Usage  Create Agreement button on case, Flow- Case-Clone Joint Owners

*/

public class JointOwnerSR_AgreementProcessCtrl {
    
   @InvocableMethod(label='Close Joint SR' description='Agreement' category='')
        public static void createAgreement(List<ID> caseIDS){
        boolean isSuccess = false;    
        List<Case> cases = [select id, Status,Agreement_Created__c,Deal__c,Deal__r.Unit__c ,Deal__r.AccountID,
                           (select id,Primary_Account__c,Relationship_with_Owner__c,Secondary_Account__c,Share_Percentage__c,
                            Unit__c from Requested_Joint_Owners__r) from Case WHERE ID IN :caseIDS];
            
         createNewJointOwnersonOpp(cases[0].Deal__c , cases[0],isSuccess);  
            
         List<Agreement__c > spaContractList = New List<Agreement__c >();
         for(Case cs :cases ){
            Id spaRecordTypeId = Schema.SObjectType.Agreement__c.getRecordTypeInfosByDeveloperName().get('SPA').getRecordTypeId();
                Agreement__c  newAgreement = New Agreement__c ();
                newAgreement.RecordTypeId = spaRecordTypeId;
                newAgreement.Opportunity__c = cs.Deal__c;
                newAgreement.Status__c = 'Draft';
                newAgreement.Account__c = cs.Deal__r.AccountId;
                newAgreement.Unit__c = cs.Deal__r.Unit__c ;
                spaContractList.add(newAgreement);          
                
        }
        
        system.debug('contract-- ' + spaContractList);    
        
            try{
               /* if(spaContractList.size()>0){
                  insert spaContractList;
                   cases[0].Agreement_Created__c = true;
                   cases[0].Agreement__c  = spaContractList[0].ID;
                   update cases[0];
                    isSuccess = true;
                }*/
                
            }  
            catch(Exception ex){
                system.debug('errror is '+ ex.getMessage());
                isSuccess = false;
            }
           //return  isSuccess;
        }
    
    public static boolean createNewJointOwnersonOpp(ID oppID ,Case cs , boolean isSuccess){
        
    List<Joint_Buyer__c > jointBuyers_Lst =[select id,First_name__c, Last_Name__c,Primary_Account__c,Relationship_with_Owner__c,
                                            Secondary_Account__c,Share_Percentage__c,Unit__c FROM Joint_Buyer__c WHERE Opportunity__c=:oppID];
    List<Requested_Joint_Owner__c> reqJointOwners   =   [select id,First_name__c, Last_Name__c,Primary_Account__c,Relationship_with_Owner__c,
                                            Secondary_Account__c,Share_Percentage__c,Unit__c FROM Requested_Joint_Owner__c WHERE Case__c=:cs.ID];
    List<Joint_Buyer__c>  newJoint_BuyerLst =new List<Joint_Buyer__c>();
        
        for(Requested_Joint_Owner__c jb :reqJointOwners ){
            Joint_Buyer__c rq_jOwner = new Joint_Buyer__c();
            rq_jOwner.Primary_Account__c = jb.Primary_Account__c;
            rq_jOwner.Relationship_with_Owner__c = jb.Relationship_with_Owner__c;
            rq_jOwner.Secondary_Account__c = jb.Secondary_Account__c;
            rq_jOwner.Share_Percentage__c =jb.Share_Percentage__c;
            rq_jOwner.Unit__c =    jb.Unit__c; 
            rq_jOwner.Opportunity__c =oppID;
            rq_jOwner.First_name__c = jb.First_name__c;
            rq_jOwner.Last_Name__c =jb.Last_Name__c;
            newJoint_BuyerLst.add(rq_jOwner);
        } 
        
        if(newJoint_BuyerLst.size()>0){
            try{
                delete JointBuyers_Lst;
                insert newJoint_BuyerLst;
                cs.Status ='Closed';
                update cs;
                
                isSuccess = true;
            }
            catch(Exception ex){
             system.debug('errror is '+ ex.getMessage());
             isSuccess = false;   

            }
        }
        
        return isSuccess;
        
        
         
    }


}