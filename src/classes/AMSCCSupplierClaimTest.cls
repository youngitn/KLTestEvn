@isTest
private class AMSCCSupplierClaimTest { 

    static testMethod void testMethod1() {
        Test.startTest();
         //添加员工
        RecordType rc = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Custom_Approval_Managed__c' AND  DeveloperName = 'SCCSUPPLIERCLAIM'];
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

        RecordType rc = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Custom_Approval_Managed__c' AND  DeveloperName = 'SCCSUPPLIERCLAIM'];  
        RecordType rcContact = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Contact' AND DeveloperName = 'Staff'];
        Contact con = new Contact(LastName = '测试人员',number__c = '10210911', RecordTypeId=rcContact.Id);
        insert con;

        //创建流程查询SQL
        Id qId = Utils.getRecordTypeId('Metadata__c', 'Query_SQL');
        String str = '[{"Model_Group__c":"ALL","SQL_Short__c":null,"SQL_Long__c":"SELECT Id,RecordTypeId,Name,Approval_Name__c,Applicant__c,Dept_Name__c,Applicant_Code__c,Bill_Date__c,Applicant_Name__c,Approval_Status__c,ECRType__c,ChangeDescription__c,Factory__c,Remark__c,Material_Number__c,WorkOrderCount__c,AnomalyStation__c,WorkOrderNumber__c,ReworkOrderNumber__c,ProcessLossTime__c,MaterialLossTime__c,AppearanceLossTime__c,ProductLoss__c,OtherlLoss__c,BUProductionValue__c,SupplierName_Code__c,ConfirmDescription__c,ProcessCost__c,ProductCost__c,TimeCost__c,OtherCost__c,TotalCost__c,Vendor__c,ProcessDeductionNumber__c,ProcessDeductionMoney__c,ProductDeductionNumber__c,ProductDeductionMoney__c,Approval_User1__c,Approval_User2__c,Approval_User3__c,Approval_User5__c,Approval_User7__c FROM Custom_Approval_Managed__c","Approval_Name__c":"SCCSUPPLIERCLAIM"}]';
        List<Metadata__c> sqls = (List<Metadata__c>)JSON.deserialize(str,List<Metadata__c>.class);
        for(Metadata__c md : sqls){
            md.RecordTypeId = qId;
        }

        INSERT sqls;

        //配置文件数据创建
        Custom_Approval_Managed__c am = new Custom_Approval_Managed__c();
        am.RecordTypeId = rc.Id;

        am.Factory__c = '1000';
        am.ChangeDescription__c = 'sdgfdsg';
        am.ECRType__c = 'AD'; 

        INSERT am;

        AMSCCSUPPLIERCLAIMExtension extension = new AMSCCSUPPLIERCLAIMExtension(new ApexPages.StandardController(am));
        extension.save();
        extension.cancel();

        Test.stopTest();
    }


}