/**
* @author Shruti Khodabole
* @date  30/12/2022
* @purpose - Initial Development
* @usage -Trigger handler for ContractTriggerHandler
*/
public class ContractTriggerHandler {
    List<Lease_Contract__c> recordNewList = new List<Lease_Contract__c>();
    List<Lease_Contract__c> recordOldList = new List<Lease_Contract__c>();
    Map<Id, Lease_Contract__c> recordNewMap = new Map<Id, Lease_Contract__c>();
    Map<Id, Lease_Contract__c> recordOldMap = new Map<Id, Lease_Contract__c>();
    Boolean isInsert, isUpdate, isDelete, isUndelete = false;
    public static boolean recursionController = false;
    
    public ContractTriggerHandler(List<Lease_Contract__c> newList, List<Lease_Contract__c> oldList, Map<Id, Lease_Contract__c> newMap, Map<Id, Lease_Contract__c> oldMap, boolean isInsert, boolean isUpdate, Boolean isDelete, Boolean isUndelete) {
        this.recordNewList = newList;
        this.recordOldList = oldList;
        this.recordNewMap = newMap;
        this.recordOldMap = oldMap;
        this.isInsert = isInsert;
        this.isUpdate = isUpdate;
        this.isDelete = isDelete;
        this.isUndelete = isUndelete;
    }
    
    public void BeforeInsertEvent() {
    }
    public void BeforeUpdateEvent() {
        approvedContractAutomations();
        erpLeaseSOCreation();
    }
    public void BeforeDeleteEvent() {
    }
    public void AfterInsertEvent() {
        updateContractIdOnOpportunityUnit();
        GenericTriggerHandler.createDocRecord(recordNewList,'Lease_Contract__c');
        erpLeaseSOCreation();
        syncDraftEjariOnApproval();
    }
    public void AfterUpdateEvent() {
        updateStatus();  
        terminateContractERP();
        updatePropertyAndUnitsAsPerContractStage(); 
        contractGenerationFormDocument();
        signedContractGenerationFormDocument();
        generateEjariQueable();
        generateRenewEjariPDF();
        //activateRenewedEjari(); commented by Karishma as renewal ejari will be activated similar to that of normal lease contract - 20-05-2022
        terminateContractAutomations();
        activateEjari();
        flagCustomersUnderCompliance();
    }
    public void AfterDeleteEvent() {
    }
    public void AfterUndeleteEvent() {
    }
    public void updateStatus(){
        List<Opportunity> oppListUpdate = new  List<Opportunity>();
        List<Unit__c> unitListUpdate = new List<Unit__c>();
        Set<Id> oppId = new Set<Id>();
        //Map<String,String> oppVsCon = new     Map<String,String>();
        Map<String,String> oppVsConStatus = new     Map<String,String>();
        Map<String,Lease_Contract__c> oppVsCon = new    Map<String,Lease_Contract__c>();
        Id renewalContractRcdTyId = Schema.SObjectType.Lease_Contract__c.getRecordTypeInfosByDeveloperName().get('Renewal_Contract').getRecordTypeId();
        for(Lease_Contract__c le : recordNewList){
            //if(le.RecordTypeId != renewalContractRcdTyId){ // condition added to by pass for the lease Renewal contract - hitesh s
            oppId.add(le.Opportunity__c);
            if(le.Contract_Stages__c == 'Approved' || le.Contract_Stages__c == 'Customer signature'){
               // oppVsConStatus.put(le.Opportunity__c, 'Booking'); 
            }else if(le.Contract_Stages__c == 'Under handover' && le.Handover_Status__c != 'Completed'){
                oppVsConStatus.put(le.Opportunity__c, 'Handover');
                oppVsCon.put(le.Opportunity__c, le);
            }else if(le.Contract_Stages__c == 'Active' || (le.Handover_Status__c == 'Completed' && le.Handover_Status__c != recordOldMap.get(le.Id).Handover_Status__c)){
                if(le.RecordTypeId !=  renewalContractRcdTyId){
                oppVsConStatus.put(le.Opportunity__c, 'Leased');
                }
                else{
                    oppVsConStatus.put(le.Opportunity__c, 'Renewed');
                }
            }
           // }
        }
        List<Unit_Plan__c> unlist = [select unit__c,id,opportunity__c,Renewal_new_unit__c from Unit_Plan__c where opportunity__c IN :oppId];
        if(unlist <> null && unlist.size() > 0){
            for(Unit_Plan__c units : unlist){
                Unit__c uniObj = new Unit__c();
                if(oppVsConStatus.containsKey(units.opportunity__c)){
                   /* if(oppVsConStatus.get(units.opportunity__c) == 'Booking'){
                        uniObj.Unit_Status__c = 'Booked';
                        uniObj.Id =  units.unit__c;
                        unitListUpdate.add(uniObj);
                    }else*/ if(oppVsConStatus.get(units.opportunity__c) == 'Handover' && units.Renewal_new_unit__c==true){
                        uniObj.Unit_Status__c = 'Booked';
                        uniObj.Id =  units.unit__c;
                        unitListUpdate.add(uniObj);
                    }else if(oppVsConStatus.get(units.opportunity__c) == 'Leased'|| oppVsConStatus.get(units.opportunity__c) == 'Renewed'){
                        uniObj.Unit_Status__c = 'Leased';
                        uniObj.Id =  units.unit__c;
                        unitListUpdate.add(uniObj);
                    }
                }
            }
        }
        for(Id opp : oppId){
            Opportunity oppObj = new Opportunity();
            if(oppVsConStatus.containsKey(opp)){
                /*if(oppVsConStatus.get(opp) == 'Booking'){
                    oppObj.Unit_Status__c = 'Booking';
                    oppObj.StageName = 'Booking';
                    oppObj.Id =  opp;
                    oppListUpdate.add(oppObj);   
                }else*/ if(oppVsConStatus.get(opp) == 'Handover'){
                    Lease_Contract__c contract =  oppVsCon.get(opp);
                    oppObj.Unit_Status__c = 'Handover';
                    oppObj.StageName = 'Handover';
                    oppObj.Handover_Date__c = contract.Handover_Date__c != null ? contract.Handover_Date__c : contract.Contract_Start__c;
                    oppObj.Id =  opp;
                    oppListUpdate.add(oppObj);
                }else if(oppVsConStatus.get(opp) == 'Leased'){
                    Lease_Contract__c contract =  oppVsCon.get(opp);
                    oppObj.Unit_Status__c = 'Leased';
                    oppObj.StageName = 'Leased';
                    oppObj.Id =  opp;
                    oppListUpdate.add(oppObj);
                }
                else if(oppVsConStatus.get(opp) == 'Renewed'){
                   Lease_Contract__c contract =  oppVsCon.get(opp);
                  oppObj.Unit_Status__c = 'Leased';
                 oppObj.StageName = 'Renewed';
                 oppObj.Id =  opp;
                 oppListUpdate.add(oppObj);
                }
            }
        }
        
        if(oppListUpdate <> null && oppListUpdate.size() > 0){
            update oppListUpdate;
        }
        if(unitListUpdate <> null && unitListUpdate.size() > 0){
            update unitListUpdate;
        }
        
        
    }
    public void updateContractIdOnOpportunityUnit()
    {
        Set<Id> oppId = new  set<Id>();
        Map<Id,Id> oppIdVscontractId = new Map<Id,Id>();
        List<Unit_Plan__c> oppListUpdate = new List<Unit_Plan__c>();
        for(Lease_Contract__c le : recordNewList){
            oppId.add(le.Opportunity__c);
            oppIdVscontractId.put(le.Opportunity__c, le.Id);
        }
        List<Unit_Plan__c> listopp = [select Id,Opportunity__c, Project__c from Unit_Plan__c where Opportunity__c IN :oppId];
        if(listopp <> null && listopp.size() > 0){
            for(Unit_Plan__c units : listopp){
                Unit_Plan__c unitOb = new Unit_Plan__c();
                if(oppIdVscontractId.containsKey(units.Opportunity__c))
                    unitOb.Contract__c = oppIdVscontractId.get(units.Opportunity__c);
                unitOb.Id = units.Id;
                oppListUpdate.add(unitOb);
            } 
        }
        if(oppListUpdate <> null && oppListUpdate.size() > 0){
            update oppListUpdate;
        }
    }
    
