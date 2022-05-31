/**************************************************************************************************
* Name               : SendMassEmailTo_Queue                                                      
* Description        : Send Email in Queue members
* Created Date       : 09/03/2022                                                                 
* Created By         : Cloudworks                                                                    
* -------------------------------------------------------------------------------------------------
* VERSION  AUTHOR    DATE            COMMENTS                                                    
* 1.0      Mamta      09/03/2022      Initial Draft.                                               
**************************************************************************************************/
public class SendEmailToQueueofTask {
      @InvocableMethod(label='send mail notification' description='Send mail notification to task asignees' category='')
        public static void sendMail(List<ID> taskIDS){
         List<Task> tskLst =[select id,OwnerID, what.Type from Task where ID IN:taskIDS] ;
            Task tsk = tskLst[0];
            List<String> whatTypeLst = (system.label.Task_Queue_Email_Objects).split(','); 
            //if(tsk.what.Type=='Calling_List_line_Item__c'|| tsk.What.Type=='Calling_List__c' || tsk.What.Type=='Registration__c'){
            if(whatTypeLst.contains(tsk.what.Type)){
               Group gp = [SELECT Id, Name, DeveloperName, Type FROM Group WHERE Type = 'Queue' AND 
                           ID =:tsk.OwnerID  LIMIT 1];
                List<EmailTemplate> tmplts = [select id, developerName from EmailTemplate WHERE Developername='Task_Details_to_Queue'];

                SendMassEmailTo_Queue.sendEmailNotice(tskLst, gp,tmplts[0],false);
            }   
            
            
            
        }



}