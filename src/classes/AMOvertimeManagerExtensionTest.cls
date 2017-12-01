@isTest
private class AMOvertimeManagerExtensionTest {
    static testMethod void testMethod1() {
        RecordType rc = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Approval_Managed__c' AND  DeveloperName = 'OvertimeWork'];
         //createApprovalconfig(26,'MeasuringInstRequest');
         Approval_Managed__c cusApprove = new Approval_Managed__c();
         cusApprove.RecordTypeId = rc.Id;
         cusApprove.Factory__c = '1000';

         INSERT cusApprove;
         AMOvertimeManagerExtension amIt = new AMOvertimeManagerExtension(new ApexPages.StandardController(cusApprove));
            cusApprove.Factory__c = '1000';
            //amIt.isDeletedStatus = true;
            amIt.save();
            amIt.cancel();

        test.startTest();
        //cusApprove.Factory__c='1000';
        cusApprove.apply_dept__c='02';
        cusApprove.overtime_instructions__c='123';
        cusApprove.Remark__c='456';
        Update cusApprove;

        

        test.stopTest();
    }
}