    /**********************************************************************************************
* @Description  : Method to Generate Ejari
* @Return       : void
* @Author       : Sajid Hameed
**********************************************************************************************/
    public void generateEjariQueable(){
        for(Lease_Contract__c contract : recordNewList){
            String className;
            String recordId = contract.Id;
            
            if(contract.Trigger_Create_Draft_Ejari__c && (contract.Trigger_Create_Draft_Ejari__c != recordOldMap.get(contract.Id).Trigger_Create_Draft_Ejari__c)){
                className = 'CreatePendingTenancyContractRequest';
            }
            else if(contract.Trigger_Activate_Ejari_Contract__c && (contract.Trigger_Activate_Ejari_Contract__c != recordOldMap.get(contract.Id).Trigger_Activate_Ejari_Contract__c)){
                className = 'ActivateTcByContractNumber';
            }
            else if(contract.Trigger_Download_Draft_Ejari_Document__c && (contract.Trigger_Download_Draft_Ejari_Document__c != recordOldMap.get(contract.Id).Trigger_Download_Draft_Ejari_Document__c)){
                className = 'PrintTcByContractNumberToStream';
            }
            else if(contract.Trigger_Download_Final_Ejari_certificate__c && (contract.Trigger_Download_Final_Ejari_certificate__c != recordOldMap.get(contract.Id).Trigger_Download_Final_Ejari_certificate__c)){
                className = 'PrintCertificateByContractNumberToStream';
                
            }
            else if(contract.Trigger_Edit_Draft_Ejari_Document__c && (contract.Trigger_Edit_Draft_Ejari_Document__c != recordOldMap.get(contract.Id).Trigger_Edit_Draft_Ejari_Document__c)){
                className = 'EditTenancyContract';
            }
            else if(contract.Trigger_Renew_Ejari_Contract__c && (contract.Trigger_Renew_Ejari_Contract__c != recordOldMap.get(contract.Id).Trigger_Renew_Ejari_Contract__c)){
                className = 'RenewTenancyContract';
            }
            else if(contract.Trigger_Terminate_Ejari_Contract__c && (contract.Trigger_Terminate_Ejari_Contract__c != recordOldMap.get(contract.Id).Trigger_Terminate_Ejari_Contract__c)){
                className = 'TerminateTcByContractNumber';
            }
            
            if(String.isNotEmpty(className)){               
                System.enqueueJob(new Ejari_QueueableHandlerUtil.Ejari_QueueableCreateEjari(recordId, className)); /* commented by karishma 11-03-2022 as it was needing recompilation*/
            }
        }
    }
    
