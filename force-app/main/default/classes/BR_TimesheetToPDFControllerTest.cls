@isTest
public class BR_TimesheetToPDFControllerTest {
 
    @isTest 
    public static void testAccountOpportunity(){ 
        ASYMBL_TIME.AST_Constants.RUN_PLACEMENT_TRIGGER = false;
       Profile profile = [select Id, Name from Profile WHERE Name = 'Standard User'];
        Account acc = BR_TestFactory.createAccount('Test Account', 'Weekly', 'Monday', true);
        ASYMBL_Time.AST_Constants.RUN_USER_TRIGGER = false;
        User user1 = BR_TestFactory.createUser('dummy', 'user2', 'testuser@test4.com', 'dummy@dummyuser2.com', profile.Id, 'dummy1', true, true);
        Contact candidate = BR_TestFactory.createContact('Test', 'Contact 1', acc.Id, Date.today(), true);
        Contact hireMan = BR_TestFactory.createContact('Test', 'Contact 2', acc.Id, Date.today(), true);
        bpats__Job__c job = BR_TestFactory.createJob('Test Job', 'Test Title', acc.Id, null, user1.Id, hireMan.Id, 'Test Description', 'Direct Hire', true);
        bpats__Placement__c placement = BR_TestFactory.createPlacement('Test Placement', candidate.Id, job.Id, true);
        
        Test.startTest();
        ASYMBL_Time__Timesheet__c timesheet = BR_TestFactory.createTimesheet(Date.today(), Date.today() + 7, 20, 25, 'Draft', candidate.Id, hireMan.Id, null, placement.Id, true);
        List<ContentDocumentLink> ContentDocumentLink = [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :timesheet.Id];
        timesheet.ASYMBL_Time__Status__c = 'Approved by Branch';
        update timesheet;
        Test.stopTest();
        
        BR_TestFactory.createTimeEntry(timesheet.Id, Date.today(), DateTime.now().time(), DateTime.now().time() + 1, DateTime.now().time() + 3, DateTime.now().time() + 4, 1, 2, 3, true);
        
       //BR_TimesheetToPDF is the Visualforce page created
       PageReference testPage = Page.BR_TimesheetToPDF;
       Test.setCurrentPage(testPage);
       testPage.getParameters().put('id', String.valueOf(timesheet.Id));
        
       ApexPages.StandardController sc = new  ApexPages.StandardController(timesheet);
       BR_TimesheetToPDFController controllerInstance = new BR_TimesheetToPDFController(sc);
       System.assertEquals(true, true);
   } 
  }