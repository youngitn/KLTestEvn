@isTest
public with sharing class MeetingMinutesQueryPageControllerTest {
	 @isTest
    static void  testMethod2()
    {
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

            Contact con2 = new Contact(LastName = 'bbb', number__c = '30210999', SF_User__c = usr.id , Email = 'test@test.com',Human_Range__c = '3000');

            insert con2;
             RecordType rc = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Approval_Managed1__c' AND  DeveloperName = 'EducationTraining'];
          MeetingMinutesQueryPageController.doQuery('{"sobjName":"Approval_Managed1__c","recordTypeId":"'+rc.Id+'","SOQL":"select id from Approval_Managed1__c limit 1 "}');
          MeetingMinutesQueryPageController m = new MeetingMinutesQueryPageController();
          m.kls = new KL_Systems__c();

        }

        test.stopTest();
    }
}