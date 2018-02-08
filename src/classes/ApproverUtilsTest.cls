@isTest
private class ApproverUtilsTest
{

    @isTest static void test_method_one()
    {
        Test.startTest();
        Profile pf = [SELECT Id FROM Profile WHERE name = '员工'];
        System.debug('pf->' + pf);
        UserRole ur = new UserRole(Name = 'Finance');
        insert ur;
        User usr = TestUserUtil.createTestUser(ur.Id, pf.Id, 'Test FirstName', 'Test LastName', '30210999');
        // Implement test code
        Organizational__c o = new Organizational__c();
        o.Approval_Rule__c  = '指定人部门主管';

        System.runAs(usr)
        {

            Contact con2 = new Contact(LastName = 'bbb', number__c = '30210999', SF_User__c = usr.id);
            insert con2;
            Contact con = !String.isBlank(con2.Id) ? Peoples.getInstance().KlAllContactMapGetById.get(con2.Id) : null;
            System.debug( Peoples.getInstance().KlAllContactMapGetById.get(con2.Id));
            ApproverUtils.approvalSearchApprrovalerByRuleWithOutSOQL(o, con2.Id);
        }
        Test.stopTest();
    }
    @isTest static void test_method_TWO()
    {
        Test.startTest();
        Profile pf = [SELECT Id FROM Profile WHERE name = '员工'];
        System.debug('pf->' + pf);
        UserRole ur = new UserRole(Name = 'Finance');
        insert ur;
        User usr = TestUserUtil.createTestUser(ur.Id, pf.Id, 'Test FirstName', 'Test LastName', '30210999');
        // Implement test code
        Organizational__c o = new Organizational__c();
        o.Approval_Rule__c  = '指定人一阶主管';

        System.runAs(usr)
        {


            
            Contact con2 = new Contact(LastName = 'bbb', number__c = '30210999', SF_User__c = usr.id);
            insert con2;
            ApproverUtils.approvalSearchApprrovalerByRuleWithOutSOQL(o, con2.Id);
        }
        Test.stopTest();
    }
    @isTest static void test_method_three()
    {
        Test.startTest();
        Profile pf = [SELECT Id FROM Profile WHERE name = '员工'];
        System.debug('pf->' + pf);
        UserRole ur = new UserRole(Name = 'Finance');
        insert ur;
        User usr = TestUserUtil.createTestUser(ur.Id, pf.Id, 'Test FirstName', 'Test LastName', '30210999');
        // Implement test code
        Organizational__c o = new Organizational__c();
        o.Approval_Rule__c  = '指定人上级主管';

        System.runAs(usr)
        {


            
            Contact con2 = new Contact(LastName = 'bbb', number__c = '30210999', SF_User__c = usr.id);
            insert con2;
            ApproverUtils.approvalSearchApprrovalerByRuleWithOutSOQL(o, con2.Id);
        }
        Test.stopTest();
    }
    @isTest static void test_method_Four()
    {
        Test.startTest();
        Profile pf = [SELECT Id FROM Profile WHERE name = '员工'];
        System.debug('pf->' + pf);
        UserRole ur = new UserRole(Name = 'Finance');
        insert ur;
        User usr = TestUserUtil.createTestUser(ur.Id, pf.Id, 'Test FirstName', 'Test LastName', '30210999');
        // Implement test code
        Organizational__c o = new Organizational__c();
        o.Approval_Rule__c  = '指定人员';

        System.runAs(usr)
        {


            
            Contact con2 = new Contact(LastName = 'bbb', number__c = '30210999', SF_User__c = usr.id);
            insert con2;
            ApproverUtils.approvalSearchApprrovalerByRuleWithOutSOQL(o, con2.Id);
        }
        Test.stopTest();
    }
    @isTest static void test_method_Five()
    {
        Test.startTest();
        Profile pf = [SELECT Id FROM Profile WHERE name = '员工'];
        System.debug('pf->' + pf);
        UserRole ur = new UserRole(Name = 'Finance');
        insert ur;
        User usr = TestUserUtil.createTestUser(ur.Id, pf.Id, 'Test FirstName', 'Test LastName', '30210999');
        // Implement test code
        Organizational__c o = new Organizational__c();
        o.Approval_Rule__c  = '指定岗位';
        
        System.runAs(usr)
        {


            
            Contact con2 = new Contact(LastName = 'bbb', number__c = '30210999', SF_User__c = usr.id);
            insert con2;
            ApproverUtils.approvalSearchApprrovalerByRuleWithOutSOQL(o, con2.Id);
        }
        Test.stopTest();
    }
    @isTest static void test_method_Six()
    {
        Test.startTest();
        Profile pf = [SELECT Id FROM Profile WHERE name = '员工'];
        System.debug('pf->' + pf);
        UserRole ur = new UserRole(Name = 'Finance');
        insert ur;
        User usr = TestUserUtil.createTestUser(ur.Id, pf.Id, 'Test FirstName', 'Test LastName', '30210999');
        // Implement test code
        Organizational__c o = new Organizational__c();
        o.Approval_Rule__c  = '指定部门';
        
        System.runAs(usr)
        {


            
            Contact con2 = new Contact(LastName = 'bbb', number__c = '30210999', SF_User__c = usr.id);
            insert con2;
            ApproverUtils.approvalSearchApprrovalerByRuleWithOutSOQL(o, con2.Id);
        }
        Test.stopTest();
    }
    @isTest static void test_method_seven()
    {
        Test.startTest();
        Profile pf = [SELECT Id FROM Profile WHERE name = '员工'];
        System.debug('pf->' + pf);
        UserRole ur = new UserRole(Name = 'Finance');
        insert ur;
        User usr = TestUserUtil.createTestUser(ur.Id, pf.Id, 'Test FirstName', 'Test LastName', '30210999');
        // Implement test code
        Organizational__c o = new Organizational__c();
        o.Approval_Rule__c  = '指定部门';
        
        System.runAs(usr)
        {


            
            Contact con2 = new Contact(LastName = 'bbb', number__c = '30210999', SF_User__c = usr.id);
            insert con2;
            ApproverUtils.approvalSearchManagerByApplicationWithOutSOQL(con2.Id,false);
            ApproverUtils.approvalSearchSpecificManagerByApplicationWithOutSOQL(usr.id, 5,true);
            ApproverUtils.approvalSearchManagerByApplicationWithOutSOQL(usr.id,true);
        }
        Test.stopTest();
    }

