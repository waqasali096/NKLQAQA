/**	
* @author : Muhammad Moneeb	
* @createdDate : 29 Dec 2021	
* @lastModifiedDate : 29 Dec 2021	
* @purpose - Initial Development	
* @usage -Trigger handler for ContentDocumentLinkTrigger	
*/	
public class ContentDocumentLinkHandler {	
    
    public static void afterEvent(List<ContentDocumentLink> cvList , String eventType){	
        Set<ID> IDSet = new Set<ID>();
        Set<ID> CDIDSet = new Set<ID>();
        Map<ID, ContentDocumentLink> linkEntityIdContentDocLinkMap = new Map<ID, ContentDocumentLink>();// Added by Sajid
    
        for(ContentDocumentLink cv : cvList){	
            system.debug('ContentDocumentLink%%'+cv);
            String strObjPrefix = String.valueOf(cv.LinkedEntityId).substring(0, 3);	
            if(strObjPrefix != User.sObjectType.getDescribe().getKeyPrefix()) {	
                IDSet.add(cv.LinkedEntityId);
                // Added by Sajid
                if(eventType == 'Insert'){
                    linkEntityIdContentDocLinkMap.put(cv.LinkedEntityId, cv);
                }
            }	
            CDIDSet.add(cv.Id);
        }	
        if(IDSet.size() > 0){
            if(eventType == 'Insert'){
                attatchFileToDoc(CDIDSet, IDSet);
            }
            updateObjectList(IDSet ,eventType, linkEntityIdContentDocLinkMap);
        }	
    }	
    
