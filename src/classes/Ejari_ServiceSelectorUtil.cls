/*
Created By: Taha Hamid
Description: This class will be used to call relevant method from the list of methods available 
             from Ejari Integration, this will return the entire payload
*/             
public class Ejari_ServiceSelectorUtil {
    
    // method to retrieve desired xml for Ejari Integration available methods
    public static EjariWrapperUtil getServiceBody(String recordId, String methodName){
        EjariWrapperUtil objReturnWrap = new EjariWrapperUtil();
        try{

            // First up query the desired data for the objects
            Lease_Contract__c contRec = new Lease_Contract__c();
            Opportunity oppRec = new Opportunity();
            Account accRec = new Account();
            Contact con = new Contact();
            Contact conRec = new Contact();
            List<Unit__c> lstUnits = new list<Unit__c>();
            List<Unit_Plan__c> lstUnitPlan = new List<Unit_Plan__c>();
            Address__c address = new Address__c();        
            //List<Unit_Reference__c> lstUnitRef = new List <Unit_Reference__c>();
            List<ID> lstPlanUnitID = new list<ID>();
            List<ID> lstUnitID = new list<ID>();

            Ejari_Integration_Credential__mdt intCreds = new Ejari_Integration_Credential__mdt(); //To hold custom metadata record
            
            contRec = Database.query(getQuery('Lease_Contract__c', recordId, null));
            accRec = Database.query(getQuery('Account', contRec.Account__c, null));
            oppRec = Database.query(getQuery('Opportunity', contRec.Opportunity__c, null));
            lstUnitPlan = Database.query(getQuery('Unit_Plan__c', recordId, null));
            for(Unit_Plan__c unPlan : lstUnitPlan)
            {
                lstPlanUnitID.add(unPlan.Unit__c);
            }
            system.debug('Taha lstUnitPlan => '+lstUnitPlan);
            lstUnits = Database.query(getQuery('Unit__c',null, lstPlanUnitID));
            for(Unit__c unit : lstUnits)
            {
                lstUnitID.add(unit.ID);
            }
            system.debug('Taha lstUnits => '+lstUnits);
            //lstUnitRef = Database.query(getQuery('Unit_Reference__c', null, lstUnitID));
            //system.debug('Taha lstUnitRef => '+lstUnitRef);
            address = Database.query(getQuery('Address__c', accRec.ID, null));
            intCreds = [Select Password__c, User_Name__c from Ejari_Integration_Credential__mdt limit 1]; //Querying custom metadata record
            if(!accRec.IsPersonAccount)
            {
                con = Database.query(getQuery('Contact', contRec.Account__c, null));
            }

			if(methodName == 'EditTenancyContract'){
                if(accRec.IsPersonAccount)
                    objReturnWrap.body = Ejari_XMLConstructorUtil.EditTenancyContract_Person(oppRec,contRec,accRec,lstUnits,intCreds,lstUnitPlan, address);
                else
                    objReturnWrap.body = Ejari_XMLConstructorUtil.EditTenancyContract_ORG(oppRec,contRec,accRec,lstUnits,intCreds,con, lstUnitPlan, address);                
                objReturnWrap.soapAction = 'http://tempuri.org/IEjariProxy/EditTenancyContract';
            }

            else if(methodName == 'TerminateTcByContractNumber'){
                objReturnWrap.body = Ejari_XMLConstructorUtil.TerminateTcByContractNumber(oppRec, contRec, intCreds);
				objReturnWrap.soapAction = 'http://tempuri.org/IEjariProxy/TerminateTcByContractNumber';
            }

            else if(methodName == 'RenewTenancyContract'){
                if(accRec.IsPersonAccount)
                    objReturnWrap.body = Ejari_XMLConstructorUtil.RenewTenancyContract_Person(oppRec,contRec,accRec,lstUnits,intCreds,lstUnitPlan, address);
                else
                    objReturnWrap.body = Ejari_XMLConstructorUtil.RenewTenancyContract_ORG(oppRec,contRec,accRec,lstUnits,intCreds,con, lstUnitPlan, address);                
                objReturnWrap.soapAction = 'http://tempuri.org/IEjariProxy/RenewPendingTenancyContract';
            }
            
            else if(methodName == 'ActivateTcByContractNumber'){
                objReturnWrap.body = Ejari_XMLConstructorUtil.ActivateTcByContractNumber(oppRec, contRec, intCreds);
				objReturnWrap.soapAction = 'http://tempuri.org/IEjariProxy/ActivateTcByContractNumber';
            }
            
            else if(methodName == 'PrintCertificateByContractNumberToStream'){
                objReturnWrap.body = Ejari_XMLConstructorUtil.PrintCertificateByContractNumberToStream(oppRec,contRec,intCreds);
				objReturnWrap.soapAction = 'http://tempuri.org/IEjariProxy/PrintCertificateByContractNumberToStream';
            }
            else if(methodName == 'PrintTcByContractNumberToStream'){
                objReturnWrap.body = Ejari_XMLConstructorUtil.PrintTcByContractNumber(oppRec,contRec,intCreds);
				objReturnWrap.soapAction = 'http://tempuri.org/IEjariProxy/PrintTcByContractNumberToStream';
            }
            /*else if(methodName == 'TCGetByContractNumber'){
                objReturnWrap.body = Ejari_XMLConstructorUtil.TCGetByContractNumber(oppRec,contRec, intCreds);
				objReturnWrap.soapAction = 'http://tempuri.org/IEjariProxy/TCGetByContractNumber';
            }*/

            else if(methodName == 'CreatePendingTenancyContractRequest'){
                if(accRec.IsPersonAccount){
                    objReturnWrap.body = Ejari_XMLConstructorUtil.CreatePendingTenancyContractRequest_Person(oppRec,contRec,accRec,lstUnits,intCreds, lstUnitPlan, address);
                
                }else{
                    objReturnWrap.body = Ejari_XMLConstructorUtil.CreatePendingTenancyContractRequest_ORG(oppRec,contRec,accRec,lstUnits,intCreds,con, lstUnitPlan, address);                
            	}
                objReturnWrap.soapAction = 'http://tempuri.org/IEjariProxy/CreatePendingTenancyContractRequest';
            }
                      
        }
        catch(Exception e){
            system.debug('Error: ' + e.getMessage() +' at line '+ e.getLineNumber());
            objReturnWrap.body = 'Error';
            objReturnWrap.soapAction = 'Error';            
        }
        return objReturnWrap; 
     }
    
