@isTest
private class AMWasteDisposeExtensionTest {
    
    static testMethod void testhandler() {
        Test.startTest();
        RecordType rc = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Custom_Approval_Managed__c' AND  DeveloperName = 'WasteDispose'];
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
        RecordType rc = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Custom_Approval_Managed__c' AND  DeveloperName = 'WasteDispose'];
        RecordType item = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Custom_Approval_Managed_Item__c' AND  DeveloperName = 'Waste_Handle'];
        RecordType rcContact = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Contact' AND DeveloperName = 'Staff'];
        Contact con = new Contact(LastName = '测试人员',number__c = '10210911', RecordTypeId=rcContact.Id);
        insert con;
        //创建流程查询SQL
        Id qId = Utils.getRecordTypeId('Metadata__c', 'Query_SQL');
        String str5 = '[{"Model_Group__c":"ALL","SQL_Short__c":null,"SQL_Long__c":"SELECT Id,RecordTypeId,SAPID__c,Name,Dept_Name__c,Approval_Name__c,Status__c,Applicant__c,Applicant_Code__c,Applicant_Name__c,Bill_Date__c,Type_of_Scrap__c,Factory__c,Vendor__c,Scrap_Date__c,Amount_Receipts__c,Order_of_Sales__c,Invoice_and_Remark__c,Approval_Status__c FROM Custom_Approval_Managed__c","Approval_Name__c":"WasteDispose"}]';
        List<Metadata__c> sqls = (List<Metadata__c>)JSON.deserialize(str5,List<Metadata__c>.class);
        for(Metadata__c md : sqls){
            md.RecordTypeId = qId;
        }
        INSERT sqls;
        //配置文件数据创建
        Custom_Approval_Managed__c am = new Custom_Approval_Managed__c();
        am.Applicant__c = con.Id;
        am.RecordTypeId = rc.Id;
        am.Employee__c = con.Id;
        System.debug(LoggingLevel.INFO, '*** am.Employee__c: ' + am.Employee__c);
        insert am;

        Custom_Approval_Managed_Item__c ami = new Custom_Approval_Managed_Item__c();
        ami.Material_Name__c = '0100';
        ami.Qty__c = 1.2;
        ami.Weight_Actual__c = 2;
        ami.Price__c = 3.3;
        ami.RecordTypeId = item.Id;
        ami.Waste_Approval__c = am.Id;
        insert ami;

        AMWasteDisposeExtension extension = new AMWasteDisposeExtension(new ApexPages.StandardController(am));
        extension.rowID = 1;
        extension.listRowInfo.add(ami);

        extension.cancelAction();
        extension.addBankDetail();
        extension.deleteRow();
        extension.saveAction();
        Test.stopTest();
    }
}