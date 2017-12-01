/**
* @author exia.huang
* @homepage http://salesforcexytools.com
*/
@isTest
private class HLYSyncBusinessTravelTest {

    /**
     * This is a test method for doPost
     */
    static testMethod void test_doPost() {

        Test.startTest();

        TestUtil.createBasicData();
        TestUtil.createBusinessTravel();
        TestUtil.createBusinessTravel2();

        Test.stopTest();
    }
}