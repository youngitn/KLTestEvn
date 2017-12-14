@isTest
private class AMEducationTrainingHandlerTest
{

    @isTest static void test_method_one()
    {
        Test.startTest();
        // Implement test code
        RecordType rc = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Approval_Managed1__c' AND  DeveloperName = 'EducationTraining'];
        
        Profile pf = [SELECT Id FROM Profile WHERE name = '员工'];
        System.debug('pf->' + pf);
        UserRole ur = new UserRole(Name = 'Finance');
        insert ur;
        User usr = TestUserUtil.createTestUser(ur.Id, pf.Id, 'Test FirstName', 'Test LastName', '30210999');
        System.runAs(usr)
        {
            Contact con = new Contact(LastName = '测试人员', number__c = '30210999' ,SF_User__c = usr.id,email = usr.Email);
            //必須insert
            insert con;

            Approval_Managed1__c capp1 = new Approval_Managed1__c();

            capp1.Applicant__c = con.Id;
            capp1.RecordTypeId = rc.Id;
            capp1.InternalEducationParticipants__c = 'aaa-30210999';

            INSERT capp1;

            capp1 = [select Applicant__c,Is_Reset_Approvaler__c,Approval_Status__c from Approval_Managed1__c where Id =: capp1.Id].get(0);
            capp1.Is_Reset_Approvaler__c = true;
            capp1.Approval_Status__c = 'A';
            UPDATE capp1;

        }


        Test.stopTest();

    }

}