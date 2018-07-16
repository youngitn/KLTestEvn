@isTest
private class AMItProgressTest {


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

      

        INSERT tcapp;

        //流程审批1
        rc = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Approval_Managed1__c' AND  DeveloperName = 'IRS_InformationService'];
        Approval_Managed1__c app1 = new Approval_Managed1__c();
        app1.RecordTypeId = rc.Id;
        app1.Applicant__c = con.Id;
        app1.Approval_Status__c = 'A';

        INSERT app1;

        //QUERY查询方法1
        AMItProgress am = new AMItProgress();
        
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