    /******************************************************************************************************
    * @Description        : Function to update respective documents checkboxes to attach file to document.                                                                                         
    * @Return             : void   
    * @Author             : Sajid Hameed 
    * Module 			  : Leasing, Sales   
    * LastModified By 	  : Ashams on 19th April
    * Changes			  : Added checkbox updates for Sales SPA & Booking form updates                                                                    
    *******************************************************************************************************/
    public static void attatchFileToDoc(Set<ID> CDIDSet, Set<ID> cdLinkIdSet){
        String query;
        String subQuery = '( SELECT Id, contentdocument.title, ContentDocument.CreatedDate FROM ContentDocumentLinks where Id IN: CDIDSet order by ContentDocument.CreatedDate desc)';
        Set<ID> oppIdList = new Set<ID>();
        Set<ID> contractIdList = new Set<ID>();
        Set<ID> handoverIdList = new Set<ID>();
        Set<ID> projectIdList = new Set<ID>();
        String sObjName;
        /* Check sObject Name */
        for(ID objId : cdLinkIdSet){
            sObjName = objId.getSObjectType().getDescribe().getName();
            if(sObjName == 'Opportunity') {
                oppIdList.add(objId);	
            }else if(sObjName == 'Lease_Contract__c'){
                contractIdList.add(objId);
            }else if(sObjName == 'Handover__c'){
                handoverIdList.add(objId);
            }else if(sObjName == 'Project__c'){
                projectIdList.add(objId);
            }else{
                return;
            }
        }
        
        if(oppIdList.size() > 0){
            query = 'SELECT Id, Booking_Form_Generated__c, Payment_Advice_Uploaded__c, Payment_Receipt_Uploaded__c,Document_Type__c,Booking_Form_Generated_Sales__c,SPA_Document_Generated__c, '+ subQuery +' FROM Opportunity where Id IN: oppIdList';
        }else if(contractIdList.size() > 0){
            query = 'SELECT Id, Signed_Contract_Uploaded__c, '+ subQuery +' FROM Lease_Contract__c where Id IN: contractIdList';
        }else if(handoverIdList.size() > 0){
            query = 'SELECT Id, Move_In_Application_Uploaded__c, '+ subQuery +' FROM Handover__c where Id IN: handoverIdList';
        }else if(projectIdList.size() > 0){
            query = 'SELECT Id, Landlord_Signature_Uploaded__c, '+ subQuery +' FROM Project__c where Id IN: projectIdList';
        }
        
        if(String.isNotEmpty(query)){
            List<sObject> objSet = new List<sObject>();
            for(sObject obj: Database.query(query)){
                //Added by Ashams for Sales SPA & BF changes
                if(sObjName == 'Opportunity'){
                    if(obj.get('Document_Type__c') == 'Sales Booking Form' && obj.get('Document_Type__c')!=null ){
                        obj.put('Booking_Form_Generated_Sales__c', true);
                        obj.put('Document_Type__c', '');
                    }else if(obj.get('Document_Type__c') == 'Sales SPA' && obj.get('Document_Type__c')!=null){
                        obj.put('SPA_Document_Generated__c', true);
                        obj.put('SPA_Generated__c', true);
                        obj.put('Document_Type__c', '');
                    }
                }
                
                System.debug(JSON.serialize('Opp Before:******* '+obj));
                List<SObject> contentDocLink= obj.getSObjects('ContentDocumentLinks');
                for(sObject CDL : contentDocLink){
                    System.debug('Title '+CDL.getSobject('contentdocument').get('title'));
                    String title = (String) CDL.getSobject('contentdocument').get('title');
                    /***** Update checkbox according to title *****/
                    
                    if(title.contains( system.Label.Leasing_Booking_Form)){
                        obj.put('Booking_Form_Generated__c', true);
                        System.debug('Booking Form Generated ');
                    }
                    else if(title.contains(system.Label.Payment_Advice)){
                        obj.put('Payment_Advice_Uploaded__c', true);
                        System.debug('Payment Advice Generated ');
                    }
                    else if(title.contains( system.Label.Payment_Receipt)){
                        obj.put('Payment_Receipt_Uploaded__c', true);
                        System.debug('Payment Receipt Generated ');
                    }
                    else if(title.contains(system.Label.Contract)){
                        obj.put('Contract_Document_Uploaded__c', true);
                    }
                    else if(title.contains(system.Label.Signed_Contract)){
                        obj.put('Signed_Contract_Uploaded__c', true);
                    }
                    else if(title.contains(system.Label.Move_In_Form)){
                        obj.put('Move_In_Application_Uploaded__c', true);
                    }
                    else if(title.contains(system.Label.Landlord_Signature)){
                        obj.put('Landlord_Signature_Uploaded__c', true);
                    }
                    
                }
                objSet.add(obj); 
                System.debug(JSON.serialize('Opp After:******* '+obj));
            }
            
            /* Update record */
            if(objSet.size() > 0){
                //List<sObject> objList = new List<sObject>(objSet);
                System.debug('Before Update Opp: '+objSet);
                update objSet;
                System.debug('Update Opp: '+objSet);
            }
            
        }
    }
    
