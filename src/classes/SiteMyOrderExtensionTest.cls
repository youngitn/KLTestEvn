/**
* @author exia.huang
* @homepage http://salesforcexytools.com
*/
@isTest
private class SiteMyOrderExtensionTest {

    /**
     * This is a test method for queryCustomerOrder
     */
    static testMethod void test_queryCustomerOrder() {

        System_Setting__c ssc = new System_Setting__c();
        ssc.Name = 'Setting';
        ssc.URL_Customer__c = '/apex';
        INSERT ssc;

        PageReference pageRef = new PageReference(ssc.URL_Customer__c + '/sitetakeorder');
        Cookie un = new Cookie('apex__un', '0001009030', null, 7200, false);
        Cookie pw = new Cookie('apex__pw', 'customer', null, 7200, false);
        pageRef.setCookies(new Cookie[] {un,pw});
        pageRef.getParameters().put('language', 'zh_CN');
        pageRef.getParameters().put('typeCV', 'customer');
        SiteMyOrderExtension soe = new SiteMyOrderExtension();
        soe.Check();
/*
        Test.startTest();

        String customerCode = '0001009030';
        String orderStatus = '';
        String orderCode = '';
        String createdDate = '2017-01-01';
        String deliveryDate = '2019-12-31';
        Object result_queryCustomerOrder = SiteMyOrderExtension.queryCustomerOrder(customerCode , orderStatus , orderCode , createdDate , deliveryDate);

        Test.stopTest();*/

    }


    /**
     * This is a test method for queryOderDetail
     */
    static testMethod void test_queryOderDetail() {

        // PageReference pageRef = Page.undefined;
        // Test.setCurrentPage(pageRef);
        // pageRef.getParameters().put('param1', 'param1');

        Test.startTest();

        // String orderId;
        // Object result_queryOderDetail = SiteMyOrderExtension.queryOderDetail(orderId);

        Test.stopTest();

        // Check
        // System.assert(ApexPages.hasMessages());
        // for(ApexPages.Message msg : ApexPages.getMessages()) {
        //     System.assertEquals('Upload file is NULL', msg.getSummary());
        //     System.assertEquals(ApexPages.Severity.ERROR, msg.getSeverity());
        // }
    }


    /**
     * This is a test method for querySelfOrder
     */
    static testMethod void test_querySelfOrder() {

        // PageReference pageRef = Page.undefined;
        // Test.setCurrentPage(pageRef);
        // pageRef.getParameters().put('param1', 'param1');

        Test.startTest();

        // String usernameCode;
        // Object result_querySelfOrder = SiteMyOrderExtension.querySelfOrder(usernameCode);

        Test.stopTest();

        // Check
        // System.assert(ApexPages.hasMessages());
        // for(ApexPages.Message msg : ApexPages.getMessages()) {
        //     System.assertEquals('Upload file is NULL', msg.getSummary());
        //     System.assertEquals(ApexPages.Severity.ERROR, msg.getSeverity());
        // }
    }


    /**
     * This is a test method for queryBill
     */
    static testMethod void test_queryBill() {

        // PageReference pageRef = Page.undefined;
        // Test.setCurrentPage(pageRef);
        // pageRef.getParameters().put('param1', 'param1');

        Test.startTest();

        // String customercode;
        // Boolean hasBeenInvoiced;
        // Boolean notInvoiced;
        // Boolean prepayment;
        // Object result_queryBill = SiteMyOrderExtension.queryBill(customercode , hasBeenInvoiced , notInvoiced , prepayment);

        Test.stopTest();

        // Check
        // System.assert(ApexPages.hasMessages());
        // for(ApexPages.Message msg : ApexPages.getMessages()) {
        //     System.assertEquals('Upload file is NULL', msg.getSummary());
        //     System.assertEquals(ApexPages.Severity.ERROR, msg.getSeverity());
        // }
    }

}