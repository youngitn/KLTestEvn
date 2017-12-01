@isTest
private class ApprovalsPendingControllerTest {
    static testMethod void testMethod1() {
        ApprovalsPendingController.runningInTestMode = true;
        ApprovalsPendingController.getPendingApprovals();

        ApprovalsPendingController ss = new ApprovalsPendingController();
        ss.lstPending = null;
    }
}