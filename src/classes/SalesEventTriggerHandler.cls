/*
Class Name: SalesEventTrigger
Class Description: Trigger on Sales Event object
Author: Gaurav Malik
Created Date: 20 December, 2021
Updated by:
Last Update Date:
*/
/* 23 Jan 22
     Comment by Huzefa - 
     changed sales_status__c to unit_status__c */

public class SalesEventTriggerHandler {
    
    public static void updateSalesStatusUnit(List<Sales_Event__c> triggerNew, Map<Id, Sales_Event__c> triggerOldMap){
        //get all related unit to Sales Event after the status is changed to Closed and update their status
        List<String> seClosedIdList = new List<String>();
        for(Sales_Event__c sec: triggerNew){
            if(sec.Status__c=='Closed' && triggerOldMap.get(sec.Id).Status__c!='Closed'){
                seClosedIDList.add(sec.Id);
            }    
        }
        //get all sales event record which stores unit record id
        List<String> unitIdList = new List<String>();
        for(Sales_Event_Unit__c seu:[SELECT Id, Name, Unit__c FROM Sales_Event_Unit__c WHERE Sales_Event__c IN: seClosedIDList]){   unitIdList.add(seu.Unit__c);
        }
        
        List<Unit__c> unitUpdateList = new List<Unit__c>();
        for(Unit__c u: [SELECT Id, Name, unit_status__c FROM Unit__c WHERE Id IN: unitIdList]){
            if(u.unit_status__c == 'Blocked'){   u.unit_status__c = 'Inventory';
                unitUpdateList.add(u);
            }
        }
        if(unitUpdateList.size()>0){   update unitUpdateList;   }
    }
}