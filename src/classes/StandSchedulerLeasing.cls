global class  StandSchedulerLeasing implements Schedulable{
    global void execute(SchedulableContext sc)
        
    {
        
        StandLeasingBatch b = new StandLeasingBatch(); // Your batch class
        
        database.executeBatch(b);
        
    }
}