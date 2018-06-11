@isTest
private class AMCreditAuditingTest {
    static testMethod void testhandler() {
        Test.startTest();
        RecordType rc = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Approval_Managed1__c' AND  DeveloperName = 'CreditAuditing'];
        RecordType rcContact = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Contact' AND  DeveloperName = 'Staff'];
        Contact con = new Contact(LastName = '测试人员',number__c = '10210911', RecordTypeId=rcContact.Id);
        insert con;

        Approval_Managed1__c am = new Approval_Managed1__c();
        am.Applicant__c = con.Id;
        am.RecordTypeId = rc.Id;
        INSERT am;
        am.Applicant__c = con.Id;
        am.RecordTypeId = rc.Id;
        am.Is_Reset_Approvaler__c = true;
        UPDATE am;
        Test.stopTest();
    }

    static testMethod void testextension() {
         test.startTest();
        Approval_Managed1__c am = new Approval_Managed1__c();      
        am.Order_unpaid_cost__c=666;
        am.Remarks__c='客户单笔信贷核发申请';
        INSERT am;
        am.Order_unpaid_cost__c=666;
        am.Remarks__c='客户单笔信贷核发申请';
        UPDATE am;
        
        Custom_Approval_Managed_Item__c cami =new Custom_Approval_Managed_Item__c(); 
        am.Order_unpaid_cost__c=666;
        am.Remarks__c='客户单笔信贷核发申请';       
        cami.Sales_name__c='1100082639';
        cami.Customer_code__c='12345';
        cami.Customer_name__c='jj';
        cami.Risk_category__c='高';
        cami.Total_amount_receivable__c=33.3;
        cami.Overdue_amount__c=111111;
        cami.Estimated_amount__c=44.4;
        cami.Overdue_proportion__c=0.33;
        cami.Letter_limit__c=55.5;
        AMCreditAuditingExtension a = new AMCreditAuditingExtension(new ApexPages.StandardController(am));
        
        a.saveAction();
        a.addDetail();
        a.cancelAction();
        a.queryClient();
        a.selectClient();
        test.stopTest();
    }




}