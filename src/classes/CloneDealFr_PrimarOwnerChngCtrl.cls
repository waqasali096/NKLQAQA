/**
* Created by Mamta Gupta on 4 Feb 2022
  Name CloneJointOwnersCtrl
  Purpose Clone Primary Deal for primary owner change
  Usage Create New Deal button on case
*/

public class CloneDealFr_PrimarOwnerChngCtrl {
    
    //@InvocableMethod(label='Clone_Deal' description='Clone Deal for Primary owner Change' category='')
    @AuraEnabled
    public static boolean cloneDeal(List<ID> caseIDS){
        boolean isSuccess = false;
        Case cs =[select id,New_deal__c ,Status,New_Primary_Owner__c,Deal__c from Case WHERE ID=:caseIDS[0]];
        String oppID= cs.Deal__c;
        // Get the Map of Schema of Opportunity SObject
        Map<String, Schema.SObjectField> fieldMap = Opportunity.sObjectType.getDescribe().fields.getMap();
        
        // Get all of the fields on the object
        Set<String> setFieldNames = fieldMap.keySet();
        list<String> lstFieldNames = new List<String>(setFieldNames);
         
      // Dynamic Query String.
        List<Opportunity> opps = Database.query('SELECT ' + String.join(lstFieldNames, ',') + ' FROM opportunity '+ 'where ID =: oppID');
        opps[0].AccountID =  cs.New_Primary_Owner__c ;
        List<Opportunity> deals_Lst = new List<Opportunity>();
        Opportunity deal = new Opportunity();
        deals_Lst =  opps.deepClone() ;
        //deals_Lst[0].AccountID = cs.New_Primary_Owner__c ;
        //deals_Lst.add(deal);
        
        if(deals_Lst.size()>0){
            try{
               insert deals_Lst ;
                system.debug('deals_Lst is '+ deals_Lst);
                //deals_Lst[0].New_deal__c  = deals_Lst[0].ID;
                cs.New_deal__c  = deals_Lst[0].ID;
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