@isTest
private class AMChangJobTest {

	static testMethod void testhandler() {
        Test.startTest();
        RecordType rc = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Approval_Managed1__c' AND  DeveloperName = 'changejobs'];
        RecordType rcContact = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Contact' AND  DeveloperName = 'Staff'];
        Contact con = new Contact(LastName = '测试人员',number__c = '10210911', RecordTypeId=rcContact.Id);
        insert con;

        Approval_Managed1__c am = new Approval_Managed1__c();
        am.Applicant__c = con.Id;
        am.RecordTypeId = rc.Id;
        INSERT am;
        am.Applicant__c = con.Id;
        am.RecordTypeId = rc.Id;
        am.Is_Reset_Approvaler__c = true;
        UPDATE am;
        Test.stopTest();
    }

    static testMethod void testextension() {
        RecordType rc = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Approval_Managed1__c' AND  DeveloperName = 'changejobs'];
        Approval_Managed1__c cusApprove = new Approval_Managed1__c();
        cusApprove.RecordTypeId = rc.Id;
        cusApprove.Factory__c = '1000';

        INSERT cusApprove;
        AMChangeJobsExtension amIt = new AMChangeJobsExtension(new ApexPages.StandardController(cusApprove));
        cusApprove.Factory__c = '1000';
        amIt.save();
        amIt.cancel();

        test.startTest();
        cusApprove.add_overclass_deapart__c = 'Y';
        cusApprove.job_add_cancel__c = true;
        cusApprove.change_explain__c = '133';

        Update cusApprove;   

        test.stopTest();
    }

    
}