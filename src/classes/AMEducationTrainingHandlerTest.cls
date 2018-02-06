@isTest
private class AMEducationTrainingHandlerTest
{

    /*@isTest static void test_method_one()
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

    }*/
    @isTest
    static void  testMethod1() {
        Test.startTest();
        
            //amIt.isDeletedStatus = true;
            //amIt.save();
            //amIt.cancel();
        System.debug('@@ ' + [SELECT Id, name FROM user ].get(0).name); //有資料
        
        Profile pf = [SELECT Id FROM Profile WHERE name = '员工'];
        System.debug('pf->' + pf);
        UserRole ur = new UserRole(Name = 'Finance');
        insert ur;
        User usr = TestUserUtil.createTestUser(ur.Id, pf.Id, 'Test FirstName', 'Test LastName', '30210999');
        
        System.runAs(usr)
        {
            
            Contact con2 = new Contact(LastName = 'bbb', number__c = '30210999', SF_User__c = usr.id ,Email = 'test@test.com');
            insert con2;
            RecordType rc = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Approval_Managed1__c' AND  DeveloperName = 'EducationTraining'];
             //createApprovalconfig(26,'MeasuringInstRequest');
             Approval_Managed1__c cusApprove = new Approval_Managed1__c();
             cusApprove.RecordTypeId = rc.Id;
             
             cusApprove.InternalEducationParticipants__c = '30210999  test';
             INSERT cusApprove;
            AMEducationTrainingExtension amIt = new AMEducationTrainingExtension(new ApexPages.StandardController(cusApprove));
            cusApprove.Applicant__c = con2.Id;
            cusApprove.EducationTrainingType__c = 'InternalTraining';
            cusApprove.StartDate__c = Date.today();
            cusApprove.EndDate__c = Date.today();
            cusApprove.BegingTime__c = '10:00 AM';
            cusApprove.EndTime__c = '11:00 AM';
            cusApprove.EducationTrainingName__c = 'test';
            cusApprove.EducationTrainingHours__c = 1;
            cusApprove.Days__c = 1;
            cusApprove.InternalEducationParticipants__c = '30210999  test';
            cusApprove.Approval_Status__c = 'A';
            /*cusApprove.die_use_bu__c='BU1';
            cusApprove.Material_Number__c='123';
            cusApprove.Dept_of_CostCenter__c='1000E001';
            cusApprove.Factory__c='1000';
            cusApprove.Modify_description__c='888';*/
            Update cusApprove;

        }

        test.stopTest();
    }

}