@isTest
private class AMITServiceRequestExtensionTest {
    //测试AMITServiceRequestExtension类
    static testMethod void testMethod1() {
        RecordType rc = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Approval_Managed1__c' AND  DeveloperName = 'IRS_InformationService'];
    	 createApprovalconfig(26,'IRS_InformationService');
    	 Approval_Managed1__c cusApprove = new Approval_Managed1__c();
        cusApprove.RecordTypeId = rc.Id;
        cusApprove.ServiceCategory__c = '100';
        cusApprove.Factory__c = '1000';
        INSERT cusApprove;
    	AMITServiceRequestExtension amIt = new AMITServiceRequestExtension(new ApexPages.StandardController(cusApprove));
    		amIt.isDeletedStatus = true;
    		amIt.save();
    		amIt.cancel();

        cusApprove.ServiceCategory__c = '120';
        cusApprove.Factory__c = '3000';
            amIt.isDeletedStatus = true;
            amIt.save();
            amIt.cancel();
    }
    //测试AMInformationServiceHANDLER类
    static testMethod void testMethod2() {
        test.startTest();
        RecordType rc = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Approval_Managed1__c' AND  DeveloperName = 'IRS_InformationService'];
        Approval_Managed1__c cusApprove = new Approval_Managed1__c();
        cusApprove.RecordTypeId = rc.Id;
        cusApprove.ServiceCategory__c = '100';
        cusApprove.Factory__c = '1000';
        INSERT cusApprove;
        cusApprove.Is_Reset_Approvaler__c =true;
        cusApprove.ServiceCategory__c = '';
        cusApprove.Factory__c = '1000';
        cusApprove.ModuleName__c = '100';
        Update cusApprove;

        cusApprove.Is_Reset_Approvaler__c =true;
        cusApprove.ServiceCategory__c = '120';
        cusApprove.Factory__c = '1000';
        cusApprove.ModuleName__c = '110';
        Update cusApprove;

        cusApprove.Is_Reset_Approvaler__c =true;
        cusApprove.ServiceCategory__c = '120';
        cusApprove.Factory__c = '1000';
        cusApprove.ModuleName__c = '130';
        Update cusApprove;

        cusApprove.Is_Reset_Approvaler__c =true;
        cusApprove.ServiceCategory__c = '120';
        cusApprove.Factory__c = '1000';
        cusApprove.ModuleName__c = '140';
        Update cusApprove;

        cusApprove.Is_Reset_Approvaler__c =true;
        cusApprove.ServiceCategory__c = '120';
        cusApprove.Factory__c = '1000';
        cusApprove.ModuleName__c = '150';
        Update cusApprove;

        cusApprove.Is_Reset_Approvaler__c =true;
        cusApprove.ServiceCategory__c = '120';
        cusApprove.Factory__c = '1000';
        cusApprove.ModuleName__c = '160';
        Update cusApprove;

        cusApprove.Is_Reset_Approvaler__c =true;
        cusApprove.ServiceCategory__c = '120';
        cusApprove.Factory__c = '1000';
        cusApprove.ModuleName__c = '170';
        Update cusApprove;

        cusApprove.Is_Reset_Approvaler__c =true;
        cusApprove.ServiceCategory__c = '999';
        cusApprove.Factory__c = '3000';
 //       cusApprove.ModuleName__c = '170';
        Update cusApprove;

        cusApprove.Is_Reset_Approvaler__c =true;
        cusApprove.ServiceCategory__c = '120';
        cusApprove.Factory__c = '3000';
        cusApprove.ModuleName__c = '100';
        Update cusApprove;

        cusApprove.Is_Reset_Approvaler__c =true;
        cusApprove.ServiceCategory__c = '120';
        cusApprove.Factory__c = '3000';
        cusApprove.ModuleName__c = '120';
        Update cusApprove;

        cusApprove.Is_Reset_Approvaler__c =true;
        cusApprove.ServiceCategory__c = '120';
        cusApprove.Factory__c = '3000';
        cusApprove.ModuleName__c = '120';
        Update cusApprove;

        cusApprove.Is_Reset_Approvaler__c =true;
        cusApprove.ServiceCategory__c = '160';
        cusApprove.Factory__c = '3000';
        cusApprove.ModuleName__c = '120';
 //       Update cusApprove;

        cusApprove.Is_Reset_Approvaler__c =true;
        cusApprove.ServiceCategory__c = '100';
        cusApprove.Factory__c = '3000';
 //       cusApprove.ModuleName__c = '120';
        Update cusApprove;

        test.stopTest();

    }
       /***
    创建相应审批配置记录
    ***/
    static  void createApprovalconfig(Integer step, String approvalName) {
        if (step>0) {
            RecordType rc = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Organizational__c' AND  DeveloperName = 'Approval_Config'];
            List<Organizational__c> lstOrg = new List<Organizational__c>();
            for (Integer i =0;i<step ; i++) {
                lstOrg.add(new Organizational__c(Approval_Name__c = approvalName ,Approval_Step__c = i+1, Approval_Rule__c = '指定人部门主管',RecordTypeId=rc.Id));
            }
            System.debug(LoggingLevel.INFO, '*** lstOrg: ' + lstOrg);
            insert lstOrg;
        }
    }
}