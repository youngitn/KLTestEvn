/**
* @author exia.huang
* @homepage http://salesforcexytools.com
*/
@isTest
private class ContactControllerTest {

    /**
     * This is a test method for findAll
     */
    static testMethod void test_findAll() {

        // PageReference pageRef = Page.undefined;
        // Test.setCurrentPage(pageRef);
        // pageRef.getParameters().put('param1', 'param1');

        Test.startTest();

        // LIST result_findAll = ContactController.findAll();

        Test.stopTest();

        // Check
        // System.assert(ApexPages.hasMessages());
        // for(ApexPages.Message msg : ApexPages.getMessages()) {
        //     System.assertEquals('Upload file is NULL', msg.getSummary());
        //     System.assertEquals(ApexPages.Severity.ERROR, msg.getSeverity());
        // }
    }


    /**
     * This is a test method for findByName
     */
    static testMethod void test_findByName() {

        // PageReference pageRef = Page.undefined;
        // Test.setCurrentPage(pageRef);
        // pageRef.getParameters().put('param1', 'param1');

        Test.startTest();

        // String name;
        // LIST result_findByName = ContactController.findByName(name);

        Test.stopTest();

        // Check
        // System.assert(ApexPages.hasMessages());
        // for(ApexPages.Message msg : ApexPages.getMessages()) {
        //     System.assertEquals('Upload file is NULL', msg.getSummary());
        //     System.assertEquals(ApexPages.Severity.ERROR, msg.getSeverity());
        // }
    }

}