/**
* 
*/
@isTest
private class SapInputArgCreateTest {

    static testMethod void test1() { 

        Test.startTest();

        TestUtil.createBasicData();
        //测试createSapProfileInputArgs方法
        SapInputArgCreate.createSapProfileInputArgs();
        //测试createSapRoleInputArgs方法
        SapInputArgCreate.createSapRoleInputArgs();

        //客户主数据
        Custom_Approval_Managed__c cam = TestUtil.createCustomerData();
        SapInputArgCreate.createSapCustomerInputArgs(cam.Id);

        Test.stopTest();
    }
    static testMethod void test2() { 
        Test.startTest();

        TestUtil.createBasicData();
        //出差：TA00011731
        TestUtil.createBusinessTravel();
        //交际：EA10007155
        TestUtil.createEntertaineCost();
        //费用报销 ER10008001
        TestUtil.createExpenseReimburse();

        //员工出差
        List<CustoM_Approval_Managed__c> camlist = [SELECT Id FROM CustoM_Approval_Managed__c WHERE SAPID__c = 'TA00011731'];
        if(camlist.size() > 0){
            SapInputArgCreate.createSapBusinessTravelInputArgs(camlist[0].Id);
        }
        Test.stopTest();
    }
    static testMethod void test3() {
        Test.startTest();

        TestUtil.createBasicData();
        //预付款申请单
        Approval_Managed__c ac = TestUtil.createAdvanceCharge();
        SapInputArgCreate.createSapAdvanceChargeInputArgs(ac.Id);

        //员工异动
        Approval_Managed__c st = TestUtil.createStaffTransfer();
        SapInputArgCreate.createSapStaffTransferInputArgs(st.Id);

        //供应商
        Custom_Approval_Managed__c cam = TestUtil.createVendorData();
        SapInputArgCreate.createSapVendorInputArgs(cam.Id);

        Test.stopTest();
    }
    static testMethod void test4() {
        Test.startTest();

        TestUtil.createBasicData();
        //品质异常单
        Approval_Managed__c am1 = TestUtil.createAbnormalQuality();
        SapInputArgCreate.createSapAbnormalQualityInputArgs(am1.Id);
        //采购信息记录
        Custom_Approval_Managed__c cam = TestUtil.createPurchaseInformation();
        SapInputArgCreate.createSapPurchaseInformationInputArgs(cam.Id);

        Test.stopTest();
    }
    static testMethod void test5() {
        Test.startTest();

        TestUtil.createBasicData();
        //销售订单
        Custom_Approval_Managed__c cam1 = TestUtil.createSaleOrder();
        SapInputArgCreate.createSapSaleOrderInputArgs(cam1.Id);
        //费料处理
        Custom_Approval_Managed__c cam2 = TestUtil.createWasteDispose();
        SapInputArgCreate.createSapWasteDisposeInputArgs(cam2.Id);

        Test.stopTest();
    }
    static testMethod void test6() {
        Test.startTest();

        TestUtil.createBasicData();
        //资产购置流程
        Approval_Managed__c am1 = TestUtil.createAssetPurchase();
        SapInputArgCreate.createSapAssetPurchaseInputArgs(am1.Id);

        Test.stopTest();
    }
    static testMethod void test7() { 
        Test.startTest();

        TestUtil.createBasicData();
        //出差：TA00011731
        TestUtil.createBusinessTravel();
        //交际：EA10007155
        TestUtil.createEntertaineCost();
        //费用报销 ER10008001
        TestUtil.createExpenseReimburse();

        //费用报销
        List<Approval_Managed__c> amList = [SELECT Id FROM Approval_Managed__c WHERE SAPID__c = 'ER10008001'];
        if(amlist.size() > 0){
            SapInputArgCreate.createSapExpenseReimburseInputArgs(amlist[0].Id);
        }

        Test.stopTest();
    }
    static testMethod void test8() {
 
        //TestUtil.createBasicData();
        //成本中心发料作业
        //Custom_Approval_Managed__c cam3 = TestUtil.createCostCenterSend();
        //SapInputArgCreate.createSapCostCenterSendInputArgs(cam3.Id);

    }
    static testMethod void test9() {
        Test.startTest();

        TestUtil.createBasicData();

        //标准采购订单
        Approval_Managed__c am2 = TestUtil.createPurchaseOrder();
        SapInputArgCreate.createSapPurchaseOrderInputArgs(am2.Id);

        Test.stopTest();
    }
    static testMethod void test10() {
        Test.startTest();

        TestUtil.createBasicData();

        //员工主动离职
        Approval_Managed__c am2 = TestUtil.createStaffLeaveOffice();
        SapInputArgCreate.createSapStaffLeaveOfficeInputArgs(am2.Id);

        Test.stopTest();
    }
    static testMethod void test11() {
        Test.startTest();
        TestUtil.createBasicData();

        //员工请假
        Approval_Managed__c amleave = TestUtil.createAmleave();
        SapInputArgCreate.createSapAmleaveInputArgs(amleave.Id);

        Test.stopTest();
    }
    static testMethod void test12() {
        Test.startTest();

        TestUtil.createBasicData();

        //标准采购订单
        Approval_Managed__c amc = TestUtil.createPurchaseOrder();
        SapInputArgCreate.createSapPurchaseOrderInputArgs(amc.Id);

        Test.stopTest();
    }

    
}