    /******************************************************************************************************
    * @Description        : This Function updates checkbox on document's parent records after file is inserted                                                                                        
    * @Return             : void   
    * @Author             :                                                                     
    *******************************************************************************************************/
    public static void updateObjectList(Set<ID> cdLinkIdSet , String eventType, Map<ID, ContentDocumentLink> linkEntityIdContentDocLinkMap) {	
        try{	
            system.debug('cdLinkIdSet->'+cdLinkIdSet);
            Map<String, String> LinkedEntityDownURLMap;
            //Added by Sajid
            if(linkEntityIdContentDocLinkMap.size() > 0){
                LinkedEntityDownURLMap = createContentDistribution(cdLinkIdSet, linkEntityIdContentDocLinkMap); 
            }
            List<sObject> finalList = getObjectList(cdLinkIdSet , eventType);	
            //Modified By Sajid, Added Download_Url_Field_Api_Name__c, Document__c, Lead__c
            List<Object_Document__c> objDocList = [Select id,Checkbox_Field_API_Name__c,Calling_List__c,Registration__c,
                                                   Opportunity__c,Case__c,Special_Offer__c, Project__c, Handover__c,Contract__c, 
                                                   Download_Url_Field_Api_Name__c, Document__c, Lead__c from Object_Document__c 	
                                                   where Document__c IN : cdLinkIdSet]; 	
            system.debug('objDocList>>>' + objDocList);	
            Map<ID,Object_Document__c> oppobjDocMap = new Map<ID,Object_Document__c>();	
            Map<ID,Object_Document__c> caseObjDocMap = new Map<ID,Object_Document__c>();	
            Map<ID,Object_Document__c> OfferObjDocMap = new Map<ID,Object_Document__c>();	
            Map<ID,Object_Document__c> registerationObjDocMap = new Map<ID,Object_Document__c>();	
            Map<ID,Object_Document__c> callingObjDocMap = new Map<ID,Object_Document__c>();	
            Map<ID,Object_Document__c> projectObjDocMap = new Map<ID,Object_Document__c>();	
            Map<ID,Object_Document__c> handoverObjDocMap = new Map<ID,Object_Document__c>();
            Map<ID,Object_Document__c> leaseContractDocMap = new Map<ID,Object_Document__c>();
            Map<ID,Object_Document__c> leadDocMap = new Map<ID,Object_Document__c>(); //Added By Sajid
            
            for(Object_Document__c objDoc : objDocList){	
                if(objDoc.Opportunity__c != null && objDoc.Checkbox_Field_API_Name__c != '' ){	
                    oppobjDocMap.put(objDoc.Opportunity__c,objDoc);	
                }else if(objDoc.Case__c != null && objDoc.Checkbox_Field_API_Name__c != ''){	
                    caseObjDocMap.put(objDoc.Case__c,objDoc);	
                }else if(objDoc.Special_Offer__c != null && objDoc.Checkbox_Field_API_Name__c != ''){	
                    OfferObjDocMap.put(objDoc.Special_Offer__c,objDoc);	
                }else if(objDoc.Registration__c!=null && objDoc.Checkbox_Field_API_Name__c!= ''){	
                    registerationObjDocMap.put(objDoc.Registration__c,objDoc);	
                }	
                else if(objDoc.Calling_List__c!=null && objDoc.Checkbox_Field_API_Name__c!= ''){	
                    callingObjDocMap.put(objDoc.Calling_List__c,objDoc);	
                }else if(objDoc.Project__c!=null && (objDoc.Checkbox_Field_API_Name__c!= '' ||
                                                     objDoc.Download_Url_Field_Api_Name__c!= '')){ // Added by Sajid
                    projectObjDocMap.put(objDoc.Project__c,objDoc);	
                }else if(objDoc.Handover__c != null && objDoc.Checkbox_Field_API_Name__c!= ''){
                    handoverObjDocMap.put(objDoc.Handover__c, objDoc);
                }else if(objDoc.Contract__c != null && objDoc.Checkbox_Field_API_Name__c!= ''){
                    leaseContractDocMap.put(objDoc.Contract__c, objDoc);
                }else if(objDoc.Lead__c != null && objDoc.Checkbox_Field_API_Name__c!= ''){ //Added by Sajid
                    leadDocMap.put(objDoc.Lead__c, objDoc);
                }		
            }	
            system.debug('oppobjDocMap>>>' + oppobjDocMap);
            system.debug('caseObjDocMap>>>' + caseObjDocMap);
            List<Opportunity> oppList = new List<Opportunity>();
            List<Case> caseList = new List<Case>();
            List<special_offer__c> specialOfferList = new List<special_offer__c>();
            List<Registration__c> registerationList = new List<Registration__c>();
            List<Calling_List__c> callingList= new List<Calling_List__c>();
            List<Project__c> projectList= new List<Project__c>();
            List<Handover__c> handoverList= new List<Handover__c>();
            List<Lease_Contract__c> contractList= new List<Lease_Contract__c>();
            List<Lead> leadList= new List<Lead>();
            if(oppobjDocMap.keySet().Size()>0)  oppList = [Select id from Opportunity where ID IN: oppobjDocMap.keySet()];	
            if(caseObjDocMap.keySet().Size()>0) caseList = [Select id from Case where ID IN: caseObjDocMap.keySet()];	
            if(OfferObjDocMap.keySet().Size()>0)  specialOfferList = [Select id from special_offer__c where ID IN: OfferObjDocMap.keySet()];	
            if(registerationObjDocMap.keySet().Size()>0)  registerationList = [SELECT Id FROM Registration__c WHERE ID IN: registerationObjDocMap.keySet()];	
            if(callingObjDocMap.keySet().Size()>0)  callingList = [SELECT Id FROM Calling_List__c WHERE ID IN: callingObjDocMap.keySet()];	
            if(projectObjDocMap.keySet().Size()>0)  projectList = [SELECT Id FROM Project__c WHERE ID IN: projectObjDocMap.keySet()];	
            if(handoverObjDocMap.keySet().Size()>0)  handoverList = [SELECT Id FROM Handover__c WHERE ID IN: handoverObjDocMap.keySet()];
            if(leaseContractDocMap.keySet().Size()>0) contractList = [SELECT Id FROM Lease_Contract__c WHERE ID IN: leaseContractDocMap.keySet()];
            if(leadDocMap.keySet().Size()>0) leadList = [SELECT Id FROM Lead WHERE ID IN: leadDocMap.keySet()];// Added by Sajid

            
            system.debug('oppList>>>' + oppList);	
            system.debug('caseList>>>' + caseList);	
            
            for(Opportunity opp : oppList){	
                String checkBoxField = oppobjDocMap.get(opp.ID).Checkbox_Field_API_Name__c;
                if(checkBoxField != null){	
                    if(eventType == 'Insert'){	
                        opp.put(checkBoxField,true);	
                    }else if(eventType == 'Delete'){	
                        opp.put(checkBoxField,false);	
                    }	
                    finalList.add(opp);	
                }
            }
            for(case cs : caseList){	
                String checkBoxField = caseObjDocMap.get(cs.ID).Checkbox_Field_API_Name__c;	
                if(checkBoxField != null){	
                    if(eventType == 'Insert'){	
                        cs.put(checkBoxField,true);	
                    }else if(eventType == 'Delete'){	
                        cs.put(checkBoxField,false);	
                    }	
                    finalList.add(cs);	
                }	
            }	
            for(special_offer__c spOffer : specialOfferList){	
                String checkBoxField = OfferObjDocMap.get(spOffer.ID).Checkbox_Field_API_Name__c;	
                if(checkBoxField != null){	
                    if(eventType == 'Insert'){	
                        spOffer.put(checkBoxField,true);	
                    }else if(eventType == 'Delete'){	
                        spOffer.put(checkBoxField,false);	
                    }	
                    finalList.add(spOffer);	
                }	
            }for(Registration__c registerObj :registerationList ){	
                String checkBoxField = registerationObjDocMap.get(registerObj.ID).Checkbox_Field_API_Name__c;	
                if(checkBoxField != null){	
                    if(eventType == 'Insert'){	
                        registerObj.put(checkBoxField,true);	
                    }else if(eventType == 'Delete'){	
                        registerObj.put(checkBoxField,false);	
                    }	
                    finalList.add(registerObj);	
                }	
            }// added by cw swapnil for registeration	
            for(Calling_List__c callObj : callingList){	
                String checkBoxField = callingObjDocMap.get(callObj.ID).Checkbox_Field_API_Name__c;	
                if(checkBoxField != null){	
                    if(eventType == 'Insert'){	
                        callObj.put(checkBoxField,true);	
                    }else if(eventType == 'Delete'){	
                        callObj.put(checkBoxField,false);	
                    }	
                    finalList.add(callObj);	
                }	
            }	
            //Added by Jayesh for Sales Inventory Feedbacks. Dated: 21 March 2022	
            for(Project__c pr : projectList){	
                String checkBoxField = projectObjDocMap.get(pr.ID).Checkbox_Field_API_Name__c;
                String downloadURL = projectObjDocMap.get(pr.ID).Download_Url_Field_Api_Name__c;//Added by Sajid
                if(checkBoxField != null){	
                    if(eventType == 'Insert'){	
                        pr.put(checkBoxField,true);	
                    }else if(eventType == 'Delete'){	
                        pr.put(checkBoxField,false);	
                    }	
                    finalList.add(pr);	
                }
                //Added by Sajid, Save Download Url
                if(downloadURL != null){	
                    if(eventType == 'Insert'){
                        String Url = LinkedEntityDownURLMap.get(projectObjDocMap.get(pr.ID).Document__c);
                        pr.put(downloadURL,Url);	
                    }else if(eventType == 'Delete'){	
                        pr.put(downloadURL,'');	
                    }	
                    finalList.add(pr);	
                }
            }
            //Added by karishma for Handover 
            for(Handover__c handover : handoverList){
                String checkboxField = handoverObjDocMap.get(handover.Id).Checkbox_Field_API_Name__c;
                system.debug('@@Checkbox :'+ checkboxField);
                if(checkboxField != null){
                    if(eventType == 'Insert'){
                        handover.put(checkboxField,true);
                    }else if(eventType == 'Delete'){
                        handover.put(checkboxField,false);
                    }
                    finalList.add(handover);
                }
            }
            
            //Added by karishma for Contract 
            for(Lease_Contract__c contract : contractList){
                String checkboxField = leaseContractDocMap.get(contract.Id).Checkbox_Field_API_Name__c;
                system.debug('@@Checkbox :'+ checkboxField);
                if(checkboxField != null){
                    if(eventType == 'Insert'){
                        contract.put(checkboxField,true);
                    }else if(eventType == 'Delete'){
                        contract.put(checkboxField,false);
                    }
                    finalList.add(contract);
                }
            }
            
            //Added by Sajid for Lead 
            for(Lead lead : leadList){
                String checkboxField = leadDocMap.get(lead.Id).Checkbox_Field_API_Name__c;
                system.debug('@@Checkbox :'+ checkboxField);
                if(checkboxField != null){
                    if(eventType == 'Insert'){
                        lead.put(checkboxField,true);
                    }else if(eventType == 'Delete'){
                        lead.put(checkboxField,false);
                    }
                    finalList.add(lead);
                }
            }
            
            system.debug('finalList>>>' + finalList);	
            if(finalList.size() > 0){	
                update finalList;	
            }	
            
        }catch(Exception e){	
            System.debug('The following exception has occurred: ' + e.getMessage()+'line: '+e.getLineNumber() + 'stack trace :'+e.getStackTraceString());            	
        }	
    }	
    
