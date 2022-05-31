global class AssignedResourceCapacityScheduler implements Schedulable {
    global void execute(SchedulableContext sc)

     {

     AssignedResourceCapacityBatch b = new AssignedResourceCapacityBatch(); // Your batch class

       database.executeBatch(b);

     }

}