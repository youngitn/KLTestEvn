@isTest
private class SyncFromSfToSapScheduleTest {
    static testMethod void test1() {
    	Test.startTest();

    	TestUtil.createBasicData();
    	SyncFromSfToSapSchedule sc = new SyncFromSfToSapSchedule();
    	Custom_Approval_Managed__c cam = TestUtil.createCustomerData();

    	Utils.addToSendQueue(SapApprovalEnum.CUSTOMER, cam.Id, '新建');
    	Utils.addToSendQueue(SapApprovalEnum.VENDOR, cam.Id, '新建');
    	Utils.addToSendQueue(SapApprovalEnum.COSTCENTERSEND, cam.Id, '新建');
    	Utils.addToSendQueue(SapApprovalEnum.EXPENSEREIMBURSE, cam.Id, '新建');
    	Utils.addToSendQueue(SapApprovalEnum.ASSETPURCHASE, cam.Id, '新建');
        Utils.addToSendQueue(SapApprovalEnum.LEAVE, cam.Id, '新建');
        WebServiceMockImpl mock = new WebServiceMockImpl();
    	mock.returnJson = '{"SFID": "' + cam.Id + '","SAPID": "10000","status": "1","message": "调用成功"}';
        Test.setMock(SapWebServiceReturnResult.class, mock);
        sc.execute(null);
        //sc.updateCostCenterSendVoucherCode(cam.Id, String voucherCode);
        Test.stopTest();
    }
    
    static testMethod void test2() {
    	Test.startTest();

    	TestUtil.createBasicData();
    	Custom_Approval_Managed__c cam = TestUtil.createCustomerData();
    	Utils.addToSendQueue(SapApprovalEnum.ABNORMALQUALITY, cam.Id, '新建');
    	Utils.addToSendQueue(SapApprovalEnum.ADVANCECHARGE, cam.Id, '新建');
    	Utils.addToSendQueue(SapApprovalEnum.BUSINESSTRAVEL, cam.Id, '新建');
    	Utils.addToSendQueue(SapApprovalEnum.PURCHASEINFORMATION, cam.Id, '新建');
    	Utils.addToSendQueue(SapApprovalEnum.PURCHASEORDER, cam.Id, '新建');
        SyncFromSfToSapSchedule sc = new SyncFromSfToSapSchedule();
        //WebServiceMockImpl mock = new WebServiceMockImpl();
        //mock.returnJson = '{"SFID": "' + cam.Id + '","SAPID": "10000","status": "0","message": "调用失败"}';
        //Test.setMock(WebServiceMock.class, mock);
        sc.execute(null);

        Test.stopTest();
    }
    static testMethod void test3() {
    	Test.startTest();

    	TestUtil.createBasicData();
    	Custom_Approval_Managed__c cam = TestUtil.createCustomerData();

    	Utils.addToSendQueue(SapApprovalEnum.STAFFTRANSFER, cam.Id, '新建');
    	Utils.addToSendQueue(SapApprovalEnum.STAFFLEAVEOFFICE, cam.Id, '新建');
    	Utils.addToSendQueue(SapApprovalEnum.SALEORDER, cam.Id, '新建');
    	Utils.addToSendQueue(SapApprovalEnum.RFQ, cam.Id, '新建');
    	Utils.addToSendQueue(SapApprovalEnum.WASTEDISPOSE, cam.Id, '新建');
        SyncFromSfToSapSchedule sc = new SyncFromSfToSapSchedule();
        //WebServiceMockImpl mock = new WebServiceMockImpl();
    	//mock.returnJson = '{"SFID": "' + cam.Id + '","SAPID": "10000","status": "1","message": "调用成功"}';
        //Test.setMock(WebServiceMock.class, mock);
        //sc.execute(null);
        //mock.returnJson = '{"SFID": "' + cam.Id + '","SAPID": "10000","status": "0","message": "调用失败"}';
        //Test.setMock(WebServiceMock.class, mock);
        //sc.execute(null);

        Test.stopTest();
    }
    
}