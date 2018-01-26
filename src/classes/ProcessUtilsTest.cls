@isTest(SeeAllData=true)
public  class ProcessUtilsTest {
	@isTest(SeeAllData=true)
	static void go() {
		Test.startTest();
		 //System.debug('@@ ' + [SELECT Id, name FROM user ].get(0).name); //有資料
        
   //     Profile pf = [SELECT Id FROM Profile WHERE name = '员工'];
   //     System.debug('pf->' + pf);
   //     UserRole ur = new UserRole(Name = 'Finance');
   //     insert ur;
   //     User usr = TestUserUtil.createTestUser(ur.Id, pf.Id, 'Test FirstName', 'Test LastName', '30210999');
        
   //     System.runAs(usr)
   //     {
        	//Contact con2 = new Contact(LastName = 'bbb', number__c = '30210999', SF_User__c = usr.id );
        	//insert con2;
        	Id recordTypeId    = Schema.getGlobalDescribe().get( 'Approval_Managed1__c' ).getDescribe().getRecordTypeInfosByName().get( '教育訓練申請流程' ).getRecordTypeId();
        	Id objId = [SELECT Id FROM Approval_Managed1__c WHERE recordTypeId =:recordTypeId LIMIT 1].get(0).Id;
	        ProcessUtils.checkEditable(objId,recordTypeId);
	   // }
        Test.stopTest();
	}
}