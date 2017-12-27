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

    static testMethod void testhandler() {
        Test.startTest();
        RecordType rc = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Approval_Managed__c' AND  DeveloperName = 'MRDieRequest'];
        RecordType rcContact = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Contact' AND  DeveloperName = 'Staff'];
        Contact con = new Contact(LastName = '测试人员',number__c = '10210911', RecordTypeId=rcContact.Id);
        insert con;

        Approval_Managed__c am = new Approval_Managed__c();
        am.Applicant__c = con.Id;
        am.RecordTypeId = rc.Id;
        INSERT am;
        am.Applicant__c = con.Id;
        am.RecordTypeId = rc.Id;
        am.Is_Reset_Approvaler__c = true;
        UPDATE am;
        Test.stopTest();
    }
}