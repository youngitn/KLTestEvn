/*@isTest
private class AMChangeJobsTest {
    static testMethod void testHandler() {
    	 Test.startTest();
         //添加员工
        RecordType rc = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Custom_Approval_Managed1__c' AND  DeveloperName = :SapApprovalEnum.CHANGEJOBS];
        RecordType rcContact = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Contact' AND  DeveloperName = 'Staff'];
        Contact con = new Contact(LastName = '测试人员',number__c = '10210911', RecordTypeId=rcContact.Id);
        insert con;

        Approval_Managed1__c am = new Approval_Managed1__c();
        am.Applicant__c = con.Id;
        am.RecordTypeId = rc.Id;
        INSERT am;
        am.Applicant__c = con.Id;
        am.RecordTypeId = rc.Id;
        am.Is_Reset_Approvaler__c = true;
        UPDATE am;
        Test.stopTest();        

    }

    static testMethod void testExtension() {
    	Test.startTest();


        RecordType rc = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Approval_Managed1__c' AND  DeveloperName = :SapApprovalEnum.CHANGEJOBS ];  
        RecordType rcContact = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Contact' AND DeveloperName = 'changejobs'];
        Contact con = new Contact(LastName = '测试人员',number__c = '10210911', RecordTypeId=rcContact.Id);
        insert con;

        //创建流程查询SQL
        Id qId = Utils.getRecordTypeId('Metadata__c', 'Query_SQL');
        String str = '[{"Model_Group__c":"ALL","SQL_Short__c":null,"SQL_Long__c":"SELECT Id,RecordTypeId,SAPID__c,Name,Approval_Name__c,Applicant_Name__c,Dept_Name__c,Applicant_Code__c,Applicant_Corp_Code__c,Bill_Date__c,Status__c,SchedulingInstructions__c,Remark__c FROM Approval_Managed1__c","Approval_Name__c":"CREWSCHEDULING"}]';
        List<Metadata__c> sqls = (List<Metadata__c>)JSON.deserialize(str,List<Metadata__c>.class);
        for(Metadata__c md : sqls){
            md.RecordTypeId = qId;
        }

        INSERT sqls;

        //配置文件数据创建 
        Approval_Managed1__c am = new Approval_Managed1__c();
        am.RecordTypeId = rc.Id;

        am.SchedulingInstructions__c = 'asfda';
        am.Remark__c = 'sdgfdsg';
        INSERT am;



        am.SchedulingInstructions__c = 'aghfa';
        am.Remark__c = 'ssfsfg';
        UPDATE am;

        AMChangeJobsExtension extension = new AMChangeJobsExtension(new ApexPages.StandardController(am));
        extension.save();
        extension.cancel();
      


        Test.stopTest();        

    }*/






@isTest
private class AMChangeJobsTest {
    static testMethod void testMethod1() {
        RecordType rc = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Approval_Managed1__c' AND  DeveloperName = 'changejobs'];
         //createApprovalconfig(26,'MeasuringInstRequest');
         Approval_Managed1__c cusApprove = new Approval_Managed1__c();
         cusApprove.RecordTypeId = rc.Id;
         cusApprove.Factory__c = '1000';

         INSERT cusApprove;
         AMChangeJobsExtension amIt = new AMChangeJobsExtension(new ApexPages.StandardController(cusApprove));
            cusApprove.Factory__c = '1000';
            //amIt.isDeletedStatus = true;
            amIt.save();
            amIt.cancel();

        test.startTest();
        cusApprove.add_overclass_deapart__c = 'Y';
        cusApprove.job_add_cancel__c = true;
        cusApprove.change_explain__c = '133';
        /*cusApprove.die_use_bu__c='BU1';
        cusApprove.Material_Number__c='123';
        cusApprove.Dept_of_CostCenter__c='1000E001';
        cusApprove.Factory__c='1000';
        cusApprove.Modify_description__c='888';*/
        Update cusApprove;

        

        test.stopTest();
    }

    static testMethod void testhandler() {
        Test.startTest();
        RecordType rc = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Approval_Managed1__c' AND  DeveloperName = 'changejobs'];
        RecordType rcContact = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Contact' AND  DeveloperName = 'Staff'];
        Contact con = new Contact(LastName = '测试人员',number__c = '10210911', RecordTypeId=rcContact.Id);
        insert con;

        Approval_Managed1__c am = new Approval_Managed1__c();
        am.Applicant__c = con.Id;
        am.RecordTypeId = rc.Id;
        INSERT am;
        am.Applicant__c = con.Id;
        am.RecordTypeId = rc.Id;
        am.Is_Reset_Approvaler__c = true;
        UPDATE am;
        Test.stopTest();
    }
}