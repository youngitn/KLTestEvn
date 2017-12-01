@isTest
private class AMAssetPurchaseHandlerTest {
    static testMethod void testMethod1() {
        RecordType rc = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Approval_Managed__c' AND  DeveloperName = 'AssetPurchase'];
        
    	Contact con = new Contact(LastName = '测试人员',number__c = '123');
        insert con;

        Approval_Managed__c capp1 = new Approval_Managed__c();
        capp1.Applicant__c = con.Id;
        capp1.RecordTypeId = rc.Id;
        capp1.Asset_Type__c = '01';
        capp1.Factory__c = '1000';
        capp1.Dept_of_CostCenter__c = '1000L001';
        INSERT capp1;

        capp1.Applicant__c = con.Id;
        capp1.RecordTypeId = rc.Id;
        capp1.Asset_Type__c = '02';
        capp1.Factory__c = '1000';
        capp1.Dept_of_CostCenter__c = '1000L001';
        capp1.Is_Reset_Approvaler__c = true;
        UPDATE capp1;

        capp1.Applicant__c = con.Id;
        capp1.RecordTypeId = rc.Id;
        capp1.Asset_Type__c = '03';
        capp1.Factory__c = '1000';
        capp1.Dept_of_CostCenter__c = '1000L001';
        capp1.Is_Reset_Approvaler__c = true;
        UPDATE capp1;

        capp1.Applicant__c = con.Id;
        capp1.RecordTypeId = rc.Id;
        capp1.Asset_Type__c = '04';
        capp1.Factory__c = '1000';
        capp1.Dept_of_CostCenter__c = '1000L001';
        capp1.Is_Reset_Approvaler__c = true;
        UPDATE capp1;

        capp1.Applicant__c = con.Id;
        capp1.RecordTypeId = rc.Id;
        capp1.Asset_Type__c = '05';
        capp1.Factory__c = '1000';
        capp1.Dept_of_CostCenter__c = '1000L001';
        capp1.Is_Reset_Approvaler__c = true;
        UPDATE capp1;

        capp1.Applicant__c = con.Id;
        capp1.RecordTypeId = rc.Id;
        capp1.Asset_Type__c = '06';
        capp1.Factory__c = '1000';
        capp1.Dept_of_CostCenter__c = '1000L001';
        capp1.Is_Reset_Approvaler__c = true;
        UPDATE capp1;

        capp1.Applicant__c = con.Id;
        capp1.RecordTypeId = rc.Id;
        capp1.Asset_Type__c = '07';
        capp1.Factory__c = '1000';
        capp1.Dept_of_CostCenter__c = '1000L001';
        capp1.Is_Reset_Approvaler__c = true;
        UPDATE capp1;

        capp1.Applicant__c = con.Id;
        capp1.RecordTypeId = rc.Id;
        capp1.Asset_Type__c = '08';
        capp1.Factory__c = '1000';
        capp1.Dept_of_CostCenter__c = '1000F072';
        capp1.Is_Reset_Approvaler__c = true;
        UPDATE capp1;
    }
}