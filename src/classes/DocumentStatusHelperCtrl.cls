public without sharing class DocumentStatusHelperCtrl {
 @AuraEnabled
    public static string getDocMatrixDeveloperName(String recTypeName,ID recId,String Country, String Emirate,String brokerAccessType){
    String developerName= ''; 
    String sObjectName=    recId.getSObjectType().getDescribe().getName(); 
        if(sObjectName==ConstantUtility.SOBJ_BrokerProprietor){//get document matrix developer name 
            if(country!='AE'){
               developerName=ConstantUtility.NKHL_SHAREHOLDER_INTRNL;
            }
            else if(country=='AE' && emirate!='Dubai'){
                //developerName='NKHL_Shareholder_Local';
                developerName=ConstantUtility.NKHL_SHAREHOLDER_LOCAL_NONDUBAI;

            }
            else if(country=='AE' && emirate=='Dubai'){
               developerName=ConstantUtility.NKHL_SHAREHOLDER_LOCAL_DUBAI;
            } 
        } 
        
        else if(sObjectName==ConstantUtility.SOBJ_Agent){
               String agentRepresentative = ConstantUtility.RT_AGENT_REP;
               String authorizeSignatory =  ConstantUtility.DN_AUTHO_SIGN;
            
             if((recTypeName=='Agent_Representative') && country!='AE')
            {
                developerName=ConstantUtility.NKHL_AGENT_REP_INTRNL;
                
            }
                else if((recTypeName=='Authorized_Signatory') && country!='AE')
            {
                developerName=ConstantUtility.NKHL_AUTH_SIGNATORY_INTRNL;
                
            }
           else if((recTypeName=='Agent_Representative') && country=='AE' && emirate != 'Dubai')
            {
                developerName=ConstantUtility.NKHL_AGENT_REP_LOCAL_NONDUBAI;        
            }
            
            else if((recTypeName=='Agent_Representative') && country=='AE' && emirate == 'Dubai' && brokerAccessType!='Admin')
            {
                developerName=ConstantUtility.NKHL_AGENT_REP_AGENT_LOCAL_DUBAI;   
            }
                else if((recTypeName=='Agent_Representative') && country=='AE' && emirate == 'Dubai' && brokerAccessType=='Admin')
            {
                developerName=ConstantUtility.NKHL_AGENT_REP_ADMIN_LOCAL_DUBAI;     
            }
            else if((recTypeName=='Authorized_Signatory') && country=='AE'  && emirate != 'Dubai')
            {
                developerName=ConstantUtility.NKHL_AUTH_SIGNATORY_LOCAL_NONDUBAI   ;  
            }
            
            else if((recTypeName=='Authorized_Signatory') && country=='AE'  && emirate == 'Dubai')
            {
                developerName=  ConstantUtility.NKHL_AUTH_SIGNATORY_DUBAI; 
            }
        }
        
        return developerName;
    }
     @AuraEnabled
    Public static Map<String,String> checkDocumentUploadStatus(List<Broker_Proprietor__c> brokerProprietorsList,List<Broker_Agents__c> brokerAgentsList){
     /*Start- Check All required files are uploaded for all individual broker Agents added by Mamta*/
        Map<String,STring> recordIDDocStatusMap = new Map<String,STring>();
        Map<String,String> IDDocUploadStatusMap = new Map<String,String>();
        Map<String,STring> agentAndDocMap = new Map<String,String>();
        Map<String,STring> partnerAndDocMap = new Map<String,String>();
        Map<String,STring> agentAndDocMatrixIDMap = new Map<String,String>();
        List<Id> documentMatrixIdList=new list<Id>();
   
        for(Broker_Proprietor__c pr:[SELECT Id, Agency_Registration__r.Place_of_Incorporation__c ,Agency_Registration__r.Emirate__c
                                     from Broker_Proprietor__c WHERE ID IN:brokerProprietorsList]){
             String developerName='';
                                         
             String country=pr.Agency_Registration__r.Place_of_Incorporation__c ;
             String emirate=  pr.Agency_Registration__r.Emirate__c;
             developerName=  getDocMatrixDeveloperName('',pr.Id, Country,  Emirate,'');
             partnerAndDocMap.put(pr.Id,developerName);                           
                                         
                                         
          }
        
        for(Broker_Agents__c br : [SELECT Id,RecordType.Developername, Broker_Access_Type__c ,Agency_Registration__r.Place_of_Incorporation__c ,Agency_Registration__r.Emirate__c 
                                       FROM Broker_Agents__c where Id IN: brokerAgentsList])
            {
                String developerName='';
                String country=br.Agency_Registration__r.Place_of_Incorporation__c ;
                String emirate=  br.Agency_Registration__r.Emirate__c;
                String brokerAccessType=br.Broker_Access_Type__c;
                String recTypeName = br.RecordType.Developername;
                developerName=  getDocMatrixDeveloperName(recTypeName,br.Id, Country,  Emirate,brokerAccessType);

             agentAndDocMap.put(br.Id,developerName);
            }
        
         for(NKHL_Documentation_Matrix__mdt  doc : [SELECT id,developerName FROM NKHL_Documentation_Matrix__mdt  WHERE developerName IN :agentAndDocMap.values() OR developerName IN : partnerAndDocMap.values()])
        {
            documentMatrixIdList.add(doc.id);
            agentAndDocMatrixIDMap.put(doc.developerName ,doc.id);
            
        } 
        
        Map<String,List<NKHL_Documentation_Template__mdt >> docandTemplatesLstMap = new Map<String,List<NKHL_Documentation_Template__mdt >>();
        for(NKHL_Documentation_Template__mdt  doc:[select id ,NKHL_Documentation_Matrix__r.DeveloperName,Document_Label__c,Is_Required_Expiry_Date__c,
                                                 Is_Required_Issue_Date__c,Required__c,is_Document_ID_NumberRequired__c 
                                                 from NKHL_Documentation_Template__mdt  where 
                                                 (NKHL_Documentation_Matrix__r.developername=:agentAndDocMap.values() OR NKHL_Documentation_Matrix__r.developername=:partnerAndDocMap.values() )AND Required__c=true ])//Get required templates
        {
          if(docandTemplatesLstMap.containskey(doc.NKHL_Documentation_Matrix__r.developername)){
              List<NKHL_Documentation_Template__mdt  > documentTemplateValues = docandTemplatesLstMap.get(doc.NKHL_Documentation_Matrix__r.developername);
              documentTemplateValues.add(doc);
              docandTemplatesLstMap.put(doc.NKHL_Documentation_Matrix__r.developername,documentTemplateValues);//Map of developerName of matrix and Required templates
          } 
          else{
              List<NKHL_Documentation_Template__mdt > documentTemplateValues = new List<NKHL_Documentation_Template__mdt >();
              documentTemplateValues.add(doc);
              docandTemplatesLstMap.put(doc.NKHL_Documentation_Matrix__r.developername,documentTemplateValues);//Map of developerName of matrix and Required templates
          }  
          
        } 
       system.debug('docandTemplatesLstMap is '+ docandTemplatesLstMap); 
      
      Map<String, Set<String>>  agentIDDocumentSetMap =new  Map<String, Set<String>> (); //Map of Agent Id and set of all document types uploaded for it
      Map<String, Set<String>>  partnerIDDocumentSetMap =new  Map<String, Set<String>> (); //Map of Partner  Id and set of all document types uploaded for it
   
      List<Document__c>  documents =[select id,Approval_Status__c ,Remark__c ,Document_Type__c ,Parent_Id__c  FROM Document__c WHERE 
                                     Parent_Id__c IN:agentAndDocMap.keySet() OR Parent_Id__c IN:partnerAndDocMap.keySet()]; 
      for(Document__c doc :documents){
          String sObjectName= Id.valueof((doc.Parent_Id__c)).getSObjectType().getDescribe().getName();
          if(sObjectName=='Broker_Agents__c'){//check added documents in broker agent sObject
          if(agentIDDocumentSetMap.containskey(doc.Parent_Id__c)){
              Set<String> documentValues = agentIDDocumentSetMap.get(doc.Parent_Id__c);
              documentValues.add(doc.Document_Type__c);
              agentIDDocumentSetMap.put(doc.Parent_Id__c,documentValues);
          }
          else{
              Set<String> documentValues = new Set<String>();
              documentValues.add(doc.Document_Type__c);
              agentIDDocumentSetMap.put(doc.Parent_Id__c,documentValues);
          }
          }
          else if(sObjectName=='Broker_Proprietor__c'){//check added documents in broker partner sObject
          if(partnerIDDocumentSetMap.containskey(doc.Parent_Id__c)){
              Set<String> documentValues = partnerIDDocumentSetMap.get(doc.Parent_Id__c);
              documentValues.add(doc.Document_Type__c);
              partnerIDDocumentSetMap.put(doc.Parent_Id__c,documentValues);
          }
          else{
              Set<String> documentValues = new Set<String>();
              documentValues.add(doc.Document_Type__c);
              partnerIDDocumentSetMap.put(doc.Parent_Id__c,documentValues);
          }
          }
            
        }  
        
       
        for(Broker_Proprietor__c partner :brokerProprietorsList){
            //BrokerDataWrapper wrp = new BrokerDataWrapper();
             boolean allRequiredFileUploaded = true;
            if(partnerAndDocMap.containskey(partner.Id)){
                String developerName = partnerAndDocMap.get(partner.Id);//get developer name of templateMatrix based on agent
                List<NKHL_Documentation_Template__mdt> requireDocLst = docandTemplatesLstMap.get(developerName);//get all required doc templates for particular developer name
                system.debug('requireDocLst is '+ requireDocLst);
                system.debug('partner is '+ partner);
                for(NKHL_Documentation_Template__mdt  DocTemp: requireDocLst){
                    Set<String> documentTypesSet = partnerIDDocumentSetMap.get(partner.Id);
                    system.debug('documentTypesSet is '+ documentTypesSet);
                    if(documentTypesSet==null){
                        allRequiredFileUploaded = false;
                        //break;
                       
                    }
                    else if(!documentTypesSet.contains(DocTemp.Document_Label__c)){//check if added document set contains all required documents or not
                        allRequiredFileUploaded= false;//mark it false , if not all files uploaded for particular agent to prevent submitting form

                    }
                    
                }
                if(allRequiredFileUploaded==false){
                   recordIDDocStatusMap.put(partner.id,'Pending');

                }
                else{
                     recordIDDocStatusMap.put(partner.id,'Uploaded');
 
                }
          }
           /* if(allRequiredFileUploaded==false){
                wrp.brokerprop= partner;
                wrp.DocUploadStatus='Pending';
            }
            else if(allRequiredFileUploaded==true){
                wrp.brokerprop= partner;
                wrp.DocUploadStatus='Completed';
            }
            brokerdocWrpLst.add(wrp);*/
        }
        
        //check if partner contains all required documents
        for(Broker_Agents__c agent :brokerAgentsList){
            boolean allRequiredFileUploaded = true;
            String recTypeName = agent.RecordType.Developername;
            String brokerAccessType=agent.Broker_Access_Type__c;
            //BrokerDataWrapper agentWrp = new BrokerDataWrapper();


            if(agentAndDocMap.containskey(agent.Id)){
                String developerName = agentAndDocMap.get(agent.Id);//get developer name of templateMatrix based on agent
                List<NKHL_Documentation_Template__mdt> requireDocLst = docandTemplatesLstMap.get(developerName);//get all required doc templates for particular developer name
                system.debug('requireDocLst is '+ requireDocLst);
                system.debug('agent is '+ agent);
                for(NKHL_Documentation_Template__mdt  DocTemp: requireDocLst){
                    Set<String> documentTypesSet = agentIDDocumentSetMap.get(agent.Id);
                    system.debug('documentTypesSet is '+ documentTypesSet);
                    if(documentTypesSet==null){
                        allRequiredFileUploaded = false;
                        //IDDocUploadStatusMap.put(agent.Id,'Pending');

                       // break;
                    }
                    else if(!documentTypesSet.contains(DocTemp.Document_Label__c)){//check if added document set contains all required documents or not
                        allRequiredFileUploaded= false;//mark it false , if not all files uploaded for particular agent to prevent submitting form
                       // IDDocUploadStatusMap.put(agent.Id,'Pending');

                        //break;
                    }
               
          }
           if(allRequiredFileUploaded==false){
                   recordIDDocStatusMap.put(agent.id,'Pending');

                }
                else{
                     recordIDDocStatusMap.put(agent.id,'Uploaded');
 
                }     
                
           /* if(recTypeName==ConstantUtility.RT_AGENT_REP && brokerAccessType=='Admin'){   
             if(allRequiredFileUploaded==false){
                agentWrp.brokerAgentRepresentativeList= agent;
                agentWrp.DocUploadStatus='Pending';
            }
            else if(allRequiredFileUploaded==true){
                agentWrp.brokerAgentRepresentativeList= agent;
                agentWrp.DocUploadStatus='Completed';
            }
                }
                
                else if(recTypeName==ConstantUtility.DN_AUTHO_SIGN){
                    if(allRequiredFileUploaded==false){
                        agentWrp.brokerAgentAuth= agent;
                        agentWrp.DocUploadStatus='Pending';
                    }
                    else if(allRequiredFileUploaded==true){
                        agentWrp.brokerAgentAuth= agent;
                        agentWrp.DocUploadStatus='Completed';
                    }
                }
                brokerdocWrpLst.add(agentWrp);*/
                }
        }
        system.debug('agentIDDocumentSetMap is '+ agentIDDocumentSetMap);
        system.debug('recordIDDocStatusMap is '+ recordIDDocStatusMap);
        
       /* if(allRequiredFileUploaded==false){
            isSuccess='false';
            message ='Upload all required documents before submitting the form';
            return isSUccessWithMsg(isSuccess,message);


       }*/
        /*End - Check All required files are uploaded for all individual broker Agents - added by Mamta*/
         /*End - File upload validation on submit*/
         //return brokerdocWrpLst;  
         return recordIDDocStatusMap;
    }
    
}