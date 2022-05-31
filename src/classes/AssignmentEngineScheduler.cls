/*
* Author - Huzefa Tarwala
* Date - 20 Oct 2019
* Description - This class is called when and engine is activated from the AssigmentEngine Trigger and schedules a batch for every one hour.
*/

public class AssignmentEngineScheduler implements Schedulable {
    
    public AssignmentEngineScheduler(Id engineInstanceID) {
        this.engineInstanceID = engineInstanceID;
    }
    public Id engineInstanceID;
    
    public void execute(SchedulableContext sc)
    {
        // Implement any logic to be scheduled
       
        // We now call the batch class to be scheduled
        AssignmentEngineInstance engineInstance = new AssignmentEngineInstance(this.engineInstanceID);
        
        //Parameters of ExecuteBatch(context,BatchSize)
        database.executebatch(engineInstance);
    }

}