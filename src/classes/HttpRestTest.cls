@isTest
private class HttpRestTest {
    @isTest
    static void testMethod1() {  

        Test.startTest();
        SAP_Interface_Setting__c sis = new SAP_Interface_Setting__c();
            sis.UserName__c = 'ZSAP03';
            sis.Password__c = 'sexrabbits';
            sis.HttpRestUrl__c  = 'http://59.120.231.206:8000/sap/bc/zhttp_rest?sap-client=400';
            sis.Name = 'SapSetting';
            insert sis;
        try{
            HttpRest hr = new HttpRest();
            hr.HttpGetSap('fun_name = demo' );   
         }catch(Exception ex){}
        Test.stopTest();
    }

    @isTest 
    static void testMethod2() {   
        Test.startTest();
        SAP_Interface_Setting__c sis = new SAP_Interface_Setting__c();
            sis.UserName__c = 'ZSAP03';
            sis.Password__c = 'sexrabbits';
            sis.HttpRestUrl__c  = 'http://59.120.231.206:8000/sap/bc/zhttp_rest?sap-client=400';
            sis.Name = 'SapSetting';
            insert sis;
        try{
            HttpRest hr = new HttpRest();
            hr.HttpPostSap('{\"approval\":\"SF_SYNC_PT60\"}'); 
         }catch(Exception ex){}   
        Test.stopTest();
    }

}