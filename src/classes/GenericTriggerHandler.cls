/**
* @author : Muhammad Moneeb
* @createdDate : 21-Dec-2021
* @lastModifieddate : 21-Dec-2021
* @purpose : Initial Development
* @usage : Generic Trigger handler for AccountTrigger,CaseTrigger,OpportunityTrigger. 
*/
public class GenericTriggerHandler{
    
    /*@usage : createDocRecord function used for create Document__c record after insertion of Case, Account & Opportunity record on the basis of DocumentConfugration.*/ 
    public static void createDocRecord(List<sObject> newList,String objectName){
        try {
            List<Document_Configuration__c> docConfList = [Select id, Object__c, Object_RecordType__c, Purpose__c from 
                                                           Document_Configuration__c];
            Map<Id,sObject> docConfObjMap = new Map<Id,sObject>();
            set<Id> accountIDSet= new set<Id>();
            Map<String,Id> recordTypenameMapToId = new Map<String,Id>();
            for (sObject obj: newList) {
                if(objectName != 'Account' && objectName != 'Special_Offer__c' && objectName != 'Lease_Contract__c' && objectName != 'Project__c'
                   && objectName != 'Unit__c' && objectName!='Handover__c' && objectName!='Agreement__c' && objectName!='Registration__c' && objectName!='Calling_List__c'
                   && objectName!='Lead' && objectName!='Price_Book__c'){
                       if((Id)obj.get('AccountId') != null)
                           accountIDSet.add((Id)obj.get('AccountId'));
                   }
                //if (objectName != 'Case'){
                recordTypenameMapToId = getRecordType(obj);
                system.debug('recordTypenameMapToId>>'+ recordTypenameMapToId);
                //}//commented by Mamta
                for (Document_Configuration__c docConf: docConfList) {
                    
                    if(/*objectName != 'Case' &&*/ objectName != 'Special_Offer__c' && objectName !='Project__c'){
                        Id recordTypeId = recordTypenameMapToId.get(docConf.Object_RecordType__c);
                        if (docConf.Object__c == objectName && recordTypeId == obj.get('RecordtypeId')) {
                            docConfObjMap.put(docConf.Id, obj);
                        }
                    }
                    //Added By Sajid
                    else if(objectName == 'Project__c' && docConf.Object__c == 'Project__c' && docConf.Purpose__c == obj.get('Project_Purpose__c')){
                        System.debug('Project Purpose '+obj.get('Project_Purpose__c'));
                        docConfObjMap.put(docConf.Id, obj);
                    }else if(docConf.Object__c != 'Project__c'){
                        if (docConf.Object__c == objectName) {
                            docConfObjMap.put(docConf.Id, obj);
                        }                        
                    }
                }
            }
            system.debug('docConfObjMap >>>' + docConfObjMap);
            List<Object_Document__c> objDocList = new List<Object_Document__c>();
            
            List<Document__c> docList = new List<Document__c>();
            Map<String,Object_Document__c> mapAccToObjDoc = new Map<String,Object_Document__c>();
            map<String,id> mapToDoc= new  map<String,id>();
            for(Document__c doc :[select id,Account__c,Document_Type__c from Document__c where Account__c in :accountIDSet]){
                String key = doc.Account__c+ (doc.Document_Type__c).toUppercase(); 
                mapToDoc.put(key,doc.id);
            }
            system.debug('mapToDoc >>>' + mapToDoc);
            List<Document_Configuration__c> documentConfList= [Select id,Import_From_Account__c,Linked_with_Account__c,Object__c,Master_Document__r.Name, Issue_Date_Mandatory__c,
                                                               Expiry_Date_Mandatory__c, Object_Status_Field_API_Name__c,Expiry_of_Set_Days__c,Document_Number_Mandatory__c,
                                                               Object_Status_Field_Value__c, IsRequired__c,Checkbox_Field_API_Name__c, Purpose__c, Download_Url_Field_Api_Name__c // Added by Sajid (Download_Url_Field_Api_Name__c)
                                                               from Document_Configuration__c where id In: docConfObjMap.keySet() and Master_Document__r.Name!='Others' ];
            system.debug('documentConfListSize >>>' + documentConfList.size());
            for (Document_Configuration__c docConf: documentConfList){
                Object_Document__c Objdoc = new Object_Document__c();
                Document__c doc = new Document__c();
                String key;
                system.debug('objectName@@@'+objectName);
                if (objectName != 'Account') {
                    if(objectName == 'Special_Offer__c'){
                        Objdoc.Special_Offer__c = docConfObjMap.get(docConf.Id).Id;
                        key=null+ (docConf.Master_Document__r.Name).toUppercase(); 
                        doc.Special_Offer__c = docConfObjMap.get(docConf.Id).Id;
                    }if(objectName == 'Unit__c'){
                        Objdoc.Unit__c = docConfObjMap.get(docConf.Id).Id;
                        key=null+ (docConf.Master_Document__r.Name).toUppercase(); 
                        doc.Unit__c = docConfObjMap.get(docConf.Id).Id;
                    }else if(objectName == 'Lease_Contract__c'){
                        Objdoc.Contract__c = docConfObjMap.get(docConf.Id).Id;
                        key=null+ (docConf.Master_Document__r.Name).toUppercase(); 
                        doc.Contract__c = docConfObjMap.get(docConf.Id).Id;
                    }else if(objectName == 'Project__c'){
                        Objdoc.Project__c = docConfObjMap.get(docConf.Id).Id;
                        key=null+ (docConf.Master_Document__r.Name).toUppercase(); 
                        doc.Project__c = docConfObjMap.get(docConf.Id).Id;
                    }else if(objectName == 'Agreement__c'){
                        Objdoc.Agreement__c = docConfObjMap.get(docConf.Id).Id;
                        key=null+ (docConf.Master_Document__r.Name).toUppercase(); 
                        doc.SPA_Agreement__c = docConfObjMap.get(docConf.Id).Id;
                    }else if(objectName == 'Registration__c'){
                        Objdoc.Registration__c = docConfObjMap.get(docConf.Id).Id;
                        key=null+ (docConf.Master_Document__r.Name).toUppercase(); 
                        doc.Registration__c = docConfObjMap.get(docConf.Id).Id;
                    }
                    else if(objectName == 'Calling_List__c'){ //Added BY Mamta
                        Objdoc.Calling_List__c  = docConfObjMap.get(docConf.Id).Id;
                        key=null+ (docConf.Master_Document__r.Name).toUppercase(); 
                        doc.Calling_List__c = docConfObjMap.get(docConf.Id).Id;
                    }else if(objectName == 'Price_Book__c'){ //Added BY Husain for Price Book
                        Objdoc.Calling_List__c  = docConfObjMap.get(docConf.Id).Id;
                        key=null+ (docConf.Master_Document__r.Name).toUppercase(); 
                        doc.Price_Book__c = docConfObjMap.get(docConf.Id).Id;
                    }else if(objectName == 'Opportunity'){
                        Objdoc.Opportunity__c = docConfObjMap.get(docConf.Id).Id;
                        if(docConf.Linked_with_Account__c){
                            doc.Account__c = ((Opportunity)docConfObjMap.get(docConf.Id)).AccountId;
                            key=((Opportunity)docConfObjMap.get(docConf.Id)).AccountId+ (docConf.Master_Document__r.Name).toUppercase(); 
                        }
                        else if(!docConf.Import_From_Account__c){
                            key=null+ (docConf.Master_Document__r.Name).toUppercase(); 
                        }
                        else{
                            key = ((Opportunity)docConfObjMap.get(docConf.Id)).AccountId+ (docConf.Master_Document__r.Name).toUppercase(); 
                        }
                        doc.Opportunity__c = docConfObjMap.get(docConf.Id).Id;//Added By Mamta- 25 Jan 22
                    }else if(objectName == 'Case'){
                        Objdoc.Case__c = docConfObjMap.get(docConf.Id).Id;
                        if(docConf.Linked_with_Account__c){
                            doc.Account__c = ((Case) docConfObjMap.get(docConf.Id)).AccountId;
                            key = ((Case)docConfObjMap.get(docConf.Id)).AccountId+ (docConf.Master_Document__r.Name).toUppercase();    
                        }
                        else if(!docConf.Import_From_Account__c){
                            key=null+ (docConf.Master_Document__r.Name).toUppercase(); 
                        }
                        else{
                            key = ((Case)docConfObjMap.get(docConf.Id)).AccountId+ (docConf.Master_Document__r.Name).toUppercase(); 
                        }
                        
                        
                        system.debug('key@@@'+key);
                    }else if(objectName == 'Handover__c'){ //Handover condition added by gaurav
                        Objdoc.Handover__c = docConfObjMap.get(docConf.Id).Id;
                        key=null+ (docConf.Master_Document__r.Name).toUppercase(); 
                        doc.Handover__c = docConfObjMap.get(docConf.Id).Id;
                    }else if(objectName == 'Lead'){ //Lead condition added by sajid
                        Objdoc.Lead__c = docConfObjMap.get(docConf.Id).Id;
                        key=null+ (docConf.Master_Document__r.Name).toUppercase(); 
                        doc.Leads__c = docConfObjMap.get(docConf.Id).Id;
                    }
                    Objdoc.Issue_Date_Mandatory__c = docConf.Issue_Date_Mandatory__c;
                    Objdoc.Expiry_Date_Mandatory__c = docConf.Expiry_Date_Mandatory__c;
                    Objdoc.Document_Number_Mandatory__c = docConf.Document_Number_Mandatory__c;
                    Objdoc.Object_Status_Field_API_Name__c = docConf.Object_Status_Field_API_Name__c;
                    Objdoc.Object_Status_Field_Value__c = docConf.Object_Status_Field_Value__c;
                    Objdoc.Is_Doc_Required__c = docConf.IsRequired__c;
                    Objdoc.Checkbox_Field_API_Name__c = docConf.Checkbox_Field_API_Name__c;
                    Objdoc.Document_Configuration__c = docConf.Id;
                    Objdoc.Download_Url_Field_Api_Name__c = docConf.Download_Url_Field_Api_Name__c;//Added By Sajid
                }else{
                    doc.Account__c = docConfObjMap.get(docConf.Id).Id;
                }
                if(mapToDoc.containskey(key) && docConf.Import_From_Account__c ){
                    Objdoc.Document__c = mapToDoc.get(key);
                    doc.id = mapToDoc.get(key);
                    system.debug('Inside mapToDoc');
                }else{
                    doc.Document_Type__c = docConf.Master_Document__r.Name;
                    doc.Issue_Date_Mandatory__c = docConf.Issue_Date_Mandatory__c;
                    doc.Expiry_Date_Mandatory__c = docConf.Expiry_Date_Mandatory__c;
                    doc.Document_Number_Mandatory__c = docConf.Document_Number_Mandatory__c;
                    doc.Object_Status_Field_API_Name__c = docConf.Object_Status_Field_API_Name__c;
                    doc.Object_Status_Field_Value__c = docConf.Object_Status_Field_Value__c;
                    doc.Is_Doc_Required__c = docConf.IsRequired__c;
                    doc.Checkbox_Field_API_Name__c = docConf.Checkbox_Field_API_Name__c ;
                    doc.Object__c = docConf.Object__c;
                    doc.Expiry_of_Set_Days__c = docConf.Expiry_of_Set_Days__c;
                    doc.Purpose__c = docConf.Purpose__c; //Added By Sajid
                    doc.Download_Url_Field_Api_Name__c = docConf.Download_Url_Field_Api_Name__c;//Added By Sajid
                    
                }
                mapAccToObjDoc.put(key,Objdoc);
                docList.add(doc); 
            }
            system.debug('docList>>'+ docList);
            if(docList.size() > 0){
                upsert  docList;   
            }
            if (objectName != 'Account') {
                saveObjDoc(mapAccToObjDoc,docList);
            }
        } catch (Exception e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
    }
    
    /*@usage : getRecordType function return Map of RecordTypeName & RecordtypeId. */
    public static Map <String,Id> getRecordType(sObject newObj) {
        String objectAPIName = (newObj.id).getSObjectType().getDescribe().getName();
        Schema.DescribeSObjectResult sobjectResult = Schema.getGlobalDescribe().get(objectAPIName).getDescribe();
        List <Schema.RecordTypeInfo> recordTypeInfo = sobjectResult.getRecordTypeInfos();
        Map <String,Id> mapofCaseRecordTypeNameandId = new Map<String,Id>();
        for (Schema.RecordTypeInfo info: recordTypeInfo) {
            mapofCaseRecordTypeNameandId.put(info.getName(), info.getRecordTypeId());
        }
        system.debug('mapofCaseRecordTypeNameandId>>'+ mapofCaseRecordTypeNameandId);
        return mapofCaseRecordTypeNameandId;
    }
    
    /*@usage : saveObjDoc function to save object document */
    public static void saveObjDoc(Map<String,Object_Document__c> mapAccToObjDoc,list<Document__c> docList) {
        List<Object_Document__c> objDocList = new  List<Object_Document__c>();
        for(String key : mapAccToObjDoc.keySet()){
            String docKey;
            Object_Document__c objDoc = mapAccToObjDoc.get(key);
            Boolean docExist = false;
            for(Document__c doc :docList){
                system.debug('doc@@@+'+doc);
                if(doc.Document_Type__c != null){
                    
                    docKey = doc.Account__c + (doc.Document_Type__c).toUppercase(); 
                }
                if(docKey == key){
                    
                    objDoc = mapAccToObjDoc.get(docKey);
                    objDoc.Document__c = doc.id;
                    objDocList.add(objDoc); 
                    docExist = true;
                    break;
                }
            }
            if(!docExist){
                objDocList.add(objDoc);  
            }
        }
        system.debug('objDocList Size>>'+ objDocList.size());
        if(objDocList.size() > 0){
            insert objDocList;
        }
    }
    
    /* @usage : validateDocRecord function runs before updation of Case,Account & Opportunity record to check file is uploaded or not on the basis of DocumentConfugration. */
    public static void validateDocRecord(List<sObject> newList, Map<Id,sObject> recordOldMap, Map<Id,sObject> recordNewMap , String objectType) {
        try{
            Map <string,list<sObject>> mapDocTypeToDoc = new Map<string, list<sObject>> ();
            List<sObject> docList = new List<sObject>();
            if(objectType == 'Opportunity'){
                docList = [select id, Is_Doc_Required__c, Object_Status_Field_API_Name__c,object_Status_Field_Value__c, 
                           document__r.Document_Type__c,document__r.Is_Document_Uploaded__c,Opportunity__c from Object_Document__c where 
                           Opportunity__c IN: recordNewMap.keySet()];
            }else if(objectType == 'Case'){
                docList = [select id,Case__c, Is_Doc_Required__c, Object_Status_Field_API_Name__c,object_Status_Field_Value__c, 
                           document__r.Is_Document_Uploaded__c,Opportunity__c,document__r.Document_Type__c from Object_Document__c where 
                           Case__c IN: recordNewMap.keySet()];
            }else if(objectType == 'Account'){
                docList = [select id,Document_Type__c, Is_Doc_Required__c, Object_Status_Field_API_Name__c,object_Status_Field_Value__c, 
                           Is_Document_Uploaded__c, Opportunity__c, Account__c from Document__c where 
                           Account__c IN: recordNewMap.keySet() AND Object__c = 'Account'];
            }
            else if(objectType == 'Agreement__c'){
                docList = [select id,Document_Type__c, Is_Doc_Required__c, Object_Status_Field_API_Name__c,object_Status_Field_Value__c, 
                           Is_Document_Uploaded__c, Opportunity__c, Account__c,SPA_Agreement__c from Document__c where 
                           SPA_Agreement__c IN: recordNewMap.keySet() AND Object__c = 'Agreement__c'];
            }
            else if(objectType == 'Registration__c'){
                docList = [select id,Document_Type__c, Is_Doc_Required__c, Object_Status_Field_API_Name__c,object_Status_Field_Value__c, 
                           Is_Document_Uploaded__c, Opportunity__c, Account__c,SPA_Agreement__c,Registration__c from Document__c where 
                           Registration__c IN: recordNewMap.keySet() AND Object__c = 'Registration__c'];
            }else if(objectType == 'Handover__c'){
                docList = [select id,Document_Type__c, Is_Doc_Required__c, Object_Status_Field_API_Name__c,object_Status_Field_Value__c, 
                           Is_Document_Uploaded__c, Opportunity__c, Account__c,SPA_Agreement__c,Registration__c from Document__c where 
                           Registration__c IN: recordNewMap.keySet() AND Object__c = 'Handover__c'];
            }
            
            else if(objectType == 'Calling_List__c'){
                docList = [select id,Document_Type__c, Is_Doc_Required__c, Object_Status_Field_API_Name__c,object_Status_Field_Value__c, 
                           Is_Document_Uploaded__c, Opportunity__c, Account__c,SPA_Agreement__c,Registration__c from Document__c where 
                           Calling_List__c  IN: recordNewMap.keySet() AND Object__c = 'Calling_List__c'];
            }
            system.debug('docList size>>>'+ docList.size());
            for (sObject docObj: docList) {
                String key;
                if(objectType == 'Opportunity'){
                    key = String.valueof(docObj.get('Opportunity__c'));
                }else if(objectType == 'Account'){
                    key = String.valueof(docObj.get('Account__c'));
                }else if(objectType == 'Case'){
                    key = String.valueof(docObj.get('Case__c'));
                }
                else if(objectType == 'Agreement__c'){
                    key = String.valueof(docObj.get('SPA_Agreement__c'));
                }
                else if(objectType == 'Registration__c'){
                    key = String.valueof(docObj.get('Registration__c'));
                }else if(objectType == 'Handover__c'){
                    key = String.valueOf(docObj.get('Handover__c'));
                }
                else if(objectType == 'Calling_List__c'){
                    key = String.valueOf(docObj.get('Calling_List__c'));//Added By Mamta
                }
                if (mapDocTypeToDoc.containskey(key)) {
                    mapDocTypeToDoc.get(key).add(docObj);
                } else {
                    mapDocTypeToDoc.put(key,new list<sObject>{docObj});
                }
            }
            for (sObject obj: newList) {
                sObject oldObj = recordOldMap.get(obj.id);
                if (mapDocTypeToDoc.containskey(obj.id)) {
                    list<sObject> docObjList = mapDocTypeToDoc.get(obj.id);
                    for (sObject docObj: docObjList) {
                        if (docObj.get('Object_Status_Field_API_Name__c') != null 
                            && docObj.get('Object_Status_Field_Value__c') != null 
                            && (boolean)docObj.get('Is_Doc_Required__c') 
                            && obj.get((string)docObj.get('Object_Status_Field_API_Name__c')) != oldObj.get((string)docObj.get('Object_Status_Field_API_Name__c'))
                            && obj.get((string)docObj.get('Object_Status_Field_API_Name__c')) == docObj.get('Object_Status_Field_Value__c')
                            && ((objectType != 'Account' && !(boolean)docObj.getSobject('document__r').get('Is_Document_Uploaded__c')) 
                                || objectType == 'Account' && !(boolean)docObj.get('Is_Document_Uploaded__c')))
                        {
                            String errorField;
                            if(objectType == 'Account'){
                                errorField=(String)docObj.get('Document_Type__c');
                            }
                            else{
                                errorField=(String)docObj.getSobject('document__r').get('Document_Type__c');
                            }
                            obj.addError('Please upload document for ' + errorField);
                        }
                    }
                }
            }
        }catch(Exception e){
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
    }
}