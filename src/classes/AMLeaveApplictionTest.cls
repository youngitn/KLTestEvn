@isTest
public class AMLeaveApplictionTest
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
            insert ami;
            upsert am;
            AMLeaveApplicationExtension.leaveAppSyncToSAP(am.Id);

        }

        Test.stopTest();

    }



    @isTest
    static void createRec()
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



            Approval_Managed_item__c ami = new Approval_Managed_item__c();



            AMLeaveApplicationExtension extension = new AMLeaveApplicationExtension(new ApexPages.StandardController(new Approval_Managed__c()));
            extension.am.Applicant__c = con2.Id;
            extension.am.Employee__c = con2.Id;
            extension.am.Annual_leave__c = '1.0';
            extension.am.Adjustable_vacation__c = '1.0';
            extension.sapInsertArgs = '{"status":"1", "message":"查詢成功", "check":"X", "leave_data":[{"time_number__c":"  8.00", "end_time__c":"170000", "end_date__c":"20180601", "start_time__c":"070000", "start_date__c":"20180601", "leave_reason__c":"asd", "typesofleave__c":"1001", "recordtypeid":"012O00000009mziIAA", "no":"0"}, {"time_number__c":"  8.00", "end_time__c":"170000", "end_date__c":"20180605", "start_time__c":"070000", "start_date__c":"20180605", "leave_reason__c":"sdfdsf", "typesofleave__c":"1001", "recordtypeid":"012O00000009mziIAA", "no":"1"}]}';
            ami.TypesOfLeave__c = '1006';
            ami.Leave_reason__c = 'test';
            ami.Start_date__c   = Date.today();
            ami.Start_Time__c   = '010000';
            ami.End_date__c   = Date.today();
            ami.End_Time__c   = '010000';
            ami.time_number__c  = '1.0';

            extension.list1 = new List<Approval_Managed_item__c>();
            extension.list1.add(ami);

            AMLeaveApplicationExtension.queryEmpId((String)con2.Id);
            AMLeaveApplicationExtension.queryVacation((String)con2.Id);
            AMLeaveApplicationExtension.queryVacation('');
            AMLeaveApplicationExtension.queryVacationTW((String)con2.Id);
            
            PageReference page = extension.saveAction();


        }

        Test.stopTest();


    }

    @isTest
    static void createRec2()
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



            Approval_Managed_item__c ami = new Approval_Managed_item__c();



            AMLeaveApplicationExtension extension = new AMLeaveApplicationExtension(new ApexPages.StandardController(new Approval_Managed__c()));
            extension.am.Applicant__c = con2.Id;
            extension.am.Employee__c = con2.Id;
            extension.am.Annual_leave__c = '1.0';
            extension.am.Adjustable_vacation__c = '1.0';
            extension.sapInsertArgs = '{"status":"1", "message":"查詢成功", "check":"X", "leave_data":[{"time_number__c":"  8.00", "end_time__c":"170000", "end_date__c":"20180601", "start_time__c":"070000", "start_date__c":"20180601", "leave_reason__c":"asd", "typesofleave__c":"1001", "recordtypeid":"012O00000009mziIAA", "no":"0"}, {"time_number__c":"  8.00", "end_time__c":"170000", "end_date__c":"20180605", "start_time__c":"070000", "start_date__c":"20180605", "leave_reason__c":"sdfdsf", "typesofleave__c":"1001", "recordtypeid":"012O00000009mziIAA", "no":"1"}]}';
            ami.TypesOfLeave__c = '1006';
            ami.Leave_reason__c = 'test';
            ami.Start_date__c   = Date.today();
            ami.Start_Time__c   = '010000';
            ami.End_date__c   = Date.today();
            ami.End_Time__c   = '010000';
            ami.time_number__c  = '1.0';
            //extension.deletelist1();
            extension.list1.add(ami);

            extension.hasError = 0;
            PageReference page = extension.saveAction();

        }

        Test.stopTest();


    }


    @isTest
    static void over3days()
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

            Contact con2 = new Contact(LastName = 'bbb', Take_Office_Date__c = Date.valueOf('2017-10-1'), number__c = '30210999', SF_User__c = usr.id );
            con2.RecordTypeId = rrid;
            insert con2;



            Approval_Managed_item__c ami = new Approval_Managed_item__c();



            AMLeaveApplicationExtension extension = new AMLeaveApplicationExtension(new ApexPages.StandardController(new Approval_Managed__c()));
            extension.am.Applicant__c = con2.Id;
            extension.am.Employee__c = con2.Id;
            extension.am.Annual_leave__c = '5.0';
            extension.am.Adjustable_vacation__c = '5.0';
            extension.sapInsertArgs = '{"status":"1", "message":"查詢成功", "check":"X", "leave_data":[{"time_number__c":"  8.00", "end_time__c":"170000", "end_date__c":"20180601", "start_time__c":"070000", "start_date__c":"20180601", "leave_reason__c":"asd", "typesofleave__c":"1001", "recordtypeid":"012O00000009mziIAA", "no":"0"}, {"time_number__c":"  8.00", "end_time__c":"170000", "end_date__c":"20180605", "start_time__c":"070000", "start_date__c":"20180605", "leave_reason__c":"sdfdsf", "typesofleave__c":"1001", "recordtypeid":"012O00000009mziIAA", "no":"1"}]}';
            ami.TypesOfLeave__c = '1006';
            ami.Leave_reason__c = 'test';
            ami.Start_date__c   = Date.today();
            ami.Start_Time__c   = '010000';
            ami.End_date__c   = Date.today();
            ami.End_Time__c   = '010000';
            ami.time_number__c  = '50.0';

            //extension.deletelist1();
            extension.list1.add(ami);

            //PageReference page = extension.saveAction();

        }

        Test.stopTest();


    }

    @isTest
    static void dateError()
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



            Approval_Managed_item__c ami = new Approval_Managed_item__c();



            AMLeaveApplicationExtension extension = new AMLeaveApplicationExtension(new ApexPages.StandardController(new Approval_Managed__c()));
            extension.am.Applicant__c = con2.Id;
            extension.am.Employee__c = con2.Id;
            extension.am.Annual_leave__c = '5.0';
            extension.am.Adjustable_vacation__c = '5.0';
            extension.sapInsertArgs = '{"status":"1", "message":"查詢成功", "check":"X", "leave_data":[{"time_number__c":"  8.00", "end_time__c":"170000", "end_date__c":"20180601", "start_time__c":"070000", "start_date__c":"20180601", "leave_reason__c":"asd", "typesofleave__c":"1001", "recordtypeid":"012O00000009mziIAA", "no":"0"}, {"time_number__c":"  8.00", "end_time__c":"170000", "end_date__c":"20180605", "start_time__c":"070000", "start_date__c":"20180605", "leave_reason__c":"sdfdsf", "typesofleave__c":"1001", "recordtypeid":"012O00000009mziIAA", "no":"1"}]}';
            ami.TypesOfLeave__c = '1006';
            ami.Leave_reason__c = 'test';
            ami.Start_date__c   = Date.today().addDays(5);
            ami.Start_Time__c   = '010000';
            ami.End_date__c   = Date.today();
            ami.End_Time__c   = '010000';
            ami.time_number__c  = '50.0';

            //extension.deletelist1();
            extension.list1.add(ami);

            PageReference page = extension.saveAction();

        }

        Test.stopTest();


    }

    @isTest
    static void leaveTimeSumError()
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



            Approval_Managed_item__c ami = new Approval_Managed_item__c();



            AMLeaveApplicationExtension extension = new AMLeaveApplicationExtension(new ApexPages.StandardController(new Approval_Managed__c()));
            extension.am.Applicant__c = con2.Id;
            extension.am.Employee__c = con2.Id;
            extension.am.Annual_leave__c = '5.0';
            extension.am.Adjustable_vacation__c = '5.0';
            extension.sapInsertArgs = '{"status":"1", "message":"查詢成功", "check":"X", "leave_data":[{"time_number__c":"  8.00", "end_time__c":"170000", "end_date__c":"20180601", "start_time__c":"070000", "start_date__c":"20180601", "leave_reason__c":"asd", "typesofleave__c":"1001", "recordtypeid":"012O00000009mziIAA", "no":"0"}, {"time_number__c":"  8.00", "end_time__c":"170000", "end_date__c":"20180605", "start_time__c":"070000", "start_date__c":"20180605", "leave_reason__c":"sdfdsf", "typesofleave__c":"1001", "recordtypeid":"012O00000009mziIAA", "no":"1"}]}';

            ami.TypesOfLeave__c = '1006';
            ami.Leave_reason__c = 'test';
            ami.Start_date__c   = Date.today().addDays(5);
            ami.Start_Time__c   = '010000';
            ami.End_date__c   = Date.today();
            ami.End_Time__c   = '010000';
            ami.time_number__c  = '0.0';

            //extension.deletelist1();
            extension.list1.add(ami);

            PageReference page = extension.saveAction();

        }

        Test.stopTest();


    }

    @isTest
    static void cancelActionTest()
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



            Approval_Managed_item__c ami = new Approval_Managed_item__c();



            AMLeaveApplicationExtension extension = new AMLeaveApplicationExtension(new ApexPages.StandardController(new Approval_Managed__c()));
            extension.am.Applicant__c = con2.Id;
            extension.am.Employee__c = con2.Id;
            extension.am.Annual_leave__c = '1.0';
            extension.am.Adjustable_vacation__c = '1.0';
            extension.sapInsertArgs = '{"status":"1", "message":"查詢成功", "check":"X", "leave_data":[{"time_number__c":"  8.00", "end_time__c":"170000", "end_date__c":"20180601", "start_time__c":"070000", "start_date__c":"20180601", "leave_reason__c":"asd", "typesofleave__c":"1001", "recordtypeid":"012O00000009mziIAA", "no":"0"}, {"time_number__c":"  8.00", "end_time__c":"170000", "end_date__c":"20180605", "start_time__c":"070000", "start_date__c":"20180605", "leave_reason__c":"sdfdsf", "typesofleave__c":"1001", "recordtypeid":"012O00000009mziIAA", "no":"1"}]}';
            ami.TypesOfLeave__c = '1006';
            ami.Leave_reason__c = 'test';
            ami.Start_date__c   = Date.today();
            ami.Start_Time__c   = '010000';
            ami.End_date__c   = Date.today();
            ami.End_Time__c   = '010000';
            ami.time_number__c  = '1.0';
            //extension.deletelist1();
            extension.list1.add(ami);


            PageReference page = extension.cancelAction();

        }

        Test.stopTest();


    }

    @isTest
    static void futureTest()
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

            Contact con2 = new Contact(LastName = 'bbb', number__c = '30210999', SF_User__c = usr.id , Take_Office_Date__c = Date.valueOf('2014-5-1'));
            con2.RecordTypeId = rrid;
            insert con2;



            Approval_Managed_item__c ami = new Approval_Managed_item__c();



            AMLeaveApplicationExtension extension = new AMLeaveApplicationExtension(new ApexPages.StandardController(new Approval_Managed__c()));
            extension.am.Applicant__c = con2.Id;
            extension.am.Employee__c = con2.Id;
            extension.am.Annual_leave__c = '1';
            extension.am.Adjustable_vacation__c = '1.0';
            extension.am.Warehouse_confirmation__c = '1.0';
            extension.sapInsertArgs = '{"status":"1", "message":"查詢成功", "check":"X", "leave_data":[{"time_number__c":"  8.00", "end_time__c":"170000", "end_date__c":"20180601", "start_time__c":"070000", "start_date__c":"20180601", "leave_reason__c":"asd", "typesofleave__c":"1001", "recordtypeid":"012O00000009mziIAA", "no":"0"}, {"time_number__c":"  8.00", "end_time__c":"170000", "end_date__c":"20180605", "start_time__c":"070000", "start_date__c":"20180605", "leave_reason__c":"sdfdsf", "typesofleave__c":"1001", "recordtypeid":"012O00000009mziIAA", "no":"1"}]}';
            ami.TypesOfLeave__c = '1006';
            ami.Leave_reason__c = 'test';
            ami.Start_date__c   = Date.valueOf('2018-5-5');
            ami.Start_Time__c   = '010000';
            ami.End_date__c   = Date.valueOf('2018-5-5');
            ami.End_Time__c   = '010000';
            ami.Time_number__c = '1.0';

            extension.newlist1();
            extension.list1.add(ami);
            extension.deletelist1();
            extension.list1.add(ami);
            PageReference page = extension.saveAction();

        }

        Test.stopTest();


    }

}