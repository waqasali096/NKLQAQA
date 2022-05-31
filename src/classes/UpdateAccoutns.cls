/**=====================================================================
** This is created as a part of data migration, to be excluded for deployment.
=======================================================================**/
@RestResource(urlMapping='/UpdateAccounts/*')
global class UpdateAccoutns {
    
    @HttpPost
    global static string UpdateAcounts(){
        
        
        list<Wrapper> JSONWrapper = new list<Wrapper>();
         JSONWrapper = (list<Wrapper>)System.JSON.deserialize(RestContext.request.requestBody.toString(),
                                                              list<Wrapper>.class); 
        
        List<Account> updateAccoutnList = new List<Account>();
        List<Contact> CreateContact = new List<Contact>();
          
        For(Wrapper wrap : JSONWrapper){
            
            Contact cc = new Contact(lastname = 'DM',AccountID=wrap.id);
            CreateContact.add(cc);
            Account aa = new Account(id=wrap.id,RecordTypeID=wrap.RecordTypeId);
            updateAccoutnList.add(aa);
            
        }
        
        try{
             insert CreateContact;
             update updateAccoutnList;
                    return 'Success';

        }catch(exception ex){
            
            return ex.getmessage();
            
        }
     
        
    }
    Public Class Wrapper{
        Public Id ID;
        Public String RecordTypeId;       
    }
}