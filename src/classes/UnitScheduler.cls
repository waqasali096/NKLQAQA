/**
    * Class Name: UnitScheduler
    * Class Description: To call Unit Batch class
    * * * @return: Void                                           
*/
global class  UnitScheduler implements Schedulable{
global void execute(SchedulableContext sc)

     {
     	UnitBatch b = new UnitBatch(); // Your batch class

       database.executeBatch(b);
     }
}