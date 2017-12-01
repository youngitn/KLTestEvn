@isTest
private class ApprovalHomeControllerTest {
    static testMethod void test1() {
        Test.startTest();

        TestUtil.createBasicData();
        
        ApprovalHomeController ext = new ApprovalHomeController();
        ext.selectedApprovalName = '测试名称';
        ext.selectedApprovalValue = '';
        ext.UpdateApprovalData();
        ext.selectedApprovalValue = SapApprovalEnum.CUSTOMER;
        ext.UpdateApprovalData();
        ext.selectedApprovalValue = SapApprovalEnum.STAFFTRANSFER;
        ext.UpdateApprovalData();
        ext.selectedApprovalValue = SapApprovalEnum.VISITORHOSTS;
        ext.UpdateApprovalData();
        ext.selectedApprovalValue = SapApprovalEnum.INVENTORYAPPLICATION;
        ext.UpdateApprovalData();

        ext.PrevPage();
        ext.NextPage();
        ext.pageCurr = 2;
        ext.GotoPage();

        ext.selectedApprovalValue = SapApprovalEnum.CUSTOMER;
        ext.CreateNewApproval();
        ext.selectedApprovalValue = SapApprovalEnum.VENDOR;
        ext.CreateNewApproval();
        ext.selectedApprovalValue = SapApprovalEnum.COSTCENTERSEND;
        ext.CreateNewApproval();
        ext.selectedApprovalValue = SapApprovalEnum.WASTEDISPOSE;
        ext.CreateNewApproval();
        ext.selectedApprovalValue = SapApprovalEnum.STAFFTRANSFER;
        ext.CreateNewApproval();
        ext.selectedApprovalValue = SapApprovalEnum.STAFFLEAVEOFFICE;
        ext.CreateNewApproval();
        ext.selectedApprovalValue = SapApprovalEnum.ASSETPURCHASE;
        ext.CreateNewApproval();
        ext.selectedApprovalValue = SapApprovalEnum.ADVANCECHARGE;
        ext.CreateNewApproval();
        ext.selectedApprovalValue = SapApprovalEnum.RFQ;
        ext.CreateNewApproval();
        ext.selectedApprovalValue = SapApprovalEnum.IRS_INFORMATIONSERVICE;
        ext.CreateNewApproval();
        ext.selectedApprovalValue = SapApprovalEnum.INTERNALMEMO;
        ext.CreateNewApproval();
        ext.selectedApprovalValue = SapApprovalEnum.VISITORHOSTS;
        ext.CreateNewApproval();
        ext.selectedApprovalValue = SapApprovalEnum.PURCHASEINFORMATION;
        ext.CreateNewApproval();
        ext.selectedApprovalValue = SapApprovalEnum.EXPENSEREIMBURSE;
        ext.CreateNewApproval();

        Test.stopTest();
    }
}