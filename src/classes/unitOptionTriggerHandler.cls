public class unitOptionTriggerHandler {
        
    public static void process(List<Unit_Option__c> triggerNew){
        system.debug('Inside Process');
        Set<id> unitIds=new Set<Id>();
        for(Master_Option__c ms : [select Option_Name__c,(select id,Unit__c  from Unit_Options__r) from Master_Option__c]){ 
            system.debug('line 6');
            for(Unit_Option__c uop : ms.Unit_Options__r){
                 unitIds.add(uop.Unit__c);
            }
		            
        }
        if(unitIds==null)return ;
        
        List<Unit__c> unitList=[select Pent_House_Option__c,Pent_House_Additional_Area_SFT__c,Pent_House_Charge__c,Pent_House_Unit_Theme__c,
                                Swimming_Pool_Option__c,Swimming_Pool_Length_SFT__c,Swimming_Pool_Width_SFT__c,Swimming_Pool_Price__c,
                                Maid_Room_Option__c,Maid_Room_Additional_Area_SFT__c,Maid_Room_Price__c,
                                Watchman_Room_Option__c,Watchman_Room_Additional_Area_SFT__c,Watchman_Room_Price__c
                                from Unit__c where id IN : unitIds];
        for(Unit__c uni : unitList){
            if(uni.Pent_House_Option__c==true){
                System.debug('Inside line 17');
                for(Unit_Option__c uoption : triggerNew){
                    uoption.Additional_Area__c=uni.Pent_House_Additional_Area_SFT__c;
                    uoption.Price__c=uni.Pent_House_Charge__c;
                    uoption.Unit_Theme__c=uni.Pent_House_Unit_Theme__c;
                }
            }
           if(uni.Swimming_Pool_Option__c==true){
               system.debug('line 30 ');
               for(Unit_Option__c uoption : triggerNew){
                    uoption.Optional_Length__c=uni.Swimming_Pool_Length_SFT__c;
                    uoption.Optional_Width__c=uni.Swimming_Pool_Width_SFT__c;
                    uoption.Price__c=uni.Swimming_Pool_Price__c;
                }
            }
            if(uni.Maid_Room_Option__c==true){
                 for(Unit_Option__c uoption : triggerNew){
                    uoption.Additional_Area__c=uni.Maid_Room_Additional_Area_SFT__c;
                    uoption.Price__c=uni.Maid_Room_Price__c;
                }
            }
             if(uni.Watchman_Room_Option__c==true){
                system.debug('line 40');
                for(Unit_Option__c uoption : triggerNew){
                    uoption.Additional_Area__c=uni.Watchman_Room_Additional_Area_SFT__c;
                    uoption.Price__c=uni.Watchman_Room_Price__c;
                }
            }
            
        }
        
    }

}