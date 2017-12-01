@isTest
private class AMSaleOrderHandlerTest {
    static testMethod void testMethod1() {
        RecordType rc = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Custom_Approval_Managed__c' AND  DeveloperName = 'SaleOrder'];
        
    	Contact con = new Contact(LastName = '测试人员',number__c = '123');
        insert con;

        Custom_Approval_Managed__c capp1 = new Custom_Approval_Managed__c();
        capp1.Applicant__c = con.Id;
        capp1.RecordTypeId = rc.Id;
        capp1.Sales_Employee__c = '10210224';
        capp1.Kind_of_Order__c = 'Z008';
        capp1.Applicant_Corp_Code__c = '1000';
        capp1.Type_of_Approval__c = '新增';
        INSERT capp1;

        capp1.Applicant__c = con.Id;
        capp1.RecordTypeId = rc.Id;
        capp1.Sales_Employee__c = '10210224';
        capp1.Kind_of_Order__c = 'Z008';
        capp1.Applicant_Corp_Code__c = '1000';
        UPDATE  capp1;

    }
}