/**
* @description      To schedule Rent Batch
* @param            rnone
* @return           None
* @throws           NA
* @author Kshitij Tiwari
*/
global class RentBatchSchedular implements Schedulable {

    global void execute(SchedulableContext ctx) {
        BatchUpdateRentStructure obj= new BatchUpdateRentStructure();
        //Batch size is 200, records will be split into batches
        Database.ExecuteBatch(obj, 200);
    }
}