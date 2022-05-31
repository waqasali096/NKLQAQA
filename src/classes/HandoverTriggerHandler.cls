public class HandoverTriggerHandler {
    List<Handover__c> newList = new List<Handover__c>();
    List<Handover__c> oldList = new List<Handover__c>();
    Map<Id, Handover__c> newMap = new Map<Id, Handover__c>();
    Map<Id, Handover__c> oldMap = new Map<Id, Handover__c>();
    Boolean isInsert, isUpdate, isDelete, isUndelete = false;
    public static boolean recursionController = false;
    
    public HandoverTriggerHandler(List<Handover__c> newList, List<Handover__c> oldList, Map<Id, Handover__c> newMap, Map<Id, Handover__c> oldMap, boolean isInsert, boolean isUpdate, Boolean isDelete, Boolean isUndelete) {
        this.newList = newList;
        this.oldList = oldList;
        this.newMap = newMap;
        this.oldMap = oldMap;
        this.isInsert = isInsert;
        this.isUpdate = isUpdate;
        this.isDelete = isDelete;
        this.isUndelete = isUndelete;
    }
    
    public void BeforeInsertEvent() {}
    
    public void AfterInsertEvent() {
        GenericTriggerHandler.createDocRecord(newList, 'Handover__c');
        updateContractLookup(newList);
        autoAssignOwnertoHandover();
        createTaskforSalesHandover(newList);//Added by Anshita 13-04-2022
        //contractUnderHandover(newList, oldMap, newMap); //Commented by Karishma 03-03-2022
    }
    
    public void BeforeUpdateEvent() {
        GenericTriggerHandler.validateDocRecord(newList,oldMap,newMap,'Handover__c');  
        displayErrorOnHandover(newList, oldMap, newMap);
        updateRoundRobinSales(newList, oldMap);//Added by Anshita 07-04-2022
        populateFieldsforSalesHandover(newList, oldMap);//Added by Anshita 13-04-2022
        validationOnStatusSales(newList, oldMap);//Added by Anshita 16-05-2022
    }
    
    public void AfterUpdateEvent() {
        completedHandover(newList, oldMap);
        autoCompleteHandover(newList, oldMap, newMap);
        attachMoveInFormToDocument();
        sendEmailToExecutive(newList, oldMap);//Added by Anshita 13-04-2022
        updateTaskOwner(newList, oldMap);//Added by Anshita 13-05-2022
    }
    
    public void BeforeDeleteEvent() {}
    
    public void AfterUndeleteEvent() {}
    
    public void AfterDeleteEvent() {}


/********************************************************************************************** 
* @Description  : Propose Ownership to Sales handover Records
* @Params       : 
* @Return       : void
* @Author       : Mamta Gupta
**********************************************************************************************/
    public void autoAssignOwnertoHandover(){
        system.debug('Inside autoAssignOwnertoHandover');
        boolean runEngine = false;
        Set<String> setRecordTypes= new Set<String>();
        Id salesHandoverRecID = Schema.SObjectType.Handover__c.getRecordTypeInfosByName().get('Sales').getRecordTypeId();

        for(Handover__c handover: newList){
            if(handover.Put_in_round_robin__c == true && handover.RecordTypeID==salesHandoverRecID){
                setRecordTypes.add(handover.Record_Type_Name__c);
                runEngine= true;
                }
            } 
        system.debug('runEngine is '+ runEngine);    
        if(runEngine== true){
            AssignmentEngineInstance engineInstance;
            for(Assignment_Engine_Setting__mdt settings : [Select Engine_ID__c from Assignment_Engine_Setting__mdt 
                                                           where SObject__c = 'Handover__c' and TriggerMatchParameter1__c in 
                                                           :setRecordTypes]){
                    engineInstance = new AssignmentEngineInstance(settings.Engine_ID__c);
                    //Parameters of ExecuteBatch(context,BatchSize)
                    database.executebatch(engineInstance);
            }
        }      
    }

    
            
      
    
    public void completedHandover(List<Handover__c> newList, Map<Id, Handover__c> oldMap){
        Set<Id> handoverCompletedOpportunityIdSet = new Set<Id>();
        for(Handover__c handover: newList){
            if(handover.Status__c == 'Completed' && handover.Status__c!=oldMap.get(handover.Id).Status__c){
                if(handover.Deal__c!=null){
                	handoverCompletedOpportunityIdSet.add(handover.Deal__c);    
                }
            }
        }
        Set<Id> updateUnitStatusIdSet = new Set<Id>();
        List<Unit_Plan__c> opportunityUnitList = [SELECT Id, Opportunity__c, Unit__c FROM Unit_Plan__c WHERE Opportunity__c IN: handoverCompletedOpportunityIdSet];
        for(Unit_Plan__c unitPlan: opportunityUnitList){
            updateUnitStatusIdSet.add(unitPlan.Unit__c);
        }
        List<Unit__c> unitStatusUpdateList = [SELECT Id, Unit_Status__c FROM Unit__c WHERE Id IN: updateUnitStatusIdSet];
        if(unitStatusUpdateList.size()>0){
            for(Unit__c unit: unitStatusUpdateList){
                unit.Unit_Status__c = 'Leased'; //updated by karishma changed from under refurbishment to leased 02/03/2022
            }
            update unitStatusUpdateList;
        }
        //Added by karishma to mark opportunity as leased and activate the contract
        List<Opportunity> opptyList = new List<Opportunity>();
        for(Id dealId : handoverCompletedOpportunityIdSet){
            Opportunity deal = new Opportunity();
            deal.Id = dealId;
            deal.StageName = 'Leased';
            opptyList.add(deal);
        }
        if(!opptyList.isEmpty()){
            update opptyList;
        }
        List<Lease_Contract__c> leaseContracts = getContractDetails(handoverCompletedOpportunityIdSet);
        if(leaseContracts.size() > 0){
            for(Lease_Contract__c lc: leaseContracts){
                lc.Contract_Stages__c = 'Active';
                lc.Handover_Status__c = 'Completed';
                lc.Handover_Date__c	 = system.today();
            }
            update leaseContracts;
        }
        

    }

    //Added by Karishma to auto update handover status to completed
    public void autoCompleteHandover(List<Handover__c> newList, Map<Id, Handover__c> oldMap, Map<Id, Handover__c> newMap){
        try{
            Id residentialCommercialRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(system.label.Residential_Leasing_Commercial_Units).getRecordTypeId();
            Id residentialShopRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(system.label.Commercial_Units_Leasing).getRecordTypeId(); //Added by Sajid
            Id residentialUnitRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(system.label.Residential_Leasing_Unit).getRecordTypeId();
            Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Lease_Renewal').getRecordTypeId();
        	Id oppCommRenewRcdTyp= Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Commercial Lease Renewal').getRecordTypeId();

            system.debug('@@RecordTypeId :'+residentialCommercialRecordTypeId + 'unit :'+residentialUnitRecordTypeId);
            List<Handover__c> handoverList = [SELECT Id, Deal__c, Deal__r.RecordTypeId,Is_SR_Closed__c,Key_Handover_Done__c,
                                                Access_Card_Handover_Done__c,Status__c,Move_In_Form_Uploaded_Validation__c
                                              	FROM Handover__c WHERE Id =: newMap.keySet()];
            system.debug('@@handoverList :'+handoverList);
            List<Handover__c> handoverL = new List<Handover__c>();
            /* Move_In_Form_Uploaded_Validation__c Added by sajid*/
            for(Handover__c handover : handoverList){
                Handover__c hd = new Handover__c();
                if(handover.Deal__r.RecordTypeId == residentialUnitRecordTypeId || handover.Deal__r.RecordTypeId == oppRecordTypeId){
                    if(handover.Is_SR_Closed__c == true && handover.Key_Handover_Done__c == true
                        && handover.Access_Card_Handover_Done__c == true && handover.Move_In_Form_Uploaded_Validation__c == true 
                       	&& handover.Status__c != 'Completed'){
                            hd.Id = handover.Id;
                            hd.Status__c = 'Completed';
                            handoverL.add(hd);
                    }
                }else if(handover.Deal__r.RecordTypeId == residentialShopRecordTypeId){ //Added By Sajid
                    if(handover.Is_SR_Closed__c == true && handover.Key_Handover_Done__c == true
                        && handover.Access_Card_Handover_Done__c == true && handover.Move_In_Form_Uploaded_Validation__c == true 
                       	&& handover.Status__c != 'Completed'){
                            hd.Id = handover.Id;
                            hd.Status__c = 'Completed';
                            handoverL.add(hd);
                    }
                }else if(handover.Deal__r.RecordTypeId == residentialCommercialRecordTypeId || handover.Deal__r.RecordTypeId ==oppCommRenewRcdTyp){
                    if(handover.Is_SR_Closed__c == true && handover.Key_Handover_Done__c == true 
                       && handover.Move_In_Form_Uploaded_Validation__c == true && handover.Status__c != 'Completed'){
                        hd.Id = handover.Id;
                        hd.Status__c = 'Completed';
                        handoverL.add(hd);
                    }
                }
            }
            system.debug('@@handoverL :'+handoverL);
            if(!handoverL.isEmpty()){
                update handoverL;
            }

        }catch(Exception ex){
            system.debug('@@Error :'+ex.getMessage()+ 'Line :'+ex.getLineNumber()+ 'Stack Trace: '+ex.getStackTraceString());
        }
    }

    // Added by Karishma to display error message on Access Cards handover process
    public void displayErrorOnHandover(List<Handover__c> newList, Map<Id, Handover__c> oldMap, Map<Id, Handover__c> newMap){
        Id residentialUnitRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(system.label.Residential_Leasing_Unit).getRecordTypeId();
        Map<Id,Integer> handoverCardSize =  new Map<Id,Integer>();
        Map<Id,Id> handoverDealRecordTypeId = new Map<Id,Id>();
        List<Handover__c> handoverList = [SELECT Id,Access_Card_Handover_Done__c,Deal__r.RecordTypeId, (SELECT Id from Cards__r) 
                                            FROM Handover__c WHERE Id=:newMap.keySet() ];
        for(Handover__c hd : handoverList){
                handoverCardSize.put(hd.Id,hd.Cards__r.size());
                handoverDealRecordTypeId.put(hd.Id,hd.Deal__r.RecordTypeId);
        }
        
        for(Handover__c handover: newList){
            if(handoverCardSize.containsKey(handover.Id) && handoverDealRecordTypeId.containsKey(handover.Id)){
                if(handoverCardSize.get(handover.Id) == 0 && handover.Access_Card_Handover_Done__c && handoverDealRecordTypeId.get(handover.Id) == residentialUnitRecordTypeId
                    && handover.Access_Card_Handover_Done__c != oldMap.get(handover.Id).Access_Card_Handover_Done__c){
                    handover.addError(system.label.Access_Card_Handover_Error);
                }
            }
            
        }
    }

    //Added by Karishma to update contract to under handover when handover record gets created
    public void contractUnderHandover(List<Handover__c> newList, Map<Id, Handover__c> oldMap, Map<Id, Handover__c> newMap){
        Set<Id> underhandoverOpportunityIdSet = new Set<Id>();
        for(Handover__c handover: newList){
            if(handover.Status__c == 'Initiated' && handover.Status__c!=oldMap.get(handover.Id).Status__c){
                if(handover.Deal__c!=null){
                	underhandoverOpportunityIdSet.add(handover.Deal__c);    
                }
            }
        }
        List<Lease_Contract__c> leaseContracts = getContractDetails(underhandoverOpportunityIdSet);
        if(leaseContracts.size() > 0){
            for(Lease_Contract__c lc: leaseContracts){
                lc.Contract_Stages__c = 'Under handover';
            }
            update leaseContracts;
        }

    }

    public List<Lease_Contract__c> getContractDetails(Set<Id> opptyIds){
        List<Lease_Contract__c> leaseContracts = new List<Lease_Contract__c>();
        leaseContracts = [SELECT Id,Contract_Stages__c,Opportunity__c FROM 
                                                    Lease_Contract__c WHERE Opportunity__c =: opptyIds];
        return leaseContracts;
    }

    //ADded by Karishma to update Contract Lookup on Handover 
    public void updateContractLookup(List<Handover__c> newList){
        set<Id> opptyIds = new set<Id>();
        Map<Id,Id> opptyIdMapToContractId = new Map<Id,Id>();
        List<Handover__c> handoverList = new List<Handover__c>();
        for(Handover__c handover : newList){
            if(handover.Deal__c != null) opptyIds.add(handover.Deal__c);
        }

        List<Lease_Contract__c> contractList = getContractDetails(opptyIds);
        for(Lease_Contract__c contract : contractList){
            opptyIdMapToContractId.put(contract.Opportunity__c,contract.Id);
        }

        for(Handover__c h : newList){
            if(opptyIdMapToContractId.containsKey(h.Deal__c)){
                Handover__c hover = new Handover__c();
                hover.Id = h.Id;
                hover.Contract__c = opptyIdMapToContractId.get(h.Deal__c);
                handoverList.add(hover);
            }
        }

        if(!handoverList.isEmpty()){
            update handoverList;
        }

    }
    /********************************************************************************************** 
    * @Description  : Update Round Robin for Sales handover Records
    * @Params       : 
    * @Return       : void
    * @Author       : Anshita Mittal
    **********************************************************************************************/
    public void updateRoundRobinSales(List<Handover__c> newList, Map<Id, Handover__c> oldMap){
        system.debug('Inside updateRoundRobinSales');
        Boolean runBatchFlag = false;
        Id salesHandoverRecID = Schema.SObjectType.Handover__c.getRecordTypeInfosByName().get('Sales').getRecordTypeId();
        for(Handover__c handover: newList){
            if(handover.Put_in_round_robin__c == true && handover.RecordTypeID==salesHandoverRecID 
                && handover.Proposed_Handover_Executive__c != null && handover.Proposed_Handover_Executive__c != oldMap.get(handover.Id).Proposed_Handover_Executive__c){
                handover.Put_in_round_robin__c = false;
            }
            else if(handover.Put_in_round_robin__c == false && handover.RecordTypeID==salesHandoverRecID 
                && handover.HE_Acceptance_Status__c == 'Reject' && handover.Proposed_Handover_Executive__c != null){
                handover.Put_in_round_robin__c = true;
                handover.Assigned_Resource__c = null;
                handover.Proposed_Handover_Executive__c = null;
                handover.HE_Acceptance_Status__c = null;
                runBatchFlag = true;
            }
        } 
        if(runBatchFlag){
            autoAssignOwnertoHandover();
        }
    }
    /********************************************************************************************** 
    * @Description  : Send email to the Handover Executive
    * @Params       : 
    * @Return       : void
    * @Author       : Anshita Mittal
    **********************************************************************************************/
    public void sendEmailToExecutive(List<Handover__c> newList, Map<Id, Handover__c> oldMap){
        system.debug('Inside sendEmailToExecutive');
        List<wrapperClass> wrapperClsList = new List<wrapperClass>();
        List<Task> tskList = new List<Task>();
        Id arFinQueueId = System.Label.ARFinanceQueueId;
        Id arFinGroupId = System.Label.ARFinanceGroupId;
        List<Unit__Share> unitShareList  = new List<Unit__Share>();
        List<AccountShare> accShareList  = new List<AccountShare>();
        List<SendMailForEmailAlerts.InvokeSendEmail> requests = new List<SendMailForEmailAlerts.InvokeSendEmail>();
        list<string> documentTypeList = new list<string>();
        Map<Id,String> closeTaskByHandover = new Map<Id,String>();
        
        try{
            Id salesHandoverRecID = Schema.SObjectType.Handover__c.getRecordTypeInfosByName().get('Sales').getRecordTypeId();
            for(Handover__c handover: newList){
                if(handover.RecordTypeID==salesHandoverRecID && handover.Proposed_Handover_Executive__c != null &&
                   handover.Proposed_Handover_Executive__c != oldMap.get(handover.Id).Proposed_Handover_Executive__c){
                       SendMailForEmailAlerts.InvokeSendEmail sendEmailObj = new SendMailForEmailAlerts.InvokeSendEmail();
                       sendEmailObj.EmailAlertAPIName = 'Handover_Sales_Email_to_Assignee';
                       sendEmailObj.RecordId = handover.Id;
                       requests.add(sendEmailObj);
                   }
                if(handover.RecordTypeID==salesHandoverRecID && handover.Status__c == 'Inspection Approved' &&
                   handover.Status__c != oldMap.get(handover.Id).Status__c){
                       Task taskToInsert = createTask(NakheelTaskSubject__mdt.getInstance('HandoverTask1').Subject__c , handover.Id, handover.OwnerId);
                       tskList.add(taskToInsert);
                   }
                /*if(handover.RecordTypeID==salesHandoverRecID && handover.Status__c == 'Home Orientation Invite Sent' &&
                    handover.Status__c != oldMap.get(handover.Id).Status__c){
                    //Task taskToInsert = createTask('Fullfill the home orientation pre-checklist', handover.Id, handover.OwnerId);
                    //tskList.add(taskToInsert);
				}
				if(handover.RecordTypeID==salesHandoverRecID && handover.Customer_Snags_Desnagging_Completed__c == true &&
                    handover.Customer_Snags_Desnagging_Completed__c != oldMap.get(handover.Id).Customer_Snags_Desnagging_Completed__c){
                    Task taskToInsert = createTask('Task for Inspection', handover.Id, handover.OwnerId);
                    tskList.add(taskToInsert);
				}*/
                if(handover.RecordTypeID==salesHandoverRecID && handover.Home_Orientation_PDF_Uploaded__c == true &&
                   handover.Home_Orientation_PDF_Uploaded__c != oldMap.get(handover.Id).Home_Orientation_PDF_Uploaded__c){
                      
                       wrapperClass wrapObj = new wrapperClass(handover,'Post-Home Orientation','Home_Orientation_Email');
                       wrapperClsList.add(wrapObj);
                   }
                if(handover.RecordTypeID==salesHandoverRecID && handover.Internal_De_snagging_uploaded__c &&
                   handover.Internal_De_snagging_uploaded__c != oldMap.get(handover.Id).Internal_De_snagging_uploaded__c){
                       Task taskToInsert = createTask(handover.Unit_Name__c + ' ' + NakheelTaskSubject__mdt.getInstance('HandoverTask2').Subject__c, handover.Id, handover.OwnerId);
                       tskList.add(taskToInsert);
                   }
                if(handover.RecordTypeID==salesHandoverRecID && handover.Post_Home_Orientation_De_snagging_Upload__c &&
                   handover.Post_Home_Orientation_De_snagging_Upload__c != oldMap.get(handover.Id).Post_Home_Orientation_De_snagging_Upload__c){
                       /*Task taskToInsert = createTask('Sedchule Appointment with customer for Post-Home Orientation De-snagging', handover.Id, handover.OwnerId);
						tskList.add(taskToInsert);*/
                       wrapperClass wrapObj = new wrapperClass(handover,'Post-Home Orientation De-snagging','Handover_Sales_Customer_De_Snag_List');
                       wrapperClsList.add(wrapObj);
                       //closeTaskByHandover.put(handover.Id, 'Desnagging of Customer Raised Snags');
                   } 
                if(handover.RecordTypeID==salesHandoverRecID && handover.Proof_of_Payment_Uploaded__c &&
                   handover.Proof_of_Payment_Uploaded__c != oldMap.get(handover.Id).Proof_of_Payment_Uploaded__c){
                       Approval.UnLockResult lrList = Approval.Unlock(handover, false);
                       closeTaskByHandover.put(handover.Id, NakheelTaskSubject__mdt.getInstance('HandoverTask3').Subject__c);
                   } 
                if(handover.RecordTypeID==salesHandoverRecID && handover.Initiate_DEWA_Transfer__c &&
                   handover.Initiate_DEWA_Transfer__c != oldMap.get(handover.Id).Initiate_DEWA_Transfer__c &&
                   handover.DEWA_Premise_Number__c != '' && handover.DEWA_Premise_Number__c != null){
                       wrapperClass wrapObj = new wrapperClass(handover,null,'Handover_Sales_DEWA_Registration');
                       wrapperClsList.add(wrapObj);
                       closeTaskByHandover.put(handover.Id, NakheelTaskSubject__mdt.getInstance('HandoverTask4').Subject__c);
                       if(handover.Unit_Mortgaged__c){
                           Task taskToInsert = createTask(NakheelTaskSubject__mdt.getInstance('HandoverTask5').Subject__c, handover.Id, handover.OwnerId);
                           tskList.add(taskToInsert);
                       }
                       Task taskToInsert = createTask(NakheelTaskSubject__mdt.getInstance('HandoverTask6').Subject__c, handover.Id, handover.OwnerId);
                       tskList.add(taskToInsert);
                   }
                if(handover.RecordTypeID==salesHandoverRecID && handover.Key_Handover_Form_Uploaded__c &&
                   handover.Key_Handover_Form_Uploaded__c != oldMap.get(handover.Id).Key_Handover_Form_Uploaded__c){
                       //close Task: Upload Key Handover Form
                       closeTaskByHandover.put(handover.Id, NakheelTaskSubject__mdt.getInstance('HandoverTask7').Subject__c);
                       wrapperClass wrapObj = new wrapperClass(handover,null,'Handover_Sales_Key_Handover_Done');
                       wrapperClsList.add(wrapObj);
                   } 
                if(handover.RecordTypeID==salesHandoverRecID && handover.Home_Orientation_Checklist_Completed__c == true &&
                   handover.Home_Orientation_Checklist_Completed__c != oldMap.get(handover.Id).Home_Orientation_Checklist_Completed__c){
                       closeTaskByHandover.put(handover.Id, NakheelTaskSubject__mdt.getInstance('HandoverTask8').Subject__c);
                   }
                if(handover.RecordTypeID==salesHandoverRecID && handover.Bank_NOC_Uploaded__c == true &&
                   handover.Bank_NOC_Uploaded__c != oldMap.get(handover.Id).Bank_NOC_Uploaded__c){
                       closeTaskByHandover.put(handover.Id, NakheelTaskSubject__mdt.getInstance('HandoverTask5').Subject__c);
                   }
                if(handover.RecordTypeID==salesHandoverRecID && handover.Approval_Rejected__c == true &&
                   handover.Approval_Rejected__c != oldMap.get(handover.Id).Approval_Rejected__c){
                       Task taskToInsert = createTask(NakheelTaskSubject__mdt.getInstance('HandoverTask3').Subject__c, handover.Id, arFinQueueId);
                       tskList.add(taskToInsert);
                   }
                if(handover.RecordTypeID==salesHandoverRecID && handover.Status__c == 'Customer Approved' &&
                   handover.Status__c != oldMap.get(handover.Id).Status__c){
                       Unit__Share unitShare  = new Unit__Share();
                       unitShare.ParentId = handover.Unit__c;
                       unitShare.UserOrGroupId = arFinGroupId;
                       unitShare.AccessLevel = 'Read';
                       unitShareList.add(unitShare);
                       
                       AccountShare accShare  = new AccountShare();
                       accShare.accountid = handover.AccountId__c;
                       accShare.UserOrGroupId = arFinGroupId;
                       accShare.OpportunityAccessLevel = 'Read';
                       accShare.accountaccesslevel = 'Read';
                       accShareList.add(accShare);
                   }
            }
            if(unitShareList.size() > 0){
                insert unitShareList;
            }
            if(accShareList.size() > 0){
                insert accShareList;
            }
            if(requests.size() > 0){
                SendMailForEmailAlerts.sendEmail(requests);
            }
            if(wrapperClsList.size() > 0){
                SendMailForEmailAlerts.sendEmailWithAttachment(wrapperClsList);
            }
            if(closeTaskByHandover.isEmpty() == false){
                List<Task> taskToClose = new List<Task>();
                List<Task> taskList = [Select Id, Subject, Status, WhatId from Task where WhatId IN: closeTaskByHandover.keySet()];
                for(Task t: taskList){
                    if(t.Subject == closeTaskByHandover.get(t.WhatId)){
                        t.Status = 'Completed';
                        taskToClose.add(t);
                    }
                }
                update taskToClose;
            }
            if(tskList.size() > 0){
                insert tskList;
            }
        }
        catch(Exception e){
            System.debug('Exception :'+e.getMessage()+'at Line: '+ e.getLineNumber());
        }
    }
    /********************************************************************************************** 
    * @Description  : Create Task for Sales Handover After Creation
    * @Params       : 
    * @Return       : void
    * @Author       : Anshita Mittal
    **********************************************************************************************/
    public void createTaskforSalesHandover(List<Handover__c> newList){
        system.debug('Inside createTaskforSalesHandover');
        List<Task> tskList = new List<Task>();
        //Group crmQueue = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'CRM_Team'];
        Group handoverQueue = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'Handover_Team'];
        Id salesHandoverRecID = Schema.SObjectType.Handover__c.getRecordTypeInfosByName().get('Sales').getRecordTypeId();
        try{
            for(Handover__c handover: newList){
                if(handover.RecordTypeID==salesHandoverRecID){
                    Task taskToInsert = createTask(NakheelTaskSubject__mdt.getInstance('HandoverTask9').Subject__c, handover.Id, handoverQueue.Id);
                    tskList.add(taskToInsert);
                }
            } 
            if(tskList.size() > 0){
                insert tskList;
            }
        }
        catch(Exception e){
            System.debug('Exception :'+e.getMessage()+'at Line: '+ e.getLineNumber());
        }
    }
   /********************************************************************************************** 
    * @Description  : Populate fields on Handover Records on before update
    * @Params       : 
    * @Return       : void
    * @Author       : Anshita Mittal
    **********************************************************************************************/
    public void populateFieldsforSalesHandover(List<Handover__c> newList, Map<Id, Handover__c> oldMap){
        system.debug('Inside populateFieldsforSalesHandover');
        Group crmQueue = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'CRM_Team'];
        Id salesHandoverRecID = Schema.SObjectType.Handover__c.getRecordTypeInfosByName().get('Sales').getRecordTypeId();
        Map<Id,Id> userIdByAccId = new Map<Id,Id>();
        for(Handover__c handover: newList){
            if(handover.RecordTypeID==salesHandoverRecID && handover.Home_Orientation_Checklist_Completed__c == true &&
            handover.Home_Orientation_Checklist_Completed__c != oldMap.get(handover.Id).Home_Orientation_Checklist_Completed__c){
                handover.Status__c = 'Ready for Home Orientation';
            }
            if(handover.RecordTypeID==salesHandoverRecID && handover.Status__c == 'Inspection Approved' &&
            handover.Status__c != oldMap.get(handover.Id).Status__c){
                //handover.OwnerId = crmQueue.Id;
            }
            if(handover.RecordTypeID==salesHandoverRecID && handover.Status__c == 'Home Orientation Invite Sent' &&
            handover.Status__c != oldMap.get(handover.Id).Status__c){
                handover.Home_Orientation_Invite_Sent_Date__c = System.today();
            }
            if(handover.RecordTypeID==salesHandoverRecID && handover.HE_Acceptance_Status__c == 'Accept' &&
            handover.HE_Acceptance_Status__c != oldMap.get(handover.Id).HE_Acceptance_Status__c){
                handover.OwnerId = handover.Proposed_Handover_Executive__c;
                if(handover.AccountId__c != null && handover.AccountId__c != '')
                	userIdByAccId.put(handover.AccountId__c,handover.OwnerId);
            }
            if(handover.RecordTypeID==salesHandoverRecID && handover.Internal_De_snagging_uploaded__c &&
            handover.Internal_De_snagging_uploaded__c != oldMap.get(handover.Id).Internal_De_snagging_uploaded__c){
                handover.Status__c = 'Inspection Pending';
            } 
        }
        if(userIdByAccId.keySet().size() > 0){
            List<AccountTeamMember> accMemList = new List<AccountTeamMember>();
            for(Id i : userIdByAccId.keySet()){
                AccountTeamMember accTeamMem = new AccountTeamMember();
                accTeamMem.AccountId = i;
                accTeamMem.UserId = userIdByAccId.get(i);
                accTeamMem.TeamMemberRole = 'Handover Executive';
                accMemList.add(accTeamMem);
            }
            if(accMemList.size() > 0){
                insert accMemList;
            }
        }
    }
    /********************************************************************************************** 
    * @Description  : Method to create Task
    * @Params       : Subject, WhatId , Owner ID for the Task
    * @Return       : Task
    * @Author       : Anshita Mittal 14-04-2022
    **********************************************************************************************/
    public Task createTask(String subject,Id whatId,Id ownerId){
        Task taskObj = new Task();
        taskObj.Subject= subject;
        taskObj.WhatId = whatId;
        taskObj.OwnerId= ownerId;
        taskObj.Priority = 'Normal';
        taskObj.Status = 'Open';
        taskObj.ActivityDate = System.today() + 2;
        return taskObj;
    }
    
    /********************************************************************************************** 
    * @Description  : Method to attach moveIn form to document object.
    * @Return       : void
    * @Author       : Sajid 19-04-2022
    **********************************************************************************************/
    public void attachMoveInFormToDocument(){
        Set<ID> recordSet = newMap.keySet();
        Set<ID> verifiedIds = new Set<ID>();
        Boolean hasRecord = false;
        Set<ID> captureContDocId = new Set<ID>();
        Set<ID> contentVersionId = new Set<ID>();
        
        for(ID recordId : recordSet){
            System.debug('RecordNewMapMoneIn: '+newMap.get(recordId).Move_In_Application_Uploaded__c);
            System.debug('RecordOldMapMoveIn: '+oldMap.get(recordId).Move_In_Application_Uploaded__c);

            if(((newMap.get(recordId).Move_In_Application_Uploaded__c  == true) && (oldMap.get(recordId).Move_In_Application_Uploaded__c != true))){
                   System.debug('@@@@@ Phase 2 @@@@@');
                   verifiedIds.add(recordId);
                   hasRecord = true;
               }
        }
        
        if(hasRecord){
            
            List<Handover__c> updatedHandoverContatiner = new List<Handover__c>();
            List<Handover__c> updateHandover = [Select id, Move_In_Application_Uploaded__c from Handover__c where id in :verifiedIds];
            
            for(Handover__c Handover : updateHandover){
                if(Handover.Move_In_Application_Uploaded__c == true){
                    Handover.Move_In_Application_Uploaded__c = false;
                }
                updatedHandoverContatiner.add(Handover);
            }
            
            Map<ID,ID> contentDocumentLinkMap = new Map<ID,ID>();
            List<ContentDocumentLink> allIds = [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId in :verifiedIds];
            System.debug('ContentDocumentLink: '+JSON.serialize(allIds));
            for(ContentDocumentLink cl : allIds){
                contentDocumentLinkMap.put(cl.LinkedEntityId, cl.ContentDocumentId);
            } 
            
            System.debug('contentDocumentLinkMap: '+contentDocumentLinkMap);
            System.debug('[V] allIds '+allIds);
            
            for(ContentDocumentLink c : allIds){
                System.debug('Phase 3 ContentDocumentLink '+c);
                captureContDocId.add(c.ContentDocumentId);
                
            }
            System.debug('[V] captureContDocId '+captureContDocId);
            
            Map<ID,ContentVersion> contentVersionMap = new Map<ID,ContentVersion>();
            List<ContentVersion> contentVersionList = [Select Id,ContentDocumentId, ContentUrl,VersionData,Title,PathOnClient from ContentVersion where ContentDocumentId in :captureContDocId ];
            for(ContentVersion cv : contentVersionList){
                System.debug('Phase 4 ContentVersion '+cv);
                contentVersionMap.put(cv.ContentDocumentId, cv);
                contentVersionId.add(cv.id);
            }
            System.debug('[V] contentVersionMap '+contentVersionMap);
            
            List<Id> docList = new List<Id>();
            Map<ID,ID> obDocMap = new Map<ID,ID>();  
            List<Object_Document__c> objDocument = [Select id, Handover__c, Document__c from Object_Document__c where Handover__c in :verifiedIds];
            for(Object_Document__c obj : objDocument){
                obDocMap.put(obj.Document__c,obj.Handover__c);
                docList.add(obj.Document__c);
            }
            
            
            List<Document__c> documents = [Select id, Handover__c, Handover__r.Move_In_Application_Uploaded__c,
                                            Attachment_Id__c, Document_Type__c from Document__c where id in :docList];
            Map<Document__c,ID> documentHandoverMap = new Map<Document__c,ID>();
            Set<ID> documentId = new Set<ID>();
            
            
            for(Document__c doc : documents){
                System.debug('Phase 5 Document '+doc);
                documentHandoverMap.put(doc,doc.Handover__c);
            }
            List<Document__c> updateDocumentOperation = new List<Document__c>();
            List<ContentVersion> insertContentVersion = new List<ContentVersion>();
            List<ContentDocumentLink> insertContentDocumentLink = new List<ContentDocumentLink>();
            Set<Id> docId = new Set<Id>();
            
            Map<Id,Handover__c> handoverDetails = new Map<Id,Handover__c>();
            Map<Id,List<ContentVersion>> contentVersionsToHandover = new Map<Id,List<ContentVersion>>();
            String emailTemplateName;
            
            for(Document__c doc : documents){
                if((doc.Document_Type__c == 'Move In Application' && doc.Handover__r.Move_In_Application_Uploaded__c)){
                       
                       
                       System.debug('Phase 6 Document and Handover ===>'+doc);
                       
                       handoverDetails.put(doc.Handover__c, newMap.get(doc.Handover__c));
                       
                       Id contentDocumentId = contentDocumentLinkMap.get(doc.Handover__c);
                       
                       ContentVersion contentVersionHandover = contentVersionMap.get(contentDocumentId);
                       
                       ContentVersion contentVersionDocument = new ContentVersion();
                       contentVersionDocument.ContentDocumentId = contentDocumentId;
                       contentVersionDocument.Title = contentVersionHandover.Title;
                       contentVersionDocument.PathOnClient = contentVersionHandover.PathOnClient;
                       contentVersionDocument.VersionData = contentVersionHandover.VersionData;
                       insertContentVersion.add(contentVersionDocument);
                       
                       
                       contentVersionsToHandover.put(doc.Handover__c , insertContentVersion);
                       
                       
                       ContentDocumentLink cdLinkDocument = new ContentDocumentLink();
                       cdLinkDocument.LinkedEntityId = doc.Id;
                       cdLinkDocument.ContentDocumentId = contentDocumentId;
                       insertContentDocumentLink.add(cdLinkDocument);
                       
                       doc.Attachment_Id__c = contentDocumentId;
                       doc.Handover__c = obDocMap.get(doc.id);
                       updateDocumentOperation.add(doc);  
                    
                    if(doc.Document_Type__c == 'Move In Application'){
                        docId.add(doc.Id);
                        emailTemplateName = ConstantUtility.MOVE_IN_FORM_EMAIL_TEMP;
                    }

                   }
            }  
            
            try{
                System.debug('@@@@@ Before Update: '+updatedHandoverContatiner);
                update updatedHandoverContatiner;
                update updateDocumentOperation;
                //insert insertContentVersion;
                insert insertContentDocumentLink;  
                
                if(docId.size() > 0){
                    sendEmailToCustomer(contentVersionsToHandover, handoverDetails, emailTemplateName);                    
                }
            }
            catch (Exception ex){
                system.debug('error is '+ ex.getMessage() + ' at '+ ex.getLineNumber());
            }  
            
        }
    }
    
    
    /**********************************************************************************************
        * @Description  : Method to send email to customer after new lease document creation.
        * @Params       : Map<Id,List<ContentVersion>> contentVersionsToHandover
        * @Param        : Map<Id,Handover__c> oppDetails
        * @Param        : String emailTemplateName
        * @Return       : void
        * @Author       : Sajid Hameed
        **********************************************************************************************/
    public void sendEmailToCustomer(Map<Id,List<ContentVersion>> contentVersionsToHandover, Map<Id,Handover__c> handoverDetails, String emailTemplateName){
        // initialize temporary email list
        String accEmail = '';
        String conId = '';
        List<Messaging.SingleEmailMessage> messageList = new List<Messaging.SingleEmailMessage>();
        
        EmailTemplate emailTemplate = [ SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body 
                                       FROM EmailTemplate 
                                       WHERE name =: emailTemplateName];
        
        System.debug('emailTemplate:  '+ emailTemplate);
        Contact con = [SELECT ID FROM Contact WHERE Email != null LIMIT 1 ];
        
        for(Id handoverId : contentVersionsToHandover.keySet()){
            if(handoverDetails.containsKey(handoverId)){
                accEmail = handoverDetails.get(handoverId).Account_Email__c;
            }
            system.debug('@@conID :'+con.Id);
            System.debug('accEmail:  '+ accEmail);
            List<Messaging.Emailfileattachment> efaList = new List<Messaging.Emailfileattachment>();
            // initialize one or more single emails as you need 
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            for(ContentVersion cv : contentVersionsToHandover.get(handoverId)){
                Blob fileData  = cv.VersionData;  
                Messaging.EmailFileAttachment efa = new Messaging.EmailfileAttachment();
                efa.setFileName(cv.Title);
                efa.setBody(fileData);
                efaList.add(efa);
            }
            // set the recipient email
            message.setToAddresses(new String[] {accEmail });
            // set the email template id
            message.setTemplateId(emailTemplate.Id);
            // do not save email as activity
            message.setSaveAsActivity(false);
            // set the id for the object
            message.setWhatId(handoverId);
            // set target object id as your current user id
            message.setTargetObjectId( con.ID );
            message.setFileAttachments(efaList);
            // add current message to message list
            messageList.add(message);
        }
        
        // create savepoint before executing statement
        Savepoint sp = Database.setSavepoint();
        
        // send the temporary email list
        Messaging.sendEmail(messageList);
        
        // rollback the transaction before commiting to database
        Database.rollback(sp);            
        // initialize the actual message list to be sent
        List<Messaging.SingleEmailMessage> actualMessageList = new List<Messaging.SingleEmailMessage>();
        
        OrgWideEmailAddress orgWideEmailAddress = new OrgWideEmailAddress();
        if(!String.isBlank(AppSettings__c.getValues('OrgWideEmailAddressForLeasing').TextValue__c)){
            orgWideEmailAddress = EmailNotificationHelper.getOrgWideEmailAddress(AppSettings__c.getValues('OrgWideEmailAddressForLeasing').TextValue__c);
        }
        system.debug(orgWideEmailAddress.Id);
        // loop through the previous message list and set the email fields
        for (Messaging.SingleEmailMessage email : messageList) {
            Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
            emailToSend.setToAddresses(email.getToAddresses());
            emailToSend.setHTMLBody(email.getHTMLBody());
            emailToSend.setSubject(email.getSubject());
            if(orgWideEmailAddress!=null){
                emailToSend.setOrgWideEmailAddressId(orgWideEmailAddress.Id);
            }   
            emailToSend.setFileAttachments(email.getFileAttachments());
            actualMessageList.add(emailToSend);
        }
        
        // send the actual message list
        Messaging.SendEmailResult [] serList = Messaging.sendEmail(actualMessageList);
        
        // make sure the emails are sent successfully
        String errorMessage = '';
        for(Messaging.SendEmailResult ser : serList){
            if(!ser.isSuccess()){
                for(Messaging.SendEmailError err : ser.getErrors()) {
                    errorMessage += err.getMessage() + '\n';
                }
                system.debug('@@Error :'+errorMessage);
            }
        }
    }   
    /********************************************************************************************** 
    * @Description  : Update open Tasks owner on update of Handover owner 
    * @Params       : 
    * @Return       : void
    * @Author       : Anshita Mittal
    **********************************************************************************************/
    public void updateTaskOwner(List<Handover__c> newList,Map<Id, Handover__c> oldMap){
        system.debug('Inside updateTaskOwner');
        List<Task> tskList = new List<Task>();
        Id salesHandoverRecID = Schema.SObjectType.Handover__c.getRecordTypeInfosByName().get('Sales').getRecordTypeId();
        Map<Id,Id> ownerByHandoverId = new Map<Id,Id>();
        for(Handover__c handover : newList){
            if(handover.RecordTypeID==salesHandoverRecID && handover.OwnerId != null &&
               handover.OwnerId != oldMap.get(handover.Id).OwnerId){
                   ownerByHandoverId.put(handover.Id, handover.OwnerId);
               }
        }
        if(ownerByHandoverId.keySet().size() > 0){
            tskList = [Select Id,Status,WhatId from Task where WhatId IN: ownerByHandoverId.keySet() and Status = 'Open'];
        }
        for(Task t: tskList){
            t.OwnerId = ownerByHandoverId.get(t.WhatId);
        } 
        if(tskList.size() > 0){
            update tskList;
        }
    }
    /********************************************************************************************** 
    * @Description  : Validate Handover Status change after Rejection
    * @Params       : 
    * @Return       : void
    * @Author       : Anshita Mittal
    **********************************************************************************************/
    public void validationOnStatusSales(List<Handover__c> newList,Map<Id, Handover__c> oldMap){
        System.debug('Inside validationOnStatusSales');
        Id salesHandoverRecID = Schema.SObjectType.Handover__c.getRecordTypeInfosByName().get('Sales').getRecordTypeId();
        Set<Id> handoverCompleted = new Set<Id>();
        for(Handover__c handover : newList){
            if(handover.RecordTypeID == salesHandoverRecID && oldMap.get(handover.Id).Status__c == 'Customer Rejected' &&
               handover.Status__c != oldMap.get(handover.Id).Status__c && (handover.Home_Orientation_PDF_Uploaded__c == false ||
               handover.Post_Home_Orientation_De_snagging_Upload__c == false)){
                   handover.addError('Please upload Post Home Orientation Snagging and Desnagging document on Handover before changing the Status'); 
               }
            if(handover.RecordTypeID == salesHandoverRecID && oldMap.get(handover.Id).Status__c == 'Inspection Rejected' &&
               handover.Status__c != oldMap.get(handover.Id).Status__c && (handover.Internal_Snagging_uploaded__c == false ||
               handover.Internal_De_snagging_uploaded__c == false)){
                   handover.addError('Please upload Internal Snagging and Desnagging document on Handover before changing the Status'); 
               }
            if(handover.RecordTypeID == salesHandoverRecID && handover.Status__c == 'Handover Completed' &&
               handover.Status__c != oldMap.get(handover.Id).Status__c){
                   //handover.addError('Please close all the tasks on Handover before completing the Handover'); 
                   handoverCompleted.add(handover.Id);
               }
            if(handover.RecordTypeID == salesHandoverRecID && handover.Status__c == 'Home Orientation Invite Sent' &&
               handover.Status__c != oldMap.get(handover.Id).Status__c && handover.Home_Orientation_Date__c == null){
                   handover.addError('Please schedule appointment for Home Orientation'); 
               }
        }
        if(handoverCompleted.size() > 0){
            Map<Id,Integer> openTaskCountByHandover = new Map<Id,Integer>();
            for(Handover__c h : [Select Id,(Select Id,Status,WhatId from Tasks where Status = 'Open') 
                                 from Handover__c where Id IN: handoverCompleted]){
                                     if(h.Tasks.size() > 0){
                                         openTaskCountByHandover.put(h.Id,h.Tasks.size());
                                     }
                                 }
            for(Handover__c handover : newList){
                if(openTaskCountByHandover.containsKey(handover.Id)){
                    handover.addError('Please complete all the tasks on Handover before completing the Handover'); 
                }
            }
        }
        
    }

        /********************************************************************************************** 
    * @Description  : Wrapper Class to contain information for handover email with attachment
    * @Params       : handover, documentType, emailTemplate
    * @Return       : void
    * @Author       : Anshita Mittal 12-05-2022
    **********************************************************************************************/
    public class wrapperClass {
        public Handover__c handover {get; set;}
        public String documentType {get; set;}
        public String emailTemplate {get; set;}
        
        public wrapperClass(Handover__c h, String documentType, String emailTemplate) {
            this.handover = h;
            this.documentType = documentType;
			this.emailTemplate = emailTemplate;            
        }
    }
}