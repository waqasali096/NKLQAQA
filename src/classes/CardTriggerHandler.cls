/*
Class Name: CardTriggerHandler
Class Description: Handler for Card__c object
Author: Karishma Kotian
Created Date: 28th Feb 2022
Updated by: 
Last Update Date:
*/
public class CardTriggerHandler {
    List<Card__c> newList = new List<Card__c>();
    List<Card__c> oldList = new List<Card__c>();
    Map<Id, Card__c> newMap = new Map<Id, Card__c>();
    Map<Id, Card__c> oldMap = new Map<Id, Card__c>();
    Boolean isInsert, isUpdate, isDelete, isUndelete = false;
    public static boolean recursionController = false;
    
    public CardTriggerHandler(List<Card__c> newList, List<Card__c> oldList, Map<Id, Card__c> newMap, Map<Id, Card__c> oldMap, boolean isInsert, boolean isUpdate, Boolean isDelete, Boolean isUndelete) {
        this.newList = newList;
        this.oldList = oldList;
        this.newMap = newMap;
        this.oldMap = oldMap;
        this.isInsert = isInsert;
        this.isUpdate = isUpdate;
        this.isDelete = isDelete;
        this.isUndelete = isUndelete;
    }
    
    public void BeforeInsertEvent(){}
    
    public void AfterInsertEvent(){
        updateUnits(newList);
    }
    
    public void BeforeUpdateEvent(){}
    
    public void AfterUpdateEvent(){
    }
    
    public void BeforeDeleteEvent(){}
    
    public void AfterUndeleteEvent(){}
    
    public void AfterDeleteEvent(){}
    
    // Added by Karishma to update unit details on card record
    public void updateUnits(List<Card__c> newList){
        Set<Id> handoverIds = new Set<Id>();
        Map<String,String> handoverToOppty = new Map<String,String>();
        Map<String,List<Card__c>> cardToHandover = new Map<String,List<Card__c>> ();
        List<Card__c> cardList = new List<Card__c> ();
        for(Card__c card: newList){
            if(card.Handover__c != null){
                handoverIds.add(card.Handover__c); 
                if(cardToHandover.containsKey(card.Handover__c)){
                    cardToHandover.get(card.Handover__c).add(card);
                }else{
                    cardToHandover.put(card.Handover__c, new List<Card__c>{card});
                }
            }
        }
        if(handoverIds.size() > 0){
            List<Handover__c> handoverL = [SELECT Id, Deal__c FROM Handover__c WHERE Id IN: handoverIds];
            for(Handover__c handover : handoverL){
                handoverToOppty.put(handover.Deal__c,handover.Id);
            }
            List<Opportunity> OpportunityList = [SELECT Id, 
                                             (SELECT Id, Unit__c, Opportunity__c FROM Unit_Plans__r Limit 1) 
                                             FROM Opportunity WHERE Id=: handoverToOppty.keySet()];
            for(Opportunity oppty : OpportunityList){
                if(handoverToOppty.containsKey(oppty.Id)){
                if(cardToHandover.containsKey(handoverToOppty.get(oppty.Id))){
                   for(Card__c card : cardToHandover.get(handoverToOppty.get(oppty.Id))){
                        Card__c newCard = new Card__c();
                        newCard.Unit__c = oppty.Unit_Plans__r[0].Unit__c;
                        newCard.Id = card.Id;
                        cardList.add(newCard);
                    }
                
                }
                }
            }
        }

        if(!cardList.isEmpty()){
            update cardList;
        }
    }
}