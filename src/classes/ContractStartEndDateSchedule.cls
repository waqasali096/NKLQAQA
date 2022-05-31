global class ContractStartEndDateSchedule implements schedulable
{
    global void execute(SchedulableContext sc)
    {
    	ContractStartEndBatch b = new ContractStartEndBatch(); //run batch class
      	database.executebatch(b);
    }
}