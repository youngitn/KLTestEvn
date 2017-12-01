@isTest
private class GetTaskInfoFromCRMHandlerTest {
    static testMethod void testMethod1() {
    	SAP_Interface_Setting__c sis = new SAP_Interface_Setting__c();
    	sis.Name = 'CRMSetting';
    	sis.EndPoint__c = 'http://test';
    	sis.UserName__c = '测试用户名';
    	sis.Password__c = '测试密码';
    	sis.Timeout__c = '1';
    	insert sis;
        Custom_Approval_Managed_Item__c cam = new Custom_Approval_Managed_Item__c();
        cam.Campaign__c = '测试id';
        insert cam;

        Approval_Managed_Item__c am = new Approval_Managed_Item__c();
        am.TaskID__c = '测试id';
        insert am;

    }
}