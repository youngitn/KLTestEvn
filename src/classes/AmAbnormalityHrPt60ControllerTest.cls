@isTest
private class AmAbnormalityHrPt60ControllerTest {
    static testMethod void testMethod1() {
        AbnormalityHrPt60 a = new AbnormalityHrPt60();
        a.pernr = 'a';

        	a.ename  = 'a';
	a.kurzt = 'a';
	a.ldate  = 'a';
	a.ltime  = 'a';
	a.ltime2  = 'a';
	a.error  = 'a';
	a.etext = 'a';
	a.schkz  = 'a';
	a.ttext  = 'a';
	a.sobeg  = 'a';
	a.soend  = 'a';
    }

    
    static testMethod void testMethod2() {
    	        SAP_Interface_Setting__c sis = new SAP_Interface_Setting__c();
            sis.UserName__c = 'ZSAP03';
            sis.Password__c = 'sexrabbits';
            sis.HttpRestUrl__c  = 'http://59.120.231.206:8000/sap/bc/zhttp_rest?sap-client=400';
            sis.Name = 'SapSetting';
            insert sis;
        AmAbnormalityHrPt60Controller a = new AmAbnormalityHrPt60Controller();
    }


}