    /**********************************************************************************************
* @Description  : Method to terminate contract in ERP system
* @Params       : List< Lease_Contract__c > newList
* @Param        : Map< Id, Lease_Contract__c > oldMap
* @Return       : void
* @Author       : Karishma Kotian
**********************************************************************************************/
    public void terminateContractERP(){
        Set<Id> contractId = new Set<Id>();
        String SObjectName = 'Lease_Contract__c';
        for(Lease_Contract__c contract : recordNewList){
            if(contract.Sync_Contract_Termination__c && (recordOldMap == null || contract.Sync_Contract_Termination__c != recordOldMap.get(contract.Id).Sync_Contract_Termination__c)){
                contractId.add(contract.Id);
            }
        }
        if(!contractId.isEmpty()){
            //terminateContract(contractId,SObjectName);
            ERPIntegrationHelper.contractTermination(contractId);
        }
    }
    
    /********************************************************************************************** 
* @Description  : Method to terminate contract in ERP system
* @Params       : Contract Ids - Set of Contract Ids
* @Return       : void
* @Author       : Karishma Kotian
**********************************************************************************************/
    /*public Static void terminateContract(Set<Id> contractIds,String SObjectName) {
        terminateContractQueueable terminatContractNewObj = new terminateContractQueueable(contractIds,SObjectName);
        system.enqueueJob(terminatContractNewObj);
    }*/
    
    /********************************************************************************************** 
* @Description  : Queueable class to for callout to ERP system
* @Params       : Contract Ids - Set of Contract Ids
* @Return       : void
* @Author       : Karishma Kotian
**********************************************************************************************/
    /*public class terminateContractQueueable implements system.Queueable, Database.AllowsCallouts{
        Private  Set<Id> contractIds;
        Private String SobjectName;
        public terminateContractQueueable(set<Id> contractIds,String SobjectName){
            this.contractIds=contractIds;
            this.SobjectName = SobjectName;
        }
        public void execute(QueueableContext content){
            ERPAPIIntegration.contractTermination(contractIds,SobjectName);
        }
    }*/
    
    /********************************************************************************************** 
* @Description  : Update Property Status as per Contract status
* @Params       : List<Lease_Contract__c>, Map<Id,Lease_Contract__c>
* @Return       : void
* @Author       : Karishma Kotian
**********************************************************************************************/
    public void updatePropertyAndUnitsAsPerContractStage(){
        Set<Id> opptyIds = new Set<Id>();
        Map<Id,Lease_Contract__c> leaseContractMap = new Map<Id,Lease_Contract__c>();
        Map<Id,Id> unitMapToProperty = new Map<Id,Id>();
        //Map<String,String> unitMaptoContract =  new Map<String,String>();
        Map<String,List<String>> contractMaptoUnitList =  new Map<String,List<String>>();
        List<Property__c> updateProperties = new List<Property__c>();
        List<Unit__c> unitList = new List<Unit__c>();
        
        for(Lease_Contract__c leaseContract : recordNewList){
            if(leaseContract.Contract_Stages__c != null && leaseContract.Contract_Stages__c != recordOldMap.get(leaseContract.Id).Contract_Stages__c ){
                leaseContractMap.put(leaseContract.Id,leaseContract);
                opptyIds.add(leaseContract.Opportunity__c);
            }
        }
        
        List<Property__c> propertyList = [SELECT Id, Unit__c, Account__c, Deal__c, Active__c,Status__c
                                          FROM Property__c WHERE Deal__c IN: opptyIds];
        for(Property__c property : propertyList){
            unitMapToProperty.put(property.Unit__c,property.Id);
        }
        
        List<Unit_Plan__c> unitPlanList = [SELECT ID, Opportunity__c, Unit__c,Contract__c, Is_Terminated__c FROM Unit_Plan__c
                                           WHERE Opportunity__c IN: opptyIds];
        for(Unit_Plan__c opptyUnit: unitPlanList){
            // unitMaptoContract.put(opptyUnit.Contract__c,opptyUnit.Unit__c);
            // Modified by Karishma to accomodate one contract to multiple unit scenario
            if(contractMaptoUnitList.containsKey(opptyUnit.Contract__c)){
                contractMaptoUnitList.get(opptyUnit.Contract__c).add(opptyUnit.Unit__c);
            }else{
                contractMaptoUnitList.put(opptyUnit.Contract__c,new List<String>{opptyUnit.Unit__c});
            }
        }
        
        
        /*for(Id key : leaseContractMap.keySet()){
if(unitMaptoContract.containsKey(key)){
if(unitMapToProperty.containsKey(unitMaptoContract.get(key))){
Property__c property = new Property__c();
property.Id = unitMapToProperty.get(unitMaptoContract.get(key));
if(leaseContractMap.get(key).Contract_Stages__c == 'Terminated'){
property.Status__c = 'Lease Terminated';
property.Active__c = false;
}else if(leaseContractMap.get(key).Contract_Stages__c == 'Compliance') {
property.Status__c = 'Lease Compliance'; //leaseContractMap.get(key).Contract_Stages__c;
}else if(leaseContractMap.get(key).Contract_Stages__c == 'Expired'){
property.Status__c = 'Lease Expired';
}else if(leaseContractMap.get(key).Contract_Stages__c == 'Active'){
property.Active__c = true;
property.Status__c = 'Leased';
}
updateProperties.add(property);
}
if(leaseContractMap.get(key).Contract_Stages__c == 'Terminated'){
Unit__c unit = new Unit__c(); 
unit.Id = unitMaptoContract.get(key);
unit.Opportunity__c = null;
unit.Unit_Status__c = 'Under Refurbishment';
unitList.add(unit);
}
}

}*/
        // Modified by Karishma to accomodate one contract to multiple unit scenario
        for(Id key : leaseContractMap.keySet()){
            if(contractMaptoUnitList.containsKey(key)){
                for(String unitId : contractMaptoUnitList.get(key)){
                    if(unitMapToProperty.containsKey(unitId)){
                        Property__c property = new Property__c();
                        property.Id = unitMapToProperty.get(unitId);
                        if(leaseContractMap.get(key).Contract_Stages__c == 'Terminated'){
                            property.Status__c = 'Lease Terminated';
                            property.Active__c = false;
                        }else if(leaseContractMap.get(key).Contract_Stages__c == 'Compliance') {
                            property.Status__c = 'Lease Compliance'; 
                        }else if(leaseContractMap.get(key).Contract_Stages__c == 'Expired'){
                            property.Status__c = 'Lease Expired';
                        }else if(leaseContractMap.get(key).Contract_Stages__c == 'Active'){
                            property.Active__c = true;
                            property.Status__c = 'Leased';
                        }
                        updateProperties.add(property);
                    }
                    
                    /*if(leaseContractMap.get(key).Contract_Stages__c == 'Terminated'){
                        Unit__c unit = new Unit__c(); 
                        unit.Id = unitId;
                        unit.Opportunity__c = null;
                        unit.Unit_Status__c = 'Under Refurbishment';
                        unitList.add(unit);
                    }*/
                }
            }
        }
        
        if(!updateProperties.isEmpty())
            update updateProperties;
        
        if(!unitList.isEmpty())
            update unitList;
        
    }
    
