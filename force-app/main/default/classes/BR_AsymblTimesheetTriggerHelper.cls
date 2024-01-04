public class BR_AsymblTimesheetTriggerHelper {
    private static String STATUS_VALUE_APPROVED_BY_BRANCH = 'Approved by Branch';
    private static String STATUS_VALUE_APPROVED = 'Approved';

    public static void afterUpdate(List<ASYMBL_Time__Timesheet__c> oldTimesheets, Map<Id, ASYMBL_Time__Timesheet__c> newTimesheetDetails){
        for(ASYMBL_Time__Timesheet__c ots : oldTimesheets){
            generateTimesheetAsPDF( ots, newTimesheetDetails.get(ots.Id));
        }
    }
    
    private static Boolean isTimesheetEligibleToGeneratePDF(ASYMBL_Time__Timesheet__c oldTs, ASYMBL_Time__Timesheet__c newTs){
        Boolean result = false;
        
        if((oldTs.ASYMBL_Time__Status__c != STATUS_VALUE_APPROVED_BY_BRANCH && (newTs.ASYMBL_Time__Status__c == STATUS_VALUE_APPROVED_BY_BRANCH || newTs.ASYMBL_Time__Status__c == STATUS_VALUE_APPROVED)) 
           ||
		   (oldTs.ASYMBL_Time__Status__c != STATUS_VALUE_APPROVED && (newTs.ASYMBL_Time__Status__c == STATUS_VALUE_APPROVED_BY_BRANCH || newTs.ASYMBL_Time__Status__c == STATUS_VALUE_APPROVED ))){
            result = true;
        }  
        return result;
    }
    
    private static void generateTimesheetAsPDF(ASYMBL_Time__Timesheet__c oldTs, ASYMBL_Time__Timesheet__c newTs){
        if(isTimesheetEligibleToGeneratePDF( oldTs, newTs)){
            saveTimesheetAsPDF(newTs.Id);
        }
    }
    
    @Future(callout=true)
    public static void saveTimesheetAsPDF(String recordId){
        System.debug('1 recordId = '+recordId);
        deleteExistingTimesheetPDFs(recordId);
        PageReference MyFirstPDF = new PageReference('/apex/BR_TimesheetToPDF');
        MyFirstPDF.getParameters().put('id', recordId);

        ContentVersion cont = new ContentVersion();
        cont.Title = 'TimeSheet_' + DateTime.now();
        cont.PathOnClient = 'TimeSheet_' + DateTime.now() + '.pdf';
        cont.VersionData = !Test.isRunningTest() ? MyFirstPDF.getContentAsPDF() : Blob.valueOf('Fake PDF content');
        cont.Origin = 'H';
        insert cont;
        
        cont = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cont.Id];
        ContentDocumentLink cdl = new ContentDocumentLink(
        	ContentDocumentId = cont.ContentDocumentId,
          	LinkedEntityId = recordId,
            ShareType = 'I',
            Visibility = 'AllUsers'
        );
        insert cdl;
    }
    
    @AuraEnabled
    public static void generateTimesheetAsPDF(String recordId){
        saveTimesheetAsPDF(recordId);
    }
    
    public static void deleteExistingTimesheetPDFs(String recordId){
        System.debug('Att ::> '+[Select Id, LinkedEntityId from ContentDocumentLink WHERE LinkedEntityId = :recordId]);
        //delete [Select Id, LinkedEntityId from ContentDocumentLink WHERE LinkedEntityId = :recordId];
        delete [Select Id, LinkedEntityId from ContentDocumentLink WHERE LinkedEntityId = :recordId AND ContentDocument.Title LIKE '%Timesheet%'];
    }
}