/**
* @author exia.huang
* @homepage http://salesforcexytools.com
*/
@isTest
private class HLYSyncExpenseReimburseTest {

    /**
     * This is a test method for doPost
     */
    static testMethod void test_doPost() {


        Test.startTest();

        TestUtil.createBasicData();
        //出差：TA00011731
        TestUtil.createBusinessTravel();
        //交际：EA10007155
        TestUtil.createEntertaineCost();
        //TestUtil.createEntertaineCost2();
        //费用报销 ER10008001
        TestUtil.createExpenseReimburse();
        TestUtil.createExpenseReimburse2();

        Test.stopTest();

    }

}