    /******************************************************************************************************
* @Description        : Identify Lease Sales Order call to ERP                                                                                      
* @Return             : void         
* @Author       : Vishal A                                                                
*******************************************************************************************************/ 
    public void erpLeaseSOCreation() {
        Set<Id> contrctId = new Set<Id>();
        for(Lease_Contract__c leasContrct: recordNewList) {
            if(leasContrct.Send_Lease_to_ERP__c && leasContrct.ERP_Lease_ID__c == null && (recordOldMap == null || leasContrct.Send_Lease_to_ERP__c != recordOldMap.get(leasContrct.Id).Send_Lease_to_ERP__c)) {
                contrctId.add(leasContrct.Id);
                if(recordOldMap != null) {
                    leasContrct.Send_Lease_to_ERP__c = false;
                }
            }
        }
        if(!contrctId.isEmpty()) {
            ERPIntegrationHelper.createLeasingSO(contrctId);
        }
    }
    
    /********************************************************************************************** 
* @Description  : Method to sync Lease SO in ERP system
* @Params       : Lease Contract Id - Set Id of Lease Contract 
* @Return       : void
* @Author       : Vishal A
**********************************************************************************************/
    /*public Static void leaseContractSOCreation(Set<Id> contrctId) {
        syncLeaseContSOQueuable syncLeaseSOAgr = new syncLeaseContSOQueuable(contrctId);
        system.enqueueJob(syncLeaseSOAgr);
    }*/
    
    /********************************************************************************************** 
* @Description  : Queueable class for callout to ERP system
* @Params       : Lease Contract Id - Set Id of Lease Contract
* @Return       : void
* @Author       : Vishal A
**********************************************************************************************/
    /*public class syncLeaseContSOQueuable implements system.Queueable, Database.AllowsCallouts{
        Private  Set<Id> contrctId;
        public syncLeaseContSOQueuable(set<Id> agree){
            this.contrctId = agree;
        }
        public void execute(QueueableContext content){
            for(Id aId: contrctId){
                //ERPAPIIntegration.leaseContracatSOCreation(new set<Id>{aId});
            }
            
        }
    }*/
    
    public void approvedContractAutomations(){
        for(Lease_Contract__c leaseContract : recordNewList){
            if(leaseContract.Contract_Stages__c == 'Approved' && leaseContract.Contract_Stages__c != recordOldMap.get(leaseContract.Id).Contract_Stages__c){
                leaseContract.Send_Lease_to_ERP__c = true;
            }
        }
    }
    