    /******************************************************************************************************
    * @Description        : This Function retrieve Account record and document__c records after insert file 
    * 						Updates document uploaded check.                                                                                       
    * @Return             : void   
    * @Author             :                                                                     
    *******************************************************************************************************/
    public static List<sObject> getObjectList(Set<ID> cdLinkIdSet , String eventType){	
        List<Document__c> docList = [Select Id, Is_Document_Uploaded__c, Account__c,Account__r.Primary_Email__c, Object__c,Checkbox_Field_API_Name__c	
                                     from Document__c where Id IN : cdLinkIdSet];	
        system.debug('docList>>>' + docList);	
        List<sObject> finalList = new List<sObject>();	
        Map<ID,Document__c> accountDocMap = new Map<ID,Document__c>();	
        for(Document__c doc: docList){	
            if(eventType == 'Insert'){	
                doc.Is_Document_Uploaded__c = true;	
            }else if(eventType == 'Delete'){	
                doc.Is_Document_Uploaded__c = false;	
            }	
            finalList.add(doc);	
            if(doc.Account__c != null && doc.Object__c == 'Account'){	
                accountDocMap.put(doc.Account__c,doc);	
            }	
        }	
        List<Account> accList = [Select id from Account where ID IN: accountDocMap.keySet()];	
        for(Account acc : accList){	
            String checkBoxField = accountDocMap.get(acc.ID).Checkbox_Field_API_Name__c;	
            //Added by Karishma to fetch more than one api field name from checkbox field api name of document object on account	
            if(checkBoxField.contains(',')){	
                List<String> checkboxFieldNameSet = checkBoxField.split(',');	
                for(String field : checkboxFieldNameSet){	
                    if(eventType == 'Insert'){	
                        acc.put(field,true);	
                    }else if(eventType == 'Delete'){	
                        acc.put(field,false);	
                    }	
                }	
                finalList.add(acc);	
            }else{	
                if(checkBoxField != null){	
                    if(eventType == 'Insert'){	
                        acc.put(checkBoxField,true);	
                    }else if(eventType == 'Delete'){	
                        acc.put(checkBoxField,false);	
                    }	
                    finalList.add(acc);	
                }	
            }	
        }	
        system.debug('finalList>>>' + finalList);	
        return finalList;	
    }	
    
