/**
* Class Name: LeadStatus7DaysSchedular
* Class Description: it schedule the LeadStatus7DaysBatch class                                          
*/
global class LeadStatus7DaysSchedular implements Schedulable {
    global void execute(SchedulableContext sc){
        LeadStatus7DaysBatch leadStatus7DaysBatch = New LeadStatus7DaysBatch();
        Database.executeBatch(leadStatus7DaysBatch);
    }
}