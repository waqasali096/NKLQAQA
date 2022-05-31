/*
Class Name: UnitTriggerHandler
Class Description: Handler for UnitTrigger Class
Author: Gaurav Malik
Created Date: 20 December 2021
Updated by: Moneeb
Last Update Date:08 Jan 2022
V1.1 : Added by Moneeb for History Task on 08/02/2022 
Update 15 Feb - added logic for unit code creation and new roll up logic - Huzefa and Swapnil
*/
//Comment by Swapnil - neeed to use Business_Unit__c instead of master_community__c and use unit_Status__c instead of sales_status__c and leasing_status__c
public without sharing class UnitTriggerHandler {
    List<Unit__c> newList = new List<Unit__c>();
    List<Unit__c> oldList = new List<Unit__c>();
    Map<Id, Unit__c> newMap = new Map<Id, Unit__c>();
    Map<Id, Unit__c> oldMap = new Map<Id, Unit__c>();
    Boolean isInsert, isUpdate, isDelete, isUndelete = false;
    public static boolean recursionController = false;
    
    public UnitTriggerHandler(List<Unit__c> newList, List<Unit__c> oldList, Map<Id, Unit__c> newMap, Map<Id, Unit__c> oldMap, boolean isInsert, boolean isUpdate, Boolean isDelete, Boolean isUndelete) {
        this.newList = newList;
        this.oldList = oldList;
        this.newMap = newMap;
        this.oldMap = oldMap;
        this.isInsert = isInsert;
        this.isUpdate = isUpdate;
        this.isDelete = isDelete;
        this.isUndelete = isUndelete;
    }
    
    public void BeforeInsertEvent() {
        /*for(Unit__c unt: newList) {
            unt.Send_Unit_to_ERP__c = true;
        }*/
        
        updateUnitProjectType(newList);
        updateDateAvailableStatus(newList,oldMap);
        //GenerateInventoryCode.generateUnitCode(newList); // added by huzefa - 15 feb 2022
        upsertFloorDetails(newList,oldMap); // Added by Shivani - 23rd March 2022
        updateUnitDetails(newList,oldMap); // Added by Shivani - 5th April 2022
        updateUnitName(newList,oldMap); // Added by Shivani - 8th April 2022
        //updateAddtionalArea(newList,oldMap); // Added by Shivani - 11th April 2022
        updateSpaceType(newList,null); 
        //populateBusinessUnit(newList); // added by Deep Banerjee
        sendUnitERP();
        
    }
    
    public void AfterInsertEvent() {
        
        system.debug('@@@@ AfterInsertEvent @@@@');
       // unitCountUpdateOnFloor(newList);
        //UpdateRollups();
        GenericTriggerHandler.createDocRecord(newList,'Unit__c');
        unitCreation();
        checkMasterPayPlanonUnit();//Added BY Mamta - 2 Feb
        
        updateRollupQueable();  
        //creatUnitOptionsfromImport(newList); // added by deep
        createUnitOptions(); //Added by Rohit 10th May, 2022

    }
    
    public void BeforeUpdateEvent() {
        System.debug('Before Update Event started');
        
        
        //UpdateRollups();
        System.debug('Before Update Event end');
        updateDateAvailableStatus(newList,oldMap);
        updateDateOnHoldStatus(newList,oldMap);
        //unitCreation();
        //GenerateInventoryCode.generateUnitCode(newList); // added by huzefa - 15 feb 2022
        //createHandovers(newList);
        updateUnitDetails(newList,oldMap); // Added by Shivani - 7th April 2022
        updateUnitName(newList,oldMap); // Added by Shivani - 8th April 2022
        //updateAddtionalArea(newList,oldMap); // Added by Shivani - 11th April 2022
        updateSpaceType(newList,oldMap);  // added by swapnil 22 march 2022
        sendUnitERP();//Added By Vishal
        unitCreation();
    }
    
    public void AfterUpdateEvent() {
        
        system.debug('@@@@ AfterUpdateEvent @@@@');
        // unitCountUpdateOnFloor(newList);
        // UpdateRollups();
        
        checkMasterPayPlanonUnit();//Added BY Mamta - 2 Feb
        createHistoryRecord(newList,oldMap,'Unit__c');//Added by Moneeb for History Task on 08/02/2022 
        createHandovers(newList);// Added by Anshita 07 Apr 2022 for Handover Creation
        updateRollupQueable();  
        //creatUnitOptionsfromImport(newList);
        createUnitOptions(); //Added by Rohit 10th May, 2022
        makeDealAndSpaReadOnly(); //Added by Rohit 20th May, 2022
        updateProperty();
    }
    
    public void BeforeDeleteEvent() {  
      
       
    }
    
    public void AfterUndeleteEvent() {
       
       updateRollupQueable();   
    }
    
    public void AfterDeleteEvent() {
      
     //  updateRollupQueable();   
    }
    
    /********************************************************************************************** 
* @Description  : Create Handover Records
* @Params       : Unit Id
* @Return       : void
* @Author       : Mamta Gupta
**********************************************************************************************/
    
    /*private void createHandovers(List<Unit__c> unitLst){
    List<Handover__c> handovers = new List<Handover__c>(); 
    Id salesHandoverRecID = Schema.SObjectType.Handover__c.getRecordTypeInfosByName().get('Sales').getRecordTypeId();
    
        for(Unit__c un: unitLst){
            if(newMap.get(un.ID).Ready_for_Inspection__c && !oldMap.get(un.ID).Ready_for_Inspection__c){
                Handover__c hnd = new Handover__c();
                hnd.Unit__c = un.ID;
                hnd.Deal__c = un.Active_Deal__c;
                hnd.Status__c ='Inspection Pending';
                hnd.Put_in_round_robin__c = true;
                hnd.RecordtypeID = salesHandoverRecID;
                handovers.add(hnd);
            }
            
        } 
        
        if(!handovers.isEmpty()){
            insert handovers;
        }
     
    }*/
    
    private void createHandovers(List<Unit__c> unitLst){
        List<Handover__c> handovers = new List<Handover__c>(); 
        Id salesHandoverRecID = Schema.SObjectType.Handover__c.getRecordTypeInfosByName().get('Sales').getRecordTypeId();
        Group handoverQueue = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'Handover_Team'];
        for(Unit__c un: unitLst){
            if(newMap.get(un.ID).Handover_Status__c == 'Ready for Inspection' && (newMap.get(un.ID).Handover_Status__c != oldMap.get(un.ID).Handover_Status__c)){
                Handover__c hnd = new Handover__c();
                hnd.Unit__c = un.ID;
                hnd.Deal__c = un.Active_Deal__c;
                hnd.Status__c ='Inspection Pending';
                hnd.Put_in_round_robin__c = true;
                hnd.RecordtypeID = salesHandoverRecID;
                hnd.Inspection_Target_Date__c = un.Inspection_Target_Date__c;
                hnd.OwnerId = handoverQueue.Id;
                handovers.add(hnd);
            }
            
        } 
        
        
        if(!handovers.isEmpty()){
            insert handovers;
        }
        
    }

    public void updateRollupQueable(){
       Set<Id> projectIdList = new Set<Id>();
        System.debug('@@@ '+ isUpdate);
         if(isUpdate){
             for(Unit__c u: newList){
                 if(u.unit_Status__c == oldMap.get(u.Id).unit_Status__c){
                    return ;
                 }
             }  
         }
         for(Unit__c u: newList){
             if(u.Project__c!=null){
                 projectIdList.add(u.Project__c);
             }
         }
         CustomRollupsQueueable myJob = new CustomRollupsQueueable(projectIdList);
         System.enqueueJob(myJob);
    }
    
    public void checkMasterPayPlanonUnit(){
        Map<Unit__c,ID> unitID_MasterPayPlanID = new Map<Unit__c,ID >();
        for(Unit__c unit : newList){
            if(unit.Master_Payment_Plan__c!=null && oldMap==null ){
               unitID_MasterPayPlanID.put(unit, unit.Master_Payment_Plan__c); 
            }
            else if(oldMap!=null){
                if(unit.Master_Payment_Plan__c!=null && unit.Master_Payment_Plan__c!= oldMap.get(unit.ID).Master_Payment_Plan__c){
                    unitID_MasterPayPlanID.put(unit, unit.Master_Payment_Plan__c); 

                }
            }
        }
        
        if(!unitID_MasterPayPlanID.isEmpty()){
            createPaymentMilestonesonUnit(unitID_MasterPayPlanID);
        }
    }
    
    
    
    /* These Payment milestones will reflect as part of generate quotation function */
    public static void createPaymentMilestonesonUnit( Map<Unit__c,ID> unitID_MasterPayPlanID){
        
        List<Payment_Milestone__c> oldMilestones = [select id from Payment_Milestone__c WHERE Unit__c IN :unitID_MasterPayPlanID.keySet()];
        Map<ID, List<Master_Payment_Milestone__c>> maPlanID_MilesLst_Map = new Map<ID, List<Master_Payment_Milestone__c>>();
        
        List<Master_Payment_Plan__c> mpmsLst = [select id, Name,(select id,Name, Due_In_Days__c ,Installment__c ,Installment_No__c ,Amount_Percentage__c 
                                                              from Master_Payment_Milestones__r) from Master_Payment_Plan__c WHERE 
                                                               ID IN :unitID_MasterPayPlanID.values() ];
        for(Master_Payment_Plan__c mp : mpmsLst){
            maPlanID_MilesLst_Map.put(mp.ID ,mp.Master_Payment_Milestones__r );
            
        }
        List<Payment_Milestone__c> newpayMilestones = new List<Payment_Milestone__c>();
        for(Unit__c un : unitID_MasterPayPlanID.keySet()){
            if(maPlanID_MilesLst_Map.containsKey(un.Master_Payment_Plan__c)){
                for(Master_Payment_Milestone__c mp : maPlanID_MilesLst_Map.get(un.Master_Payment_Plan__c)){
                    Payment_Milestone__c pm  = new Payment_Milestone__c();
                    pm.Master_Payment_Milestone__c = mp.ID;
                    pm.Name = mp.Name;
                    pm.Master_Payment_Plan__c = un.Master_Payment_Plan__c;
                    pm.Amount_Percentage__c = mp.Amount_Percentage__c;
                    pm.Installment__c =  mp.Installment__c;
                    pm.Installment_No__c =mp.Installment_No__c;
                    pm.Due_In_Days__c = mp.Due_In_Days__c;
                    Integer dueDays = Integer.valueof(mp.Due_In_Days__c);
                    if(dueDays!=null){
                         pm.Due_Date__c = (system.today()).addDays(dueDays);
                    }
                    pm.Amount__c = ((un.Total_Selling_Price__c)*mp.Amount_Percentage__c)/100;
                    pm.Unit__c = un.ID;
                    newpayMilestones.add(pm);
                    
                }
            }
        }
        
        if(oldMilestones.size()>0){
            try{
                delete oldMilestones;
            }
            catch(Exception ex){
            system.debug('error is '+ ex.getMessage() + ' at line '+ ex.getLineNumber());   
            }
        }
        
        if(!newpayMilestones.isEmpty()){
            try{
                insert newpayMilestones;
            }
            catch(Exception ex){
            system.debug('error is '+ ex.getMessage() + ' at line '+ ex.getLineNumber());   
  
            }
        }
        
        
        
    }
    public static void updateDateOnHoldStatus(List<Unit__c> triggerNew,Map<Id,Unit__c> oldMap){
        for(Unit__c unitObj : triggerNew){
            if(unitObj.unit_status__c == 'On Hold' && oldMap.get(unitObj.id).unit_status__c != 'On Hold'){
                unitObj.Date_when_Leasing_status_changes__c = system.now();
            }
        }
    }
    public static void updateDateAvailableStatus(List<Unit__c> triggerNew,Map<Id,Unit__c> oldMap){
        for(Unit__c unitObj : triggerNew){
            if(unitObj.unit_status__c == 'Available' && (oldMap == null || oldMap.get(unitObj.id).unit_status__c != 'Available')){
                unitObj.Unit_Available_Timestamp__c = system.now();
            }
        }
    }
    public static void updateUnitProjectType(List<Unit__c> triggerNew){
        List<Id> projectIdList = new List<Id>();
        for(Unit__c u: triggerNew){
            if(u.Project__c!=null){
                projectIdList.add(u.Project__c);
            }
        }
        /*Map<Id, Project__c> idToProjectMap = new Map<Id, Project__c>([Select Id, Name, Project_Type__c FROM Project__c WHERE Id IN: projectIdList]);
        for(Unit__c u:triggerNew){
            if(u.Project__c!=null){
                u.Project_Type__c = idToProjectMap.get(u.Project__c).Project_Type__c;
            }
        }*/
    }
    
    public void UpdateRollups(){
        // Add try catch for the whole method and log exceptions.
        try{
            // user already defined boolean instead of new.
            Map<String,String> recordCountFields = New Map<String,String>();
            Map<String,String> sumFields = New Map<String,String>(); 
            Set<Id> floorIdSet = New Set<Id>(); 
            Set<Id> unitIdSet = New Set<Id>(); 
            List<String> floorFields = new List<String>(); 
            List<String> unitFields = new List<String>();
            Map<Id,Integer> floorToUnitCount = New Map<Id,Integer>();
            
            Map<id,List<Id>> floorToUnitIdListMap = New Map<id,List<Id>>(); 
            Map<Id,Map<String,Decimal>> floorIdToFieldValueMap = New  Map<Id,Map<String,Decimal>>(); 
            
            Map<Id,Integer> floorToSoldUnitCount = new Map<Id,Integer>();
            Map<Id,Integer> floorToLeasedUnitCount = new Map<Id,Integer>();
            Map<Id,Integer> floorToAvailableUnitCount = new Map<Id,Integer>();
            Map<Id,Integer> floorToBookedUnitCount = new Map<Id,Integer>();
            Map<Id,Integer> floorToReservedUnitCount = new Map<Id,Integer>();
            
            List<Floor_Rollup_fields__c> rollupfields = Floor_Rollup_fields__c.getall().values();
            
            for(Floor_Rollup_fields__c rollupField :rollupfields){  // for loop to capture field from custom setting as a string
                
                if(rollupField.SUM__c){
                    sumFields.put(rollupField.Unit_Field__c, rollupField.Floor_Field__c);
                }
                if(rollupField.COUNT__c){
                    recordCountFields.put(rollupField.Unit_Field__c, rollupField.Floor_Field__c);
                }
                if(rollupField.Unit_Field__c != null && rollupField.Unit_Field__c != ''){
                    unitFields.add(rollupField.Unit_Field__c);
                }
                if(rollupField.Floor_Field__c != null && rollupField.Floor_Field__c != ''){
                    floorFields.add(rollupField.Floor_Field__c);
                }
                
            }
            for(Unit__c unit : newList){  // trigger loop of product for capturing ids of floor & unit
                
                floorIdSet.add(unit.Floor__c);
                unitIdSet.add(unit.Id);
                if(!floorToUnitIdListMap.containsKey(unit.Floor__c)){
                    List<Id> idlist = New LIst<Id>();
                    idlist.add(unit.id);
                    floorToUnitIdListMap.put(unit.Floor__c, idlist);
                }else{
                    floorToUnitIdListMap.get(unit.Floor__c).add(unit.Id);
                }
                
            }
            Schema.SObjectType floorObjectType = Schema.getGlobalDescribe().get('Floor__c');
            Map<String, SObjectField> floorFieldMap = floorObjectType.getDescribe().fields.getMap();  // map of sobject field
            System.debug('@@@@##'+floorFieldMap);
            Schema.SObjectType unitobjectType = Schema.getGlobalDescribe().get('Unit__c');
            Map<String, SObjectField> unitFieldMap = unitobjectType.getDescribe().fields.getMap();  // map of sobject field
            
            
            // -----------------------floor qry--------------------------------------------------        
            String floorqry = 'Select Id,';
            for(String unt : floorFields){
                
                Schema.SobjectField theField = floorFieldMap.get(unt);
                system.debug('the field '+theField);
                if(theField!=null){
                    floorqry = floorqry + theField + ','; 
                }
            }
            floorqry = floorqry.removeEnd(',');
            floorqry = floorqry + ' from Floor__c where Id IN: floorIdSet';
            
            system.debug('qry==== ' + floorqry);
            List<Floor__c>floorList = New List<Floor__c>(); 
            List<Floor__c> floorLstToUpdate = new List<Floor__c>();
            
            floorList = Database.query(floorqry);
            
            
            //----------------------ends---------------------------------------------------------
            //
            //   -------------------------------------------------unit qry---------------------------
            String unitqry = 'Select Id,';
            for(String unitFieldString : unitFields){
                
                Schema.SobjectField unitField = unitFieldMap.get(unitFieldString);
                System.debug('the unit field '+unitField);
                if(unitField!=null){
                    unitqry = unitqry + unitField + ','; 
                }
            }
            unitqry = unitqry.removeEnd(',');
            unitqry = unitqry + ' ,Unit_Status__c ,Floor__c from Unit__c where Floor__c IN: floorIdSet';
            
            
            List<Unit__c>unitList = New List<Unit__c>(); 
            
            unitList = Database.query(unitqry);
            
            
            
            //  ---------------------------------------------------------------------------------------        
            system.debug('qryres ' + unitList);
            // Check if floor exist to avoid null pointer exception
            for(Unit__c unit : unitList){ 
                if(unit.Floor__c != Null)  {   
                    if(newMap.containsKey(unit.id)){
                        unit = newMap.get(unit.id);
                    }
                    Map<String,Decimal> unitFieldSum = New Map<String,Decimal>(); 
                    for(String fieldName : sumFields.keySet()){ 
                        Schema.SobjectField unitFieldName = unitFieldMap.get(fieldName); // never user number
                        if(Integer.valueof(unit.get(unitFieldName)) > 0){
                            unitFieldSum.put(fieldName,Integer.valueof(unit.get(unitFieldName)));  // map for field string name and its value from record
                        }
                    }
                    system.debug('unitFieldSum is '+ unitFieldSum);
                    if(!floorIdToFieldValueMap.containsKey(unit.Floor__c)){
                        Map<String,Decimal> unitFieldToUnitFieldSum = New Map<String,Decimal>(); //NEVER use temp :D
                        unitFieldToUnitFieldSum.putAll(unitFieldSum);
                        system.debug('unitFieldToUnitFieldSum if not contains key '+ unitFieldToUnitFieldSum);
                        system.debug(unitFieldToUnitFieldSum);
                        floorIdToFieldValueMap.put(unit.Floor__c,unitFieldToUnitFieldSum);
                        system.debug('floorIdToFieldValueMap if not contains key '+ floorIdToFieldValueMap);
                        system.debug(floorIdToFieldValueMap);
                        floorToUnitCount.put(unit.Floor__c,1);
                        floorToAvailableUnitCount.put(unit.Floor__c,0);
                        floorToReservedUnitCount.put(unit.Floor__c,0);
                        floorToBookedUnitCount.put(unit.Floor__c,0);
                        floorToSoldUnitCount.put(unit.Floor__c,0);
                        floorToLeasedUnitCount.put(unit.Floor__c,0);
                        if(unit.Unit_Status__c=='Available'){
                            system.debug('in available');
                            floorToAvailableUnitCount.put(unit.Floor__c,floorToAvailableUnitCount.get(unit.Floor__c)+1);
                        }else if(unit.Unit_Status__c=='Reserved'){
                            floorToReservedUnitCount.put(unit.Floor__c,floorToReservedUnitCount.get(unit.Floor__c)+1);
                        }else if(unit.Unit_Status__c=='Booked'){
                            floorToBookedUnitCount.put(unit.Floor__c,floorToBookedUnitCount.get(unit.Floor__c)+1);
                        }else if(unit.Unit_Status__c=='Sold'){
                            floorToSoldUnitCount.put(unit.Floor__c,floorToSoldUnitCount.get(unit.Floor__c)+1);
                        }
                        else if(unit.Unit_Status__c=='Leased'){
                            floorToLeasedUnitCount.put(unit.Floor__c,floorToLeasedUnitCount.get(unit.Floor__c)+1);
                        }
                        System.debug('@@@334'+floorToAvailableUnitCount);
                    }else{
                        Map<String,Decimal> unitFieldToUnitFieldSum = New Map<String,Decimal>();
                        unitFieldToUnitFieldSum.putAll(floorIdToFieldValueMap.get(unit.Floor__c));
                        system.debug('unitFieldToUnitFieldSum if contains key '+ unitFieldToUnitFieldSum);
                        for(String st : unitFieldToUnitFieldSum.keySet()){
                            Decimal val = unitFieldToUnitFieldSum.get(st);
                            if(Integer.valueOf(unitFieldSum.get(st)) > 0){
                                val = val + unitFieldSum.get(st);
                                
                                unitFieldToUnitFieldSum.put(st,val); 
                            }
                        }
                        floorIdToFieldValueMap.put(unit.Floor__c,unitFieldToUnitFieldSum);
                        Integer Productcount = floorToUnitCount.get(unit.Floor__c);
                        Productcount = Productcount + 1; 
                        floorToUnitCount.put(unit.Floor__c,Productcount);
                        
                        if(unit.Unit_Status__c=='Available'){
                            floorToAvailableUnitCount.put(unit.Floor__c,floorToAvailableUnitCount.get(unit.Floor__c)+1);
                        }else if(unit.Unit_Status__c=='Reserved'){
                            floorToReservedUnitCount.put(unit.Floor__c,floorToReservedUnitCount.get(unit.Floor__c)+1);
                        }else if(unit.Unit_Status__c=='Booked'){
                            floorToBookedUnitCount.put(unit.Floor__c,floorToBookedUnitCount.get(unit.Floor__c)+1);
                        }else if(unit.Unit_Status__c=='Sold'){
                            floorToSoldUnitCount.put(unit.Floor__c,floorToSoldUnitCount.get(unit.Floor__c)+1);
                        }
                        else if(unit.Unit_Status__c=='Leased'){
                            floorToLeasedUnitCount.put(unit.Floor__c,floorToLeasedUnitCount.get(unit.Floor__c)+1);
                        }
                        
                        System.debug('@@@335'+floorToAvailableUnitCount);
                    }
                }
            }
            
            for(Floor__c floor : floorList){ // for loop for assigning values to floor field and update
                if(floorIdToFieldValueMap.containsKey(floor.Id)){
                    Map<String,Decimal> floorFieldToSumMap = New Map<String,Decimal>();
                    floorFieldToSumMap.putAll(floorIdToFieldValueMap.get(floor.Id));
                    system.debug('floorFieldToSumMap.keySet() is '+ floorFieldToSumMap.keySet());
                    for(String str :floorFieldToSumMap.keySet()){
                        Schema.SobjectField floorFieldName = floorFieldMap.get(sumFields.get(str    ));
                        
                        Decimal sumOfField = 0.00;
                        // system.debug('floor.get(floorFieldName) is '+ floor.get(floorFieldName));
                        system.debug('floorFieldName is '+ floorFieldName );
                        if(floorFieldName!=null){
                            if(Integer.valueof(floor.get(floorFieldName)) > 0 ){
                                sumOfField  = Integer.valueof(floor.get(floorFieldName));
                                
                                sumOfField = floorFieldToSumMap.get(str);
                                
                                floor.put(floorFieldName,sumOfField);
                            }else{
                                sumOfField = floorFieldToSumMap.get(str);
                                floor.put(floorFieldName,sumOfField);
                            }
                        }
                        system.debug('floor is '+ floor);
                        
                        
                        
                    }
                }
                system.debug('floor is '+ floor);
                floor.Total_Units__c = floorToUnitCount.get(floor.id);
                floor.Available_Units__c = floorToAvailableUnitCount.get(floor.Id);
                floor.Reserved_Units__c = floorToReservedUnitCount.get(floor.Id);
                floor.Booked_Units__c = floorToBookedUnitCount.get(floor.Id);
                floor.Sold_Units__c = floorToSoldUnitCount.get(floor.Id);
                floor.Leased_Units__c = floorToLeasedUnitCount.get(floor.Id);
                floorLstToUpdate.add(floor);
            }
            
            system.debug('floorList is '+ floorList);
            
            //update floorList;  
            if(floorLstToUpdate.size()>0){
                update floorLstToUpdate;
            }
            
            // logger object
            
            
            // only one try catch
            
            //Add count logic in this method only.
        }catch(Exception ex){
            system.debug('error is '+ ex.getCause() + ' '+ ex.getMessage()+ ' '+ ex.getLineNumber());
        }
    }
    
    public void unitCountUpdateOnFloor (List<Unit__c> unitList) {
        
        Set<Id> setFloorIds = new Set<Id>();
        
        for(Unit__c unitRecord : unitList){
            setFloorIds.add(unitRecord.Floor__c);
            system.debug('==ProdIds==' + unitRecord.Floor__c);
            system.debug('==setFloorIds==' + unitRecord.Floor__c);
        }
        
        for(Unit__c unitRecord : unitList){
            //Condition to check if the Floor lookup field is updated or not
            if(oldMap !=null && oldMap.get(unitRecord.Id) != null && unitRecord.Floor__c!=oldMap.get(unitRecord.Id).Floor__c){
                setFloorIds.add(unitRecord.Floor__c);
                setFloorIds.add(oldMap.get(unitRecord.Id).Floor__c);
                system.debug('==setFloorIds==' + setFloorIds);
            }
        }
        
        for(Unit__c unitRecord : unitList) {
            setFloorIds.add(unitRecord.Floor__c);
        }
        
        List<Floor__c> floorList=new List<Floor__c>();
        Integer availableUnits = 0;
        Integer reservedUnits = 0;
        Integer soldUnits = 0;
        Integer bookedUnits = 0;
        Integer leasedUnits =0;
        for(Floor__c floor :[Select id,Total_Units__c,Leased_Units__c, Available_Units__c ,(Select id, Unit_Status__c from Units__r) from Floor__c where Id in : setFloorIds]){    
            availableUnits=0;
            reservedUnits=0;
            soldUnits=0;
            bookedUnits=0;
            leasedUnits = 0;
            for(Unit__c unit: floor.Units__r){

                if(unit.Unit_Status__c=='Available'){
                    availableUnits+=1;
                }else if(unit.Unit_Status__c=='Reserved'){
                    reservedUnits+=1;
                }else if(unit.Unit_Status__c=='Booked'){
                    bookedUnits+=1;
                }else if(unit.Unit_Status__c=='Sold'){
                    soldUnits+=1;
                }
                else if(unit.Unit_Status__c=='Leased'){
                    leasedUnits+=1;
                }
            }
            system.debug('==UnitSize==' + floor.Units__r.size());
            floor.Total_Units__c = floor.Units__r.size();
            floor.Available_Units__c = availableUnits;
            floor.Reserved_Units__c = reservedUnits;
            floor.Sold_Units__c = soldUnits;
            floor.Booked_Units__c = bookedUnits;
            floor.Leased_Units__c = leasedUnits;
            floorList.add(floor);
        }
        
        if(!floorList.isEmpty()){
            system.debug('==floorList==' + floorList);
            update floorList;
        }
    }
    
    //Check for ERP criteria for Unit and call 
    public void unitCreation() {
        Set<Id> untId = new Set<Id>();
        
        for(Unit__c unt : newList){
            if(unt.Send_Unit_to_ERP__c && (oldMap == null || unt.Send_Unit_to_ERP__c != oldMap.get(unt.Id).Send_Unit_to_ERP__c)){
                untId.add(unt.Id);
                if(oldMap != null) {
                    unt.Send_Unit_to_ERP__c = false;
                }
            }
        }
        if(!untId.isEmpty()){
            createUnit(untId);
        }
    }
    
    //Added by Moneeb for History Task on 08/02/2022 
    public static void createHistoryRecord(List<sObject> newList,Map<ID,sObject> oldMap ,String objectName){
        List<History_Management__mdt> hmList = [Select id,Field_API_Name__c,Field_Label_Name__c from History_Management__mdt 
                                                where Object_Name__c =: objectName];
        system.debug('hmList**' + hmList);
        List<History__c> historyObjectList = new List<History__c>();
        for(History_Management__mdt hm : hmList){
            for(sObject obj :newList){
                if(obj.get(hm.Field_API_Name__c) != oldMap.get(obj.ID).get(hm.Field_API_Name__c)){
                    History__c hist = new History__c ();
                    hist.Field_Name__c = hm.Field_Label_Name__c;
                    hist.New_Value__c = String.valueof(obj.get(hm.Field_API_Name__c));
                    hist.Old_Value__c = String.valueof(oldMap.get(obj.ID).get(hm.Field_API_Name__c));
                    hist.Unit__c = obj.ID;
                    historyObjectList.add(hist);
                }
            }
        }
        system.debug('historyObjectList Size**' + historyObjectList.size());
        if(historyObjectList.size() > 0){
            insert historyObjectList;   
        }
    }
    
     /*Method: createUnit
* Desc:  Create Unit in ERP
* Param: Unit - Set of Unit Ids
* Return: None
*/
    //@Future(Callout=true)
    public Static void createUnit(Set<Id> unitId) {
        ERPIntegrationHelper.createUnit(unitId);
    }
     /**
* This method is used to update spacetype with spacetype fields on unit are changed or new unit is inserted
* @date   21/01/2022
* @author Swapnil Mohite
*/
    public static void updateSpaceType(List<Unit__c> newList,Map<Id,Unit__c> oldMap){
        Set<String> noOfBedSet = new Set<String>();
        Set<String> unitTypeSet = new Set<String>();
        Set<String> propertyTypeSet = new Set<String>();
        Set<Id> unitIdSet = new Set<Id>();
        Map<String,Space_Type__c> spaceTypeMap = new Map<String,Space_Type__c>();
        for(Unit__c unitObj : newList){
            if(oldMap == null || (unitObj.Leasing_Property_Type__c != oldMap.get(unitObj.Id).leasing_property_type__c ||
                                  unitObj.Unit_space_Type__c != oldMap.get(unitObj.Id).Unit_space_Type__c || 
                                  unitObj.No_of_Bedrooms__c != oldMap.get(unitObj.Id).No_of_Bedrooms__c)){
                                      if(String.isNotBlank(unitObj.No_of_Bedrooms__c)){
                                          noOfBedSet.add(unitObj.No_of_Bedrooms__c);
                                      }
                                      if(String.isNotBlank(unitObj.Leasing_Property_Type__c)){
                                          propertyTypeSet.add(unitObj.Leasing_Property_Type__c);
                                      }
                                      if(String.isNotBlank(unitObj.Unit_space_Type__c)){
                                          unitTypeSet.add(unitObj.Unit_space_Type__c);
                                      }
                                      unitIdSet.add(unitObj.Id); 
                                  }
        }
        system.debug('noOfBedSet-->'+noOfBedSet);
        system.debug('propertyTypeSet-->'+propertyTypeSet);
        system.debug('unitTypeSet-->'+unitTypeSet);
        if(unitIdSet.size() > 0){
            List<Space_Type__c> spaceTypeList = [SELECT id,name,no_of_bedrooms__c,Unit_Type__c,Property_Type__c  
                                                 FROM Space_Type__c
                                                 WHERE purpose__c = 'Leasing' and
                                                 (No_of_bedrooms__c IN : noOfBedSet or  Unit_Type__c IN : unitTypeSet or  property_type__c IN : propertyTypeSet)];
            for(Space_Type__c spaceType : spaceTypeList){
                String key= '';
                if(String.isNotBlank(spaceType.No_of_bedrooms__c)){
                    key = spaceType.No_of_bedrooms__c + '-';
                }
                if(String.isNotBlank(spaceType.property_type__c)){
                    if(String.isBlank(key)){
                        key = spaceType.property_type__c + '-';
                    }else{
                        key = key + spaceType.property_type__c + '-';
                    } 
                }
                if(String.isNotBlank(spaceType.unit_Type__c)){
                     if(String.isBlank(key)){
                        key = spaceType.unit_type__c;
                    }else{
                        key = key + spaceType.unit_type__c;
                    }
                }
                
                spaceTypeMap.put(key,spaceType); 
            }
            System.debug('spaceTypeMap->'+spaceTypeMap);
            for(Unit__c unitObj : newList){
                String key='';
                if(String.isNotBlank(unitObj.No_of_bedrooms__c)){
                    key = unitObj.No_of_bedrooms__c + '-';
                }
                if(String.isNotBlank(unitObj.Leasing_Property_Type__c)){
                     if(String.isBlank(key)){
                        key = unitObj.Leasing_Property_Type__c + '-';
                    }else{
                        key = key + unitObj.Leasing_Property_Type__c + '-';
                    } 
                }
                if(String.isNotBlank(unitObj.Unit_space_Type__c)){
                    if(String.isBlank(key)){
                        key = unitObj.Unit_space_Type__c;
                    }else{
                        key = key + unitObj.Unit_space_Type__c;
                    }   
                }
                system.debug('Key->'+key);
                if(spaceTypeMap.containsKey(key)){
                     system.debug('Key from inside->'+key);
                    unitObj.Unit_Leasing_Type__c = spaceTypeMap.get(key).Id;
                }
            }
        }
    }

    /**
    * This method is used to create floor records if any new Floor code is populated in Unit Record. Also It populated the Floor Lookup value on Unit Record
    * @date   23/03/2022
    * @author Shivani Rathi
    */
    public static void upsertFloorDetails(List<Unit__c> newList, Map<Id,Unit__c> oldMap){
        Set<String> floorCodes = new Set<String>();
        Map<String,Floor__c> mapFloorCodeToFloor = new Map<String,Floor__c>();
        system.debug('%%units'+newList);
        for(Unit__c objUnit : newList){
            if(String.isBlank(objUnit.Floor__c) && (String.isNotBlank(objUnit.Floor_Code_New__c) || (String.isNotBlank(objUnit.Floor_Code_New__c) && oldMap != null && oldMap.get(objUnit.Id).Floor_Code_New__c != objUnit.Floor_Code_New__c))){      
                   floorCodes.add(objUnit.Floor_Code_New__c);
               }
        }
        
		system.debug('==floorCodes=='+floorCodes);
        
        Map<String,Floor__c> mapFloorCodeToFloorFromSalesforce = new Map<String,Floor__c>();
        List<String> FloorCodeToUpdateInUnit = new List<String>();
        
        if(floorCodes.isEmpty() == false){
            for(Floor__c objFloor : [SELECT ID,Floor_Code__c, Floor_Plan__c,Floor_Purpose__c,Start_Date__c, End_Date__c 
                                     FROM Floor__c 
                                     WHERE Floor_Code__c IN : floorCodes]){
                                         mapFloorCodeToFloorFromSalesforce.put(objFloor.Floor_Code__c,objFloor);
                                     }
        }
        
        for(Unit__c objUnit : newList){
            system.debug('%%objUnit'+objUnit);
            if(mapFloorCodeToFloorFromSalesforce.containsKey(objUnit.Floor_Code_New__c)){
                objUnit.Floor__c = mapFloorCodeToFloorFromSalesforce.get(objUnit.Floor_Code_New__c).Id;
            } else {
                mapFloorCodeToFloor.put( objUnit.Floor_Code_New__c,
                                        new Floor__c( Floor_Code__c = objUnit.Floor_Code_New__c, 
                                                     Floor_Plan__c = objUnit.Floor_Plan__c,
                                                     Floor_Alias__c = objUnit.Floor_Alias__c,
                                                     Name =  objUnit.Floor_Name__c,
                                                     Building__c =  objUnit.Building__c
                                                     // Start_Date__c = objUnit.Actual_Start_Date__c,
                                                     // End_Date__c = objUnit.Actual_End_Date__c
                                                    )
                                       );
                FloorCodeToUpdateInUnit.add(objUnit.Floor_Code_New__c);
            }
        }
        
        system.debug('==mapFloorCodeToFloor=='+mapFloorCodeToFloor);
        
        if(!mapFloorCodeToFloor.KeySet().isEmpty()){ 
            upsert mapFloorCodeToFloor.values();
            if(!FloorCodeToUpdateInUnit.isEmpty()){ 
                updateFloorDetails(FloorCodeToUpdateInUnit);
            }
        }
    }

    /**
    * This method is used to create floor records if any new Floor code is populated in Unit Record. Also It populated the Floor Lookup value on Unit Record
    * @date   23/03/2022
    * @author Shivani Rathi
    */
    @Future
    private static void updateFloorDetails(List<String> listFloorCodes){
        Map<String,Floor__c> mapFloorCodeToFloor = new Map<String,Floor__c>();
        for(Floor__c objFloor : [SELECT ID,Floor_Code__c, Floor_Plan__c,Floor_Purpose__c,Start_Date__c, End_Date__c 
                                        FROM Floor__c 
                                        WHERE Floor_Code__c IN : listFloorCodes]){
            mapFloorCodeToFloor.put(objFloor.Floor_Code__c,objFloor);
        }

        List<Unit__c> listUnit = [Select Id, Floor__c, Floor_Code_New__c FROM Unit__c Where Floor_Code_New__c IN : listFloorCodes];
        for(Unit__c objUnit : listUnit){
            if(mapFloorCodeToFloor.containsKey(objUnit.Floor_Code_New__c)){
                objUnit.Floor__c = mapFloorCodeToFloor.get(objUnit.Floor_Code_New__c).Id;
            }
        }

        if(!listUnit.isEmpty()){
            update listUnit;
        }
    }
    /**
    * This method is used to update bussiness details on in Unit Record.
    * @date   23/03/2022
    * @author Shivani Rathi
    */
    public static void updateUnitDetails(List<Unit__c> newList, Map<Id,Unit__c> oldMap){
        Set<String> buildingIds = new Set<String>();
        Set<String> projectIdSet = new Set<String>();
        
        for(Unit__c objUnit : newList){
            if(String.isNotBlank(objUnit.Building__c) || (String.isNotBlank(objUnit.Building__c) && oldMap != null && oldMap.get(objUnit.Id).Building__c != objUnit.Building__c)){
                buildingIds.add(objUnit.Building__c);
            }
            if(objUnit.Project__c != null || (objUnit.Project__c != null && oldMap != null && oldMap.get(objUnit.Id).Project__c != objUnit.Project__c)){
                projectIdSet.add(objUnit.Project__c) ;
            }
        }
        
        Map<Id,Building__c> mapBuilding = new Map<Id,Building__c>([SELECT ID,Business_Group__c, Business_Unit__c, Building_Purpose__c, Project__c, Cluster__c
                                                                   FROM Building__c 
                                                                   WHERE ID IN : buildingIds]);
        
        Map<Id, Project__c> projectMap = new Map<Id, Project__c> ([Select id,Business_Group__c ,Business_Unit__c, Project_Purpose__c, DLD_Area_Name__c, DLD_Nakheel_Share__c, DLD_Customer_Share__c, Master_Payment_Plan__c 
                                                                   FROM Project__c WHERE Id IN : projectIdSet]);
        
        for(Unit__c objUnit : newList){
            if(String.isNotBlank(objUnit.Building__c) && mapBuilding.containsKey(objUnit.Building__c)){
                objUnit.Business_Group__c = mapBuilding.get(objUnit.Building__c).Business_Group__c;
                objUnit.Business_Unit__c = mapBuilding.get(objUnit.Building__c).Business_Unit__c;
                objUnit.Unit_Purpose__c = mapBuilding.get(objUnit.Building__c).Building_Purpose__c;
                objUnit.Project__c = mapBuilding.get(objUnit.Building__c).Project__c;
                objUnit.Cluster__c = mapBuilding.get(objUnit.Building__c).Cluster__c;
            }else if(objUnit.Project__c != null && projectMap.containsKey(objUnit.Project__c)){
                objUnit.Business_Group__c = projectMap.get(objUnit.Project__c).Business_Group__c;
                objUnit.Business_Unit__c = projectMap.get(objUnit.Project__c).Business_Unit__c;
                objUnit.Unit_Purpose__c = projectMap.get(objUnit.Project__c).Project_Purpose__c;
            }
            
            if(objUnit.Project__c != null && projectMap.containsKey(objUnit.Project__c)){
                objUnit.DLD_Area_Name__c = projectMap.get(objUnit.Project__c).DLD_Area_Name__c;
                //Commented by Ashams
                if(objUnit.DLD_Nakheel_Share__c == null){
                    objUnit.DLD_Nakheel_Share__c = projectMap.get(objUnit.Project__c).DLD_Nakheel_Share__c;
                }
                if(objUnit.DLD_Customer_Share__c == null){
                    objUnit.DLD_Customer_Share__c = projectMap.get(objUnit.Project__c).DLD_Customer_Share__c;
                }
                objUnit.Master_Payment_Plan__c = projectMap.get(objUnit.Project__c).Master_Payment_Plan__c;
            }
            //added by Husain to update total area
            if((oldMap == null && (objUnit.Built_Up_Area__c != null || objUnit.Balcony_Area__c != null)) || 
               (((oldMap != null && oldMap.get(objUnit.Id).Built_Up_Area__c != objUnit.Built_Up_Area__c))
                || (oldMap != null && oldMap.get(objUnit.Id).Balcony_Area__c != objUnit.Balcony_Area__c))) {
                    objUnit.Total_Area__c = (objUnit.Built_Up_Area__c != null ? objUnit.Built_Up_Area__c : 0) + (objUnit.Balcony_Area__c != null ? objUnit.Balcony_Area__c : 0);
                }
        }
    }
    /**
    * This method is used to update Unit Name on in Unit Record.
    * @date   08/04/2022
    * @author Shivani Rathi
    */
    public static void updateUnitName(List<Unit__c> newList, Map<Id,Unit__c> oldMap){
        Set<String> buildingIds = new Set<String>();
        for(Unit__c objUnit : newList){
            if(String.isNotBlank(objUnit.Unit_Code__c) || (oldMap != null && oldMap.get(objUnit.Id).Unit_Code__c != objUnit.Unit_Code__c)){
                objUnit.Name = objUnit.Unit_Code__c;
            }
        }
    }
    /**
    * This method is used to update Additional Area on in Unit Record.
    * @date   11/04/2022
    * @author Shivani Rathi
    * Commented by Ashams - Logic moved to formula fields
    */
    /*public static void updateAddtionalArea(List<Unit__c> newList, Map<Id,Unit__c> oldMap){
        Set<String> buildingIds = new Set<String>();
        for(Unit__c objUnit : newList){
            if(objUnit.Additional_area__c != 0 || (oldMap != null && oldMap.get(objUnit.Id).Additional_area__c != objUnit.Additional_area__c)){
                objUnit.Built_Up_Area__c = objUnit.Built_Up_Area__c + objUnit.Additional_area__c;
                objUnit.Total_Area__c = objUnit.Total_Area__c + objUnit.Additional_area__c;
            }
        }
    }*/
    
    /**
    * This method is used to check checkbox Send Unit to ERP.
    * @author Vishal A
    */
    public void sendUnitERP() {
        for(Unit__c unt: newList) {
            if(unt.Building__c != null && unt.Business_Unit__c != null && unt.Floor__c != null && unt.Project__c != null && String.isBlank(unt.ERP_Unit_Id__c) && (unt.Unit_Status__c == 'Available' || unt.Unit_Status__c == 'Vacant' )&& 
                (oldMap == null || oldMap.get(unt.Id).Building__c == null || oldMap.get(unt.Id).Business_Unit__c == null || oldMap.get(unt.Id).Floor__c == null || oldMap.get(unt.Id).Project__c == null || oldMap.get(unt.Id).Unit_Status__c != unt.Unit_Status__c)) {
                unt.Send_Unit_to_ERP__c = true;
            }
        }
    }
    
    /*
  *Author : Deep Banerjee
  *Created Date: 21/04/22
  *Purpose: to pre-poulate the business unit and business group from project of the unit

 */
    public static void populateBusinessUnit(List<Unit__c> triggerNew){
        set<Id> projectIds = new Set<Id>();
        
        for(Unit__c unit : triggerNew){
            if(unit.Building__c==null && unit.Project__c!=null ){
               projectIds.add(unit.Project__c) ;
            }
        }
       
        Map<Id,Id> bgroupMap = new Map<Id,Id>();
        Map<Id,Id> buintMap= new Map<Id,Id>();
        if(getRemainingQueryLimit() >0){
            for(Project__c project : getProjects(projectIds)){
                bgroupMap.put(project.id,project?.Business_Group__c);
                buintMap.put(project.id,project?.Business_Unit__c);
            }
            
            for(Unit__c unit : triggerNew){
                unit.Business_Group__c= bgroupMap.containsKey(unit.Project__c) ? bgroupMap?.get(unit.Project__c) : null;
                unit.Business_Unit__c= bgroupMap.containsKey(unit.Project__c) ? buintMap?.get(unit.Project__c) : null;
            }
        }
                               
    }
    
     /*
  *Author : Deep Banerjee
  *Created Date: 21/04/22
 */
    
    private static List<Project__c> getProjects(set<id> ids){
        if(ids==null) return null;
        
        return [Select id,Business_Group__c ,Business_Unit__c  
                FROM Project__c WHERE Id IN: ids];
    }
    
     /*
  *Author : Deep Banerjee
  *Created Date: 21/04/22
 */
    
    private static Integer getRemainingQueryLimit(){
        return Limits.getLimitQueries() - Limits.getQueries();
    }
    
     /*
  *Author : Deep Banerjee
  *Created Date: 08/05/22
  *Purpose: to create unit option using standard import
 */
    
    public static void creatUnitOptionsfromImport(List<Unit__c> triggerNew){
        system.debug('inside creatUnitOptionsfromImport');
        if(!recursionController){
           recursionController=true; 

            List<Master_Option__c> masterOptions = [Select id,Option_Name__c FROM Master_Option__c Limit 50000];
            Map<String,Master_Option__c> masterOptionsMap = new Map<String,Master_Option__c>();
            for(Master_Option__c mo : masterOptions){  
                
                masterOptionsMap.put(mo.Option_Name__c,mo);
            }
            List<Unit_Option__c> options = new List<Unit_Option__c>();
            for(Unit__c unit : triggerNew){
                if(unit.Unit_color_option__c =='Light' && masterOptionsMap.containsKey(unit.Unit_color_option__c)) 
                {   
                     Unit_Option__c uop = new Unit_Option__c();
                     uop.Master_Option__c= masterOptionsMap.get(unit.Unit_color_option__c).Id;
                     uop.Unit__c= unit.id;
                     options.add(uop);
                    
                }else if(unit.Unit_color_option__c =='Dark' && masterOptionsMap.containsKey(unit.Unit_color_option__c)){
                     Unit_Option__c uop = new Unit_Option__c();
                     uop.Master_Option__c= masterOptionsMap.get(unit.Unit_color_option__c).Id;
                     uop.Unit__c= unit.id;
                     options.add(uop);
                }
                
                if(unit.Pent_House_Option__c ){
                    
                     Unit_Option__c uop = new Unit_Option__c();
                     uop.Master_Option__c=  masterOptionsMap.containsKey('Pent House') ?
                                            masterOptionsMap.get('Pent House').Id : null;
                     uop.Unit__c= unit.id;
                     uop.Additional_Area__c=unit.Pent_House_Additional_Area_SFT__c;
                     uop.Price__c=unit.Pent_House_Charge__c;
                     uop.Unit_Theme__c=unit.Pent_House_Unit_Theme__c;
                     options.add(uop);
                }
                   
                if(unit.Swimming_Pool_Option__c){
                     Unit_Option__c uop = new Unit_Option__c();
                     uop.Master_Option__c= masterOptionsMap.containsKey('Swimming Pool') ?
                                             masterOptionsMap.get('Swimming Pool').Id : null;
                    uop.Unit__c= unit.id;
                    uop.Optional_Length__c=unit.Swimming_Pool_Length_SFT__c;
                    uop.Optional_Width__c=unit.Swimming_Pool_Width_SFT__c;
                    uop.Price__c=unit.Swimming_Pool_Price__c;
                    options.add(uop);
                }
                if(unit.Maid_Room_Option__c){
                     Unit_Option__c uop = new Unit_Option__c();
                     uop.Master_Option__c= masterOptionsMap.containsKey('Maid Room') ?
                                           masterOptionsMap.get('Maid Room').Id : null;
                     uop.Unit__c= unit.id;
                     uop.Additional_Area__c=unit.Maid_Room_Additional_Area_SFT__c;
                     uop.Price__c=unit.Maid_Room_Price__c;
                     options.add(uop);
                }
                if(unit.Watchman_Room_Option__c){
                     
                     Unit_Option__c uop = new Unit_Option__c();
                     uop.Master_Option__c= masterOptionsMap.containsKey('Watchman Room') ?
                                           masterOptionsMap.get('Watchman Room').Id : null;
                     uop.Unit__c= unit.id;
                     uop.Additional_Area__c=unit.Watchman_Room_Additional_Area_SFT__c;
                     uop.Price__c=unit.Watchman_Room_Price__c;
                     options.add(uop);
                }

            }
             insertUnitOptions(options);
            
        }
  
    }
    
    private static void insertUnitOptions(List<Unit_Option__c> options){
        system.debug('@@@ options @@@ '+options);
        if(!options.isEmpty()){
           database.insert(options,false) ;
        }
    }
    
    /**
    * This method is used to update DLD field details on in Unit from Project in sales only.
    * @date   10/05/2022
    * @author Ashams
    */
    public static void updateDLDdetailsSales(List<Unit__c> newList,Map<Id,Unit__c> oldMap){
        Set<Id> projectIds = new Set<Id>();
        Map<Id,Project__c> projectIdMap = new Map<Id,Project__c>();
        for(Unit__c objUnit : newList){
            if((objUnit.Unit_Purpose__c == 'Sales' && objUnit.Unit_Purpose__c != null && String.isNotBlank(objUnit.Project__c)) || 
               (oldMap != null && objUnit.Unit_Purpose__c == 'Sales' && objUnit.Project__c!=null && oldMap.get(objUnit.Id).Project__c != objUnit.Project__c)){
               projectIds.add(objUnit.Project__c); 
            }
        }
        if(!projectIds.isEmpty()){
            projectIdMap = new Map<Id,Project__c>([SELECT ID,Name,DLD_Customer_Share__c,DLD_Nakheel_Share__c
                                                   FROM Project__c 
                                                   WHERE ID IN : projectIds]);
        }
        
        for(Unit__c objUnit : newList){
            if(String.isNotBlank(objUnit.Project__c) && projectIdMap.containsKey(objUnit.Project__c)){
                if(projectIdMap.get(objUnit.Project__c).DLD_Customer_Share__c!=null && objUnit.DLD_Customer_Share__c==null){
                    objUnit.DLD_Customer_Share__c = projectIdMap.get(objUnit.Project__c).DLD_Customer_Share__c;
                }
                if(projectIdMap.get(objUnit.Project__c).DLD_Nakheel_Share__c!=null && objUnit.DLD_Nakheel_Share__c==null){
                    objUnit.DLD_Nakheel_Share__c = projectIdMap.get(objUnit.Project__c).DLD_Nakheel_Share__c;
                }
            }
        }
    }

    /******************************************************************************************************
    * @Description        : Make Deal and SPA read Only when unit is sold
    * Date                : 20/05/2022
    * Author              : Rhoit Sharma                                                                   
    * @Return             : void                                                                         
    *******************************************************************************************************/
    public void makeDealAndSpaReadOnly(){
        Set<Id> unitIdSet = new Set<Id>();
        for(Unit__c unit : newList){
            if(unit.Unit_Status__c != null && unit.Unit_Status__c == 'Sold' && unit.Unit_Status__c != oldMap.get(unit.Id).Unit_Status__c){
                unitIdSet.add(unit.Id);
            }
        }
        if(!unitIdSet.isEmpty()){
            List<Agreement__c> spaList = new List<Agreement__c>();
            List<Opportunity> oppList = new List<Opportunity>();
            Id spaReadOnly = Schema.SObjectType.Agreement__c.getRecordTypeInfosByDeveloperName().get('SPA_Read_Only').getRecordTypeId();
            Id readOnlyUnitSold = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Deal_Unit_Sold').getRecordTypeId();
            for(Opportunity op : [SELECT Id, Agreement__c FROM Opportunity WHERE Unit__c IN: unitIdSet AND StageName = 'SPA Executed']){
                Opportunity opp = new Opportunity();
                opp.Id = op.Id;
                opp.RecordTypeId = readOnlyUnitSold;
                oppList.add(opp);
                if(op.Agreement__c != null){
                    Agreement__c ag = new Agreement__c();
                    ag.Id = op.Agreement__c;
                    ag.RecordTypeId = spaReadOnly;
                    spaList.add(ag);
                }
            }
            if(!oppList.isEmpty()){
                update oppList;
            }
            if(!spaList.isEmpty()){
                update spaList;
            }
        }
    }
    
    /******************************************************************************************************
    * @Description        : Create/Delete Unit Option on Unit Creation/Updation 
    * Date                : 10/05/2022
    * Author              : Rhoit Sharma                                                                   
    * @Return             : void                                                                         
    *******************************************************************************************************/
    public void createUnitOptions(){
        system.debug('%%createUnitOptions');
        Boolean callFutureMethod = false;
        NKLWrapperUtil.OptionsWrapper wrap = new NKLWrapperUtil.OptionsWrapper();
        Set<Id> setUnitIdsColorOption = new Set<Id>();
        Set<Id> setUnitIdsForPentHouseTrue = new Set<Id>();
        Set<Id> setUnitIdsForPentHouseFalse = new Set<Id>();
        Set<Id> setUnitIdsForSwimmingPoolTrue = new Set<Id>();
        Set<Id> setUnitIdsForSwimmingPoolFalse = new Set<Id>();
        Set<Id> setUnitIdsForMaidRoomTrue = new Set<Id>();
        Set<Id> setUnitIdsForMaidRoomFalse = new Set<Id>();
        Set<Id> setUnitIdsForWatchmanRoomTrue = new Set<Id>();
        Set<Id> setUnitIdsForWatchmanRoomFalse = new Set<Id>();
        Set<Id> allUnitIds = new Set<Id>();
        for(Unit__c unit : newList){
            if( oldMap == null || oldMap.get( unit.Id ).Color_Option__c != unit.Color_Option__c ){
                setUnitIdsColorOption.add( unit.Id ) ;
                allUnitIds.add( unit.Id );
                callFutureMethod = true;
            }
            if( oldMap == null || oldMap.get( unit.Id ).Pent_House_Option__c != unit.Pent_House_Option__c ){
                if( unit.Pent_House_Option__c ){
                    setUnitIdsForPentHouseTrue.add( unit.Id );
                    allUnitIds.add( unit.Id );
                    callFutureMethod = true;
                }else{
                    setUnitIdsForPentHouseFalse.add( unit.Id );
                    allUnitIds.add( unit.Id );
                    callFutureMethod = true;
                }
            }
            if( oldMap == null || oldMap.get( unit.Id ).Swimming_Pool_Option__c != unit.Swimming_Pool_Option__c ){
                if( unit.Swimming_Pool_Option__c ){
                    setUnitIdsForSwimmingPoolTrue.add( unit.Id );
                    allUnitIds.add( unit.Id );
                    callFutureMethod = true;
                }else{
                    setUnitIdsForSwimmingPoolFalse.add( unit.Id );
                    allUnitIds.add( unit.Id );
                    callFutureMethod = true;
                }
            }
            if( oldMap == null || oldMap.get( unit.Id ).Maid_Room_Option__c != unit.Maid_Room_Option__c ){
                if( unit.Maid_Room_Option__c ){
                    setUnitIdsForMaidRoomTrue.add( unit.Id );
                    allUnitIds.add( unit.Id );
                    callFutureMethod = true;
                }else{
                    setUnitIdsForMaidRoomFalse.add( unit.Id );
                    allUnitIds.add( unit.Id );
                    callFutureMethod = true;
                }
            }
            if( oldMap == null || oldMap.get( unit.Id ).Watchman_Room_Option__c != unit.Watchman_Room_Option__c ){
                if( unit.Watchman_Room_Option__c ){
                    setUnitIdsForWatchmanRoomTrue.add( unit.Id );
                    allUnitIds.add( unit.Id );
                    callFutureMethod = true;
                }else{
                    setUnitIdsForWatchmanRoomFalse.add( unit.Id );
                    allUnitIds.add( unit.Id );
                    callFutureMethod = true;
                }
            }
        }
        wrap.setUnitIdsColorOption = setUnitIdsColorOption;
        wrap.setUnitIdsForPentHouseTrue = setUnitIdsForPentHouseTrue;
        wrap.setUnitIdsForPentHouseFalse = setUnitIdsForPentHouseFalse;
        wrap.setUnitIdsForSwimmingPoolTrue = setUnitIdsForSwimmingPoolTrue;
        wrap.setUnitIdsForSwimmingPoolFalse = setUnitIdsForSwimmingPoolFalse;
        wrap.setUnitIdsForMaidRoomTrue = setUnitIdsForMaidRoomTrue;
        wrap.setUnitIdsForMaidRoomFalse = setUnitIdsForMaidRoomFalse;
        wrap.setUnitIdsForWatchmanRoomTrue = setUnitIdsForWatchmanRoomTrue;
        wrap.setUnitIdsForWatchmanRoomFalse = setUnitIdsForWatchmanRoomFalse;
        wrap.allUnitIds = allUnitIds;

        if(callFutureMethod && !system.isFuture() && !system.isBatch()){
            createUnitOptionsFutureMethod(JSON.serialize(wrap));
        }
    }

    /******************************************************************************************************
    * @Description        : Create/Delete Unit Option on Unit Creation/Updation 
    * Date                : 10/05/2022
    * Author              : Rhoit Sharma                                                                   
    * @Return             : void                                                                         
    *******************************************************************************************************/
    @Future
    public static void createUnitOptionsFutureMethod(String optionsWrap){
        Savepoint sp = Database.setSavepoint();
        NKLWrapperUtil.OptionsWrapper wrappper = (NKLWrapperUtil.OptionsWrapper) JSON.deserialize(optionsWrap, NKLWrapperUtil.OptionsWrapper.class);
        List<Unit_Option__c> unitOptionsToInsert = new List<Unit_Option__c>();
        List<Unit_Option__c> unitOptionsToDelete = new List<Unit_Option__c>();
        Set<Id> unitIdsForOptionsToDelete = new Set<Id>();
        unitIdsForOptionsToDelete.addAll(wrappper.setUnitIdsColorOption);
        unitIdsForOptionsToDelete.addAll(wrappper.setUnitIdsForPentHouseFalse);
        unitIdsForOptionsToDelete.addAll(wrappper.setUnitIdsForSwimmingPoolFalse);
        unitIdsForOptionsToDelete.addAll(wrappper.setUnitIdsForMaidRoomFalse);
        unitIdsForOptionsToDelete.addAll(wrappper.setUnitIdsForWatchmanRoomFalse);
        Map<String,Master_Option__c> masterOptionsMap = new Map<String,Master_Option__c>();
        system.debug('%%wrappper'+wrappper);
        system.debug('%%setUnitIdsForMaidRoomTrue'+wrappper.setUnitIdsForMaidRoomTrue);
        for(Master_Option__c mo : [SELECT Id,Option_Name__c FROM Master_Option__c LIMIT 5000]){  
            masterOptionsMap.put( mo.Option_Name__c, mo );
        }
        if(!masterOptionsMap.isEmpty()){
            for(Unit__c unit : [SELECT Id,Color_Option__c,Project__c,Unit_Style__c,Unit_Theme__c,Pent_House_Charge__c,Pent_House_Additional_Area_SFT__c,Pent_House_Unit_Theme__c,
                                Swimming_Pool_Length_SFT__c,Swimming_Pool_Price__c,Swimming_Pool_Width_SFT__c,
                                Maid_Room_Additional_Area_SFT__c,Maid_Room_Price__c,Watchman_Room_Additional_Area_SFT__c,
                                Watchman_Room_Price__c FROM Unit__c WHERE Id IN: wrappper.allUnitIds]){
                if( wrappper.setUnitIdsColorOption != null && !wrappper.setUnitIdsColorOption.IsEmpty() && wrappper.setUnitIdsColorOption.contains( unit.Id) ){
                    List<String> colorOptionList = unit.Color_Option__c != null ? unit.Color_Option__c.split(';') : null;
                    if(colorOptionList != null){
                        for(String color : colorOptionList){
                            Unit_Option__c up = new Unit_Option__c();
                            up.Unit__c = unit.Id;
                            up.Master_Option__c = masterOptionsMap.containsKey(color) ? masterOptionsMap.get(color).Id : null;
                            up.Project__c = unit.Project__c;
                            up.Price__c = 0;
                            //up.Unit_Theme__c = unit.Unit_Theme__c;
                            //up.Unit_Style__c = unit.Unit_Style__c;
                            unitOptionsToInsert.add( up );
                        }
                    }
                }
                if( wrappper.setUnitIdsForPentHouseTrue != null && !wrappper.setUnitIdsForPentHouseTrue.IsEmpty() && wrappper.setUnitIdsForPentHouseTrue.contains( unit.Id) ){
                    Unit_Option__c up = new Unit_Option__c();
                    up.Unit__c = unit.Id;
                    up.Master_Option__c = masterOptionsMap.containsKey('Pent House') ? masterOptionsMap.get('Pent House').Id : null;
                    up.Project__c = unit.Project__c;
                    up.Price__c = unit.Pent_House_Charge__c;
                    up.Additional_Area__c = unit.Pent_House_Additional_Area_SFT__c;
                    up.Unit_Theme__c = unit.Pent_House_Unit_Theme__c;
                    unitOptionsToInsert.add( up );
                }
                if( wrappper.setUnitIdsForSwimmingPoolTrue != null && !wrappper.setUnitIdsForSwimmingPoolTrue.IsEmpty() && wrappper.setUnitIdsForSwimmingPoolTrue.contains( unit.Id) ){
                    Unit_Option__c up = new Unit_Option__c();
                    up.Unit__c = unit.Id;
                    up.Master_Option__c = masterOptionsMap.containsKey('Swimming Pool') ? masterOptionsMap.get('Swimming Pool').Id : null;
                    up.Project__c = unit.Project__c;
                    up.Price__c = unit.Swimming_Pool_Price__c;
                    up.Optional_Length__c = unit.Swimming_Pool_Length_SFT__c;
                    up.Optional_Width__c = unit.Swimming_Pool_Width_SFT__c;
                    unitOptionsToInsert.add( up );
                }
                if( wrappper.setUnitIdsForMaidRoomTrue != null && !wrappper.setUnitIdsForMaidRoomTrue.IsEmpty() && wrappper.setUnitIdsForMaidRoomTrue.contains( unit.Id) ){
                    Unit_Option__c up = new Unit_Option__c();
                    up.Unit__c = unit.Id;
                    up.Master_Option__c = masterOptionsMap.containsKey('Maid Room') ? masterOptionsMap.get('Maid Room').Id : null;
                    up.Project__c = unit.Project__c;
                    up.Price__c = unit.Maid_Room_Price__c;
                    up.Additional_Area__c = unit.Maid_Room_Additional_Area_SFT__c;
                    unitOptionsToInsert.add( up );
                }
                if( wrappper.setUnitIdsForWatchmanRoomTrue != null && !wrappper.setUnitIdsForWatchmanRoomTrue.IsEmpty() && wrappper.setUnitIdsForWatchmanRoomTrue.contains( unit.Id) ){
                    Unit_Option__c up = new Unit_Option__c();
                    up.Unit__c = unit.Id;
                    up.Master_Option__c = masterOptionsMap.containsKey('Watchman Room') ? masterOptionsMap.get('Watchman Room').Id : null;
                    up.Project__c = unit.Project__c;
                    up.Price__c = unit.Watchman_Room_Price__c;
                    up.Additional_Area__c = unit.Watchman_Room_Additional_Area_SFT__c;
                    unitOptionsToInsert.add( up );
                }
            }
        }
        if(unitIdsForOptionsToDelete != null && !unitIdsForOptionsToDelete.isEmpty()){
            Set<Id> optionsId = new Set<Id>();
            for(Unit_Option__c uo : [SELECT Id,unit__c,Unit_Option_Name__c,unit__r.Pent_House_Option__c,
                                     unit__r.Swimming_Pool_Option__c,unit__r.Maid_Room_Option__c,unit__r.Watchman_Room_Option__c 
                                     FROM Unit_Option__c WHERE Unit__c IN:unitIdsForOptionsToDelete ]){
                if(wrappper.setUnitIdsColorOption != null && !wrappper.setUnitIdsColorOption.IsEmpty() &&  wrappper.setUnitIdsColorOption.contains( uo.unit__c)){
                    if(uo.Unit_Option_Name__c == 'Dark Color' || uo.Unit_Option_Name__c == 'Light Color'){
                        optionsId.add(uo.Id);
                    }
                }
                if(!uo.unit__r.Pent_House_Option__c){
                    if(uo.Unit_Option_Name__c == 'Pent House'){
                        optionsId.add(uo.Id);
                    }
                }
                if(!uo.unit__r.Swimming_Pool_Option__c){
                    if(uo.Unit_Option_Name__c == 'Swimming Pool'){
                        optionsId.add(uo.Id);
                    }
                }
                if(!uo.unit__r.Maid_Room_Option__c){
                    if(uo.Unit_Option_Name__c == 'Maid Room'){
                        optionsId.add(uo.Id);
                    }
                }
                if(!uo.unit__r.Watchman_Room_Option__c){
                    if(uo.Unit_Option_Name__c == 'Watchman Room'){
                        optionsId.add(uo.Id);
                    }
                }
            }
            if(!optionsId.isEmpty()){
                unitOptionsToDelete = [SELECT Id FROM Unit_Option__c WHERE Id IN:optionsId];
            }
        }
        try{
            system.debug('%%unitOptionsToInsert'+unitOptionsToInsert.size());
            system.debug('%%unitOptionsToInsert'+unitOptionsToInsert);
            if(!unitOptionsToDelete.isEmpty()){
                delete unitOptionsToDelete;
            }
            if(!unitOptionsToInsert.isEmpty()){
                insert unitOptionsToInsert;
            }
        }catch(Exception ex){
            System.debug('Error: '+ex.getMessage());
            Database.RollBack(sp);
        }
    } 
    /** 
    * @createdDate : 20 May 2022 
    * @author : Husain Sayyed
    * @Version : V1.1
    * @usage : This function invokes before Insert and Update of Account to update country and nationality fields. 
    **/    
    public void updateProperty(){
        list<Property__c> propertyToUpdateList = new list<Property__c>();
        set<Id> unitIdSet = new set<Id>();
        
        for(Unit__c unitRecord : this.newList){
            if(unitRecord.Blocked_Sub_status__c != null && unitRecord.Blocked_Sub_status__c == 'Sold Cancelled' && unitRecord.Blocked_Sub_status__c != this.oldMap.get(unitRecord.Id).Blocked_Sub_status__c){
                unitIdSet.add(unitRecord.Id);
            }
        }
        
        if(unitIdSet.isEmpty() == false){
            for(Property__c propertyRecord : [select Id from Property__c where Unit__c in : unitIdSet]){
                propertyRecord.Active__c = false;
                propertyToUpdateList.add(propertyRecord);
            }
            
            if(propertyToUpdateList.isEmpty() == false){
                update propertyToUpdateList;
            }
        }
    }
}