    /******************************************************************************************************
    * @Description        : This function create ContentDistribution.                                                                                       
    * @Return             : Map<String, String>   
    * @Author             : Sajid H                                                                    
    *******************************************************************************************************/
    public static Map<String, String> createContentDistribution(Set<ID> cdLinkIdSet, Map<ID, ContentDocumentLink> linkEntityIdContentDocLinkMap){
        Map<String, String> LinkedEntityDownURLMap = new Map<String, String>();
        
        try{
            Set<ID> contentVersionIdSet = new Set<ID>();
            Map<ID, ID> cdIdLinkedEnitIdSet = new Map<ID, ID>();           
            List<Object_Document__c> objDocList = [Select id, Download_Url_Field_Api_Name__c, Document__c 
                                               from Object_Document__c where Document__c IN : cdLinkIdSet AND Download_Url_Field_Api_Name__c != '']; 
    
            for(Object_Document__c objDoc: objDocList){
                
                if(linkEntityIdContentDocLinkMap.containsKey(objDoc.Document__c)){
                    ContentDocumentLink cdlink = linkEntityIdContentDocLinkMap.get(objDoc.Document__c);
                    cdIdLinkedEnitIdSet.put(cdlink.ContentDocumentId, cdlink.LinkedEntityId);
                }
            }
            List<ContentDistribution> d = new List<ContentDistribution>();
            for(ContentVersion c : [Select Id, ContentDocumentId from ContentVersion where ContentDocumentId IN: cdIdLinkedEnitIdSet.KeySet()]){
               
                contentVersionIdSet.add(c.Id);
                
                ContentDistribution contentdist = new ContentDistribution();
                contentdist.ContentVersionId = c.Id;
                contentdist.Name = 'FILE';
                
                d.add(contentdist);
            }
            
            if(d.size() > 0){
                insert d;  
            }
            
            for(ContentDistribution dis: [Select Id,  Name, ContentVersionId, ContentDocumentId, DistributionPublicUrl, ContentDownloadUrl from ContentDistribution where ContentVersionId IN: contentVersionIdSet]){
                String linkedEntity = cdIdLinkedEnitIdSet.get(dis.ContentDocumentId);
                LinkedEntityDownURLMap.put(linkedEntity, dis.ContentDownloadUrl);
            }
            System.debug('cdlMap: '+LinkedEntityDownURLMap);
        }
        catch (Exception ex){
            system.debug('error is '+ ex.getMessage() + ' at '+ ex.getLineNumber());
        }  
		return LinkedEntityDownURLMap;
    }
}