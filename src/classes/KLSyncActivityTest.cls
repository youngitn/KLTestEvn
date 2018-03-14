@isTest
private class KLSyncActivityTest {
    static testMethod void testMethod1() {
        Test.startTest();
        KLSyncActivity ka=new KLSyncActivity();
        KLSyncActivity.doPost('1');
        Test.stopTest();
    }
}