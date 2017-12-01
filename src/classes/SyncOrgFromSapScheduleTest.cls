@isTest
private class SyncOrgFromSapScheduleTest {
    static testMethod void test1() {
    	Test.startTest();

    	TestUtil.createBasicData();
    	SyncOrgFromSapSchedule sc = new SyncOrgFromSapSchedule();
        sc.execute(null);

        Test.stopTest();
    }
}