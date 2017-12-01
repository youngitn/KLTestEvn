@isTest
private class AMCostCenterSendHandlerTest {
    static testMethod void test1() {
        RecordType rc = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Custom_Approval_Managed__c' AND  DeveloperName = 'CostCenterSend'];
        
    	Contact con = new Contact(LastName = '测试人员',number__c = '123');
        insert con;

        Custom_Approval_Managed__c capp1 = new Custom_Approval_Managed__c();
        capp1.Applicant__c = con.Id;
        capp1.RecordTypeId = rc.Id;
        capp1.Option_of_Operate__c = '201';
        capp1.Factory__c = '1000';
        capp1.Address_of_Stock__c = 'D04';
        capp1.Dept_of_CostCenter__c = '1000L001';
        INSERT capp1;

        capp1.Applicant__c = con.Id;
        capp1.RecordTypeId = rc.Id;
        capp1.Option_of_Operate__c = '201';
        capp1.Factory__c = '1000';
        capp1.Address_of_Stock__c = 'D01';
        capp1.Dept_of_CostCenter__c = '1000L001';
        capp1.Is_Reset_Approvaler__c = true;
        UPDATE capp1;

        capp1.Applicant__c = con.Id;
        capp1.RecordTypeId = rc.Id;
        capp1.Option_of_Operate__c = '201';
        capp1.Factory__c = '1000';
        capp1.Address_of_Stock__c = 'A00';
        capp1.Dept_of_CostCenter__c = '1000L001';
        UPDATE capp1;

        capp1.Applicant__c = con.Id;
        capp1.RecordTypeId = rc.Id;
        capp1.Option_of_Operate__c = '201';
        capp1.Factory__c = '2000';
        capp1.Address_of_Stock__c = 'A00';
        capp1.Dept_of_CostCenter__c = '1000L001';
        UPDATE capp1;

        capp1.Applicant__c = con.Id;
        capp1.RecordTypeId = rc.Id;
        capp1.Option_of_Operate__c = 'Z61';
        capp1.Factory__c = '1000';
        capp1.Address_of_Stock__c = 'C14';
        capp1.Order_of_Production__c = '10213';
        UPDATE capp1;

        capp1.Applicant__c = con.Id;
        capp1.RecordTypeId = rc.Id;
        capp1.Option_of_Operate__c = 'Z61';
        capp1.Factory__c = '1000';
        capp1.Address_of_Stock__c = 'P04';
        capp1.Order_of_Production__c = '10213';
        UPDATE capp1;

        capp1.Applicant__c = con.Id;
        capp1.RecordTypeId = rc.Id;
        capp1.Option_of_Operate__c = '201';
        capp1.Factory__c = '1000';
        capp1.Address_of_Stock__c = 'D03';
        capp1.Dept_of_CostCenter__c = '1000L001';
        UPDATE capp1;

        capp1.Applicant__c = con.Id;
        capp1.RecordTypeId = rc.Id;
        capp1.Option_of_Operate__c = '201';
        capp1.Factory__c = '1000';
        capp1.Address_of_Stock__c = 'E02';
        capp1.Dept_of_CostCenter__c = '1000L001';
        UPDATE capp1;

        capp1.Applicant__c = con.Id;
        capp1.RecordTypeId = rc.Id;
        capp1.Option_of_Operate__c = '201';
        capp1.Applicant_Corp_Code__c = '6000';
        capp1.Address_of_Stock__c = 'C00';
        capp1.Dept_of_CostCenter__c = '1000L001';
        UPDATE capp1;

        try {
        capp1.Applicant__c = con.Id;
        capp1.RecordTypeId = rc.Id;
        capp1.Option_of_Operate__c = '201';
        capp1.Factory__c = '1000';
        capp1.Address_of_Stock__c = 'C10';
        UPDATE capp1;

        }catch(exception e){}
    }

}