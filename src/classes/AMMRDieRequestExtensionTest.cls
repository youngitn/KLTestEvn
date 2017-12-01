@isTest
private class AMMRDieRequestExtensionTest {
    static testMethod void testMethod1() {
        RecordType rc = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Approval_Managed__c' AND  DeveloperName = 'MRDieRequest'];
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
        cusApprove.die_use_bu__c='BU1';
        cusApprove.Material_Number__c='123';
        cusApprove.Dept_of_CostCenter__c='1000E001';
        cusApprove.Factory__c='1000';
        cusApprove.Modify_description__c='888';
        Update cusApprove;

        

        test.stopTest();
    }
}