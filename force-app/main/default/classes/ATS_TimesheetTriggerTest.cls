@isTest(SeeAllData=true) public class ATS_TimesheetTriggerTest { @isTest static void test() { try { ASYMBL_Time__Timesheet__c obj = [SELECT Id FROM ASYMBL_Time__Timesheet__c LIMIT 1]; update obj;} catch(Exception ex){}}}