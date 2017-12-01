@isTest
private class AMInventoryKinglaiTest {
 
    static testMethod void testhandler() {
        Test.startTest();
         //添加员工
        RecordType rc = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Approval_Managed__c' AND  DeveloperName = 'InventoryKinglai'];
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

        RecordType rc = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Approval_Managed__c' AND  DeveloperName = 'InventoryKinglai'];
        RecordType item = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Approval_Managed_Item__c' AND  DeveloperName = 'InventoryKinglai_son'];
        RecordType rcContact = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Contact' AND DeveloperName = 'Staff'];
        Contact con = new Contact(LastName = '测试人员',number__c = '10210911', RecordTypeId=rcContact.Id);
        insert con;

        //创建流程查询SQL
        Id qId = Utils.getRecordTypeId('Metadata__c', 'Query_SQL');
        String str = '[{"Model_Group__c":"ALL","SQL_Short__c":null,"SQL_Long__c":"SELECT Id,RecordTypeId,InventoryType__c,Factory__c,Remark__c,Dept_of_CostCenter__c FROM Approval_Managed__c","Approval_Name__c":"InventoryKinglai"}]';
        List<Metadata__c> sqls = (List<Metadata__c>)JSON.deserialize(str,List<Metadata__c>.class);
        for(Metadata__c md : sqls){
            md.RecordTypeId = qId;
        }
        INSERT sqls;

        //配置文件数据创建
        Approval_Managed__c am = new Approval_Managed__c();
        am.RecordTypeId = rc.Id;

        am.Factory__c = '1000';
        am.Dept_of_CostCenter__c = '1000E004';
        am.InventoryType__c = '1'; 
        am.Remark__c = 'sdsdsd';
        am.Total_Price__c = 456445; 
 
        INSERT am; 

        Approval_Managed_Item__c amtc = new Approval_Managed_Item__c();
        amtc.RecordTypeId = item.Id;
        amtc.InventoryKinglai_table__c = am.Id;
        amtc.Material_Number__c = 'z210-02220';
        amtc.Material_Description__c = '扎带 8*300';
        amtc.Storage__c = 'D05';
        amtc.batch__c = '293823452';
        amtc.Quantity__c = 34;
        amtc.Tprice__c = 10; 

        AMInventoryKinglaiExtension extension = new AMInventoryKinglaiExtension(new ApexPages.StandardController(am));
        WebServiceMockImpl wbi = new WebServiceMockImpl();
        wbi.returnJson = '{"status": "1", message": "信息获取成功", "approval": "INVENTORYKINGLAI", "content": [{"main":"", "details": {"Material_Number__c":"z210-02220","Material_Description__c":"扎带 8*300","Storage__c":"D05"} }]}';
        Test.setMock(WebServiceMock.class, wbi);

        extension.rowID = 1;
        extension.resultRowID = 1;
        extension.selectRow = 0;
        extension.listson.add(amtc);
        extension.listDetail.add(amtc);

        extension.save();
        extension.cancel();
        extension.addDetail();
        extension.deleteDetail();
        extension.queryMaterial();
        extension.selectMaterial();
        

        
        Approval_Managed__c am2 = new Approval_Managed__c();
        am2.RecordTypeId = rc.Id;
        am.Factory__c = '1000';
        INSERT am2;

        Approval_Managed_Item__c amtc2 = new Approval_Managed_Item__c();
        amtc.Material_Number__c = '';
        
        AMInventoryKinglaiExtension extension2 = new AMInventoryKinglaiExtension(new ApexPages.StandardController(am2));
        
        extension2.rowID = 1;
        extension2.resultRowID = 1;
        extension2.selectRow = 1;
        extension2.listson.add(amtc);
        extension2.listDetail.add(amtc2);

        extension2.save();
        extension2.cancel();
        extension2.addDetail();
        extension2.deleteDetail();
        extension2.queryMaterial();
        // extension2.selectMaterial();

        Test.stopTest();

    }

}