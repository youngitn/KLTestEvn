@isTest
private class AMVisitorHostsTest {
    static testMethod void testMethod1() {
         RecordType rc = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Approval_Managed1__c' AND  DeveloperName = 'VisitorHosts'];
        
    	Contact con = new Contact(LastName = '测试人员',number__c = '123');
        insert con;

        Approval_Managed1__c capp1 = new Approval_Managed1__c();
        capp1.Applicant__c = con.Id;
        capp1.RecordTypeId = rc.Id;

        INSERT capp1;


        capp1.Applicant__c = con.Id;
        capp1.RecordTypeId = rc.Id;

        UPDATE capp1;


    }

        static testMethod void TestExtension() {
         RecordType rc = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Approval_Managed1__c' AND  DeveloperName = 'VisitorHosts'];       
        Contact con = new Contact(LastName = '测试人员',number__c = '123');
        insert con;

        Approval_Managed1__c am = new Approval_Managed1__c();
        AMVisitorHostsExtension  ah =new AMVisitorHostsExtension(new ApexPages.StandardController(am));


        am.Head_description__c='经验交流';
        am.Factory__c= '1000';
        am.KOSTL__c= '1000E001';
        am.Reservation_type__c= '1 早餐';
        am.Creation_date__c=Date.today();
        am.Ordering_time__c=Date.today();
        am.Eat_number__c=2+'';
        am.CustomerName__c='龙卷风';
        am.Dinner__c='白色风车';
        am.deliver_airline__c='asda';
        am.souvenir_YN__c= 'Y';
        am.pickup_car_time__c=Date.today();
        am.deliver_plane_YN__c= 'Y';
        ah.save();
   



    }
 




}