    //Added by Karishma for transfering the Contract Generation form from files to Document Record
    public void contractGenerationFormDocument(){
        Set<Id> verifiedIds = new Set<Id>();
        Set<Id> setOppId=new Set<Id>();
        String documentType = system.label.Contract_Document;
        for(Lease_Contract__c contract : recordNewMap.values()){
            if(recordNewMap.get(contract.Id).Contract_Document_Uploaded__c && !recordOldMap.get(contract.Id).Contract_Document_Uploaded__c ){
                verifiedIds.add(contract.Id);
                 setOppId.add(contract.Opportunity__c);
            }
        }
        attachFilesToDocument(verifiedIds,documentType,setOppId);
    }
    
    //Added by Karishma for transfering the Contract Generation form from files to Document Record
    public void signedContractGenerationFormDocument(){
        Set<Id> verifiedIds = new Set<Id>();
        String documentType = 'Signed Contract';
        Set<Id> setOppId=new Set<Id>();
        for(Lease_Contract__c contract : recordNewMap.values()){
            if(recordNewMap.get(contract.Id).Signed_Contract_Uploaded__c && !recordOldMap.get(contract.Id).Signed_Contract_Uploaded__c  ){
                verifiedIds.add(contract.Id);
                setOppId.add(contract.Opportunity__c);
            }
        }
        attachFilesToDocument(verifiedIds,documentType,setOppId);
    }
    
    //Added by Karishma for files to be attached on document object
    public void attachFilesToDocument(Set<Id> verifiedIds, String documentType,Set<Id> setOppId){
        Set<ID> captureContDocId = new Set<ID>();
         Id renewalContractRcdTyId = Schema.SObjectType.Lease_Contract__c.getRecordTypeInfosByDeveloperName().get('Renewal_Contract').getRecordTypeId();
        Id oppCommRenewRcdTyp= Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Commercial Lease Renewal').getRecordTypeId();

        Map<Id,Boolean> mapOppIdToNewUnitFlag=new Map<Id,Boolean>();
        
        if(verifiedIds.Size() > 0){
            Map<ID,ID> contentDocumentLinkMap = new Map<ID,ID>();
            List<Lease_Contract__c> updatedContractContatiner = new List<Lease_Contract__c>();
            List<ContentDocumentLink> allIds = [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId in :verifiedIds];
            List<Unit_Plan__c> lstOppUnit=[Select id,Renewal_new_unit__c,Opportunity__c from Unit_Plan__c where Opportunity__c in: setOppId];
            system.debug('lstOppUnit>>>>>>>'+lstOppUnit);
            if(!lstOppUnit.isEmpty()){
                for(Unit_Plan__c up:lstOppUnit){
                    system.debug('>>>>>>>>'+up.Renewal_new_unit__c);
                    if(up.Renewal_new_unit__c==True){
                        mapOppIdToNewUnitFlag.put(up.Opportunity__c,true);
                    }
                
                }
            } 
            system.debug('mapOppIdToNewUnitFlag>>>>>>>'+mapOppIdToNewUnitFlag);
            List<Lease_Contract__c> updatedContractList = [Select id, Contract_Stages__c, Contract_Signed_Date__c, RecordTypeId,
                                                           Contract_Document_Uploaded__c, Signed_Contract_Uploaded__c , Opportunity__c
                                                           from Lease_Contract__c where id in :verifiedIds];
            
            for(Lease_Contract__c updateContract : updatedContractList){
                if(updateContract.Signed_Contract_Uploaded__c){
                    updateContract.Signed_Contract_Uploaded__c = false;
                    // Added by sajid to change the stage after contract doc creation.
                    if(recordNewMap.get(updateContract.Id).Contract_Stages__c != 'Customer signature'&& 
                       recordOldMap.get(updateContract.Id).Contract_Stages__c != 'Customer signature'){
                       //check if the contract is renewal contract
                           if(updateContract.RecordTypeId == renewalContractRcdTyId || updateContract.RecordTypeId == oppCommRenewRcdTyp ){
                               updateContract.Contract_Signed_Date__c = System.today();
                               //Deal consist of new units check
                               if(mapOppIdToNewUnitFlag.containsKey(updateContract.Opportunity__c) && mapOppIdToNewUnitFlag.get(updateContract.Opportunity__c)==true){
                                  updateContract.Contract_Stages__c = 'Under handover'; 
                               }
                               else{
                                   updateContract.Contract_Stages__c = 'Active'; 
                               }
                               
                                
                           }
                           else{
                                updateContract.Contract_Stages__c = 'Customer signature';
                                updateContract.Contract_Signed_Date__c = System.today();
                           }
                        
                    }
                }else if(updateContract.Contract_Document_Uploaded__c){
                    updateContract.Contract_Document_Uploaded__c = false;
                }
                
                updatedContractContatiner.add(updateContract);
            }
            
            for(ContentDocumentLink cl : allIds){
                contentDocumentLinkMap.put(cl.LinkedEntityId, cl.ContentDocumentId);
            }
            
            for(ContentDocumentLink c : allIds){
                System.debug('Phase 3 ContentDocumentLink '+c);
                captureContDocId.add(c.ContentDocumentId);
                
            }
            Map<Id,ContentVersion> contentVersionMap = new Map<Id,ContentVersion>();
            List<ContentVersion> contentVersionList = [SELECT Id,ContentDocumentId, ContentUrl,VersionData,Title,PathOnClient FROM 
                                                       ContentVersion WHERE ContentDocumentId in :captureContDocId ];
            for(ContentVersion cv : contentVersionList){
                System.debug('Phase 4 ContentVersion '+cv);
                contentVersionMap.put(cv.ContentDocumentId, cv);
            }
            List<Id> docList = new List<Id>();
            Map<Id,Id> obDocMap = new Map<Id,Id>();  
            List<Object_Document__c> objDocument = [SELECT id, Contract__c, Document__c FROM Object_Document__c 
                                                    WHERE Contract__c in :verifiedIds];
            for(Object_Document__c obj : objDocument){
                obDocMap.put(obj.Document__c,obj.Contract__c);
                docList.add(obj.Document__c);
            }
            
            
            List<Document__c> documents = [Select id, Contract__c, Document_Type__c,
                                           Contract__r.Contract_Document_Uploaded__c,
                                           Contract__r.Signed_Contract_Uploaded__c,Attachment_Id__c from Document__c where id in :docList];
            
            List<Document__c> updateDocumentOperation = new List<Document__c>();
            List<ContentVersion> insertContentVersion = new List<ContentVersion>();
            List<ContentDocumentLink> insertContentDocumentLink = new List<ContentDocumentLink>();
            Set<Id> docId = new Set<Id>();
            Map<Id,Lease_Contract__c> contractDetails = new Map<Id,Lease_Contract__c>();
            Map<Id,List<ContentVersion>> contentVersionsToCont = new Map<Id,List<ContentVersion>>();
            String emailTemplateName;
            
            for(Document__c doc : documents){
                if((doc.Document_Type__c == documentType && doc.Contract__r.Contract_Document_Uploaded__c) ||
                   (doc.Document_Type__c == 'Signed Contract' && doc.Contract__r.Signed_Contract_Uploaded__c)){
                       
                       System.debug('Phase 6 Document and Opportunity ===>'+doc);
                       Id contentDocumentId = contentDocumentLinkMap.get(doc.Contract__c);
                       contractDetails.put(obDocMap.get(doc.id), recordNewMap.get(obDocMap.get(doc.id)));  
                       
                       ContentVersion contentVersionOpportunity = contentVersionMap.get(contentDocumentId);
                       
                       ContentVersion contentVersionDocument = new ContentVersion();
                       contentVersionDocument.ContentDocumentId = contentDocumentId;
                       contentVersionDocument.Title = contentVersionOpportunity.Title;
                       contentVersionDocument.PathOnClient = contentVersionOpportunity.PathOnClient;
                       contentVersionDocument.VersionData = contentVersionOpportunity.VersionData;
                       insertContentVersion.add(contentVersionDocument);
                       contentVersionsToCont.put(obDocMap.get(doc.id) , insertContentVersion);
                       
                       ContentDocumentLink cdLinkDocument = new ContentDocumentLink();
                       cdLinkDocument.LinkedEntityId = doc.Id;
                       cdLinkDocument.ContentDocumentId = contentDocumentId;
                       insertContentDocumentLink.add(cdLinkDocument);
                       
                       doc.Attachment_Id__c = contentDocumentId;
                       doc.Contract__c = obDocMap.get(doc.id);
                       updateDocumentOperation.add(doc); 
                       
                       if(doc.Document_Type__c == 'Signed Contract'){
                           docId.add(doc.Id);
                           emailTemplateName = ConstantUtility.SIGNED_CONTRACT_EMAIL_TEMP;
                       }else if(doc.Document_Type__c == documentType){
                           docId.add(doc.Id);
                           emailTemplateName = ConstantUtility.CONTRACT_EMAIL_TEMP;
                       }
                   }
            }  
            
            try{
                update updatedContractContatiner;
                update updateDocumentOperation;
                //insert insertContentVersion;
                insert insertContentDocumentLink;
                
                if(docId.size() > 0){
                    sendEmailToCustomer(contentVersionsToCont, contractDetails, emailTemplateName);
                    //    List<ContentDocumentLink> cdLinkList = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN: docId];
                    //    if(cdLinkList.size() > 0){
                    //        Delete cdLinkList;
                    //    }
                    
                }
                
            }
            catch (Exception ex){
                system.debug('error is '+ ex.getMessage() + ' at '+ ex.getLineNumber());
            }
        }
    }
    
