public class MasterAdditionalChargesClass {
  /*  public String recordId{get;set;}
    @AuraEnabled
    public static List<Additional_Charges__c> fetchAdditionalCharges(String recordId,String searchString){
        List<Additional_Charges__c> addList ;
       Opportunity opp = [Select Id,project__c from Opportunity where Id =: recordId limit 1];
        String projectId = opp.Project__c;
        //String tempInput =searchString;
        //addList = [Select Id,Name,Amount__c,Project__r.Name,Project__c,VAT_Amount__c,VAT__c  FROM Additional_Charges__c where Name Like \'%'  tempInput ];
       String query = 'Select Id,Payable_Amount__c,Name,Amount__c,Project__r.Name,Project__c,VAT_Amount__c,VAT__c  FROM Additional_Charges__c';
        query += ' where project__c =: projectId and name like \'%' + searchString +'%\' and Name != \'Ejari\' order by Name asc'; 
        addList = database.query(query);
        system.debug('addList'+addList);
        return addList;
    }

    @AuraEnabled 
    public static String saveRecord(String recordId,List<Additional_Charges__c> addList){
        String returnMessage;
        double finalAmounts =0.0;
        double addnCharges = 0.0;
        
        system.debug('recordId'+recordId);
        Opportunity opp = [Select Id,Final_Lease_Amount__c,Total_Additional_Charges__c,Lease_Start_Date__c FROM Opportunity where ID =: recordId limit 1];
        if(opp.Final_Lease_Amount__c != null){
            //finalAmounts += opp.Final_Lease_Amount__c;
        } 
        else {
            opp.Final_Lease_Amount__c = 0.0;
        }
        List<Unit_Plan__c> unitPlanList = [Select Id,Unit__c,Unit__r.Unit_Code__c FROM Unit_Plan__c where Opportunity__c =: opp.Id];
        if(opp.Total_Additional_Charges__c != null){
        addnCharges += opp.Total_Additional_Charges__c;
        }
        List<Payment_Milestone__c> oppChargeList = new List<Payment_Milestone__c>();
        for(Integer i = 0;i<unitPlanList.size();i++){
         for(Additional_Charges__c add : addList){
                Payment_Milestone__c oppCharges = new Payment_Milestone__c();
                oppCharges.Name = add.Name + '-'+ unitPlanList[i].Unit__r.Unit_Code__c;
                oppCharges.VAT_Amount__c = add.VAT_Amount__c ;
                oppCharges.VAT_Code__c = add.VAT_Code__c;
                oppCharges.VAT__c = add.VAT__c;
                oppCharges.Unit__c = unitPlanList[i].Unit__c;
                oppCharges.Payable_Amount__c = add.Payable_Amount__c;
                oppCharges.Opportunity__c = recordId;
                oppCharges.Due_Date__c = opp.Lease_Start_Date__c;
                oppCharges.Project__c = add.Project__c;
                //oppCharges.Master_Additional_Charges__c = add.ID;
                oppCharges.Amount__c = oppCharges.Payable_Amount__c + oppCharges.VAT_Amount__c;
                //oppCharge.add(oppCharges);
             oppChargeList.add(oppCharges); 
           
              if(add.Amount__c != null){
                
                    finalAmounts += double.valueOf(add.Amount__c);
                  
                }
                if(add.Amount__c != null){
                  //finalAmounts += Integer.valueOf(add.VAT_Amount__c); 
                    addnCharges += Double.valueOf(add.Amount__c);
                }
                
         }
            }
        if(oppChargeList.size() > 0){
            insert oppChargeList;
            returnMessage = 'Record Created Successfully !';
            Opportunity opty = new Opportunity();
            opty.Id = recordId;
            opty.Final_Lease_Amount__c = opp.Final_Lease_Amount__c;
            system.debug('Taha2>>' + finalAmounts);
            if(finalAmounts != null){
            opty.Final_Lease_Amount__c = opty.Final_Lease_Amount__c + double.valueOf(finalAmounts);
            system.debug('Taha>>opty.Final_Lease_Amount__c' + opty.Final_Lease_Amount__c);
            }
            if(addnCharges !=null){
            opty.Total_Additional_Charges__c = addnCharges;
            }
            update opty;
            
        }
        return returnMessage;
    }
     @AuraEnabled
    public static List<Opportunity_Charges__c> findUnitByName(String recordId) {
        Set<Id> projId = new Set<Id>();
        Set<Id> unitId = new Set<Id>();
        List<Unit_Plan__c> unitlist = [select id,Unit__c,Project__c from Unit_Plan__c where Id =: recordId];
        if(unitlist <> null && unitlist.size() > 0){
            for(Unit_Plan__c uniObj : unitlist){
               projId.add(uniObj.Project__c);
               unitId.add(uniObj.Unit__c);
            }
        }
       List<Additional_Charges__c> addchargesList = [Select id,Name,Project__r.Name,Project__c,Payable_Amount__c,Ejari__c,Security_Deposit__c,Swimming_Pool_Charges__c,Utility_Charges__c,Amount__c from Additional_Charges__c where Project__c  IN : projId AND
                                                 Unit__c IN:unitId AND Type__c = 'Leasing' ];
        List<Opportunity_Charges__c> chargesList = [Select Id,Name,Project__r.Name,Project__c,Payable_Amount__c,VAT_Amount__c,VAT_Code__c,VAT__c,Amount__c from Opportunity_Charges__c where Opportunity__c =:recordId ];
        
        return chargesList;
    }*/
 
}