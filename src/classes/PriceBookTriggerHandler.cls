public class PriceBookTriggerHandler {
   	
    public static void AfterInsertEvent(list<Price_Book__c> newList) {
        GenericTriggerHandler.createDocRecord(newList, 'Price_Book__c');
    }
    
    public static void beforeUpdate(list<Price_Book__c> unitPriceBookList, Map<Id,Price_Book__c> oldValueMap){
        system.debug('----in conidtion before update---');
        list<Id> priceBookIds = new list<Id>();
        for(Price_Book__c ins: unitPriceBookList){
            if(ins.Is_Available__c == true && oldValueMap.get(ins.Id).Is_Available__c == false){
                priceBookIds.add(ins.Id);
                system.debug('----in conidtion before update pricebookId---'+priceBookIds);
            }
        }
        
        Map<Id,Id> unitTopbMap = new Map<Id,Id>();
        Map<Id,Double> unitToPriceMap = new Map<Id,Double>();
        List<Id> unitIds = new List<Id>();
        if(!priceBookIds.isEmpty()){
            for(PriceBook_Entry__c pbe: [SELECT Id, Name,Price__c, Unit__C,Price_Book__c from PriceBook_Entry__c where Price_Book__c IN:priceBookIds]){
                
                if(pbe.Unit__c != null){
                    unitIds.add(pbe.Unit__c);
                    unitTopbMap.put(pbe.Unit__c, pbe.Price_Book__c);
                }
                if(pbe.Price__c!= null){
                    unitToPriceMap.put(pbe.Unit__c, pbe.Price__c);
                }
            }
            
        }
        
        List<Unit__c> unitList = new List<Unit__c>();
        if(!unitIds.isEmpty()){
            unitList =[SELECT Id, Price_Books__c FROM Unit__c WHERE Id IN:unitIds];
            system.debug('----in conidtion---');
            if(!unitList.isEmpty()){
                
                for(Unit__c unit:unitList){
                    system.debug('----in inner conidtion---'+unitTopbMap.get(unit.Id));
                    unit.Price_Books__c = unitTopbMap.get(unit.Id);
                    if(unitToPriceMap.containsKey(unit.Id)){
                        unit.Selling_Price__c = unitToPriceMap.get(unit.Id); 
                    }
                }
                
                try{
                   update unitList;
                }
                catch(Exception e){
                    system.debug('ERRORR## '+ e.getMessage());
                }
           
            }
        }
        
    }
    
}