@isTest
private class AMLeaveExtensionTest {

	static testMethod void testhandler() {
        Test.startTest();
        RecordType rc = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Approval_Managed__c' AND  DeveloperName = 'Leave'];
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

    
    static testMethod void testextension() {


        RecordType rc = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Approval_Managed__c' AND  DeveloperName = 'Leave'];

        RecordType rcContact = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Contact' AND DeveloperName = 'Staff'];
        Contact con = new Contact(LastName = '测试人员',number__c = '10210911', RecordTypeId=rcContact.Id);
        insert con;
         Approval_Managed__c cusApprove = new Approval_Managed__c();
       cusApprove.RecordTypeId = rc.Id;



          //创建流程查询SQL
        Id qId = Utils.getRecordTypeId('Metadata__c', 'Query_SQL');
        String str = '[{"Model_Group__c":"ALL","SQL_Short__c":null,"SQL_Long__c":"SELECT Id,RecordTypeId,SAPID__c,Name,Approval_Name__c,Applicant_Name__c,Dept_Name__c,Applicant_Code__c,Applicant_Corp_Code__c,Bill_Date__c,Status__c,SchedulingInstructions__c,Remark__c FROM Approval_Managed__c","Approval_Name__c":"Leave"}]';
        List<Metadata__c> sqls = (List<Metadata__c>)JSON.deserialize(str,List<Metadata__c>.class);
        for(Metadata__c md : sqls){
            md.RecordTypeId = qId;
        }
        INSERT cusApprove;
        
        AMLeave amIt = new AMLeave(new ApexPages.StandardController(cusApprove));
       
       cusApprove.Employee__c='yw';
       cusApprove.Employee_Code__c='123456';
       cusApprove.Annual_leave__c='123';
       cusApprove.Adjustable_vacation__c='22';


        amIt.save();

        cusApprove.Employee__c='yw2';
        cusApprove.Employee_Code__c='12345621412';
        cusApprove.Annual_leave__c='123123';
        cusApprove.Adjustable_vacation__c='21422';
        
        amIt.cancel();


        amIt.newlist1();

        test.startTest();
        

        Update cusApprove;   

        test.stopTest();
    }


     
    
}