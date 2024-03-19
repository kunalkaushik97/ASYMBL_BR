public with sharing class BR_AsymblTimesheetTriggerHelper {
    private static String STATUS_VALUE_APPROVED_BY_BRANCH = 'Approved by Branch';
    private static String STATUS_VALUE_APPROVED = 'Approved';

    public static void afterUpdate(List<ASYMBL_Time__Timesheet__c> oldTimesheets, Map<Id, ASYMBL_Time__Timesheet__c> newTimesheetDetails){
        for(ASYMBL_Time__Timesheet__c ots : oldTimesheets){
            generateTimesheetAsPDF( ots, newTimesheetDetails.get(ots.Id));
        }
    }
    
    private static Boolean isTimesheetEligibleToGeneratePDF(ASYMBL_Time__Timesheet__c oldTs, ASYMBL_Time__Timesheet__c newTs){
        Boolean result = false;
        Boolean isStatusApproved = oldTs.ASYMBL_Time__Status__c == STATUS_VALUE_APPROVED_BY_BRANCH || oldTs.ASYMBL_Time__Status__c == STATUS_VALUE_APPROVED ? true : false;
        
        if((isStatusApproved && (( oldTs.ASYMBL_Time__Status__c == STATUS_VALUE_APPROVED && newTs.ASYMBL_Time__Status__c == STATUS_VALUE_APPROVED_BY_BRANCH ) || ( oldTs.ASYMBL_Time__Status__c == STATUS_VALUE_APPROVED_BY_BRANCH && newTs.ASYMBL_Time__Status__c == STATUS_VALUE_APPROVED )))
           ||
           (!isStatusApproved && (newTs.ASYMBL_Time__Status__c == STATUS_VALUE_APPROVED_BY_BRANCH || newTs.ASYMBL_Time__Status__c == STATUS_VALUE_APPROVED ))){
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

        try{
            deleteExistingTimesheetPDFs(recordId);
            PageReference MyFirstPDF = new PageReference('/apex/BR_TimesheetToPDF');
            MyFirstPDF.getParameters().put('id', recordId);
    
            ContentVersion cont = new ContentVersion();
            cont.Title = 'TimeSheet_' + DateTime.now();
            cont.PathOnClient = 'TimeSheet_' + DateTime.now() + '.pdf';
            cont.VersionData = !Test.isRunningTest() ? MyFirstPDF.getContentAsPDF() : Blob.valueOf('Fake PDF content');
            cont.Origin = 'H';
            if(hasReadAccess('Network')){
                List<Network> communities = [SELECT Id,Name FROM Network WHERE Name = 'BTQ Connect' LIMIT 1];
                if(! communities.isEmpty()){
                        cont.NetworkId = communities[0].Id;
                }
            }
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
        catch(Exception ex){
            insert new ASYMBL_Time__AST_Log__c(ASYMBL_Time__Log_Message__c = ex.getMessage());
        }
    }
    
    public static Boolean hasReadAccess(String objectName) {
        // Get the schema describe result for the object
        Boolean result = false;
        Id profileId = userinfo.getProfileId();
		String profileName = [Select Id,Name from Profile where Id=:profileId].Name;
        
        if(profileName == 'Boutique Experience Cloud User'){
            result = true;
        }
        
        return result;
    }
    
    @AuraEnabled
    public static void generateTimesheetAsPDF(String recordId){
        saveTimesheetAsPDF(recordId);
    }
    
    public static void deleteExistingTimesheetPDFs(String recordId){
        delete [Select Id, LinkedEntityId from ContentDocumentLink WHERE LinkedEntityId = :recordId AND ContentDocument.Title LIKE '%Timesheet%'];
    }
}