@isTest
private class SyncToSfTest {
    static testMethod void testMethod0() {        
        Test.startTest();
        SyncToSf.doPost('1AP', '2017-06');
        Test.stopTest();
    }

    static testMethod void testMethod1() {        
        Test.startTest();
        SyncToSf.doPost('SAP', '2017-06');
        Test.stopTest();
    }

    static testMethod void testMethod2() {        
        Test.startTest();
        SyncToSf.doPost('SAP', '12345432');
        Test.stopTest();
    }

    static testMethod void testMethod3() {        
        Test.startTest();
        SyncToSf.doPost('SAP', '{"strSource":"sap","strJson":"{\"approval\": \"FunDemo1\",    }    }}"}');
        Test.stopTest();
    }

    static testMethod void testMethod4() {        
        Test.startTest();
        SyncToSf.doPost('SAP', '{approval: \"FunDemo\", content1: {main: {sapid__c: \"0010001138\", purchasing_request__c: \"0010001138\"}, details: {items: []}}}');
        Test.stopTest();
    }

    static testMethod void testMethod5() {        
        Test.startTest();
        SyncToSf.doPost('SAP', '{approval: \"FunDemo\", content: {main1: {sapid__c: \"0010001138\", purchasing_request__c: \"0010001138\"}, details: {items: []}}}');
        Test.stopTest();
    }

    static testMethod void testMethod6() {        
        Test.startTest();
        SyncToSf.doPost('SAP', '{approval: \"FunDemo\", content: {main1: {sapid__c: \"0010001138\", purchasing_request__c: \"0010001138\"}, details: {1items: []}}}');
        Test.stopTest();
    }

    static testMethod void testMethod7() {        
        Test.startTest();
        SyncToSf.doPost('SAP', '{approval: \"FunDemo\", content: {main: {sapid__c: \"0010001138\", purchasing_request__c: \"0010001138\"}, details: {items: []}}}');
        Test.stopTest();
    }
    
    static testMethod void testMethodX(){
        Test.startTest();
        String ttt = '';
        for(Integer i = 0;i<50100;i++){
            ttt = ttt + 'a';
        }
        SyncToSf.doPost('SAP', ttt);
        Test.stopTest();
    }
    

}