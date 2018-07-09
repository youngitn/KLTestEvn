@isTest
private class AMAssetsTransferExtensionTest {
    static testMethod void testMethod1() { 
        Test.startTest();
         //添加员工
        RecordType rc = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Approval_Managed__c' AND  DeveloperName = :SapApprovalEnum.ASSETSTRANSFER ];
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

        //RecordType rc = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Approval_Managed__c' AND  DeveloperName = :SapApprovalEnum.ASSETSTRANSFER ];  DeveloperName = 'AssetsTransfer'
        RecordType rcContact = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Contact' AND DeveloperName = 'Staff'];
        Contact con = new Contact(LastName = '测试人员',number__c = '10210911', RecordTypeId=rcContact.Id);
        insert con; 

        //创建流程查询SQL
        Id qId = Utils.getRecordTypeId('Metadata__c', 'Query_SQL');
        String str = '[{"Model_Group__c":"ALL","SQL_Short__c":null,"SQL_Long__c":"SELECT Id,RecordTypeId,SAPID__c,Name,Approval_Name__c,Applicant__c,Dept_Name__c,Applicant_Code__c,Bill_Date__c,Approval_Status__c,ChangeType__c,Corporation__c,Asset_Code__c,Asset_Name__c,Asset_Type__c,Asset_initial_value__c,Asset_date__c,Accumulated_depreciation__c,Residual_value__c,Durable_years__c,Dept_of_CostCenter__c,Entity_asset_type__c,ChangeCostCenter__c,ScrapOutage_date__c,Post_transfer_site__c,Vendor_Number__c,Remark__c FROM Approval_Managed__c","Approval_Name__c":"AssetsTransfer"}]';
        List<Metadata__c> sqls = (List<Metadata__c>)JSON.deserialize(str,List<Metadata__c>.class);
        for(Metadata__c md : sqls){
            md.RecordTypeId = qId;
        }

        INSERT sqls;

        RecordType rc = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Approval_Managed__c' AND  DeveloperName = 'AssetsTransfer'];
        //配置文件数据创建 
        Approval_Managed__c am = new Approval_Managed__c();
        am.RecordTypeId = rc.Id;

        am.Corporation__c = '1000';
        am.ChangeType__c = '2';
        am.Durable_years__c = 3;
        INSERT am;

        am.Corporation__c = '6000';
        am.ChangeType__c = '3';
        am.Durable_years__c = 4; 
        UPDATE am;


        AMAssetsTransferExtension extension = new AMAssetsTransferExtension(new ApexPages.StandardController(am));
        WebServiceMockImpl wbi = new WebServiceMockImpl();
        wbi.returnJson = '{"status": "1", message": "信息获取成功", "approval": "ASSETSTRANSFER", "content":[{"corporation__c":"1000", "asset_code__c":"00000011000002", "asset_name__c":"一号厂房、二号厂房", "kind_of_asset__c":"1100", "asset_initial_value__c":"8246078.61 ", "asset_date__c":"2002-12-07", "accumulated_depreciation__c":"43824.92-", "residual_value__c":"562639.01 ", "durable_years__c":"020", "dept_of_costcenter__c":"1000L004", "vendor_number__c":"0000100905"}]}';                                                                                                   
        Test.setMock(WebServiceMock.class, wbi);
        
        extension.save();
        extension.cancel();
        extension.queryAccountInfo();

        am.Corporation__c = '2000';
        am.ChangeType__c = '1';
        am.Durable_years__c = 5; 
        UPDATE am;
        

        Test.stopTest();
    }

}