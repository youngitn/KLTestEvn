/**
	目的：员工异动管理流程Extension测试
	作者：Lily
	创建时间：2017-05-27
**/
@isTest
private class AMStaffTransferExtensionTest {
	/*
		测试新建员工异动管理流程
	*/
    static testMethod void testInsertApprove() {
       test.startTest();
       RecordType rc = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Approval_Managed__c' AND  DeveloperName = 'StaffTransfer'];
       RecordType rcContact = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Contact' AND  DeveloperName = 'Staff'];
        Contact con = new Contact(LastName = '测试人员',number__c = '123', RecordTypeId=rcContact.Id);
        insert con;
        //创建流程查询SQL
        Id qId = Utils.getRecordTypeId('Metadata__c', 'Query_SQL');
        String str5 = '[{"Model_Group__c":"ALL","SQL_Short__c":null,"SQL_Long__c":"SELECT Id,RecordTypeId,SAPID__c,Name,Dept_Name__c,Approval_Name__c,Status__c,Applicant__c,Applicant_Code__c,Applicant_Name__c,Bill_Date__c,Employee__c,Employee_Code__c,Employee_Name__c,Human_Range__c,Work_Company_Old__c,Job_Title_Old__c,Job_Title_Level_Old__c,Staff_Sub_Group_Name__c,Staff_Group_Name__c,Work_Company_New__c,Job_Title_New__c,Job_Title_Level_New__c,Staff_Group_New__c,Staff_Sub_Group_New__c,Validate_Date__c,Reason_of_Operate__c,Is_Salary_Adjust__c,Remark_of_Explain__c,Is_Work_Transfered__c,Is_Key_Returned__c, Handover_Man1__c,Handover_Man1_Code__c,Supervisor1__c,Transfer_Date__c,Handover_Man2__c,Handover_Man2_Code__c,Supervisor2__c,Supervisor2_Code__c,Is_Good_Regurned__c,Handover_Man3__c,Handover_Man3_Code__c,Supervisor3__c,Supervisor3_Code__c,Is_Tools_Returned__c,Handover_Man4__c,Handover_Man4_Code__c,Supervisor4__c,Supervisor4_Code__c,Approval_Status__c,Job_Title_New_Code__c FROM Approval_Managed__c ","Approval_Name__c":"StaffTransfer"}]';
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
        AMStaffTransferExtension extension = new AMStaffTransferExtension(new ApexPages.StandardController(cusApprove));
        extension.save();
        extension.cancel();
        cusApprove.Is_Reset_Approvaler__c = true;
        update cusApprove;
        Test.stopTest();
    }
    
}