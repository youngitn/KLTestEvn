/** 
* @author exia.huang
* @homepage http://salesforcexytools.com
*/
@isTest
private class SiteMainExtensionTest {

    /**
     * This is a test method for exit
     */
    static testMethod void test_exit() {

        // PageReference pageRef = Page.undefined;
        // Test.setCurrentPage(pageRef);
        // pageRef.getParameters().put('param1', 'param1');

        Test.startTest();

         // SiteMainExtension obj = new SiteMainExtension();
         //  PageReference result_exit = obj.exit();

        Test.stopTest();

        // Check
        // System.assert(ApexPages.hasMessages());
        // for(ApexPages.Message msg : ApexPages.getMessages()) {
        //     System.assertEquals('Upload file is NULL', msg.getSummary());
        //     System.assertEquals(ApexPages.Severity.ERROR, msg.getSeverity());
        // }
    }


    /**
     * This is a test method for isUserExist
     */
    static testMethod void test_isUserExist() {

        // PageReference pageRef = Page.undefined;
        // Test.setCurrentPage(pageRef);
        // pageRef.getParameters().put('param1', 'param1');

        Test.startTest();

        // PageReference result_isUserExist = SiteMainExtension.isUserExist();

        Test.stopTest();

        // Check
        // System.assert(ApexPages.hasMessages());
        // for(ApexPages.Message msg : ApexPages.getMessages()) {
        //     System.assertEquals('Upload file is NULL', msg.getSummary());
        //     System.assertEquals(ApexPages.Severity.ERROR, msg.getSeverity());
        // }
    }

   
    static testMethod void test_check() {

        // PageReference pageRef = Page.undefined;
        // Test.setCurrentPage(pageRef);
        // pageRef.getParameters().put('param1', 'param1');

        Test.startTest();

        // PageReference result_check = SiteMainExtension.check();

        Test.stopTest();

        // Check
        // System.assert(ApexPages.hasMessages());
        // for(ApexPages.Message msg : ApexPages.getMessages()) {
        //     System.assertEquals('Upload file is NULL', msg.getSummary());
        //     System.assertEquals(ApexPages.Severity.ERROR, msg.getSeverity());
        // }
    }

 static testMethod void test_test() {
    Test.startTest();
        System_Setting__c ss = new System_Setting__c();
        ss.Name = 'Setting';
        ss.URL_Customer__c = 'testURL';
        INSERT ss;
        SiteMainExtension site =  new SiteMainExtension();
        site.test();
   Test.stopTest();
 }

}