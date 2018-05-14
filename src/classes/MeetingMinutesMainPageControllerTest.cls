@isTest
public with sharing class MeetingMinutesMainPageControllerTest {
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
            
         KL_Systems__c kls = new KL_Systems__c();

          MeetingMinutesMainPageController m = new MeetingMinutesMainPageController(new ApexPages.StandardController(kls));
          m.addParticipant();
          PageReference pageRef = new PageReference('/apex/EducationTraining');
	        pageRef.getParameters().put('rowId', '1');
	         pageRef.getParameters().put('inputType', 'name');
            pageRef.getParameters().put('inputValue', '30210378');
	        Test.setCurrentPage(pageRef);
	        m.putValue();
	        m.deleteRow();
	        m.selectedMeetingRoom = 'else';
	        kls.Meeting_Place__c = 'testPlace';
	        m.kls = kls;
	        m.RecordTypeId = HarryUtils.getRecordTypeIdByDevNameAndObjName('Meeting_Minutes', 'KL_Systems__c');
	        m.saveAction();
	        m.cancelAction();

        }

        test.stopTest();
    }
}