@isTest
public class RemoteActionsOfLeaveTest
{

    @isTest
    static void doUpdate()
    {
        Test.startTest();

        System.debug('@@ ' + [SELECT Id, name FROM user ].get(0).name); //有資料

        Profile pf = [SELECT Id FROM Profile WHERE name = '员工'];
        Id rrid = [Select Id, RecordType.DeveloperName From RecordType where RecordType.DeveloperName = 'staff'].get(0).Id;
        System.debug('pf->' + pf);
        UserRole ur = new UserRole(Name = 'Finance');
        insert ur;
        User usr = TestUserUtil.createTestUser(ur.Id, pf.Id, 'Test FirstName', 'Test LastName', '30210999');
        User usr2 = TestUserUtil.createTestUser(ur.Id, pf.Id, 'Test FirstName2', 'Test LastName2', '30210378');

        System.runAs(usr)
        {

            Contact con2 = new Contact(LastName = 'bbb', number__c = '30210999', Take_Office_Date__c = Date.valueOf('2017-10-1'), SF_User__c = usr.id );
            con2.RecordTypeId = rrid;
            insert con2;



            Approval_Managed__c am = new Approval_Managed__c();
            Approval_Managed_item__c ami = new Approval_Managed_item__c();
            am.RecordTypeId = HarryUtils.getRecordTypeIdByDevNameAndObjName( '請假申請流程', 'Approval_Managed__c');
            am.Employee__c = con2.Id;
            am.Employee_code__c = con2.Number__c;
            upsert am;
            am = [select id from Approval_Managed__c where RecordTypeId =: HarryUtils.getRecordTypeIdByDevNameAndObjName( '請假申請流程', 'Approval_Managed__c')].get(0);
            am.Annual_leave__c = '1.0';
            am.Approval_Status__c = 'S';
            ami.TypesOfLeave__c = '1006';
            ami.Leave_reason__c = 'test';
            ami.Start_date__c   = Date.today();
            ami.Start_Time__c   = '010000';
            ami.End_date__c   = Date.today();
            ami.End_Time__c   = '010000';
            ami.time_number__c  = '1.0';
            ami.LeaveManage__c = am.id;
            List<Approval_Managed_item__c> al = new List<Approval_Managed_item__c>();
            al.add(ami);
            insert ami;
            upsert am;

            RemoteActionsOfLeave.queryVacationTW(con2.id+'','aaaa');
            RemoteActionsOfLeave.queryVacationTW(con2.id+'');
            RemoteActionsOfLeave.queryVacation(con2.id+'');

        }

        Test.stopTest();

    }

}