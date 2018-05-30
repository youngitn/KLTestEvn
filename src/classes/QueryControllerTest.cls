@isTest
public with sharing class QueryControllerTest {
	 @isTest
    static void  testMethod1()
    {
        Test.startTest();

        //amIt.isDeletedStatus = true;
        //amIt.save();
        //amIt.cancel();
        System.debug('@@ ' + [SELECT Id, name FROM user ].get(0).name); //有資料

        Profile pf = [SELECT Id FROM Profile WHERE name = '员工'];
        System.debug('pf->' + pf);
        /*AMEducationTrainingHandler ameth=new AMEducationTrainingHandler();
        ameth.test1();
        ameth.test2();
        ameth.test3();
        ameth.test4();
        ameth.test5();*/

        UserRole ur = new UserRole(Name = 'Finance');
        insert ur;
        User usr = TestUserUtil.createTestUser(ur.Id, pf.Id, 'Test FirstName', 'Test LastName', '30210999');

        System.runAs(usr)
        {

            Contact con2 = new Contact(Corp_Code__c='3000',LastName = 'bbb', number__c = '30210999', SF_User__c = usr.id , Email = 'test@test.com');
            insert con2;
            //隨便找個rcID
            RecordType rc = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Approval_Managed1__c' AND  DeveloperName = 'EducationTraining'];
            //QueryController 執行建構式
            QueryController qc = new QueryController();
            //執行靜態方法
            QueryController.doQuery('{"sobjName":"Approval_Managed1__c","recordTypeId":"'+rc.Id+'","SOQL":"select id from Approval_Managed1__c limit 1 "}');
            //執行靜態方法
            QueryController.getEmpId(con2.id);
            qc.meta.Department = '123';
            //工號
	        qc.meta.Number__c = '30210999';
	       
	        //姓名
	        qc.meta.SAPID__c = 'aaa';
	        
	        //Email
	        qc.meta.Native_Place__c = 'aaa@aa.com';
       
            qc.query();

        }

        test.stopTest();
    }

     @isTest
    static void  testMethod2()
    {
        Test.startTest();

        //amIt.isDeletedStatus = true;
        //amIt.save();
        //amIt.cancel();
        System.debug('@@ ' + [SELECT Id, name FROM user ].get(0).name); //有資料

        Profile pf = [SELECT Id FROM Profile WHERE name = '员工'];
        System.debug('pf->' + pf);
        

        UserRole ur = new UserRole(Name = 'Finance');
        insert ur;
        User usr = TestUserUtil.createTestUser(ur.Id, pf.Id, 'Test FirstName', 'Test LastName', '30210999');

        System.runAs(usr)
        {

            Contact con2 = new Contact(LastName = 'bbb', number__c = '30210999', SF_User__c = usr.id , Email = 'test@test.com',Human_Range__c = '3000');

            insert con2;
          
            QueryController qc = new QueryController();
            //工號
	        qc.meta.Number__c = '30210999';
       		qc.meta.Human_Range__c = '3000';
            qc.query();

        }

        test.stopTest();
    }
}