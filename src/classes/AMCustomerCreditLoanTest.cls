@isTest
private class AMCustomerCreditLoanTest { 

    static testMethod void testhandler() {   
        Test.startTest();
         //添加员工
        RecordType rc = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Approval_Managed__c' AND  DeveloperName = 'CustomerCreditLoan'];
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



    static testMethod void testextension(){
 
        test.startTest();
          
        //添加客户
        RecordType rccustomer = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'Customer'];
        Account acc = new Account(RecordTypeId = rccustomer.id,AccountNumber = '001',Name = 'test');
        insert acc;

        //创建流程查询SQL
        Id qId = Utils.getRecordTypeId('Metadata__c', 'Query_SQL');
        String str = '[{"Model_Group__c":"ALL","SQL_Short__c":null,"SQL_Long__c":"SELECT Id,RecordTypeId,Name,Bill_number__c,Department__c,Approval_Name__c,Applicant_Name__c,Applicant_Code__c,Status__c,Bill_Date__c,CreditArea__c,credit_line__c,Account__c,Currency__c,Account_Number__c,Application_credit_limit__c,Third_credit_line__c,Confirmation_credit_limits__c,Amount_receivable__c,Special_current_debt__c,Term_of_Payment__c,Credit_account_numbe__c,Used_Credit_amount__c,Sales_value__c,Credit_validity__c,Total_credit_risk__c,Guarantee_amount_receivable__c,Risk_kind__c,Freeze_confirm__c,Founded_time__c,responsible_person__c,Capital_on_stock__c,Employees_number__c,Annual_sales_amount__c,Local_market_share__c,Responsible_person_Quality__c,Company_record__c,Suppliers__c,Sincere_cooperation__c,lawsuit__c,Average_sales__c,Bad_debt_records__c,Customer_kind__c,KLCooperate_product__c,No_delivery_amount__c,Not_received_Amount__c,Overdue_amount__c,Exception_handling__c,supplement__c FROM Approval_Managed__c","Approval_Name__c":"CustomerCreditLoan"}]';
        List<Metadata__c> sqls = (List<Metadata__c>)JSON.deserialize(str,List<Metadata__c>.class);
        for(Metadata__c md : sqls){
            md.RecordTypeId = qId;
        } 

        INSERT sqls;

        RecordType rc = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Approval_Managed__c' AND  DeveloperName = 'CustomerCreditLoan'];
        //配置文件数据创建
        Approval_Managed__c amc = new Approval_Managed__c();
        amc.RecordTypeId = rc.Id;

        amc.CreditArea__c = 'KL00';
        amc.credit_line__c = 43253;
        amc.Currency__c = 'AOR';
        amc.Account__c = acc.Id;
        amc.supplement__c = 'lkahflkahlkaj';
        amc.Exception_handling__c = 'alhjlalka';
        amc.Overdue_amount__c = 45345;
        amc.Customer_kind__c = '3';
        amc.No_delivery_amount__c = 2345345;
        amc.Sincere_cooperation__c = '1';
        
        INSERT amc;

        amc.credit_line__c = 300000;
        amc.Currency__c = 'CNY';
        amc.Amount_receivable__c = 0002004433;
        amc.Special_current_debt__c = 'asdfasdfa';
        amc.Credit_account_numbe__c = 2004433;
        amc.Used_Credit_amount__c = 0.00;
        amc.Sales_value__c = 243243;
        amc.Total_credit_risk__c = 324535;
        amc.Guarantee_amount_receivable__c = 34255;
        amc.Risk_kind__c = '001';

        UPDATE amc; 

        
        AMCustomerCreditLoanExtension amIt = new AMCustomerCreditLoanExtension(new ApexPages.StandardController(amc));
        WebServiceMockImpl wbi = new WebServiceMockImpl();
        wbi.returnJson = '{"status": "1", message": "信息获取成功", "approval": "CUSTOMERCREDITLOAN", "content":[{"credit_line__c":"300000", "currency__c":"CNY", "amount_receivable__c":"415336", "credit_account_numbe__c":"2004433", "used_credit_amount__c":"000000",  "total_credit_risk__c":"000000", "guarantee_amount_receivable__c":"000000", "risk_kind__c":"001"}, "details": ""]}';
        Test.setMock(WebServiceMock.class, wbi);

        amIt.save();
        amIt.cancel();
        amIt.queryAccountInfo(); 

        amc.Currency__c = 'BGN';
        amc.Third_credit_line__c = 463432;
        amc.Amount_receivable__c = 27509827;
        amc.Term_of_Payment__c = 'A104';
        amc.Used_Credit_amount__c = 253245;

        UPDATE amc;

        test.stopTest();


    }
}