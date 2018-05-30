@isTest
public with sharing class AMInformationServiceHandlerTest {
	@isTest
	static void  testMethodYo()
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
             String rcId =  HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.IRS_INFORMATIONSERVICE,'Approval_Managed1__c');
             Approval_Managed1__c am1 = new Approval_Managed1__c();
            am1.ServiceCategory__c = '120';
        	am1.Factory__c = '3000';
             am1.RecordTypeId = rcId;
             am1.ModuleName__c = '100';
             am1.Is_Reset_Approvaler__c = true;
             upsert am1 ;
             am1.Factory__c = '1000';
             am1.ModuleName__c = '120';
             am1.Is_Reset_Approvaler__c = true;
             update am1;
              am1.ModuleName__c = '130';
             am1.Factory__c = '1000';
             am1.Is_Reset_Approvaler__c = true;
             update am1;
              am1.ModuleName__c = '140';
             am1.Factory__c = '1000';
             am1.Is_Reset_Approvaler__c = true;
             update am1;
              am1.ModuleName__c = '150';
             am1.Factory__c = '1000';
             am1.Is_Reset_Approvaler__c = true;
             update am1;
              am1.ModuleName__c = '160';
             am1.Factory__c = '1000';
             am1.Is_Reset_Approvaler__c = true;
             update am1;
             am1.ModuleName__c = '170';
             am1.Factory__c = '1000';
             am1.Is_Reset_Approvaler__c = true;
             update am1;
             am1.ModuleName__c = '100';
             am1.Factory__c = '1000';
             am1.Is_Reset_Approvaler__c = true;
             update am1;
             am1.ModuleName__c = '110';
             am1.Factory__c = '1000';
             am1.Is_Reset_Approvaler__c = true;
             update am1;
             am1.ServiceCategory__c = '160';
             am1.Factory__c = '3000';
             am1.Is_Reset_Approvaler__c = true;
             update am1;
             am1.ServiceCategory__c = '120';
             am1.Factory__c = '3000';
             am1.Is_Reset_Approvaler__c = true;
             update am1;
             am1.ServiceCategory__c = '999';
             am1.Factory__c = '3000';
             am1.Is_Reset_Approvaler__c = true;
             update am1;
             am1.ServiceCategory__c = '100';
             am1.Factory__c = '3000';
             am1.Is_Reset_Approvaler__c = true;
             update am1;
        }

        test.stopTest();
    }
}