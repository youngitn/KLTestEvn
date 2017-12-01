@isTest
private class AMSalesPricingTest {
 static testMethod void testhandler() {  
        Test.startTest();
         //添加员工
        RecordType rc = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Approval_Managed__c' AND  DeveloperName = 'SalesPrice'];
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

        RecordType rc = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Approval_Managed__c' AND  DeveloperName = 'SalesPrice'];
        RecordType item = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Approval_Managed_Item__c' AND  DeveloperName = 'SalesPricing_son'];
        RecordType item2 = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Approval_Managed_Item__c' AND  DeveloperName = 'SalesPricing_son2'];
        RecordType rcContact = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Contact' AND DeveloperName = 'Staff'];
        Contact con = new Contact(LastName = '测试人员',number__c = '10210911', RecordTypeId=rcContact.Id);
        insert con;

        //创建流程查询SQL
        Id qId = Utils.getRecordTypeId('Metadata__c', 'Query_SQL');
        String str = '[{"Model_Group__c":"ALL","SQL_Short__c":null,"SQL_Long__c":"SELECT Id,RecordTypeId,Name,Approval_Name__c,Applicant__c,Dept_Name__c,Applicant_Code__c,Bill_Date__c,Applicant_Name__c,Approval_Status__c,ConditionType__c,KeyCombination__c,Factory__c,Sales_Org__c,Sales_channels__c,Account__c,Currency__c,Price_Group__c FROM Approval_Managed__c","Approval_Name__c":"SalesPrice"}]';
        List<Metadata__c> sqls = (List<Metadata__c>)JSON.deserialize(str,List<Metadata__c>.class);
        for(Metadata__c md : sqls){
            md.RecordTypeId = qId;
        } 

        INSERT sqls; 

        //配置文件数据创建
        Approval_Managed__c am = new Approval_Managed__c();
        am.RecordTypeId = rc.Id;

        am.ConditionType__c = 'PR01';
        am.Factory__c = '1000';
        am.KeyCombination__c = '304';
        am.Sales_Org__c = '2000';
        am.Sales_channels__c = '10';
        am.Currency__c = 'ATS';
        am.Price_Group__c = '24';
         
        INSERT am; 

        Approval_Managed_Item__c amtic2 = new Approval_Managed_Item__c();
        amtic2.RecordTypeId = item2.Id;

        amtic2.LevelNumber__c = 'lkafnhl';
        amtic2.UOM__c = '%';
        amtic2.Amount__c = 234;
        amtic2.Currency__c = 'ALL';
        amtic2.Quantity__c = 34;

        INSERT amtic2;


        Approval_Managed_Item__c amtic = new Approval_Managed_Item__c();
        amtic.RecordTypeId = item.Id;
        amtic.Material_Number__c = 'z210-02220';
        amtic.Material_Description__c = '扎带 8*300';
        amtic.Amount__c = 3280;
        amtic.Currency__c = 'AED';
        amtic.Quantity__c = 10;
        amtic.NumerationType__c = 'E';

        AMSalesPricingExtension extension = new AMSalesPricingExtension(new ApexPages.StandardController(am));
        WebServiceMockImpl wbi = new WebServiceMockImpl();
        wbi.returnJson = '{"status": "1", message": "信息获取成功", "approval": "SALESPRICE", "content": [{"main":"", "details": {"Material_Number__c":"z210-02220","Material_Description__c":"扎带 8*300","Storage__c":"D05"} }]}';
        Test.setMock(WebServiceMock.class, wbi);

        extension.rowID = 1;
        extension.rowID2 = 1;
        extension.resultRowID = 1;
        extension.selectRow = 0;
        extension.listson.add(amtic);
        extension.listDetail.add(amtic);
        extension.listDetailzi.add(amtic2);

        extension.save();
        extension.cancel();
        extension.addDetail();
        extension.deleteDetail();
        extension.addItemzi();
        extension.deleteItemzi(); 
        extension.queryMaterial();
        extension.selectMaterial();
       

        Test.stopTest();
    }

}