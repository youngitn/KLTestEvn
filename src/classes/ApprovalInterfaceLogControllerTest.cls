@isTest
private class ApprovalInterfaceLogControllerTest {
    static testMethod void test1() {
    	Test.startTest();

    	TestUtil.createBasicData();
    	Utils.addToSendQueue(SapApprovalEnum.CUSTOMER, '15555154511', '新建');
        Utils.addToSyncQueue(SapApprovalEnum.CUSTOMER,'1000001',false,'同步失败');
        Utils.addToSendQueue(SapApprovalEnum.VENDOR, '15555154511', '新建');
        Utils.addToSyncQueue(SapApprovalEnum.EXPENSEREIMBURSE,'1000001',false,'同步失败');
        Utils.addToSyncQueue(SapApprovalEnum.EXPENSEREIMBURSE,'1000001',false,'同步失败');

        ApprovalInterfaceLogController ext = new ApprovalInterfaceLogController();
        ext.meta = new Metadata__c();
        ext.startDate = '2016-01-01 12:00:00';
        ext.endDate = '2017-12-31 23:59:59';
        ext.successed = 'false';
        ext.meta.ApprovalID__c = 'a01O000000m0oG3IA';
        ext.meta.Approval_Name__c = SapApprovalEnum.EXPENSEREIMBURSE;
        ext.meta.Send_Direction__c = 'SF_TO_SAP';
        ext.QueryInterface();

        ext.meta.ApprovalID__c = null;
        ext.meta.Approval_Name__c = null;
        ext.startDate = '2016-01-01 DDD';
        ext.QueryInterface();

        ext.startDate = '2016-01-01 00:00:00';
        ext.endDate = '2017-12-31 DDD';
        ext.QueryInterface();

        ext.PrevPage();
        ext.NextPage();
        ext.pageCurr = 2;
        ext.GotoPage();
        
        ApprovalInterfaceLogController.reSyncData('123','10000001','SF_TO_SAP');
        ApprovalInterfaceLogController.reSyncData('123','10000001','SAP_TO_SF');
        Test.stopTest();
    }
}