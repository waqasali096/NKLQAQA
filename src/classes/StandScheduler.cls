global class  StandScheduler implements Schedulable{
global void execute(SchedulableContext sc)

     {
     	StandBatch b = new StandBatch(); // Your batch class

       database.executeBatch(b);
     }
}