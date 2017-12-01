@isTest
private class AMMeasuringInstRequestExtensionTest {
    static testMethod void testMethod1() {
        RecordType rc = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Approval_Managed__c' AND  DeveloperName = 'MeasuringInstRequest'];
         //createApprovalconfig(26,'MeasuringInstRequest');
         Approval_Managed__c cusApprove = new Approval_Managed__c();
         cusApprove.RecordTypeId = rc.Id;
         cusApprove.Factory__c = '1000';

         INSERT cusApprove;
         AMMeasuringInstRequestExtension amIt = new AMMeasuringInstRequestExtension(new ApexPages.StandardController(cusApprove));
            cusApprove.Factory__c = '1000';
            //amIt.isDeletedStatus = true;
            amIt.save();
            amIt.cancel();

        test.startTest();
        cusApprove.Is_Reset_Approvaler__c = true;
        cusApprove.Factory__c = '1000';
        cusApprove.Asset_Type__c = '09';
        cusApprove.Dept_of_CostCenter__c = '1000E001';
        cusApprove.Gage_Name__c = '123';
        cusApprove.Model_and_Spec__c = '234';
        //cusApprove.Required_date__c = new Datetime();
        Update cusApprove;

        cusApprove.Factory__c = '1000';
        cusApprove.Asset_Type__c = '09';
        cusApprove.Dept_of_CostCenter__c = '1000E001';
        cusApprove.Gage_Name__c = '1234';
        cusApprove.Model_and_Spec__c = '234';
        //cusApprove.Required_date__c = '2017-09-30';
        Update cusApprove;

        cusApprove.Factory__c = '1000';
        cusApprove.Asset_Type__c = '09';
        cusApprove.Dept_of_CostCenter__c = '1000E001';
        cusApprove.Gage_Name__c = '1235';
        cusApprove.Model_and_Spec__c = '234';
        //cusApprove.Required_date__c = '2017-09-30';
        Update cusApprove;

        cusApprove.Factory__c = '1000';
        cusApprove.Asset_Type__c = '09';
        cusApprove.Dept_of_CostCenter__c = '1000E001';
        cusApprove.Gage_Name__c = '1236';
        cusApprove.Model_and_Spec__c = '234';
        //cusApprove.Required_date__c = '2017-09-30';
        Update cusApprove;

        cusApprove.Factory__c = '1000';
        cusApprove.Asset_Type__c = '09';
        cusApprove.Dept_of_CostCenter__c = '1000E001';
        cusApprove.Gage_Name__c = '1237';
        cusApprove.Model_and_Spec__c = '234';
        //cusApprove.Required_date__c = '2017-09-30';
        Update cusApprove;

        cusApprove.Factory__c = '1000';
        cusApprove.Asset_Type__c = '09';
        cusApprove.Dept_of_CostCenter__c = '1000E001';
        cusApprove.Gage_Name__c = '1238432';
        cusApprove.Model_and_Spec__c = '234';
        //cusApprove.Required_date__c = '2017-09-30';
        Update cusApprove;

        cusApprove.Factory__c = '1000';
        cusApprove.Asset_Type__c = '09';
        cusApprove.Dept_of_CostCenter__c = '1000E001';
        cusApprove.Gage_Name__c = '12392131';
        cusApprove.Model_and_Spec__c = '234';
        //cusApprove.Required_date__c = '2017-09-30';
        Update cusApprove;

        cusApprove.Factory__c = '1000';
        cusApprove.Asset_Type__c = '09';
        cusApprove.Dept_of_CostCenter__c = '1000E001';
        cusApprove.Gage_Name__c = '1239564';
        cusApprove.Model_and_Spec__c = '234';
        //cusApprove.Required_date__c = '2017-09-30';
        Update cusApprove;

        cusApprove.Factory__c = '1000';
        cusApprove.Asset_Type__c = '09';
        cusApprove.Dept_of_CostCenter__c = '1000E001';
        cusApprove.Gage_Name__c = '12343249';
        cusApprove.Model_and_Spec__c = '234';
        //cusApprove.Required_date__c = '2017-09-30';
        Update cusApprove;

        

        test.stopTest();

        
    }


