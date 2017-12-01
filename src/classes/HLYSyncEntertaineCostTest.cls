/**
* @author exia.huang
* @homepage http://salesforcexytools.com
*/
@isTest
private class HLYSyncEntertaineCostTest {

    /**
     * This is a test method for doPost
     */
    static testMethod void test_doPost() {

        Test.startTest();

        TestUtil.createBasicData();
        TestUtil.createEntertaineCost();
        TestUtil.createEntertaineCost2();
        
        Test.stopTest();
    }
}