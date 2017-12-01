/**
* @author exia.huang
* @homepage http://salesforcexytools.com
*/
@isTest
private class HarryUtilsTest {

    /**
     * This is a test method for insertString
     */
    static testMethod void test_insertString() {

        Test.startTest();

        String input='abcdefghijklmnopqrstuvwxyz';
        String str='\n';
        Integer index=15;
        String result_insertString = HarryUtils.insertString(input , str , index);

        Test.stopTest();

    }


    /**
     * This is a test method for wrapWordInPdf
     */
    static testMethod void test_wrapWordInPdf() {


        Test.startTest();

        String input ='abcdefghijklmnopqrstuvwxyz';
        String character ='<br>';
        Integer width =15;
        String result_wrapWordInPdf = HarryUtils.wrapWordInPdf(input , character , width);

        Test.stopTest();

    }


    /**
     * This is a test method for date2string
     */
    static testMethod void test_date2string() {

        Test.startTest();

        Datetime dt = Datetime.now();
        String result_date2string = HarryUtils.date2string(dt);

        Test.stopTest();

    }


    /**
     * This is a test method for date2string
     */
    static testMethod void test_date2string_2() {


        Test.startTest();

        Datetime dt = Datetime.now();
        String formatString = 'yyyy/MM/dd HH:mm:ss';
        String result_date2string = HarryUtils.date2string(dt , formatString);

        Test.stopTest();

    }


    /**
     * This is a test method for date2string
     */
    static testMethod void test_date2string_3() {

        Test.startTest();

        Date d = Date.today();
        String result_date2string = HarryUtils.date2string(d);

        Test.stopTest();

    }


    /**
     * This is a test method for date2string
     */
    static testMethod void test_date2string_4() {


        Test.startTest();

        Date d = Date.today();
        String formatString = 'yyyy/MM/dd';
        String result_date2string = HarryUtils.date2string(d , formatString);

        Test.stopTest();

    }


    /**
     * This is a test method for getRecordTypeIdByDevNameAndObjName
     */
    static testMethod void test_getRecordTypeIdByDevNameAndObjName() {

        Test.startTest();

        // String name='';
        // String sobjectType = 'Account';
        // Id result_getRecordTypeIdByDevNameAndObjName = HarryUtils.getRecordTypeIdByDevNameAndObjName(name , sobjectType);

        Test.stopTest();

    }


    /**
     * This is a test method for getAllSubRoleIds
     */
    static testMethod void test_getAllSubRoleIds() {


        Test.startTest();

        // Set<Id> roleIds = new Set<Id>();
        // return Set , please fix
        // HarryUtils.getAllSubRoleIds(roleIds);

        Test.stopTest();

    }


    /**
     * This is a test method for compareObjtype
     */
    static testMethod void test_compareObjtype() {

        Test.startTest();

        // SObject compare = '';
        // String checkType = '';
        // Boolean result_compareObjtype = HarryUtils.compareObjtype(compare , checkType);

        Test.stopTest();

    }


    /**
     * This is a test method for str2Dt
     */
    static testMethod void test_str2Dt() {


        Test.startTest();

        String dtStr='2017-01-24 15:30:24';
        Datetime result_str2Dt = HarryUtils.str2Dt(dtStr);

        Test.stopTest();

    }


    /**
     * This is a test method for str2Date
     */
    static testMethod void test_str2Date() {

        Test.startTest();

        String dStr = '2017-01-24';
        Date result_str2Date = HarryUtils.str2Date(dStr);

        Test.stopTest();

    }


    /**
     * This is a test method for hlyBooleanConvert
     */
    static testMethod void test_hlyBooleanConvert() {


        Test.startTest();

        String bl = 'Y';
        Boolean result_hlyBooleanConvert = HarryUtils.hlyBooleanConvert(bl);

        Test.stopTest();

    }

}