@isTest
private class AMAdvanceChargeExtensionTest {
    static testMethod void testSave() {

        Test.startTest();

        TestUtil.createBasicData();

        Approval_Managed__c am = TestUtil.createAdvanceCharge();

        AMAdvanceChargeExtension extension = new AMAdvanceChargeExtension(new ApexPages.StandardController(am));
        PageReference page = extension.save();
        System.debug(LoggingLevel.INFO, '*** page: ' + page);
        
        Test.stopTest();
    }
    static testMethod void testCreate() {
    	Test.startTest();

        TestUtil.createBasicData();
        Approval_Managed__c am = TestUtil.createAdvanceCharge();
        AMAdvanceChargeExtension extension = new AMAdvanceChargeExtension(new ApexPages.StandardController(am));
        //测试异常插入
        extension.am.Dept_of_CostCenter__c = 'A';
        extension.save();
        extension.cancel();

        Test.stopTest();
    }
}