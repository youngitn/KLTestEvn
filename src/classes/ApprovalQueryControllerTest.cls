@isTest
private class ApprovalQueryControllerTest {
    /*
    static testMethod void test1() {
        Test.startTest();
      Profile p = [SELECT Id FROM Profile WHERE Name='员工']; 
      User u = new User(Alias = 'tesss', Email='standarduser1@testorg.com', 
      EmailEncodingKey='UTF-8', LastName='testaname', LanguageLocaleKey='en_US', 
      LocaleSidKey='en_US', ProfileId = p.Id, 
      TimeZoneSidKey='America/Los_Angeles', UserName='sss@sa.com');
      Contact con = new Contact(LastName = 'li');
      con.RecordTypeId = HarryUtils.getRecordTypeIdByDevNameAndObjName('Staff', 'Contact');
      insert con;
      Metadata__c tmeta = new Metadata__c(Model_Group__c = 'QM',Approval_Name__c = 'AbnormalQuality',Approver__c = '丁');
       Approval_Managed__c sapproval = new Approval_Managed__c();
       sapproval.Applicant__c = con.Id;
       sapproval.SAPID__c = 'sss';

        system.runAs(u){
            ApprovalQueryController am = new ApprovalQueryController();
            am.meta = tmeta;
            am.standardApproval = sapproval;
            am.selectedStatusValue = 'D';
            am.selectedModelGroupValue = 'aa';
            am.selectedApprovalName = 'customer';
            am.selectedApprovalStartTime = '1970-01-01';
            am.selectedApprovalEndTime = '4000-01-01';
            am.query();
        }
         Test.stopTest();
    }
    static testMethod void test2() {
        test.startTest();
        testutil.createBasicData();
        TestUtil.createCustomerData();
        TestUtil.createStaffTransfer();
        Approval_Managed1__c am1 = new Approval_Managed1__c();
        am1.Bill_Date__c = Date.today();
        insert am1;
        ApprovalQueryController am = new ApprovalQueryController();
        am.selectedApprovalStartTime = '1970-01-01';
        am.selectedApprovalEndTime = '2017-07-01';
        am.query();
        test.stopTest();
    }
    */

    static testMethod void testdp() {
        test.startTest();
        //联系人
        Contact con = new Contact(LastName = '测试人员',number__c = '123');
        insert con;

       //标准审批对象
        RecordType rc = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Approval_Managed__c' AND  DeveloperName = 'AdvanceCharge'];
        Approval_Managed__c app = new Approval_Managed__c();
        app.RecordTypeId = rc.Id;
        app.Applicant__c = con.Id;
        app.Approval_Status__c = 'D';
        app.Same_Sample__c = 'ac';
        app.SAPID__c = 'TST';
        app.Is_Print__c = true;
        INSERT app;

        //自定义审批对象 
        rc = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Custom_Approval_Managed__c' AND  DeveloperName = 'Vendor'];
        List<Custom_Approval_Managed__c> tcapp = new List<Custom_Approval_Managed__c>();
        Custom_Approval_Managed__c capp = new Custom_Approval_Managed__c();
        capp.RecordTypeId = rc.Id;
        capp.Applicant__c = con.Id;
        capp.Approval_Status__c = 'S';
        tcapp.add(capp);

        Custom_Approval_Managed__c capp2 = new Custom_Approval_Managed__c();
        capp2.RecordTypeId = rc.Id;
        capp2.Applicant__c = con.Id;
        capp2.Approval_Status__c = 'R';
        tcapp.add(capp2);

        INSERT tcapp;

        //流程审批1
        rc = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Approval_Managed1__c' AND  DeveloperName = 'IRS_InformationService'];
        Approval_Managed1__c app1 = new Approval_Managed1__c();
        app1.RecordTypeId = rc.Id;
        app1.Applicant__c = con.Id;
        app1.Approval_Status__c = 'A';
        INSERT app1;

        //QUERY查询方法1
        ApprovalQueryController am = new ApprovalQueryController();
        am.selectedApprovalStartTime = '1970-01-01';
        am.selectedApprovalEndTime = '2019-07-01';
        am.query();


        am.standardApproval = app;
        am.selectedStatusValue = 'D';
        am.selectedModelGroupValue = 'aa';
        am.selectedApprovalName = 'customer';
        am.selectedApprovalStartTime = '1970-01-01';
        am.selectedApprovalValue = '12';
        am.query();

        test.stopTest();
    }

}