/*
名称：售后服务简化流程测试类
作者：丁鹏
日期：2017.08.03

*/
@isTest
private class AMPostSaleServiceHandlerTest {
    static testMethod void testMethod1() {
        RecordType rc = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Approval_Managed1__c' AND  DeveloperName = 'PostSaleService'];
        
    	Contact con = new Contact(LastName = '测试人员',number__c = '123');
        insert con;

        Approval_Managed1__c am1 = new Approval_Managed1__c();
        am1.Applicant__c = con.Id;
        am1.RecordTypeId = rc.Id;
        INSERT am1;
        am1.Applicant__c = con.Id;
        am1.RecordTypeId = rc.Id;
        UPDATE am1;
    }
}