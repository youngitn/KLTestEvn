@isTest
private class AMVisitorHostsTest {
    static testMethod void testMethod1() {
        Test.startTest();
        RecordType rc = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Approval_Managed1__c' AND  DeveloperName = 'VisitorHosts'];       
    	Contact con = new Contact(LastName = '测试人员',number__c = '123');
        insert con;

        Approval_Managed1__c capp1 = new Approval_Managed1__c();
        capp1.Applicant__c = con.Id;
        capp1.RecordTypeId = rc.Id;
        capp1.Applicant_Corp_Code__c = '3000';
        INSERT capp1;

        Approval_Managed1__c capp2 = new Approval_Managed1__c();
        capp2.Applicant__c = con.Id;
        capp2.RecordTypeId = rc.Id;
        capp2.Applicant_Corp_Code__c = '1000';
        capp2.meal_YN__c = 'Y';
        INSERT capp2;

        Approval_Managed1__c capp3 = new Approval_Managed1__c();
        capp3.Applicant__c = con.Id;
        capp3.RecordTypeId = rc.Id;
        capp3.Applicant_Corp_Code__c = '1000';
        capp3.souvenir_YN__c = 'Y';
        INSERT capp3;

        Approval_Managed1__c capp4 = new Approval_Managed1__c();
        capp4.Applicant__c = con.Id;
        capp4.RecordTypeId = rc.Id;
        capp4.Applicant_Corp_Code__c = '1000';
        capp4.pickup_car_YN__c = 'Y';
        INSERT capp4;

        Approval_Managed1__c capp5 = new Approval_Managed1__c();
        capp5.Applicant__c = con.Id;
        capp5.RecordTypeId = rc.Id;
        capp5.Applicant_Corp_Code__c = '1000';
        capp5.souvenir_YN__c = 'Y';
        capp5.meal_YN__c = 'Y';
        INSERT capp5;

        Approval_Managed1__c capp6 = new Approval_Managed1__c();
        capp6.Applicant__c = con.Id;
        capp6.RecordTypeId = rc.Id;
        capp6.Applicant_Corp_Code__c = '1000';
        capp6.souvenir_YN__c = 'Y';
        capp6.meal_YN__c = 'Y';
        capp6.pickup_car_YN__c = 'Y';
        INSERT capp6;

        Approval_Managed1__c capp7 = new Approval_Managed1__c();
        capp7.Applicant__c = con.Id;
        capp7.RecordTypeId = rc.Id;
        capp7.Applicant_Corp_Code__c = '1000';
        capp7.souvenir_YN__c = 'Y';
        capp7.pickup_car_YN__c = 'Y';
        INSERT capp7;

        Approval_Managed1__c capp8 = new Approval_Managed1__c();
        capp8.Applicant__c = con.Id;
        capp8.RecordTypeId = rc.Id;
        capp8.Applicant_Corp_Code__c = '1000';
        capp8.pickup_car_YN__c = 'Y';
        capp8.meal_YN__c = 'Y';
        INSERT capp8;

        capp1.Applicant__c = con.Id;
        capp1.RecordTypeId = rc.Id;
        capp1.Is_Reset_Approvaler__c = true;
        UPDATE capp1;
        Test.stopTest();
    }

        static testMethod void TestExtension() {
        RecordType rc = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Approval_Managed1__c' AND  DeveloperName = 'VisitorHosts'];       
        Contact con = new Contact(LastName = '测试人员',number__c = '123');
        insert con;

        Approval_Managed1__c am = new Approval_Managed1__c();
        AMVisitorHostsExtension  ah =new AMVisitorHostsExtension(new ApexPages.StandardController(am));

        am.Head_description__c='经验交流';
        am.visit_reason__c ='AFDSAFDAF'; 
        am.Factory__c= '1000';
        am.KOSTL__c= '1000E001';
        am.Reservation_type__c= '1 早餐';
        am.Dinner__c='白色风车';
        am.deliver_airline__c='asda';
        am.souvenir_YN__c= 'Y';
        am.deliver_plane_YN__c= 'Y';

        ah.save();


    }

}