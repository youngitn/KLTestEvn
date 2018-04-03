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

        RecordType rc = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Approval_Managed__c' AND  DeveloperName = :SapApprovalEnum.ASSETSTRANSFER ];  
        RecordType rcContact = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Contact' AND DeveloperName = 'Staff'];
        Contact con = new Contact(LastName = '测试人员',number__c = '10210911', RecordTypeId=rcContact.Id);
        insert con;

        //创建流程查询SQL
        Id qId = Utils.getRecordTypeId('Metadata__c', 'Query_SQL');
        String str = '[{"Model_Group__c":"ALL","SQL_Short__c":null,"SQL_Long__c":"SELECT Id,RecordTypeId,SAPID__c,Name,Approval_Name__c,Applicant__c,Dept_Name__c,Applicant_Code__c,Bill_Date__c,Approval_Status__c,ChangeType__c,Corporation__c,Asset_Code__c,Asset_Name__c,Asset_Type__c,Asset_initial_value__c,Asset_date__c,Accumulated_depreciation__c,Residual_value__c,Durable_years__c,Dept_of_CostCenter__c,Entity_asset_type__c,ChangeCostCenter__c,ScrapOutage_date__c,Post_transfer_site__c,Vendor_Number__c,Remark__c FROM Approval_Managed__c","Approval_Name__c":"ASSETSTRANSFER"}]';
        List<Metadata__c> sqls = (List<Metadata__c>)JSON.deserialize(str,List<Metadata__c>.class);
        for(Metadata__c md : sqls){
            md.RecordTypeId = qId;
        }

        INSERT sqls;

        //配置文件数据创建 
        Approval_Managed__c am = new Approval_Managed__c();
        am.RecordTypeId = rc.Id;

        am.Corporation__c = '1000';
        am.ChangeType__c = '02';
        am.Durable_years__c = 3;
        INSERT am;

        am.Corporation__c = '6000';
        am.ChangeType__c = '03';
        am.Durable_years__c = 4; 
        UPDATE am;


        AMAssetsTransferExtension extension = new AMAssetsTransferExtension(new ApexPages.StandardController(am));
        extension.save();
        extension.cancel();
        

        Test.stopTest();
    }

}