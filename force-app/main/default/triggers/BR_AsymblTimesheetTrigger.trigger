trigger BR_AsymblTimesheetTrigger on ASYMBL_Time__Timesheet__c (after update) {

    if(Trigger.IsAfter){
        if(Trigger.IsUpdate){
            BR_AsymblTimesheetTriggerHelper.afterUpdate(Trigger.old, Trigger.newMap);
        }
    }
}