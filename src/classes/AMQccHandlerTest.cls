@isTest
private class AMQccHandlerTest {
    static testMethod void testMethod1() {
    	RecordType rc = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Approval_Managed1__c' AND  DeveloperName = 'Qcc'];
    	 createApprovalconfig(26,'Qcc');
    	 Approval_Managed1__c cusApprove = new Approval_Managed1__c();
    	 //cusApprove.RecordTypeId
    	 cusApprove.RecordTypeId = rc.Id;
    	 cusApprove.Factory__c = '1000';              //工厂
    	 cusApprove.KOSTL__c = '1000E001';            //成本中心
    	// cusApprove.Customer__c = 'name';             //客户
    	 cusApprove.CustomerMaterial__c = '05';       //客户物料号
    	 cusApprove.OrderNumber1__c = 5077;           //订单数量
    	 cusApprove.GuestsNumber__c = 3;              //客诉数量
    	 cusApprove.Product__c = '1000';              //产品
    	// cusApprove.AcquiringPeople__c = '10210911';  //收单人
    	 INSERT cusApprove;
    	 AMInternalmemoExtension amIt = new AMInternalmemoExtension(new ApexPages.StandardController(cusApprove));
    		amIt.save();
    		amIt.cancel();
    	test.startTest();

    	cusApprove.Is_Reset_Approvaler__c = true;
    	 cusApprove.Factory__c = '1000'; 
    	 cusApprove.KOSTL__c = '1000E002';
    	// cusApprove.Customer__c = 'ccz2';
    	 cusApprove.CustomerMaterial__c = '05';
    	 cusApprove.OrderNumber1__c = 19;
    	 cusApprove.GuestsNumber__c = 3;
    	 cusApprove.Product__c = '1000';
    	// cusApprove.AcquiringPeople__c = '10210911';
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