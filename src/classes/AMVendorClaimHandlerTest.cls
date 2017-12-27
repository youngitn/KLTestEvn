@isTest
private class AMVendorClaimHandlerTest
{
	@isTest
	static void itShould()
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

            Contact con2 = new Contact(LastName = 'bbb', number__c = '30210999', SF_User__c = usr.id);
            insert con2;
            
            
            Custom_Approval_Managed__c am = new Custom_Approval_Managed__c();
           	am.Applicant__c = con2.Id;
            

            AMVendorClaimExtension extension = new AMVendorClaimExtension(new ApexPages.StandardController(am));
           

            PageReference page = extension.saveAction();

            System.debug(LoggingLevel.INFO, '*** page: ' + page);

        }

        Test.stopTest();

	}
}