@isTest
public class ISupplierRestAPICall_Test {
    @TestSetup
    Static  void createData(){
        insert new AppSettings__c(Name='OrgWideEmailAddressForSR', TextValue__c = 'Info@brokers.nakheel.com');
       // List< OrgWideEmailAddress > owAddresses = [SELECT Id, Address FROM OrgWideEmailAddress LIMIT 1];
    }

    @IsTest
    static void SendAccountToiSupplierTest(){
        List<Id> lstIds = new List<Id>();
        List< Account > lstAcc = TestDataFactory.createAccounts(5);
        List< Contact > lstCon = TestDataFactory.createContacts(5, lstAcc);

        List< ContentVersion > lstConVersion = TestDataFactory.createcontentVersions(1); 
        List< Document__c > lstDoc = TestDataFactory.createDocuments( lstConVersion, lstAcc[0].Id ); 

        for( ContentVersion conVer : [ SELECT Id, ContentDocumentId FROM ContentVersion ] ){
            lstDoc[0].Attachment_Id__c = conVer.ContentDocumentId;
        }
        update lstDoc;

        for( Account acc: lstAcc ){
            lstIds.add( acc.Id );
        }
        System.Test.startTest();
        ISupplierRestAPICall.SendAccountToiSupplier( lstIds );
        System.Test.stopTest();        
    }
    @IsTest
    static void SendAccountToiSupplierTest1(){
        set<Id> lstIds = new set<Id>();
        
        List< Account > lstAcc = TestDataFactory.createAccounts(5);
        List< Contact > lstCon = TestDataFactory.createContacts(5, lstAcc);

        List< ContentVersion > lstConVersion = TestDataFactory.createcontentVersions(1); 
        List< Document__c > lstDoc = TestDataFactory.createDocuments( lstConVersion, lstAcc[0].Id ); 

        for( ContentVersion conVer : [ SELECT Id, ContentDocumentId FROM ContentVersion ] ){
            lstDoc[0].Attachment_Id__c = conVer.ContentDocumentId;
        }
        update lstDoc;

        for( Account acc: lstAcc ){
            lstIds.add( acc.Id );
        }
        
        System.Test.startTest();
        ISupplierRestAPICall.SendAccountToiSupplier( lstIds );
        
        
        System.Test.stopTest();        
    }
    @IsTest
    static void SendDocumentToiSupplierTest1(){
        set<Id> lstIds = new set<Id>();
        set<Id> lstdocIds = new set<Id>();
        List< Account > lstAcc = TestDataFactory.createAccounts(1);
        List< ContentVersion > lstConVersion = TestDataFactory.createcontentVersions(1); 
        system.debug('lstConVersion&&' + lstConVersion);
        ID cdID = [Select id,ContentDocumentId from contentVersion where id =: lstConVersion[0].ID][0].ContentDocumentId;
        system.debug('cdID$$' + cdID);
        //List< Document__c > lstDoc = TestDataFactory.createDocuments( lstConVersion[0], lstAcc[0].Id );
        Document__c doc = new Document__c();
        doc.Account__c = lstAcc[0].ID;
        doc.Document_Type__c = 'PASSPORT';
        doc.Broker_Agreement_Id__c = cdID;
        insert doc;
        system.debug('doc^^' + doc);
        lstIds.add( lstAcc[0].Id );
        lstdocIds.add(doc.Id);
        
        System.Test.startTest();
        //Test.setMock(HttpCalloutMock.class, new ISupplierRestAPICalloutMock());
        ISupplierRestAPICall.SendDocumentToiSupplier( lstIds,lstdocIds );
        
        System.Test.stopTest();        
    }
    
    @isTest
    static void testCalloutRest(){
        //insert new AppSettings__c(Name='OrgWideEmailAddressForSR', TextValue__c = 'info@test.com');
        AppSettings__c mycs = AppSettings__c.getValues('OrgWideEmailAddressForSR');
        
        if(mycs==null){
            mycs = new AppSettings__c(Name= 'OrgWideEmailAddressForSR');
            mycs.TextValue__c='info@test.com';
            insert mycs;
        }
        //Test.setMock(HttpCalloutMock.class, new ISupplierRestAPICalloutMock());
        //HttpResponse respond = ISupplierRestAPICall.doOracleCallout(body, credential, accountSet);
        List<Id> lstIds = new List<Id>();
        Set<Id> setIds = new Set<Id>();
        List< Account > lstAcc = TestDataFactory.createAccounts(1);
        List< Contact > lstCon = TestDataFactory.createContacts(1, lstAcc);

        List< ContentVersion > lstConVersion = TestDataFactory.createcontentVersions(1); 
        
        List< Document__c > lstDoc = TestDataFactory.createDocuments( lstConVersion, lstAcc[0].Id );
        
        Document__c doc = new Document__c();
        doc.Document_Type__c  ='PASSPORT';
        doc.Parent_Id__c=lstAcc[0].Id;
        doc.Account__c = lstAcc[0].Id;
        doc.Attachment_Id__c = lstCon[0].id;
        insert doc;

        for( ContentVersion conVer : [ SELECT Id, ContentDocumentId FROM ContentVersion ] ){
            lstDoc[0].Attachment_Id__c = conVer.ContentDocumentId;
             lstDoc[0].Broker_Agreement_Id__c=conVer.ContentDocumentId;
        }
        update lstDoc;

        for( Account acc: lstAcc ){
            lstIds.add( acc.Id );
            setIds.add(acc.Id);
        }
        
        Test.startTest();
        ISupplierRestAPICall.SendAccountToiSupplier(lstIds);
        String vendorIdFile = ISupplierRestAPICall.vendorIdForFile;
        ISupplierRestAPICall.XMLForFileGenerator(setIds, vendorIdFile,null);
        ISupplierRestAPICall.calloutForFile('test',doc,'test','test','test');
        ISupplierRestAPICall.CreateISupplierVendorForFile tt=new ISupplierRestAPICall.CreateISupplierVendorForFile(setIds,'test');
        Test.stopTest();
    }
}