    @isTest static void test_method_eight()
    {
        Test.startTest();
        Profile pf = [SELECT Id FROM Profile WHERE name = '员工'];
        System.debug('pf->' + pf);
        UserRole ur = new UserRole(Name = 'Finance');
        insert ur;
        User usr = TestUserUtil.createTestUser(ur.Id, pf.Id, 'Test FirstName', 'Test LastName', '30210999');
        usr.Is_First_Manager__c=true;
        // Implement test code
        Organizational__c o = new Organizational__c();
        o.Approval_Rule__c  = '指定人部门主管';
        
        System.runAs(usr)
        {


            
            Contact con2 = new Contact(LastName = 'bbb', number__c = '30210999', SF_User__c = usr.id);
            insert con2;
            ApproverUtils.approvalSearchManagerByApplicationWithOutSOQL(con2.Id,false);
            ApproverUtils.approvalSearchSpecificManagerByApplicationWithOutSOQL(usr.id, 5,true);
            ApproverUtils.approvalSearchManagerByApplicationWithOutSOQL(usr.id,true);
            ApproverUtils.approvalSearchManagerByApplicationWithOutSOQL(null,true);
            ApproverUtils.approvalSearchApprrovalerByRuleWithOutSOQL(o, null);
        }
        Test.stopTest();
    }
    


}