    //Added by Karishma to create and attach draft ejari on contract - 21-03-2022
    public void syncDraftEjariOnApproval(){
        Id recordTypeId = Schema.SObjectType.Lease_Contract__c.getRecordTypeInfosByDeveloperName().get('Renewal_Contract').getRecordTypeId();
        for(Lease_Contract__c contract : recordNewMap.values()){
            if(contract.Contract_Stages__c == 'Draft' && contract.RecordTypeId != recordTypeId){
                createDraftEjariOnApproval(contract.Id,'CreatePendingTenancyContractRequest');
            }else if(contract.Contract_Stages__c == 'Draft' && contract.RecordTypeId == recordTypeId){
                string className = 'RenewTenancyContract';
                System.enqueueJob(new Ejari_QueueableHandlerUtil.Ejari_QueueableCreateEjari(contract.Id, className));
            }
        }
    }
    
    public static void createDraftEjariOnApproval(String contrctId, String MethodName) {
        createDraftEjariQueueable createDraftEjari = new createDraftEjariQueueable(contrctId,MethodName);
        system.enqueueJob(createDraftEjari);
    }
    
    public class createDraftEjariQueueable implements system.Queueable, Database.AllowsCallouts{
        Private  String contrctId;
        Private  String MethodName;
        public createDraftEjariQueueable(String contrctId, String MethodName){
            this.contrctId = contrctId;
            this.MethodName = MethodName;
        }
        public void execute(QueueableContext content){
            Boolean statusCode =  Ejari_IntgCls.selectEjari(contrctId,MethodName);
            /*if(statusCode){
                MethodName = 'PrintTcByContractNumberToStream';
                printDraftEjariQueueable printDraftEjari = new printDraftEjariQueueable(contrctId,MethodName);
                system.enqueueJob(printDraftEjari);
            }*/
        }
    }
    
