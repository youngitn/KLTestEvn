@isTest()
private class ApprovalReassignShareScheduleTest {
    static testMethod void testMethod1() {
    	ApprovalReassignShareSchedule.isTestMode = true;
    	string szdate = '0 0 0 3 9 ? 2022';
         String jobId = System.schedule('testBasicScheduledApex',szdate,new ApprovalReassignShareSchedule());
    }
}