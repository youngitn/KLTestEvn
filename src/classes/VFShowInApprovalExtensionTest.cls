@isTest
public  class VFShowInApprovalExtensionTest {
	@isTest
	static void go() {
		Test.startTest();

        System.debug('@@ ' + [SELECT Id, name FROM user ].get(0).name); //有資料
        
        Profile pf = [SELECT Id FROM Profile WHERE name = '员工'];
        System.debug('pf->' + pf);
        UserRole ur = new UserRole(Name = 'Finance');
        insert ur;
        User usr = TestUserUtil.createTestUser(ur.Id, pf.Id, 'Test FirstName', 'Test LastName', '30210999');
        User usr2 = TestUserUtil.createTestUser(ur.Id, pf.Id, 'Test FirstName2', 'Test LastName2', '30210378');

        System.runAs(usr)
        {

            Contact con2 = new Contact(LastName = 'bbb', number__c = '30210999', SF_User__c = usr.id );
            insert con2;
            Approval_Managed__c am = new Approval_Managed__c();
            VFShowInApprovalExtension vfsiae = 
            new VFShowInApprovalExtension('Approval_Managed__c','請假申請流程',new ApexPages.StandardController(am),'Approval_Managed_Item__c','请假明细表','LeaveManage__c');

            vfsiae.saveAction();
            vfsiae.goPage(am.Id);
            
        }

        Test.stopTest();

	
	}

	@isTest(SeeAllData=true)
	static void go2() {
		Test.startTest();

       	Id recordTypeId    = Schema.getGlobalDescribe().get( 'Approval_Managed1__c' ).getDescribe().getRecordTypeInfosByName().get( '教育訓練申請流程' ).getRecordTypeId();
		Approval_Managed1__c obj = [SELECT Id FROM Approval_Managed1__c WHERE recordTypeId =:recordTypeId AND Approval_Status__c = 'S'LIMIT 1].get(0);
        

        VFShowInApprovalExtension vfsiae = 
        new VFShowInApprovalExtension('Approval_Managed1__c','教育訓練申請流程',new ApexPages.StandardController(obj),null,null,null);

        vfsiae.saveAction();
        vfsiae.goPage(obj.Id);
            
        

        Test.stopTest();

	
	}

	@isTest(SeeAllData=true)
	static void go3() {
		Test.startTest();

       	Id recordTypeId    = Schema.getGlobalDescribe().get( 'Approval_Managed1__c' ).getDescribe().getRecordTypeInfosByName().get( '教育訓練申請流程' ).getRecordTypeId();
		Approval_Managed1__c obj = [SELECT Id FROM Approval_Managed1__c WHERE recordTypeId =:recordTypeId AND (Approval_Status__c = 'R' OR Approval_Status__c = 'A') LIMIT 1].get(0);
        

        VFShowInApprovalExtension vfsiae = 
        new VFShowInApprovalExtension('Approval_Managed1__c','教育訓練申請流程',new ApexPages.StandardController(obj),null,null,null);

        vfsiae.saveAction();
        vfsiae.goPage(obj.Id);
            
        

        Test.stopTest();

	
	}

	@isTest(SeeAllData=true)
	static void go4() {
		Test.startTest();

       	Id recordTypeId    = Schema.getGlobalDescribe().get( 'Approval_Managed1__c' ).getDescribe().getRecordTypeInfosByName().get( '教育訓練申請流程' ).getRecordTypeId();
		Approval_Managed1__c obj = [SELECT Id FROM Approval_Managed1__c WHERE recordTypeId =:recordTypeId AND Approval_Status__c = 'D' LIMIT 1].get(0);
        

        VFShowInApprovalExtension vfsiae = 
        new VFShowInApprovalExtension('Approval_Managed1__c','教育訓練申請流程',new ApexPages.StandardController(obj),null,null,null);

        vfsiae.saveAction();
        vfsiae.goPage(obj.Id);
            
        

        Test.stopTest();

	
	}
}