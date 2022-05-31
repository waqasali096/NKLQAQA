/**
* @description      Update Rent records 
* @param            rnone
* @return           None
* @throws           NA
* @author Kshitij Tiwari
*/
public class BatchUpdateRentStructure implements Database.Batchable<Rent__c>, Database.AllowsCallouts{
    public Iterable<Rent__c> start(Database.BatchableContext BC){
        return [SELECT Id, Name, Start_Date__c,Holding_Deposit_Amount__c, Approval_Status__c,Availabe_Payment_Plan__r.Space_Type__c,Availabe_Payment_Plan__r.Project__c,Availabe_Payment_Plan__r.Security_Deposit__c,Availabe_Payment_Plan__r.Holding_Deposit_Amount__c, Active__c,Space_Type__c,Project__c,Security_Deposit__c,Base_Rent__c,Markup_Rent__c,Discount__c,Price_Per_SQ_FT__c FROM Rent__c 
                Where Approval_Status__c ='Approved'
                AND Start_Date__c >= today
                AND Active__c = False
               	AND Is_Processed__c = False limit 20];
    }
    
    public void execute(Database.BatchableContext BC,  List<Rent__c> scope){
        
        set<string> spaceTypeList = new set<string>();
        set<string> projectList = new set<string>();
        Map<String, Rent__c> rentMap = new Map<String, Rent__c>();
        
        for (Rent__c r :scope)
        {
            r.Active__c = True;
            r.Is_Processed__c = True;
        /*    if(r.Security_Deposit__c ==null)
            	 {
           		 r.Security_Deposit__c = r.Availabe_Payment_Plan__r.Security_Deposit__c;
           		 }
            if(r.Holding_Deposit_Amount__c ==null)
            	 {
           		 r.Holding_Deposit_Amount__c =r.Availabe_Payment_Plan__r.Holding_Deposit_Amount__c;
           		 }*/
            rentMap.put(r.Availabe_Payment_Plan__r.Space_Type__c+'-'+r.Availabe_Payment_Plan__r.Project__c, r);
            spaceTypeList.add(r.Availabe_Payment_Plan__r.Space_Type__c);
            projectList.add(r.Availabe_Payment_Plan__r.Project__c);           
            
            
        }
        if(scope.size()>0)
        {
            update scope;
        }
        
        List<Unit__c> lstUnit = [select id, name,Space_Types__c,Leasing_Type__c,Total_Leasable_Area__c,Unit_Leasing_Type__c,Project__c,Base_Rent__c,Security_Deposit__c,Market_Rent__c,Discount__c,Price_Per_SQ_FT__c,Holding_Deposit_Amount__c from unit__c 
                                 where Unit_Leasing_Type__c  IN :spaceTypeList 
                                 and Project__c IN :projectList];
        
        if(lstUnit.size()>0) {
            for (Unit__c u: lstUnit)
            {
                // String test ='u.Space_Types__r.name+'_'+u.Project__r.Name';
                System.debug('test1'+u); 
                String rentStr = String.valueOf(u.Unit_Leasing_Type__c+'-'+u.Project__c);
                if(rentMap.containskey(rentStr))
                {
                    System.debug('test2');
                    if(rentMap.get(rentStr).Base_Rent__c != null) {
                        u.Base_Rent__c = rentMap.get(rentStr).Base_Rent__c;
                    } else {
                        u.Base_Rent__c = 0;
                    }		
                    //  u.Base_Rent__c = rentMap.get(rentStr).Base_Rent__c;
                    if(rentMap.get(rentStr).Security_Deposit__c != null) {
                        u.Security_Deposit__c = rentMap.get(rentStr).Security_Deposit__c;
                    } else {
                        u.Security_Deposit__c = 0;
                    }	
                    //  u.Security_Deposit__c = rentMap.get(rentStr).Security_Deposit__c;
                    if(rentMap.get(rentStr).Markup_Rent__c != null) {
                        u.Markup_Rent__c = rentMap.get(rentStr).Markup_Rent__c;
                    } else {
                        u.Markup_Rent__c = 0;
                    }
                    // u.Markup_Rent__c  = rentMap.get(rentStr).Markup_Rent__c;
                    if(rentMap.get(rentStr).Discount__c != null) {
                        u.Discount__c = rentMap.get(rentStr).Discount__c;
                    } else {
                        u.Discount__c = 0;
                    }
                    //  u.Discount__c = rentMap.get(rentStr).Discount__c;
                    if(rentMap.get(rentStr).Price_Per_SQ_FT__c != null) {
                        u.Price_Per_SQ_FT__c = rentMap.get(rentStr).Price_Per_SQ_FT__c;
                    } else {
                        u.Price_Per_SQ_FT__c = 0;
                    }
                    //  u.Price_Per_SQ_FT__c = rentMap.get(rentStr).Price_Per_SQ_FT__c;
                    if(rentMap.get(rentStr).Holding_Deposit_Amount__c != null) {
                        u.Holding_Deposit_Amount__c = rentMap.get(rentStr).Holding_Deposit_Amount__c;
                    } else {
                        u.Holding_Deposit_Amount__c = 0;
                    }
                    if(u.Leasing_Type__c == 'Commercial Unit'){
                        u.Base_Rent__c = u.Price_Per_SQ_FT__c * u.Total_Leasable_Area__c;
                    }
                    //	u.Holding_Deposit_Amount__c = rentMap.get(rentStr).Holding_Deposit_Amount__c;                   
                }
            }
            if(lstUnit.size()>0)
            {
                
                update lstUnit;
            }
            
            
        }  
    }
    
    public void finish(Database.BatchableContext BC){
    }
}