global class SyncUserSchedule implements Schedulable {
    global void execute(SchedulableContext sc) {
         SynchronousOrganization.actionDMLUser();
    }
}