    //测试AMInformationServiceHANDLER类
    /*static testMethod void testMethod2() {
        test.startTest();
        RecordType rc = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Approval_Managed__c' AND  DeveloperName = 'MeasuringInstRequest'];
        Approval_Managed__c cusApprove = new Approval_Managed__c();
        cusApprove.RecordTypeId = rc.Id;
         cusApprove.Factory__c = '1000';

         INSERT cusApprove;

        cusApprove.Is_Reset_Approvaler__c = true;
        cusApprove.Factory__c = '1000';
        cusApprove.Asset_Type__c = '09';
        cusApprove.Dept_of_CostCenter__c = '1000E001';
        cusApprove.Gage_Name__c = '123';
        cusApprove.Model_and_Spec__c = '234';
        //cusApprove.Required_date__c = new Datetime();
        Update cusApprove;

        cusApprove.Factory__c = '1000';
        cusApprove.Asset_Type__c = '09';
        cusApprove.Dept_of_CostCenter__c = '1000E001';
        cusApprove.Gage_Name__c = '1234';
        cusApprove.Model_and_Spec__c = '234';
        //cusApprove.Required_date__c = '2017-09-30';
        Update cusApprove;

        cusApprove.Factory__c = '1000';
        cusApprove.Asset_Type__c = '09';
        cusApprove.Dept_of_CostCenter__c = '1000E001';
        cusApprove.Gage_Name__c = '1235';
        cusApprove.Model_and_Spec__c = '234';
        //cusApprove.Required_date__c = '2017-09-30';
        Update cusApprove;

        cusApprove.Factory__c = '1000';
        cusApprove.Asset_Type__c = '09';
        cusApprove.Dept_of_CostCenter__c = '1000E001';
        cusApprove.Gage_Name__c = '1236';
        cusApprove.Model_and_Spec__c = '234';
        //cusApprove.Required_date__c = '2017-09-30';
        Update cusApprove;

        cusApprove.Factory__c = '1000';
        cusApprove.Asset_Type__c = '09';
        cusApprove.Dept_of_CostCenter__c = '1000E001';
        cusApprove.Gage_Name__c = '1237';
        cusApprove.Model_and_Spec__c = '234';
        //cusApprove.Required_date__c = '2017-09-30';
        Update cusApprove;

        cusApprove.Factory__c = '1000';
        cusApprove.Asset_Type__c = '09';
        cusApprove.Dept_of_CostCenter__c = '1000E001';
        cusApprove.Gage_Name__c = '1238432';
        cusApprove.Model_and_Spec__c = '234';
        //cusApprove.Required_date__c = '2017-09-30';
        Update cusApprove;

        cusApprove.Factory__c = '1000';
        cusApprove.Asset_Type__c = '09';
        cusApprove.Dept_of_CostCenter__c = '1000E001';
        cusApprove.Gage_Name__c = '12392131';
        cusApprove.Model_and_Spec__c = '234';
        //cusApprove.Required_date__c = '2017-09-30';
        Update cusApprove;

        cusApprove.Factory__c = '1000';
        cusApprove.Asset_Type__c = '09';
        cusApprove.Dept_of_CostCenter__c = '1000E001';
        cusApprove.Gage_Name__c = '1239564';
        cusApprove.Model_and_Spec__c = '234';
        //cusApprove.Required_date__c = '2017-09-30';
        Update cusApprove;

        cusApprove.Factory__c = '1000';
        cusApprove.Asset_Type__c = '09';
        cusApprove.Dept_of_CostCenter__c = '1000E001';
        cusApprove.Gage_Name__c = '12343249';
        cusApprove.Model_and_Spec__c = '234';
        //cusApprove.Required_date__c = '2017-09-30';
        Update cusApprove;

        

        test.stopTest();

    }*/

       /***
    创建相应审批配置记录
    ***/
    /*static  void createApprovalconfig(Integer step, String approvalName) {
        if (step>0) {
            RecordType rc = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Organizational__c' AND  DeveloperName = 'Approval_Config'];
            List<Organizational__c> lstOrg = new List<Organizational__c>();
            for (Integer i =0;i<step ; i++) {
                lstOrg.add(new Organizational__c(Approval_Name__c = approvalName ,Approval_Step__c = i+1, Approval_Rule__c = '指定人部门主管',RecordTypeId=rc.Id));
            }
            System.debug(LoggingLevel.INFO, '*** lstOrg: ' + lstOrg);
            insert lstOrg;
        }
    }*/
}