    /*public class printDraftEjariQueueable implements system.Queueable, Database.AllowsCallouts{
        Private  String contrctId;
        Private  String MethodName;
        public printDraftEjariQueueable(String contrctId, String MethodName){
            this.contrctId = contrctId;
            this.MethodName = MethodName;
        }
        public void execute(QueueableContext content){
            Boolean statusCode =  Ejari_IntgCls.selectEjari(contrctId,MethodName);
        }
    }*/
    /***************Until here****************************************************************************************/
    
    //Added by Karishma to generate PDF of Ejari
    public void generateRenewEjariPDF(){
        for(Lease_Contract__c contract : recordNewMap.values()){
            string className = '';
            String recordId = contract.Id;
            if(contract.Ejari_Status__c == 'Ejari Activated' && contract.Ejari_Status__c != recordOldMap.get(contract.Id).Ejari_Status__c){
                className = 'PrintCertificateByContractNumberToStream';
            }else if((contract.Ejari_Status__c == 'Ejari Renewed' || contract.Ejari_Status__c == 'Draft Ejari Created' || contract.Ejari_Status__c == 'Draft Ejari Updated') && contract.Ejari_Status__c != recordOldMap.get(contract.Id).Ejari_Status__c){
                className = 'PrintTcByContractNumberToStream';
            }
            if(String.isNotEmpty(className)){               
                System.enqueueJob(new Ejari_QueueableHandlerUtil.Ejari_QueueableCreateEjari(recordId, className)); 
            }
        }
    }
    
    //Added by Karishma to activate the ejari
    public void activateEjari(){
        for(Lease_Contract__c contract : recordNewMap.values()){
            string className = '';
            String recordId = contract.Id;
            if(contract.Contract_Stages__c == 'Approved' && contract.Contract_Stages__c != recordOldMap.get(contract.Id).Contract_Stages__c && contract.Contract_Number__c != null){
                className = 'ActivateTcByContractNumber';
            }
            if(String.isNotEmpty(className)){               
                System.enqueueJob(new Ejari_QueueableHandlerUtil.Ejari_QueueableCreateEjari(recordId, className)); 
            }
        }
    }
    
   /**********************************************************************************************
    * @Description : Method to send email to customer after contract document creation.
    * @Params : Map<Id,List<ContentVersion>> contentVersionsToOpp
    * @Param : Map<Id,Opportunity> oppDetails
    * @Param : String emailTemplateName
    * @Return : void
    * @Author : Sajid Hameed
    **********************************************************************************************/
        public void sendEmailToCustomer(Map<Id,List<ContentVersion>> contentVersionsToCont, Map<Id,Lease_Contract__c> contractDetails, String emailTemplateName){
            // initialize temporary email list
            String accEmail = '';
            String conId = '';
            String contractOpp = '';
            List<Messaging.SingleEmailMessage> messageList = new List<Messaging.SingleEmailMessage>();
            EmailTemplate emailTemplate = [ SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body
                                           FROM EmailTemplate
                                           WHERE name =: emailTemplateName];
            System.debug('emailTemplate: '+ emailTemplate);
            Contact con = [SELECT ID FROM Contact WHERE Email != null LIMIT 1 ];
            for(Id contractId : contentVersionsToCont.keySet()){
                if(contractDetails.containsKey(contractId)){
                    accEmail = contractDetails.get(contractId).Email__c;
                    contractOpp = contractDetails.get(contractId).Opportunity__c;
                }
                system.debug('@@conID :'+con.Id);
                System.debug('accEmail: '+ accEmail);
                List<Messaging.Emailfileattachment> efaList = new List<Messaging.Emailfileattachment>();
                // initialize one or more single emails as you need
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                for(ContentVersion cv : contentVersionsToCont.get(contractId)){
                    Blob fileData = cv.VersionData;
                    Messaging.EmailFileAttachment efa = new Messaging.EmailfileAttachment();
                    efa.setFileName(cv.Title);
                    efa.setBody(fileData);
                    efaList.add(efa);
                }
                // set the recipient email
                message.setToAddresses(new String[] {accEmail });
                // set the email template id
                message.setTemplateId(emailTemplate.Id);
                // do not save email as activity
                message.setSaveAsActivity(false);
                // set the id for the object
                message.setWhatId(contractOpp);
                // set target object id as your current user id
                message.setTargetObjectId( con.ID );
                message.setFileAttachments(efaList);
                // add current message to message list
                messageList.add(message);
            }
            // create savepoint before executing statement
            Savepoint sp = Database.setSavepoint();
            // send the temporary email list
            Messaging.sendEmail(messageList);
            // rollback the transaction before commiting to database
            Database.rollback(sp);
            // initialize the actual message list to be sent
            List<Messaging.SingleEmailMessage> actualMessageList = new List<Messaging.SingleEmailMessage>();
            OrgWideEmailAddress orgWideEmailAddress = new OrgWideEmailAddress();
            if(!String.isBlank(AppSettings__c.getValues('OrgWideEmailAddressForLeasing').TextValue__c)){
                orgWideEmailAddress = EmailNotificationHelper.getOrgWideEmailAddress(AppSettings__c.getValues('OrgWideEmailAddressForLeasing').TextValue__c);
            }
            system.debug(orgWideEmailAddress.Id);
            // loop through the previous message list and set the email fields
            for (Messaging.SingleEmailMessage email : messageList) {
                Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
                emailToSend.setToAddresses(email.getToAddresses());
                emailToSend.setHTMLBody(email.getHTMLBody());
                emailToSend.setSubject(email.getSubject());
                if(orgWideEmailAddress!=null){
                    emailToSend.setOrgWideEmailAddressId(orgWideEmailAddress.Id);
                }
                emailToSend.setFileAttachments(email.getFileAttachments());
                actualMessageList.add(emailToSend);
            }
            // send the actual message list
            Messaging.SendEmailResult [] serList = Messaging.sendEmail(actualMessageList);
            // make sure the emails are sent successfully
            String errorMessage = '';
            for(Messaging.SendEmailResult ser : serList){
                if(!ser.isSuccess()){
                    for(Messaging.SendEmailError err : ser.getErrors()) {
                        errorMessage += err.getMessage() + '\n';
                    }
                    system.debug('@@Error :'+errorMessage);
                }
            }
        }
    
