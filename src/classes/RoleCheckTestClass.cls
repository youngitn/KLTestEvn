@isTest
private class RoleCheckTestClass
{
    static testMethod void insertUser1()
    {
        Profile pf = [SELECT Id FROM Profile WHERE name = '员工'];
       
        UserRole ur = new UserRole(Name = 'Finance Approver');
        insert ur;
        User usr = TestUserUtil.createTestUser(ur.Id, pf.Id, 'Test FirstName', 'Test LastName');
        try
        {
            insert usr;
         }
         Catch(DMLException e)
         {
         
         }
       
    }
    
     static testMethod void insertUser2()
    {
        Profile pf = [SELECT Id FROM Profile WHERE name = '员工'];
       
        UserRole ur = new UserRole(Name = 'Finance');
        insert ur;
        User usr = TestUserUtil.createTestUser(ur.Id, pf.Id, 'Test FirstName', 'Test LastName');
        insert usr;
        
        UserRole ur1 = new UserRole(Name = 'Finance Approver');
        insert ur1;
        usr.UserRoleId = ur1.Id;
        
        try
        {
        update usr;
        }
        catch(Exception e)
        {
        
        }
       
    }
}