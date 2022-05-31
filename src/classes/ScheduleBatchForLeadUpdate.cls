global class ScheduleBatchForLeadUpdate implements Schedulable {
     global void execute(SchedulableContext sc) {
      BatchToClosedLead b = new BatchToClosedLead(); 
      database.executebatch(b);
   }
}