    //Added by Karishma to activated renewed ejari
    public void activateRenewedEjari(){
        Id recordTypeId = Schema.SObjectType.Lease_Contract__c.getRecordTypeInfosByDeveloperName().get('Renewal_Contract').getRecordTypeId();
        for(Lease_Contract__c contract : recordNewMap.values()){
            string className = '';
            String recordId = contract.Id;
            if(contract.Draft_Ejari_Uploaded__c && contract.Draft_Ejari_Uploaded__c != recordOldMap.get(contract.Id).Draft_Ejari_Uploaded__c && contract.RecordTypeId == recordTypeId){
                className = 'ActivateTcByContractNumber';
            }
            if(String.isNotEmpty(className)){               
                System.enqueueJob(new Ejari_QueueableHandlerUtil.Ejari_QueueableCreateEjari(recordId, className)); 
             }
        }
    }
    
    //Added by Karishma to automate API calls on Contract Termination
    public void terminateContractAutomations(){
        system.debug('@@@inside termination automation :'+recordNewList);
        List<Lease_Contract__c> contractList = new List<Lease_Contract__c>();
        for(Lease_Contract__c contract : recordNewList){
            if(contract.Contract_Stages__c == 'Terminated' && contract.Contract_Stages__c != recordOldMap.get(contract.Id).Contract_Stages__c){
                Lease_Contract__c leaseContract = new Lease_Contract__c();
                leaseContract.Id = contract.Id;
                leaseContract.Trigger_Terminate_Ejari_Contract__c = true;
                leaseContract.Sync_Contract_Termination__c = true;
                contractList.add(leaseContract);
            }
        }
        system.debug('@@@contractList :'+contractList);
        if(!contractList.isEmpty()){
            update contractList;
        }
    }
    
    //Added by Karishma to flag customers under compliance 26th May 2022
    public void flagCustomersUnderCompliance(){
        Set<String> masterFlagERPNames = new Set<String>();
        masterFlagERPNames.add(label.COMMERCIAL_COMPLIANCE_ISSUES);
        masterFlagERPNames.add(label.RESIDENTIAL_COMPLIANCE_ISSUES);
        List<Master_Flag__c> masterFlags = [SELECT ID,ERP_Flag_Name__c FROM Master_Flag__c WHERE ERP_Flag_Name__c =: masterFlagERPNames];
        Map<String,Id> mapMasterFlag = new Map<String,Id>();
        for(Master_Flag__c mFlag: masterFlags){
            mapMasterFlag.put(mFlag.ERP_Flag_Name__c,mFlag.Id);
        }
        List<Flag__c> flagList = new List<Flag__c>();
        
        for(Lease_Contract__c contract : recordNewList){
            if(contract.Contract_Stages__c == 'Compliance' && contract.Contract_Stages__c != recordOldMap.get(contract.Id).Contract_Stages__c){
                Flag__c flag = new Flag__c();
                flag.Active__c = true;
                flag.Customer__c = contract.Account__c;
                flag.Start_Date__c = system.today();
                    
                if(contract.LeasingType__c == 'Residential Units'){
                   flag.Master_Flag__c = mapMasterFlag.get(system.label.RESIDENTIAL_COMPLIANCE_ISSUES);
                }else if(contract.LeasingType__c == 'Commercial Units'){
                   flag.Master_Flag__c = mapMasterFlag.get(system.label.COMMERCIAL_COMPLIANCE_ISSUES);       
                }
                flagList.add(flag);
            }
        }
        if(!flagList.isEmpty()){
            insert flagList;
        }
    }
    
}