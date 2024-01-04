public class BR_TimesheetToPDFController {

    public String tsId {get; set;}
    public List<ASYMBL_Time__Time_Entry__c> timeEntries;
    public List<String> inTimeEntries {get; set;}
    public List<String> outTimeEntries {get; set;}
    //public List<String> secondaryInTimeEntries {get; set;}
    //public List<String> secondaryOutTimeEntries {get; set;}
    public List<String> breakEntries {get; set;}
    public List<String> totalHourEntries {get; set;}
    public List<String> daysWithDateOfWeek {get; set;}
    public Double offset{get{
        TimeZone tz = UserInfo.getTimeZone();
        //Milliseconds to Day
        return tz.getOffset(DateTime.now()) / (1000 * 3600 * 24.0);
    }}
    
    Private Map<Integer, Integer> DayToIndexDetails {get; set;}
    
    public BR_TimesheetToPDFController(ApexPages.StandardController controller){
        inTimeEntries = new List<String>();
        outTimeEntries = new List<String>();
        //secondaryInTimeEntries = new List<String>();
        //secondaryOutTimeEntries = new List<String>();
        totalHourEntries = new List<String>();
        breakEntries = new List<String>();
        daysWithDateOfWeek = new List<String>();
        timeEntries = new List<ASYMBL_Time__Time_Entry__c>();
        DayToIndexDetails = new Map<Integer, Integer>();
        
        for(Integer index = 0; index < 7; index++){
            inTimeEntries.add(BR_Constants.DASH_CHARACTER);
            outTimeEntries.add(BR_Constants.DASH_CHARACTER);
            //secondaryInTimeEntries.add(BR_Constants.DASH_CHARACTER);
            //secondaryOutTimeEntries.add(BR_Constants.DASH_CHARACTER);
            totalHourEntries.add(BR_Constants.DASH_CHARACTER);
            breakEntries.add(BR_Constants.DASH_CHARACTER);
        }
        
        tsId = System.currentPageReference().getParameters().get('id');
        timeEntries = [SELECT Id, ASYMBL_Time__Date__c, ASYMBL_Time__Start_Time__c, ASYMBL_Time__End_Time__c, ASYMBL_Time__Break__c, ASYMBL_Time__Regular_Hours__c, ASYMBL_Time__Overtime_Hours__c, ASYMBL_Time__Double_Time_Hours__c, ASYMBL_Time__Secondary_Start_Time__c, ASYMBL_Time__Secondary_End_Time__c FROM ASYMBL_Time__Time_Entry__c WHERE ASYMBL_Time__Timesheet__c =: tsId];
        
        ASYMBL_Time__Timesheet__c timesheet = new ASYMBL_Time__Timesheet__c();
        timesheet = [SELECT Id, ASYMBL_Time__Pay_Period_Start_Date__c FROM ASYMBL_Time__Timesheet__c WHERE Id =: tsId LIMIT 1];
        
        DateTime nextDate = Datetime.valueOf(JSON.deserialize('"' + String.valueOf(timesheet.ASYMBL_Time__Pay_Period_Start_Date__c) + '"', Datetime.class));
        
        nextDate = nextDate.addHours(nextDate.hour());
        nextDate = nextDate.addMinutes(nextDate.minute());
        nextDate = nextDate.addSeconds(nextDate.second());

        for(Integer index = 0; index < 7; index++){
            daysWithDateOfWeek.add(toString((nextDate.format(BR_Constants.DAY_OF_DATE_FORMAT)).substring(0,3) + ' ' + nextDate.format(BR_Constants.DATE_FORMAT_DD_MM_YY)));
            DayToIndexDetails.put(nextDate.day(), index);
            nextDate = nextDate + 1;
        }
        
        for(ASYMBL_Time__Time_Entry__c timeEntry : timeEntries){
            Integer index = DayToIndexDetails.get((timeEntry.ASYMBL_Time__Date__c).day());
            inTimeEntries[index] = timeEntry.ASYMBL_Time__Start_Time__c != null ? toString(Datetime.newInstance(Date.today(), (timeEntry.ASYMBL_Time__Start_Time__c)).format(BR_Constants.TIME_FORMAT)) : BR_Constants.DASH_CHARACTER;
            outTimeEntries[index] = timeEntry.ASYMBL_Time__End_Time__c != null ? toString(Datetime.newInstance(Date.today(), (timeEntry.ASYMBL_Time__End_Time__c)).format(BR_Constants.TIME_FORMAT)) : BR_Constants.DASH_CHARACTER;
            //secondaryInTimeEntries[index] = timeEntry.ASYMBL_Time__Secondary_Start_Time__c != null ? toString(Datetime.newInstance(Date.today(), (timeEntry.ASYMBL_Time__Secondary_Start_Time__c)).format(BR_Constants.TIME_FORMAT)) : BR_Constants.DASH_CHARACTER;
            //secondaryOutTimeEntries[index] = timeEntry.ASYMBL_Time__Secondary_End_Time__c != null ? toString(Datetime.newInstance(Date.today(), (timeEntry.ASYMBL_Time__Secondary_End_Time__c)).format(BR_Constants.TIME_FORMAT)): BR_Constants.DASH_CHARACTER;
            breakEntries[index] = timeEntry.ASYMBL_Time__Break__c != null ? timeEntry.ASYMBL_Time__Break__c : BR_Constants.DASH_CHARACTER;
            totalHourEntries[index] = toString((timeEntry.ASYMBL_Time__Regular_Hours__c + timeEntry.ASYMBL_Time__Overtime_Hours__c + timeEntry.ASYMBL_Time__Double_Time_Hours__c).setscale(2))+ 'h';
        }
    }
    
    private static String toString(Object data){
        return '' + data;
    }
}