@isTest
private class AMSignetUseHanderTest {
   static testMethod void testMethod1() {

        test.startTest();
        //添加员工
        RecordType rcContact = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Contact' AND DeveloperName = 'Staff'];
        Contact con = new Contact(LastName = '测试人员',number__c = '10210911', RecordTypeId=rcContact.Id);
        insert con;

        //创建流程查询SQL
        Id qId = Utils.getRecordTypeId('Metadata__c', 'Query_SQL');
        String str5 = '[{"Model_Group__c":"ALL","SQL_Short__c":null,"SQL_Long__c":"SELECT Id,RecordTypeId,signet_type__c,file_type__c,FileName__c,New_account__c,Quantity__c,Summary_content__c,company_number__c,Account_Number__c,Account__c,Term_of_Payment__c,payment_terms_describe__c,Citic_policy_no__c,Overdue_amount__c,Retention_penalty__c,acacetin__c,Currency__c,Acceptance_condition__c,Content_acceptance__c,Delivery_contract_review__c,Standards__c,Standard_parts__c,Field1Intellectual_property__c,Retention__c,Contract_number__c,Bill_number__c,Name,Approval_Name__c,Applicant__c,Dept_Name__c,Applicant_Code__c,Bill_Date__c,Applicant_Name__c,Approval_Status__c FROM Approval_Managed__c","Approval_Name__c":"SignetUse"}]';
        List<Metadata__c> sqls = (List<Metadata__c>)JSON.deserialize(str5,List<Metadata__c>.class);
        for(Metadata__c md : sqls){
            md.RecordTypeId = qId;
        }
        INSERT sqls;
        //添加客户
        RecordType rccustomer = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'Customer'];
        Account acc = new Account(RecordTypeId = rccustomer.id,AccountNumber = '001',Name = 'test');
        insert acc;


        RecordType rc = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Approval_Managed__c' AND  DeveloperName = 'SignetUse'];
        Approval_Managed__c cusApprove = new Approval_Managed__c();
        cusApprove.RecordTypeId = rc.Id;

        cusApprove.signet_type__c = '01';
        cusApprove.file_type__c = '04';
        cusApprove.FileName__c = '1000';
        cusApprove.Summary_content__c = '1agdshagdsg01';
        cusApprove.company_number__c = '02';
        cusApprove.Account__c = acc.Id;
        cusApprove.Term_of_Payment__c = 'YA45';
        cusApprove.payment_terms_describe__c = '2S45DGF465EWTGEDSGHASFA';
        cusApprove.Currency__c = 'GHC';
        cusApprove.Content_acceptance__c = 'KLAHGOAHGGFNGLKAHFI';
         INSERT cusApprove;

        AMSignetUseExtension amIt = new AMSignetUseExtension(new ApexPages.StandardController(cusApprove));
         
        amIt.save();
        amIt.cancel();

        cusApprove.signet_type__c = '02';
        cusApprove.file_type__c = '04';
        cusApprove.FileName__c = '1000';
        cusApprove.Summary_content__c = '1agdshagdsg01';
        cusApprove.company_number__c = '07';
        cusApprove.Account_Number__c = '7657t784895687';
        cusApprove.Term_of_Payment__c = 'YA45';
        cusApprove.payment_terms_describe__c = '2S45DGF465EWTGEDSGHASFA';
        cusApprove.Currency__c = 'GHC';
        cusApprove.Content_acceptance__c = 'KLAHGOAHGGFNGLKAHFI';
        cusApprove.Is_Reset_Approvaler__c = true;
        Update cusApprove;

        Approval_Managed__c cusApprove2 = new Approval_Managed__c();
        cusApprove2.RecordTypeId = rc.Id;

       //  客户/合约金额/币种  不能为空
        cusApprove2.file_type__c = '02';
        cusApprove2.Currency__c = '';
        cusApprove2.Is_Reset_Approvaler__c = true;
        cusApprove2.Account__c = null;
        INSERT cusApprove2;

        AMSignetUseExtension amIt2 = new AMSignetUseExtension(new ApexPages.StandardController(cusApprove2));
        amIt2.save();
        amIt2.cancel();

        test.stopTest();


    }
}