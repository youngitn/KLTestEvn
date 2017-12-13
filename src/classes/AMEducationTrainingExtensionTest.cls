@isTest
private class AMEducationTrainingExtensionTest
{

    static void test_method_one()
    {
        // Implement test code

    }

    //static testMethod void testSave1()
    //{
    //   Test.startTest();

    //   Test.stopTest();
    //}
    static testMethod void testSave()
    {
        Test.startTest();

        System.debug('@@ ' + [SELECT Id, name FROM user ].get(0).name); //有資料
        RecordType rc = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Approval_Managed1__c' AND  DeveloperName = :SapApprovalEnum.EDUCATIONTRAININGREQUEST];



        Profile pf = [SELECT Id FROM Profile WHERE name = '员工'];
        System.debug('pf->' + pf);
        UserRole ur = new UserRole(Name = 'Finance');
        insert ur;
        User usr = TestUserUtil.createTestUser(ur.Id, pf.Id, 'Test FirstName', 'Test LastName', '30210999');
        User usr2 = TestUserUtil.createTestUser(ur.Id, pf.Id, 'Test FirstName2', 'Test LastName2', '30210378');

        System.runAs(usr)
        {

            Contact con2 = new Contact(LastName = 'bbb', number__c = '30210240', SF_User__c = usr.id);
            insert con2;

           



            Contact con3 = new Contact(LastName = 'aaa', number__c = '30210378', SF_User__c = usr2.id);
            insert con3;
            System.debug(usr);
            List<Contact> p1 = [SELECT Id, SF_User__c FROM CONTACT WHERE id = : con3.id];
            System.debug('@@ ' + p1);
            Approval_Managed1__c am = new Approval_Managed1__c();
            Datetime d = Datetime.now();
            am.BegingTime__c = '10:00 上午' ;
            am.EndTime__c = '11:00 上午';
            am.Days__c = 2;
            am.Applicant__c = p1.get(0).Id;
            System.debug('@@ ' + am.Applicant__c);
            am.RecordTypeId = rc.Id;
            am.Start_Time__c = d;
            am.End_Time__c = d.addHours(1);
            am.EducationTrainingHours__c = 8;
            am.EducationTrainingInHouseLecturerName__c = p1.get(0).id;
            am.MeetingRooms__c = con3.id;
            am.Equipment_Order__c = true;
            am.EducationTrainingInHouseLecturerName__c = usr.id;

            AMEducationTrainingExtension extension = new AMEducationTrainingExtension(new ApexPages.StandardController(am));
            System.debug('am.Days__c-----' + extension.am.Days__c);
            extension.am.Days__c = 1;
            //click add Participant
            extension.addParticipant();
            extension.ApplicantEmpid = '30210378';
            //get value from VF
            PageReference pageRef = new PageReference('/apex/EducationTraining');
            pageRef.getParameters().put('inputType', 'empid');
            pageRef.getParameters().put('inputValue', '30210378');
            pageRef.getParameters().put('rowId', '1');
            Test.setCurrentPage(pageRef);
            extension.PutValue();

            extension.deleteRow();
            extension.addParticipant();
            pageRef.getParameters().put('inputType', 'empid');
            pageRef.getParameters().put('inputValue', '311111');
            pageRef.getParameters().put('rowId', '1');
            Test.setCurrentPage(pageRef);
            extension.PutValue();
            extension.deleteRow();

            extension.addParticipant();
            pageRef.getParameters().put('inputType', 'name');
            pageRef.getParameters().put('inputValue', '30210378');
            pageRef.getParameters().put('rowId', '1');
            Test.setCurrentPage(pageRef);
            extension.PutValue();

            PageReference page = extension.save();

            System.debug(LoggingLevel.INFO, '*** page: ' + page);

        }

        Test.stopTest();

    }

    static testMethod void testaddInv()
    {
        Test.startTest();
        Profile pf = [SELECT Id FROM Profile WHERE name = '员工'];
        UserRole ur = new UserRole(Name = 'Finance');
        insert ur;
        User usr1 = [SELECT Id FROM User WHERE Number__c = '30210240'];
        System.runAs(usr1)
        {
            AMEducationTrainingExtension extension = new AMEducationTrainingExtension(new ApexPages.StandardController( new Approval_Managed1__c()));
            Event e = new Event();
            e.DurationInMinutes = 1;
            e.ActivityDateTime = Datetime.now();
            insert e;
            extension.addParticipant();
            PageReference pageRef = new PageReference('/apex/EducationTraining');
            pageRef.getParameters().put('inputType', 'empid');
            pageRef.getParameters().put('inputValue', '30210240');
            pageRef.getParameters().put('rowId', '1');
            Test.setCurrentPage(pageRef);
            extension.PutValue();
            extension.addInv(e, extension.participants.get(0));
        }

        Test.stopTest();
    }



    static testMethod void testGetContactNameByEmpid()
    {
        Contact con = new Contact(LastName = '测试人员', number__c = '123');

        insert con;
        Contact con2 = new Contact(LastName = 'bbb', number__c = '333');
        insert con2;

        Contact con3 = new Contact(LastName = 'aaa', number__c = '30210378');
        insert con3;
        Test.startTest();
        AMEducationTrainingExtension extension = new AMEducationTrainingExtension(new ApexPages.StandardController( new Approval_Managed1__c()));
        PageReference pageRef = new PageReference('/apex/EducationTraining');
        pageRef.getParameters().put('empid', '123');
        Test.setCurrentPage(pageRef);
        extension.getContactNameByEmpid();
        System.assertEquals('测试人员', extension.ApplicantEmpid);
        Test.stopTest();
    }
    static testMethod void testGetContactEmpidByName()
    {
        Contact con = new Contact(LastName = '测试人员', number__c = '123');

        insert con;
        Contact con2 = new Contact(LastName = 'bbb', number__c = '333');
        insert con2;

        Contact con3 = new Contact(LastName = 'aaa', number__c = '30210378');
        insert con3;
        Test.startTest();
        AMEducationTrainingExtension extension = new AMEducationTrainingExtension(new ApexPages.StandardController( new Approval_Managed1__c()));
        PageReference pageRef = new PageReference('/apex/EducationTraining');
        pageRef.getParameters().put('name', 'bbb');
        Test.setCurrentPage(pageRef);
        extension.getContactEmpidByName();
        System.assertEquals('333', extension.ApplicantEmpid);
        Test.stopTest();
    }
    static testMethod void testCancel()
    {
        Test.startTest();
        Approval_Managed1__c am = new Approval_Managed1__c();
        AMEducationTrainingExtension extension = new AMEducationTrainingExtension(new ApexPages.StandardController(am));

        extension.cancel();
        Test.stopTest();
    }





}