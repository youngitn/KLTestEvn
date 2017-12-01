@isTest
private class AMAssetPurchaseExtensionTest {
    static testMethod void testSave() {
        Test.startTest();

        TestUtil.createBasicData();
        Approval_Managed__c am = TestUtil.createAssetPurchase();

        AMAssetPurchaseExtension extension = new AMAssetPurchaseExtension(new ApexPages.StandardController(am));
        PageReference page = extension.save();
        System.debug(LoggingLevel.INFO, '*** page: ' + page);
        System.assertEquals('/'+am.Id, page.getUrl());

        Test.stopTest();

    }
    static testMethod void testCreate() {
    	Test.startTest();

        TestUtil.createBasicData();
        Approval_Managed__c am = TestUtil.createAssetPurchase();
        AMAssetPurchaseExtension extension = new AMAssetPurchaseExtension(new ApexPages.StandardController(am));
        //测试异常插入
        extension.am.Dept_of_CostCenter__c = 'A';
        extension.save();
        extension.cancel();

        Test.stopTest();
    }
    static testMethod void testUpdate1() {
        Test.startTest();

        TestUtil.createBasicData();
        TestUtil.createAssetPurchase2();

        Test.stopTest();
    }
    static testMethod void testUpdate2() {
        Test.startTest();

        TestUtil.createBasicData();
        TestUtil.createAssetPurchase3();

        Test.stopTest();
    }
}