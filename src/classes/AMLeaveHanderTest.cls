/**
*员工请假流程测试类
**/
@isTest
private class AMLeaveHanderTest {

    static testMethod void testhandler() {
        Test.startTest();
        RecordType rc = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Approval_Managed__c' AND  DeveloperName = 'Leave'];
        RecordType rcContact = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Contact' AND  DeveloperName = 'Staff'];
        Contact con = new Contact(LastName = '测试人员',number__c = '10210911', RecordTypeId=rcContact.Id);
        insert con;

        Approval_Managed__c am = new Approval_Managed__c();
        am.Applicant__c = con.Id;
        am.RecordTypeId = rc.Id;
        INSERT am;
        am.Applicant__c = con.Id;
        am.RecordTypeId = rc.Id;
        am.Is_Reset_Approvaler__c = true;
        UPDATE am;
        Test.stopTest();
    }

    static testMethod void testextension(){
        Test.startTest();
        RecordType rc = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Approval_Managed__c' AND  DeveloperName = 'Leave'];
        RecordType item = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Approval_Managed_Item__c' AND  DeveloperName = 'LeaveDetails'];
        RecordType rcContact = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Contact' AND DeveloperName = 'Staff'];
        Contact con = new Contact(LastName = '测试人员',number__c = '10210911', RecordTypeId=rcContact.Id);
        insert con;
        //创建流程查询SQL
        Id qId = Utils.getRecordTypeId('Metadata__c', 'Query_SQL');
        String str5 = '[{"Model_Group__c":"ALL","SQL_Short__c":null,"SQL_Long__c":"SELECT Id,RecordTypeId,SAPID__c,Name,Approval_Name__c,Applicant_Code__c,Dept_Name__c,Applicant_Name__c,Bill_Date__c,Applicant_Corp_Code__c,Approval_Status__c,Employee__c,Applicant_position__c,Annual_leave__c,Adjustable_vacation__c,Salary_Manager__c,Job_Title_Level__c ,Employee_Code__c,Sum_Vacation__c FROM Approval_Managed__c","Approval_Name__c":"Leave"}]';
        List<Metadata__c> sqls = (List<Metadata__c>)JSON.deserialize(str5,List<Metadata__c>.class);
        for(Metadata__c md : sqls){
            md.RecordTypeId = qId;
        }
        INSERT sqls;
        //配置文件数据创建

        Approval_Managed__c am = new Approval_Managed__c();
        am.Applicant__c = con.Id;
        am.RecordTypeId = rc.Id;
        insert am;
        am.Employee__c = con.Id;
        am.Annual_leave__c = '30';
        am.Adjustable_vacation__c = '30';
        upsert am;

        
        Approval_Managed_Item__c ami = new Approval_Managed_Item__c();
        ami.Leave_type__c = '0100';
        ami.Start_date__c = Date.newInstance(2017,09,01);
        ami.Start_Time__c = '000000';
        ami.End_date__c = Date.newInstance(2017,09,01);
        ami.End_Time__c = '083000';
        ami.RecordTypeId = item.Id;
        ami.LeaveManage__c = am.Id;
        ami.time_number__c = '25';


        Approval_Managed_Item__c ami2 = new Approval_Managed_Item__c();
        ami2.Leave_type__c = '1100';
        ami2.Start_date__c = Date.newInstance(2017,09,01);
        ami2.Start_Time__c = '000000';
        ami2.End_date__c = Date.newInstance(2017,09,01);
        ami2.End_Time__c = '083000';
        ami2.RecordTypeId = item.Id;
        ami2.LeaveManage__c = am.Id;
        ami2.time_number__c = '20';


        AMLeave extension = new AMLeave(new ApexPages.StandardController(am));
        WebServiceMockImpl wbi = new WebServiceMockImpl();
        wbi.returnJson = '{"status": "1", message": "信息获取成功", "approval": "VACATIONQUERY", "content": [{"main": {"employee_code__c": "10210911", "annual_leave__c": "24.5", "adjustable_vacation__c": "6.5"}, "details": ""}]}';
        Test.setMock(WebServiceMock.class, wbi);
        extension.queryVacation();
        extension.list1.add(ami);
        extension.list1.add(ami2);
        extension.save();
        extension.newlist1();
        extension.cancel();

        extension.deletelist1();


        Approval_Managed__c am2 = new Approval_Managed__c();
        AMLeave extension2 = new AMLeave(new ApexPages.StandardController(am2));
        extension2.save();

        Test.stopTest();
    }
}