@isTest
private class AMPMTicketExtensionTest {
    static testMethod void testMethod1() {
        RecordType rc = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Approval_Managed__c' AND  DeveloperName = 'PMTicket'];
         //createApprovalconfig(26,'MeasuringInstRequest');
         Approval_Managed__c cusApprove = new Approval_Managed__c();
         cusApprove.RecordTypeId = rc.Id;
         cusApprove.Factory__c = '1000';

         INSERT cusApprove;
         AMPMTicketExtension amIt = new AMPMTicketExtension(new ApexPages.StandardController(cusApprove));
            cusApprove.Factory__c = '1000';
            //amIt.isDeletedStatus = true;
            amIt.save();
            amIt.cancel();

        test.startTest();
        //cusApprove.Factory__c='1000';
        Update cusApprove;

        

        test.stopTest();
    }
}