/**
	目的：销售订单审批流程测试类
	作者：Lily
	创建时间：2017-06-05
**/
@isTest
private class AMSaleOrderExtensionTest {
    static testMethod void test1() {
        Test.startTest();

        TestUtil.createBasicData();
        
        Custom_Approval_Managed__c am = new Custom_Approval_Managed__c();
        AMSaleOrderExtension extension = new AMSaleOrderExtension(new ApexPages.StandardController(am));

        am = TestUtil.createSaleOrder();
        extension = new AMSaleOrderExtension(new ApexPages.StandardController(am));
        extension.save();
        extension.cancel();
        extension.newlist1();
        extension.deletelist1();
        extension.newlist2();
        extension.deletelist2();
        extension.newlist3();
        extension.deletelist3();
        Test.stopTest();
    }
}