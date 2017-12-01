@isTest
private class AMEducationTrainingHandlerTest
{

    @isTest static void test_method_one()
    {
        // Implement test code
        RecordType rc = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Approval_Managed1__c' AND  DeveloperName = :SapApprovalEnum.EDUCATIONTRAININGREQUEST];
        Contact con = new Contact(LastName = '测试人员',number__c = '123');
        insert con;

        Approval_Managed1__c capp1 = new Approval_Managed1__c();
        
        capp1.Applicant__c = con.Id;
        capp1.RecordTypeId = rc.Id;
        capp1.InternalEducationParticipants__c = 'aaa-30210240';
        INSERT capp1;

        capp1.Applicant__c = con.Id;
        capp1.RecordTypeId = rc.Id;
        
        UPDATE capp1;

        capp1.Applicant__c = con.Id;
        capp1.RecordTypeId = rc.Id;
        capp1.Is_Reset_Approvaler__c = true;
        capp1.Approval_Status__c = 'A';
        UPDATE capp1;

    }


}