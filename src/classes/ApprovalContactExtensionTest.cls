@isTest
private class ApprovalContactExtensionTest {
    

    static testMethod void testMethod1() { 
       test.startTest();
        Contact con = new Contact( LastName = '测试人员',number__c = '123');
        insert con;


       RecordType rc = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'contact'  AND  DeveloperName = 'Staff'];
        Contact apq = new Contact ();
        apq.RecordTypeId = rc.Id;
        apq.Human_Range__c = '3000';
        apq.Department1__c = '';
        apq.Number__c='********';
        apq.SAPID__c = 'TST';
        INSERT apq;


        ApprovalContactExtension am = new ApprovalContactExtension();
        am.selectedContactCodeValue = '30210350';
        am.selectedContactNameValue = '劉昱杰';
        am.query();

        am.selectedfactoryValue = 'aa';
        am.selectedContactNameValue = 'customer';
        am.query();
        test.stopTest();
    }
}