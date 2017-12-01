@isTest
private class AMEntertaineCostHandlerTest {
    static testMethod void testMethod1() {
        RecordType rc = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Approval_Managed__c' AND  DeveloperName = 'EntertaineCost'];
    	Contact con = new Contact(LastName = '测试人员',number__c = '123');
        insert con;

        Approval_Managed__c capp1 = new Approval_Managed__c();
        capp1.Applicant__c = con.Id;
        capp1.RecordTypeId = rc.Id;
        INSERT capp1;

        capp1.Applicant__c = con.Id;
        capp1.RecordTypeId = rc.Id;
        capp1.Is_Reset_Approvaler__c = true;
        UPDATE capp1;
    }
}