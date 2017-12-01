/**
    目的：测试员工主动离职流程的Extension
    作者：Lily
    创建时间：2017-05-27
**/
@isTest
private class AMStaffLeaveOfficeExtensionTest {
    /*
        测试新增员工主动离职申请流程
    */
    static testMethod void testInsertApprove() {
                Test.startTest();
       RecordType rc = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Approval_Managed__c' AND  DeveloperName = 'StaffLeaveOffice'];
       RecordType rcContact = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Contact' AND  DeveloperName = 'Staff'];
        Contact con = new Contact(LastName = '测试人员',number__c = '123', RecordTypeId=rcContact.Id);
        insert con;
        //创建流程查询SQL
        Id qId = Utils.getRecordTypeId('Metadata__c', 'Query_SQL');
        String str5 = '[{"Model_Group__c":"ALL","SQL_Short__c":null,"SQL_Long__c":"SELECT Id,RecordTypeId,SAPID__c,Name,Dept_Name__c,Approval_Name__c,Status__c,Applicant__c,Applicant_Code__c,Applicant_Name__c,Bill_Date__c,Factory__c,Dept_of_CostCenter__c,Required_date__c,Asset_Type__c,Asset_Name__c,Model_and_Spec__c,Asset_Code_Inner__c,Asset_Code__c,Asset_Code_Official__c,Stock_Note__c,Responsible_CostCenter__c,Place__c,Amount_of_Budget__c,Currcency_Budget__c,Quantity__c,Amount_of_Paid__c,Amount_of_Forecast__c,Material_Number__c,Work_Center__c,Keeper_Reserved__c,Capital_Order__c,REQ_Code__c,Reason_of_Purchase__c,Result_Effect_Current_Period__c,Is_Budgeted__c,Price_Purchase__c,Currency__c,Period_Delivery__c,Is_Ok_Factory_Burthen__c,Kind_of_Asset__c,Stock_Number__c,License_Number__c,Status_Asset__c,Purchase__c,Vendor__c,Model_of_Asset__c,Amount_Asset__c,Device_Number__c,Approval_Status__c,Real_Purchase__c FROM Approval_Managed__c","Approval_Name__c":"AssetPurchase"},{"Model_Group__c":"ALL","SQL_Short__c":null,"SQL_Long__c":"SELECT Id,RecordTypeId,SAPID__c,Name,Dept_Name__c,Approval_Name__c,Status__c,Applicant__c,Applicant_Code__c,Applicant_Name__c,Bill_Date__c,Employee__c,Employee_Code__c,Employee_Name__c,Human_Range__c,Department__c,Job_Title__c,Job_Title_Level__c,Birthday__c,Sex__c,Native_Place__c,Phone__c,Salary_Manager__c,Post_Category__c,Take_Office_Date__c,Leave_Office_Date__c,Kind_of_Work__c,Reason_of_Leave__c,Reason_of_Description__c,Remark_of_Explain__c,Reason_of_Leave_Human__c,Work_Date__c ,Dismisson_Reason_of_Operate__c,Approval_Status__c,Validate_Date__c,Operation_Type__c FROM Approval_Managed__c","Approval_Name__c":"StaffLeaveOffice"}]';
                List<Metadata__c> sqls = (List<Metadata__c>)JSON.deserialize(str5,List<Metadata__c>.class);
        for(Metadata__c md : sqls){
            md.RecordTypeId = qId;
        }
        INSERT sqls;
        //配置文件数据创建

        Approval_Managed__c cusApprove = new Approval_Managed__c();
        cusApprove.Applicant__c = con.Id;
        cusApprove.Employee__c = con.Id;
        cusApprove.RecordTypeId = rc.Id;
        INSERT cusApprove;
        AMStaffLeaveOfficeExtension extension = new AMStaffLeaveOfficeExtension(new ApexPages.StandardController(cusApprove));
        extension.save();
        extension.cancel();
        cusApprove.Is_Reset_Approvaler__c = true;
        update cusApprove;
        Test.stopTest();
    }
}