@isTest
private class AMAdvanceChargeExtensionTest {
    static testMethod void testhandler() {
        Test.startTest();
        RecordType rc = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Approval_Managed__c' AND  DeveloperName = 'AdvanceCharge'];
        RecordType rcContact = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Contact' AND  DeveloperName = 'Staff'];
        Contact con = new Contact(LastName = '测试人员',number__c = '10210911', RecordTypeId=rcContact.Id);
        insert con;

        Approval_Managed__c am = new Approval_Managed__c();
        am.Applicant__c = con.Id;
        am.RecordTypeId = rc.Id;
        INSERT am;
        am.Applicant__c = con.Id;
        am.RecordTypeId = rc.Id;
        am.Is_Reset_Approvaler__c = true;
        UPDATE am;
        Test.stopTest();
    }

    static testMethod void testExtension() {
        Test.startTest();
        RecordType rc = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Approval_Managed__c' AND  DeveloperName = 'AdvanceCharge'];
        RecordType rcContact = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Contact' AND  DeveloperName = 'Staff'];
        Contact con = new Contact(LastName = '测试人员',number__c = '10210911', RecordTypeId=rcContact.Id);
        insert con;


        
        Approval_Managed__c am =new Approval_Managed__c();
        AMAdvanceChargeExtension a= new AMAdvanceChargeExtension(new ApexPages.StandardController(am));
        am.Corporation__c= '1000';
        am.Expense_Type_Prepay__c= '10';
        am.Supplier_Name__c='哈哈';
        am.Applicant_Code_Cost__c=12345+'';
        am.Supplier_Number__c=132456+'';
        am.Applicant_Name_Cost__c='信仰';
        am.Purchase__c=12344+'';
        am.Amount_Prepay__c=213456;
        am.Currency__c='阿萨德';
        am.Remark_Vendor_Prepay__c='奥古斯丁';
        am.Dept_PR_Approval__c='四大金刚';
        am.Num_Unfinished__c=132456;
        am.Amount_of_Purchase__c=676+'';
        am.Preinvoice_No__c=7654+'';
        am.Term_of_Payment__c='大声道啊';
        am.Remark_of_Explain__c='苏丢啊';
        am.Type_of_Payment__c='暗红色的看';
        am.Amount_Confirm__c=9999999;
    

        Approval_Managed__c am1 =new Approval_Managed__c();
        am1.Corporation__c= '1000';
        am1.Expense_Type_Prepay__c= '10';
        am1.Supplier_Name__c='哈哈';
        am1.Applicant_Code_Cost__c=12345+'';
        am1.Supplier_Number__c=132456+'';
        am1.Applicant_Name_Cost__c='信仰';
        am1.Purchase__c=12344+'';
        am1.Amount_Prepay__c=213456;
        am1.Currency__c='阿萨德';
        am1.Remark_Vendor_Prepay__c='奥古斯丁';
        am1.Dept_PR_Approval__c='四大金刚';
        am1.Num_Unfinished__c=132456;
        am1.Amount_of_Purchase__c=676+'';
        am1.Preinvoice_No__c=7654+'';
        am1.Term_of_Payment__c='大声道啊';
        am1.Remark_of_Explain__c='苏丢啊';
        am1.Type_of_Payment__c='暗红色的看';
        am1.Amount_Confirm__c=9999999;
 
        Approval_Managed__c am2 =new Approval_Managed__c();
        am2 .Corporation__c= '1000';
        am2.Expense_Type_Prepay__c= '10';
        am2.Supplier_Name__c='哈哈';
        am2.Applicant_Code_Cost__c=12345+'';
        am2.Supplier_Number__c=132456+'';
        am2.Applicant_Name_Cost__c='信仰';
        am2.Purchase__c=12344+'';
        am2.Amount_Prepay__c=213456;
        am2.Currency__c='阿萨德';
        am2.Remark_Vendor_Prepay__c='奥古斯丁';
        am2.Dept_PR_Approval__c='四大金刚';
        am2.Num_Unfinished__c=132456;
        am2.Amount_of_Purchase__c=676+'';
        am2.Preinvoice_No__c=7654+'';
        am2.Term_of_Payment__c='大声道啊';
        am2.Remark_of_Explain__c='苏丢啊';
        am2.Type_of_Payment__c='暗红色的看';
        am2.Amount_Confirm__c=9999999;
        a.save();
        a.cancel();

        test.stopTest();


    }



}