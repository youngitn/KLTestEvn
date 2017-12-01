@isTest
private class AMExpenseReimburseHandlerTest {
    static testMethod void testMethod1() {
        RecordType rc = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Approval_Managed__c' AND  DeveloperName = 'ExpenseReimburse'];
        Contact con = new Contact(LastName = '测试人员',number__c = '123');
        insert con;

        RecordType lfa1 = [SELECT Id,DeveloperName From RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'Vendor'];
        //Account acc = new Account(AccountNumber = '0101',RecordType = 'Vendor',Name = 'TST');

        //insert acc;
        Account acc = new Account();
        acc.AccountNumber = '0001';
        acc.RecordTypeId = lfa1.Id;
        //acc.RecordType = 'Vendor';
        acc.Name = 'TST';
        insert acc;

        List<Account> lifnr = [SELECT Id FROM Account WHERE RecordType.DeveloperName = 'Vendor' LIMIT 1];

         //配置文件数据创建
        System_Setting__c ssc = new System_Setting__c();
        ssc.Name = 'Setting';
        ssc.Can_Create_ExpenseReimburse__c = '01';
        INSERT ssc;

        Approval_Managed__c approve = new Approval_Managed__c();
        approve.RecordTypeId = rc.Id;
        approve.Applicant__c = con.Id;
        approve.Expense_Type_Cost__c = '02';
        approve.Supplier__c = acc.id;
        /*
        if (lifnr.size() > 0) {
            approve.Supplier__c = lifnr[0].Id;
        }
        */
        INSERT approve;
        approve.Is_Reset_Approvaler__c = true;
        Update approve;   
    }
}