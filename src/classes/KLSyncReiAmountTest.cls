@isTest
private class KLSyncReiAmountTest {
    static testMethod void testMethod1() {
        
        Test.startTest();
        KLSyncReiAmountReturn aa = new KLSyncReiAmountReturn();
        KLSyncReiAmount.doPost('10210224', '2017-06');
        Test.stopTest();
    }
}