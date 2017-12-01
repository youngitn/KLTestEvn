@isTest
private class AMExpenseReimburseExtensionTest {

    static testMethod void test1() {
        Test.startTest();

        TestUtil.createBasicData();
        
        TestUtil.createExpenseReimburse();
        Approval_Managed__c am = new Approval_Managed__c();
        AMExpenseReimburseExtension ext = new AMExpenseReimburseExtension(new ApexPages.StandardController(am));
        
        List<Approval_Managed__c> amlist = [SELECT Id FROM Approval_Managed__c WHERE RecordType.DeveloperName='ExpenseReimburse' LIMIT 1];
        if(amlist.size() >0){
            am  = amlist[0];
            ext = new AMExpenseReimburseExtension(new ApexPages.StandardController(am));
            ext.save();
            ext.cancel();
            ext.newlist1();
            ext.deletelist1();
            ext.newlist2();
            ext.deletelist2();
        }
        Test.stopTest();
    }
    
    static testMethod void test2() {
        Approval_Managed__c am = new Approval_Managed__c();
        Approval_Managed_Item__c ami = new Approval_Managed_Item__c();
        Approval_Managed_Item__c ami2 = new Approval_Managed_Item__c();
        AMExpenseReimburseExtension ext = new AMExpenseReimburseExtension(new ApexPages.StandardController(am));
        ext.list1.add(ami);
        ext.list2.add(ami2);
        ext.save();
    }
}