@isTest
private class AMSampleRequestExtensionTest {
    static testMethod void testMethod1() {
        RecordType rc = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Approval_Managed1__c' AND  DeveloperName = 'SampleRequest'];
         //createApprovalconfig(26,'MeasuringInstRequest');
         Approval_Managed1__c cusApprove = new Approval_Managed1__c();
         cusApprove.RecordTypeId = rc.Id;
         cusApprove.Factory__c = '1000';

         INSERT cusApprove;
         AMSampleRequestExtension amIt = new AMSampleRequestExtension(new ApexPages.StandardController(cusApprove));
            cusApprove.Factory__c = '1000';
            //amIt.isDeletedStatus = true;
            amIt.test1();
            amIt.test2();
            amIt.test3();
            amIt.test4();
            amIt.test5();
            amIt.test6();
            amIt.test11();
            amIt.test12();
            amIt.test13();
            amIt.test14();
            amIt.test15();
            amIt.test16();
            amIt.test21();
            amIt.test22();
            amIt.test23();
            amIt.test24();
            amIt.test25();
            amIt.test26();
            amIt.test31();
            amIt.test32();
            amIt.test33();
            amIt.test34();
            amIt.test35();
            amIt.test36();
            amIt.test41();
            amIt.test42();
            amIt.test43();
            amIt.test44();
            amIt.test45();
            amIt.test46();
            amIt.test51();
            amIt.test52();
            amIt.test53();
            amIt.test54();
            amIt.test55();
            amIt.test56();
            amIt.save();
            amIt.cancel();


        test.startTest();
        cusApprove.SampleType__c='10';
        cusApprove.SalesGroup__c='100';
        // cusApprove.Customer__c='10';
        cusApprove.CustomerType__c='10';
        cusApprove.SampleDealType__c='10';
        cusApprove.RequireSampleReason__c='test';
        cusApprove.SendType__c='10';
        participant p = new participant();
        Update cusApprove;

        

        test.stopTest();
    }

    static testMethod void testhandler() {
        Test.startTest();
        RecordType rc = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Approval_Managed1__c' AND  DeveloperName = 'SampleRequest'];
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

    public class participant
    {
        public String matno {get; set;}
        public String descri {get; set;}
        public String num {get; set;}
        public String value {get; set;}
        public String reqdate {get; set;}
    }
}