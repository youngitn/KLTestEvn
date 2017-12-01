@isTest
private class UtilsTest {
    static testMethod void test1() {

        Test.startTest();
	
		TestUtil.createBasicData();
        List<User> users = [SELECT Id FROM User LIMIT 20];

        Organizational__c dept = [SELECT Id FROM Organizational__c LIMIT 1];
        Custom_Approval_Managed__c cam = TestUtil.createCustomerData();
        Utils.addToSendQueue(SapApprovalEnum.CUSTOMER, '15555154511', '新建');
        Utils.addToSyncQueue(SapApprovalEnum.CUSTOMER,'1000001',false,'同步失败');
        Utils.convertSObjectToMap(cam);
        Utils.getApprovalSQL(SapApprovalEnum.CUSTOMER, true);
        Utils.getByIndex(null, 0);
        List<Id> ids = new List<Id>();
        Utils.getByIndex(ids, 0);
        ids.add(cam.Id);
        Utils.getByIndex(ids, 0);
        Utils.getByIndex(ids, 1);
        Utils.serializeToJson('INSERT', 'Customer', null, null);
        Utils.getUserByEmployeeCode('10001234');
        Utils.getUserByEmployeeCode('10210361');
        Utils.generateDeptName(dept.Id);
        Utils.checkSubCorpManager('12457');
        Utils.checkSubCorpManager('10210006');
        Utils.userHasPermission(users[17].Id,'Approval_Managed__c');
        Utils.userHasPermission(users[15].Id,'Custom_Approval_Managed__c');
        Utils.ManualShareRecordToUsers(new Set<String>{users[15].Id},'Custom_Approval_Managed__c',cam.Id);
        Utils.getCAMApprovalName();
        Utils.getAMApprovalName();
        Utils.getAM1ApprovalName();
        Utils.getAM2ApprovalName();

        //StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        //mock.setStaticResource('TD_Department_Json');
        //mock.setStatusCode(200);
        //mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        //Test.setMock(SapSoapFunctions.class, mock);
	    Utils.postToSAP(SapQueryArgCreate.createSapOrganizationalQueryArgs());

        Test.stopTest();
    }
    static testMethod void test2() {
        TestAddCover.addCover1();
        TestAddCover.addCover2();
        TestAddCover.addCover3();
        TestAddCover.addCover4();
        TestAddCover.addCover5();
        TestAddCover.addCover6();
        TestAddCover.addCover7();
        TestAddCover.addCover8();
        TestAddCover.addCover9();
        TestAddCover.addCover10();
        TestAddCover.addCover11();
        TestAddCover.addCover12();
        TestAddCover.addCover13();
        TestAddCover.addCover14();
        TestAddCover.addCover15();
        TestAddCover.addCover16();

        Approval_Managed1__c am1 = new Approval_Managed1__c();
        am1.RecordTypeId = HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.VISITORHOSTS, 'Approval_Managed1__c');
        
        INSERT am1;

        Approval_Managed2__c am2 = new Approval_Managed2__c();
        am2.RecordTypeId = HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.SEV1_VENDORPERIODICASSESSMENT, 'Approval_Managed2__c');

        INSERT am2;
    }
}