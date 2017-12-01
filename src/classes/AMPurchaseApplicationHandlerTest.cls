@isTest
private class AMPurchaseApplicationHandlerTest {
    static testMethod void testMethod1() {
        RecordType rc = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Approval_Managed__c' AND  DeveloperName = 'PurchaseApplication'];
        
    	Contact con = new Contact(LastName = '测试人员',number__c = '123');
        insert con;

        Approval_Managed__c Approve = new Approval_Managed__c();
        Approve.Applicant__c = con.Id;
        Approve.RecordTypeId = rc.Id;
        INSERT Approve;

        Approve.Applicant__c = con.Id;
        Approve.RecordTypeId = rc.Id;
        approve.Is_Reset_Approvaler__c = true;
        UPDATE Approve;
    }


}