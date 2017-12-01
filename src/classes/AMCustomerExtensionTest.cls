@isTest
private class AMCustomerExtensionTest {
    static testMethod void testSave() {

        TestUtil.createBasicData();
        Custom_Approval_Managed__c am = TestUtil.createCustomerData();

        AMCustomerExtension ext = new AMCustomerExtension(new ApexPages.StandardController(am));
        ext.rowID = 1;
        ext.saveAction();
        ext.cancelAction();
        ext.addBankDetail();
        ext.deleteBankDetail();
        ext.addTax();
        ext.removeTax();
        ext.addContact();
        ext.removeContact();
        ext.addPF();
        ext.removePF();
        Test.startTest();
        WebServiceMockImpl wbi = new WebServiceMockImpl();
        wbi.returnJson = '{"status":"1",  "approval":"CUSTOMER", "content":[{"main":{"corporation__c":"1000", "sales_org__c":"1000", "distribution_channel__c":"10", "product_group__c":"31", "account_name__c":"名称1", "account_number__c":"0002006740", "name_additional__c":"名称2", "title__c":"0001", "retrieve_item1__c":"检", "retrieve_item2__c":"检索", "province_name__c":"江苏省", "city_name__c":"苏州市", "corp_address__c":"公司地址", "city_name_of_shopping__c":"苏州市", "province_name_of_shopping__c":"江苏省", "shopping_address1__c":"送货地址1", "shopping_address2__c":"江苏省,苏州市,送货地址2", "billing_address1__c":"江苏省,苏州市,发票地址1", "billing_address2__c":"江苏省,苏州市,发票地址2",  "house_number__c":"门牌号", "postcode__c":"215300", "area_code__c":"010", "country_code__c":"CN", "language__c":"E", "sales_area__c":"00012", "sales_group__c":"003", "customer_group__c":"20", "currency__c":"CNY", "price_group__c":"14", "engrave_type__c":"3", "shipping_term__c":"01", "delivery_factory__c":"1000", "tax_number__c":"S1111132222", "delivery_priority__c":"01", "control_subject__c":"1122000000", "is_order_portfolio__c":"true", "international_trade_term__c":"CFR", "account_allot_group__c":"02", "sorting_code__c":"010",  "mobile_phone__c":"15850329129", "email__c":"cangcunzhou@kinglai.com.cn", "phone__c":"051257871991", "phone_extension_number__c":"10808", "fax__c":"21321", "fax_extension_number__c":"0101", "remark__c":"寄发票地址1", "invoice_address1__c":"寄发票地址2", "sales_remark__c":"对顾客的销售注释",  "subject_group__c":"Z002", "sales_dept__c":"0005", "term_of_payment__c":"YZ00", "term_of_payment1__c":"T090"}, "details":{"banks":[{"account_name__c":"teteeeee1", "bank_of_code__c":"SWEDSESS", "account_of_bank__c":"122112323213", "country_code__c":"SE", "ibanvalue__c":"SE1400000000122112323213", "validate_date__c":"2017-06-16", "swift_code__c":"SWEDSESS"}], "taxs":[{"country_code__c":"CN", "category_of_tax__c":"MWST", "type_of_tax__c":"1"}], "partners":[{"number_partner__c":"10210911", "pf__c":"PE"}, {"number_partner__c":"10210911", "pf__c":"ER"}], "contacts":[{"lastname":"CANGCUNZ", "phone":"0513-812123", "extension_number__c":"99999", "department__c":"0001", "functionally__c":"01", "mobilephone":"15850329129", "fax":"123213", "extension_number_fax__c":"12321", "email":"407828454@QQ.COM"}, {"lastname":"CA32Z", "phone":"0513-812123", "extension_number__c":"99999", "department__c":"0001", "functionally__c":"01", "mobilephone":"15850329129", "fax":"123213", "extension_number_fax__c":"12321", "email":"407828454@QQ.COM"}, {"lastname":"jjjj", "phone":"0513-812123", "extension_number__c":"99999", "department__c":"0001", "functionally__c":"01", "mobilephone":"15850329129", "fax":"123213", "extension_number_fax__c":"12321", "email":"407828454@QQ.COM"}]}}]}';
        Test.setMock(WebServiceMock.class, wbi);
        ext.queryCustomer();
        Test.stopTest();

        SapContentOfReturnArgs con = new SapContentOfReturnArgs();
        Map<String,String> main = new Map<String,String>();
        Map<String,List<Map<String,String>>> details = new Map<String,List<Map<String,String>>>();

        main.put('Dept_Name__c','系统运维课');
        main.put('Applicant_Code__c','10210911');
        main.put('Fax__c','0571-25784513');
        main.put('Product_Group__c','10');
        main.put('Shopping_Address1__c','昆山市陆家镇友谊路412号');
        main.put('Country_Name__c','中国');
        main.put('Province_Code_of_Shopping__c','3');
        main.put('Mobile_Phone__c','13899995566');
        main.put('Sales_Dept__c','0003');
        main.put('Currency__c','CNY');
        main.put('Corp_Address__c','陆家镇友谊路412号');
        main.put('City_Name_of_Shopping__c','苏州市');
        main.put('Distribution_Channel__c','10');
        main.put('Delivery_Priority__c','01');
        main.put('Delivery_Factory__c','1000');
        main.put('Customer_Group__c','30');
        main.put('Engrave_Type__c','1');
        main.put('City_Code_of_Shopping__c','3005');
        main.put('Fax_Extension_Number__c','228');
        main.put('Retrieve_Item1__c','DD');
        main.put('Tax_Number__c','02548789545645M');
        main.put('Approval_Status__c','D');
        main.put('Term_of_Payment__c','YB30');
        main.put('Country_Code__c','CN');
        main.put('Title__c','0001');
        main.put('Province_Name_of_Shopping__c','江苏省');
        main.put('Account_Allot_Group__c','01');
        main.put('Language__c','1');
        main.put('Account_Number__c','20004567');
        main.put('Area_Code__c','jiangsu');
        main.put('Sales_Group__c','002');
        main.put('Shipping_Term__c','01');
        main.put('Price_Group__c','24');
        main.put('Control_Subject__c','1121000000');
        main.put('Sales_Area__c','00012');
        main.put('Province_Code__c','3');
        main.put('Phone_Extension_Number__c','126');
        main.put('Term_of_Payment1__c','YZ27');
        main.put('Postcode__c','524000');
        main.put('City_Name__c','苏州市');
        main.put('Phone__c','0571-25784512');
        main.put('Corporation__c','1000');
        main.put('City_Additional__c','江苏');
        main.put('City_Code__c','3005');
        main.put('Email__c','10004567@qq.com');
        main.put('Industry__c','0020');
        main.put('Subject_Group__c','Z002');
        main.put('Is_Order_Portfolio__c','false');
        main.put('Status__c','新建');
        main.put('Province_Name__c','江苏省');
        main.put('Account_Name__c','江苏省第一人民医院');
        main.put('Approval_Name__c','客户主数据维护');

        con.main = main;

        Map<String,String> banks = new Map<String,String>();
        //Map<Id,Metadata__c> mapCountry;
        Metadata__c cou = [SELECT Id,Country_Code__c,Name, Area_Code__c, City_Code__c, Privince_Code__c 
                                            FROM Metadata__c 
                                            WHERE RecordType.DeveloperName  = 'Country'
                                            AND RecordType.SobjectType = 'Metadata__c'
                                            AND Country_Code__c = 'CN' LIMIT 1];
        banks.put('Country__c',cou.Id);
        banks.put('Country_Code__c','CN');
        banks.put('Country_Name__c','中国');
        banks.put('Account_of_Bank__c','9999999999');
        banks.put('Account_Name__c','测试名');
        banks.put('Name_of_Bank__c','3433');
        banks.put('IBANValue__c','343');
        banks.put('SWIFT_Code__c','232232');
        banks.put('Validate_Date__c','2049-12-31');
        details.put('banks', new List<Map<String,String>>{banks});

        Map<String,String> taxs = new Map<String,String>();
        taxs.put('Country_Code__c','CN');
        taxs.put('Country_Name__c','中国');
        taxs.put('Category_of_Tax__c','MWST');
        taxs.put('Type_of_Tax__c','1');
        details.put('taxs', new List<Map<String,String>>{taxs});

        Map<String,String> contacts = new Map<String,String>();
        contacts.put('LastName','张三');
        contacts.put('Phone','020-56484785');
        contacts.put('Extension_Number__c','222');
        contacts.put('Department','测试部');
        contacts.put('Department__c','0001');
        contacts.put('Functionally__c','01');
        contacts.put('MobilePhone','13567895686');
        contacts.put('Fax','020-35689546');
        contacts.put('Extension_Number_Fax__c','555');
        contacts.put('Email','testContact@kl.com');
        details.put('contacts', new List<Map<String,String>>{contacts});

        Map<String,String> partners = new Map<String,String>();
        partners.put('PF__c','BP');
        partners.put('Functionally__c','02');
        partners.put('Number__c','10002345');
        partners.put('LastName','张三丰');
        partners.put('Description_of_Partner__c','测试客户合伙人');
        details.put('partners', new List<Map<String,String>>{partners});

        con.details = details;
        ext.contentList = new List<SapContentOfReturnArgs>{con};
        ext.customerRow = 0;
        ext.selectCustomer();

    }
}