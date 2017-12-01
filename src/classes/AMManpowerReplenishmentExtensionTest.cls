@isTest
private class AMManpowerReplenishmentExtensionTest {

    static testMethod void testhandler() {
        Test.startTest();
         //添加员工
        RecordType rc = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Approval_Managed__c' AND  DeveloperName = 'ManpowerReplenishment'];
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

        RecordType rc = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Approval_Managed__c' AND  DeveloperName = 'ManpowerReplenishment'];
        // RecordType item = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Approval_Managed_Item__c' AND  DeveloperName = 'ManpowerReplenishment_details'];
        RecordType rcContact = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Contact' AND DeveloperName = 'Staff'];
        Contact con = new Contact(LastName = '测试人员',number__c = '10210911', RecordTypeId=rcContact.Id);
        insert con;

        //创建流程查询SQL
        Id qId = Utils.getRecordTypeId('Metadata__c', 'Query_SQL');
        String str = '[{"Model_Group__c":"ALL","SQL_Short__c":null,"SQL_Long__c":"SELECT Id,RecordTypeId,Name,Approval_Name__c,Applicant__c,Dept_Name__c,Applicant_Code__c,Bill_Date__c,Applicant_Name__c,Approval_Status__c,Modify_description__c,Factory__c,Hiring_schedule__c,Manpower_supplement_description__c,Manpower_type__c,Dept_Code__c,Require_Job_Name__c,Position_Level__c,Sex_Preference__c,Education__c,Department_staffing__c,Existing_man_power__c,Lack_man_power__c,Requirements_number__c,Pay_scope__c,Arrival_Date__c,Major__c,Age__c,Qualification_Requirements__c,Dept_of_CostCenter__c FROM Approval_Managed__c","Approval_Name__c":"ManpowerReplenishment"}]';
        List<Metadata__c> sqls = (List<Metadata__c>)JSON.deserialize(str,List<Metadata__c>.class);
        for(Metadata__c md : sqls){
            md.RecordTypeId = qId;
        }

        INSERT sqls;

        //配置文件数据创建
        Approval_Managed__c am = new Approval_Managed__c();
        am.RecordTypeId = rc.Id;

        am.Factory__c = '6000';
        am.Dept_of_CostCenter__c = '1000E004';
        am.Position_Level__c = '6.3'; 
        am.Sex_Preference__c = '02';
        am.Existing_man_power__c = 30;

        INSERT am;

        // Approval_Managed_Item__c ami = new Approval_Managed_Item__c();
        // ami.RecordTypeId = item.Id; 

        // ami.Row_Index__c = '1';
        // ami.Header__c = con.Id;
        // ami.Header_Code__c = '10210021';        
        // ami.Manpower__c = am.Id;

        // INSERT ami;

        AMManpowerReplenishmentExtension extension = new AMManpowerReplenishmentExtension(new ApexPages.StandardController(am));
        extension.save();
        extension.cancel();
        extension.addDetail();
        extension.deleteDetail();

        Approval_Managed__c am2 = new Approval_Managed__c();
        AMManpowerReplenishmentExtension extension2 = new AMManpowerReplenishmentExtension(new ApexPages.StandardController(am2));
        extension2.save();

        Test.stopTest();
    }

}