    @InvocableMethod(label ='EjariMethodSelector')
    public static void EjariMethodSelector(List<ID> listOppid){
        
        try{
            Opportunity oportunityRec = new Opportunity();
            for(Opportunity op : [select id, StageName from Opportunity where id in :listOppid]){
                oportunityRec.Id = op.id;
                oportunityRec.StageName = op.StageName;
            }
            system.debug('Opp Record Id: '+oportunityRec.Id+' Opp Stage Name: '+oportunityRec.StageName);
            
        }
        catch(Exception e){
            system.debug('Error: ' + e.getMessage() +' at line '+ e.getLineNumber());
        }
     }  
    
    
    /*
    Description: This method will be used to Query records dynamically by Object Api name and RecordId as a string.
    */
    public static string getQuery(string objectType, string recordId, list<ID> ids){
        
        SObjectType objType = Schema.getGlobalDescribe().get(objectType);
        List<String> contractFields = new List<string>(objType.getDescribe().fields.getMap().keySet());
        string soql = 'select '+ String.join(contractFields, ',') + (objectType == 'Lease_Contract__c' ? ',Opportunity__r.Unit__c,Opportunity__r.Contact__c' : '') + ((objectType == 'Unit_Plan__c' ? ',Opportunity__r.Unit__c' : '')) +(objectType == 'Unit_Reference__c' ? ',Unit__r.Lease_Rent__c,Unit__r.Unit_Code__c,Unit__r.DEWA_Number__c' : '')+ ' from '+objectType;
        if(objectType == 'Unit_Plan__c')
            soql += ' where Contract__c = ' + '\''+ recordId + '\'';
        else if(objectType == 'Unit_Reference__c')
        {
            String idsString = String.join(new List<Id>(ids), '\',\'');
            String whereClause = ' where Unit__c IN (\'' + idsString + '\')';
            soql += whereClause;
        }
            //soql += 'Unit__c IN :ids';// + lstRecID;
        else if(objectType == 'Unit__c')
        {
            String idsString = String.join(new List<Id>(ids), '\',\'');
            String whereClause = ' where Id IN (\'' + idsString + '\')';
            soql += whereClause;
        }
            //soql += 'ID IN :ids';// + lstRecID;    
        else if(objectType == 'Contact')
            soql += ' where Is_Primary__c = true and AccountId = ' + '\''+ recordId + '\' Limit 1';
        else if(objectType == 'Address__c')
            soql += ' where Primary__c = true and Account__c = ' + '\''+ recordId + '\' Limit 1' ;
        else
            soql += ' where id = ' + '\''+ recordId + '\'';
        //soql += '\''+ recordId + '\'';
        system.debug('Taha>>query' + soql);
        return soql;

    }

}