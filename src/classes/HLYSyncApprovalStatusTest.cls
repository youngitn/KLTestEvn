@isTest
private class HLYSyncApprovalStatusTest {

    static testMethod void test_doPost() {


        Test.startTest();
        TestUtil.createBasicData();
        RecordType rc = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Approval_Managed__c' AND  DeveloperName = 'ExpenseReimburse'];
        Contact con = new Contact(LastName = '测试人员',number__c = '123');
        insert con;
         //配置文件数据创建
        System_Setting__c ssc = new System_Setting__c();
        ssc.Name = 'Setting';
        ssc.Can_Create_ExpenseReimburse__c = '01';
        INSERT ssc;

        Approval_Managed__c approve = new Approval_Managed__c();
        approve.RecordTypeId = rc.Id;
        approve.Applicant__c = con.Id;
        approve.Expense_Type_Cost__c = '01';
        approve.Employee__c = con.id;
        approve.Is_HLY_ExpenseReimburse__c = true;
        INSERT approve;

            //自动提交数据待审批
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setObjectId(approve.Id);
            req.setComments('SAP同步数据，系统自动提交，等待审批!');
            Approval.ProcessResult result = Approval.process(req);
            if(!result.isSuccess()){
                System.debug('*** 自动提交品质异常单审批出错(出差)：' + result.getErrors());
            }

        String action ='QUERY';
        String data_type ='APPROVAL';
        String begin_date ='2016-01-01 1:00:00';
        String end_date ='2017-10-21 1:00:00';
        String pagenum ='1';
        String pagesize ='10000';
        String fetchall ='false';

        HLYSyncApprovalStatus.MainInfo main = new HLYSyncApprovalStatus.MainInfo();
        main = HLYSyncApprovalStatus.doPost(action , data_type , begin_date , end_date  , pagenum , pagesize , fetchall);
        System.debug(LoggingLevel.INFO , '*** : ' + main);

        Test.stopTest();
    }

}