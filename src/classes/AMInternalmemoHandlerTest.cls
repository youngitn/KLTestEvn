@isTest
private class AMInternalmemoHandlerTest {
    static testMethod void testMethod1() {
    	RecordType rc = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Approval_Managed1__c' AND  DeveloperName = 'Internalmemo'];
    	 createApprovalconfig(26,'Internalmemo');
    	 Approval_Managed1__c cusApprove = new Approval_Managed1__c();
    	 //cusApprove.RecordTypeId
    	 cusApprove.RecordTypeId = rc.Id;
    	 cusApprove.Factory__c = '1000';
    	 cusApprove.TYPE__c = '05';
    	 INSERT cusApprove;
    	 AMInternalmemoExtension amIt = new AMInternalmemoExtension(new ApexPages.StandardController(cusApprove));
    		amIt.save();
    		amIt.cancel();
    	test.startTest();

    	cusApprove.Is_Reset_Approvaler__c = true;
    	cusApprove.Factory__c = '1000';
    	cusApprove.TYPE__c = '06';
    	Update cusApprove;

    	cusApprove.Is_Reset_Approvaler__c = true;
    	cusApprove.Factory__c = '1000';
    	cusApprove.TYPE__c = '07';
    	Update cusApprove;

    	cusApprove.Is_Reset_Approvaler__c = true;
    	cusApprove.Factory__c = '1000';
    	cusApprove.TYPE__c = '08';
    	Update cusApprove;

    	cusApprove.Is_Reset_Approvaler__c = true;
    	cusApprove.Factory__c = '1000';
    	cusApprove.TYPE__c = '19';
    	Update cusApprove;

    	cusApprove.Is_Reset_Approvaler__c = true;
    	cusApprove.Factory__c = '1000';
    	cusApprove.TYPE__c = '12';
    	Update cusApprove;

    	cusApprove.Is_Reset_Approvaler__c = true;
    	cusApprove.Factory__c = '1000';
    	cusApprove.TYPE__c = '12';
    	Update cusApprove;

    	cusApprove.Is_Reset_Approvaler__c = true;
    	cusApprove.Factory__c = '1000';
    	cusApprove.TYPE__c = '14';
    	Update cusApprove;

    	cusApprove.Is_Reset_Approvaler__c = true;
    	cusApprove.Factory__c = '1000';
    	cusApprove.TYPE__c = '15';
    	Update cusApprove;
        
        cusApprove.Is_Reset_Approvaler__c = true;
    	cusApprove.Factory__c = '1000';
    	cusApprove.TYPE__c = '16';
    	Update cusApprove;

    	cusApprove.Is_Reset_Approvaler__c = true;
    	cusApprove.Factory__c = '1000';
    	cusApprove.TYPE__c = '17';
    	Update cusApprove;

    	cusApprove.Is_Reset_Approvaler__c = true;
    	cusApprove.Factory__c = '1000';
    	cusApprove.TYPE__c = '18';
    	Update cusApprove;
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