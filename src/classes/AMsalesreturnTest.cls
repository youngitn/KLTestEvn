@isTest
private class AMsalesreturnTest {

    static testMethod void testhandler() {
        Test.startTest();
        RecordType rc = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Custom_Approval_Managed__c' AND  DeveloperName = 'SALESRETURN'];
        RecordType rcContact = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Contact' AND  DeveloperName = 'Staff'];
        Contact con = new Contact(LastName = '测试人员',number__c = '10210911', RecordTypeId=rcContact.Id);
        insert con;

        Custom_Approval_Managed__c am = new Custom_Approval_Managed__c();
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
        RecordType rc = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Custom_Approval_Managed__c' AND  DeveloperName = 'SALESRETURN'];
        RecordType item = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Custom_Approval_Managed_Item__c' AND  DeveloperName = 'SALESRETURNDETAILS'];
        RecordType rcContact = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Contact' AND DeveloperName = 'Staff'];
        Contact con = new Contact(LastName = '测试人员',number__c = '10210911', RecordTypeId=rcContact.Id);
        insert con;
        //创建流程查询SQL
        Id qId = Utils.getRecordTypeId('Metadata__c', 'Query_SQL');
        String str5 = '[{"Model_Group__c":"ALL","SQL_Short__c":null,"SQL_Long__c":"SELECT Id,RecordTypeId,SAPID__c,Name,Approval_Name__c,Applicant_Code__c,Dept_Name__c,Applicant_Name__c,Bill_Date__c,Applicant_Corp_Code__c,Approval_Status__c,Bill_No__c,SAP_STATUS__c,IS_SCRAP__c,Approval_User1__c,Approval_User2__c,Approval_User3__c,Approval_User4__c,Approval_User5__c,Approval_User6__c FROM Custom_Approval_Managed__c","Approval_Name__c":"SALESRETURN"}]';
        List<Metadata__c> sqls = (List<Metadata__c>)JSON.deserialize(str5,List<Metadata__c>.class);
        for(Metadata__c md : sqls){
            md.RecordTypeId = qId;
        }
        INSERT sqls;
        //配置文件数据创建
        Custom_Approval_Managed__c am = new Custom_Approval_Managed__c();
        am.Applicant__c = con.Id;
        am.RecordTypeId = rc.Id;
        insert am;
        am.Employee__c = con.Id;
        am.Bill_No__c = '6100005902';
        am.SAP_STATUS__c = 'X';
        //am.Approval_User1__c = utils.getUserByEmployeeCode('10210911');
        //am.Approval_User3__c = utils.getUserByEmployeeCode('10210911');
        upsert am;

        
        Custom_Approval_Managed_Item__c ami = new Custom_Approval_Managed_Item__c();
        ami.Material_Number__c = '1234987';
        ami.IS_SCRAP__c = true;
        ami.SALESRETURN_DETAILS__c = am.Id;
        ami.RecordTypeId = item.Id;
        insert ami;
        AMSalesReturnExtension extension = new AMSalesReturnExtension(new ApexPages.StandardController(am));
        WebServiceMockImpl wbi = new WebServiceMockImpl();
        wbi.returnJson = '{"status": "1", message": "信息获取成功", "approval": "ZSALESFORCE_SD_RETURN_QUERY", "content": [{"main": {"Bill_No__c": "6100005902", "SAP_STATUS__c": "X"}, "details": ""}]}';
        Test.setMock(WebServiceMock.class, wbi);
        extension.querySalesReturn();
        extension.save();
        extension.cancel();


        Custom_Approval_Managed__c am2 = new Custom_Approval_Managed__c();
        AMSalesReturnExtension extension2 = new AMSalesReturnExtension(new ApexPages.StandardController(am2));
        extension2.save();

        Test.stopTest();
    }

}