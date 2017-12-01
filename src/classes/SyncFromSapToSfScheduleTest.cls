@isTest
private class SyncFromSapToSfScheduleTest {
    static testMethod void test1() {
    	Test.startTest();

    	TestUtil.createBasicData();
    	List<Contact> cons = [SELECT Id,Number__c FROM Contact WHERE RecordType.DeveloperName='Staff' LIMIT 10];
    	SyncFromSapToSfSchedule sc = new SyncFromSapToSfSchedule();
        sc.execute(null);

        SyncSapToSfReturnArgs args = new SyncSapToSfReturnArgs();
        SapContentOfReturnArgs con = new SapContentOfReturnArgs();
        Map<String,String> main = new Map<String,String>();
        Map<String,List<Map<String,String>>> details = new Map<String,List<Map<String,String>>>();
        con.main = main;
        con.details = details;
        args.status = '1';
        args.message = '成功';
        args.keyno = '10000';
        args.approval = SapApprovalEnum.ABNORMALQUALITY;
        args.content = con;

        main.put('Applicant_Code__c', cons[0].Number__c);
        Map<String,String> pro = new Map<String,String>();
        pro.put('Row_Index__c', '0001');
        pro.put('Code_Group__c', '01');
        pro.put('Type_of_Bug__c', '02');
        details.put('problems', new List<Map<String,String>>{pro});
        SyncFromSapToSfSchedule.syncAbnormalQuality(args);

        Test.stopTest();
    }
    static testMethod void test2() {
        Test.startTest();

        TestUtil.createBasicData();
        List<Contact> cons = [SELECT Id,Number__c FROM Contact WHERE RecordType.DeveloperName='Staff' LIMIT 10];
        SyncFromSapToSfSchedule sc = new SyncFromSapToSfSchedule();
        sc.execute(null);

        SyncSapToSfReturnArgs args = new SyncSapToSfReturnArgs();
        SapContentOfReturnArgs con = new SapContentOfReturnArgs();
        Map<String,String> main = new Map<String,String>();
        Map<String,List<Map<String,String>>> details = new Map<String,List<Map<String,String>>>();
        
        main.put('Expense_Type_Prepay__c', '10');
        main.put('Corporation__c','1000');
        main.put('Type_of_Payment__c','02');
        main.put('Dept_of_CostCenter__c','1000E007');
        main.put('Dept_PR_Approval__c','1000E001');
        main.put('Amount_Prepay__c','21546.22');
        con.main = main;
        con.details = details;
        args.status = '1';
        args.message = '成功';
        args.keyno = '10001';
        args.approval = SapApprovalEnum.ADVANCECHARGE;
        args.content = con;

        SyncFromSapToSfSchedule.syncAdvanceCharge(args);

        Test.stopTest();
    }
    static testMethod void test3() {
        Test.startTest();

        TestUtil.createBasicData();
        List<Contact> cons = [SELECT Id,Number__c FROM Contact WHERE RecordType.DeveloperName='Staff' LIMIT 10];
        SyncFromSapToSfSchedule sc = new SyncFromSapToSfSchedule();
        sc.execute(null);

        SyncSapToSfReturnArgs args = new SyncSapToSfReturnArgs();
        SapContentOfReturnArgs con = new SapContentOfReturnArgs();
        Map<String,String> main = new Map<String,String>();
        Map<String,List<Map<String,String>>> details = new Map<String,List<Map<String,String>>>();
        main.put('Number_of_Purchase_Info__c','24554515');
        main.put('Status_of_Purchase_Info__c','A');
        main.put('Kind_of_Material__c','003');
        con.main = main;

        Map<String,String> items = new Map<String,String>();
        items.put('Applicant_Code__c', cons[2].Number__c);
        items.put('Row_Index__c','10');
        items.put('Selected__c','是');
        items.put('Quote__c','Q.12488554544');
        items.put('Quote_Item__c','10');
        items.put('Number_of_Purchase__c','P.545455551');
        items.put('Number_of_Item__c','20');
        items.put('Vendor_Number__c','10005648');
        items.put('Vendor_Name__c','江苏来来不锈钢厂');
        items.put('Material_Number__c','M55845855');
        items.put('Material_Name__c','测试物料名称');
        items.put('Material_Number_of_Vendor__c','QM578545554');
        items.put('Category_Text__c','005');
        items.put('Quote_Request_Date__c','2017-07-04');
        items.put('Factory__c','1000');
        items.put('Request_Track_No__c','10');
        items.put('Material_Group__c','02');
        items.put('Purchase_Info_Number__c','24554515');
        items.put('Price_of_Purchase_Voucher__c','12.5');
        items.put('Price_of_Quantity__c','50');
        items.put('End_Date__c','2017-07-25');
        items.put('Currency__c','CNY');
        items.put('Exchange_Rate__c','1.0');
        items.put('Price_of_Last__c','12.5');
        items.put('Date_of_Last_Trade__c','2017-05-05');
        items.put('Type_of_Tax__c','1');
        items.put('Tax_Number__c','J1');
        items.put('Quantity_of_RFQ__c', '584');
        items.put('Days_of_Delivery_Period__c','7');
        items.put('Kind_of_Material__c','01');
        items.put('Days_of_Validity__c','90');
        items.put('Quantity_of_Min_Order__c','50');
        items.put('Price_of_Moving_Average__c','12.22');
        details.put('items', new List<Map<String,String>>{items});

        Map<String,String> zrows = new Map<String,String>();
        items.put('Row_Index__c','10');
        items.put('Index_Item__c','10');
        items.put('Purchase_Org__c','1000');
        items.put('Factory__c','1000');
        items.put('Purchase_Info_Number__c','24554515');
        items.put('Created_Date__c','2017-07-08');
        items.put('Price__c','12.5');
        items.put('Currency__c','CNY');
        items.put('Price_of_Quantity__c','50');
        items.put('Term_Unit__c','0001');
        items.put('Start_Date__c','2017-07-05');
        items.put('End_Date__c','2017-09-30');
        items.put('Term_Number__c','NO.68754455');
        details.put('zrows', new List<Map<String,String>>{zrows});

        con.details = details;
        args.status = '1';
        args.message = '成功';
        args.keyno = '10002';
        args.approval = SapApprovalEnum.PURCHASEINFORMATION;
        args.content = con;
        SyncFromSapToSfSchedule.syncPurchaseInformation(args);

        Test.stopTest();
    }
    static testMethod void test4() {
        Test.startTest();

        TestUtil.createBasicData();
        List<Contact> cons = [SELECT Id,Number__c FROM Contact WHERE RecordType.DeveloperName='Staff' LIMIT 10];
        SyncFromSapToSfSchedule sc = new SyncFromSapToSfSchedule();
        sc.execute(null);

        SyncSapToSfReturnArgs args = new SyncSapToSfReturnArgs();
        SapContentOfReturnArgs con = new SapContentOfReturnArgs();
        Map<String,String> main = new Map<String,String>();
        Map<String,List<Map<String,String>>> details = new Map<String,List<Map<String,String>>>();
        
        main.put('Applicant__c',cons[0].Id);
        main.put('Kind_of_Order__c','NB');
        main.put('Bill_No__c','NB.58741464');
        main.put('Purchase_Date__c','2017-07-12');
        main.put('Purchase_Org__c','1000');
        main.put('Purchase_Group__c','100');
        main.put('Corporation__c','1000');
        main.put('Currency__c','CNY');
        main.put('Days_of_Payment__c','7');
        main.put('Percent_of_Payment__c','0.5');
        main.put('Exchange_Rate__c','1');
        main.put('Term_of_Payment__c','XA07');
        main.put('Days_of_Payment_Term__c','7');
        main.put('Percent_of_Payment_Term__c','0.5');
        main.put('Amount_Net_Days__c','15.6');
        main.put('International_Trade_Term__c','CIF');
        main.put('Required_date__c','2017-07-15');
        main.put('Is_Receipt_Info__c','true');
        con.main = main;

        Map<String,String> items = new Map<String,String>();
        items.put('Row_Index__c','10');
        items.put('Index_Item__c','0001');
        items.put('Material_Number__c','M12457545');
        items.put('Material_Name__c','测试物料名称');
        items.put('Quantity__c','1000');
        items.put('Unit__c','个');
        items.put('Delivery_Date__c','2017-07-13');
        items.put('Price_Net__c','12.5');
        items.put('Currency__c','CNY');
        items.put('Price_Tax__c','13.8');
        items.put('Currency_Tax__c','CNY');
        items.put('Vendor_Response__c','2017-07-18');
        items.put('Last_Pick_Date__c','2017-06-13');
        items.put('Last_Pick_Price__c','13.7');
        items.put('Last_Pick_Currency__c','CNY');
        items.put('Per__c','500');
        items.put('Unit3__c','个');
        items.put('Factory__c','1000');
        items.put('Applicant__c',cons[1].Id);
        items.put('Is_Free__c','false');
        items.put('Purchase_Order_Number__c','PO1244444');
        items.put('Applicant_Row__c','10');
        items.put('Amount_Price__c','13.8');
        items.put('Last_Pick_Number__c','PO1223441');
        items.put('Dept_of_CostCenter__c','1000E005');
        items.put('Item__c','0002');
        items.put('Sales_Amount_Total__c','15643');
        items.put('Ledger_Account__c','8000190000');
        details.put('items', new List<Map<String,String>>{items});

        Map<String,String> prices = new Map<String,String>();
        prices.put('Row_Index__c','10');
        prices.put('Index_Item__c','10');
        prices.put('Type_of_Price__c','研发');
        prices.put('Name_of_Price__c','研发');
        prices.put('Value_of_Price__c','15.8');
        prices.put('Currency__c','CNY');
        details.put('prices', new List<Map<String,String>>{prices});

        con.details = details;
        args.status = '1';
        args.message = '成功';
        args.keyno = '10003';
        args.approval = SapApprovalEnum.PURCHASEORDER;
        args.content = con;
        SyncFromSapToSfSchedule.syncPurchaseOrder(args);

        List<Map<String,String>> keys = new List<Map<String,String>>();
        Map<String,String> key = new Map<String,String>();
        key.put('keyno', '121232323');
        key.put('status', '1');
        keys.add(key);
        SyncFromSapToSfSchedule.createSapSynchronousResult(keys);

        Test.stopTest();
    }
    static testMethod void test5() {
        Test.startTest();

        TestUtil.createBasicData();
        List<Contact> cons = [SELECT Id,Number__c FROM Contact WHERE RecordType.DeveloperName='Staff' LIMIT 10];
        SyncFromSapToSfSchedule sc = new SyncFromSapToSfSchedule();
        sc.execute(null);

        SyncSapToSfReturnArgs args = new SyncSapToSfReturnArgs();
        SapContentOfReturnArgs con = new SapContentOfReturnArgs();
        Map<String,String> main = new Map<String,String>();
        Map<String,List<Map<String,String>>> details = new Map<String,List<Map<String,String>>>();
        
        main.put('Kind_of_Order__c','Z001');
        main.put('Bill_No__c','ORD.5487122');
        main.put('Is_Agree_Refund__c','true');
        main.put('Type_of_Approval__c','01');
        main.put('Customer_Code__c','CUR.588445565');
        main.put('Customer_Name__c','测试客户名称');
        main.put('Delivery_Party_Code__c','0001');
        main.put('Delivery_Party_Name__c','圆通快递');
        main.put('Weight_Total__c','14512');
        main.put('Opportunity_Code__c','OP.94941551');
        main.put('Sales_Org__c','1000');
        main.put('Distribution_Channel__c','10');
        main.put('Product_Group__c','11');
        main.put('Price_Group__c','14');
        main.put('Customer_Group__c','50');
        main.put('Sales_Area__c','00001');
        main.put('Sales_Office_Area__c','上海');
        main.put('Sales_Group__c','001');
        main.put('Is_Based_Quotation__c','true');
        main.put('Code_Reference__c','Q.564845224');
        main.put('Currency_Reference__c','CNY');
        main.put('Amount_Reference__c','54424');
        main.put('Info_of_Discount__c','95折');
        main.put('Text1_Additional__c','补充文本1');
        main.put('Term_of_Contract__c','合同附文');
        main.put('Remark__c','备注信息');
        main.put('NotStandard_Price_Flag__c','非标件价格判定标记');
        main.put('Prepare_Feed_Protocol__c','备料单协议');
        main.put('Sales_Employee__c','销售员1');
        con.main = main;

        Map<String,String> items = new Map<String,String>();
        items.put('Row_Index__c','10');
        items.put('Index_Item__c','10');
        items.put('Material_Number__c','M1245782');
        items.put('Material_Name__c','测试物料名称');
        items.put('Quantity__c','4500');
        items.put('Unit__c','个');
        items.put('Status_Overview__c','总揽状态');
        items.put('Material_of_Customer__c','245784155');
        items.put('Schedule_Date__c','2017-07-05');
        items.put('Price_Net__c','12.8');
        items.put('Currency__c','CNY');
        items.put('Reason__c','原因');
        items.put('Your_Reference__c','你的参考');
        items.put('Material_Cost__c','12.8');
        items.put('Operate_Flag__c','操作标记 ');
        items.put('Operate_Type__c','操作类型');
        details.put('items', new List<Map<String,String>>{items});

        Map<String,String> zrows = new Map<String,String>();
        zrows.put('Type_of_Price__c','0002');
        zrows.put('Name_of_Price__c','95折');
        zrows.put('Amount__c','1245');
        zrows.put('Currency__c','CNY');
        zrows.put('Quantity__c','4500');
        zrows.put('Uom__c','Uom');
        zrows.put('Value_of_Price__c','12.8');
        details.put('zrows', new List<Map<String,String>>{zrows});

        Map<String,String> partners = new Map<String,String>();
        partners.put('LastName', 'aaatest');
        partners.put('Row_Index__c', '10');
        partners.put('Index_Item__c', '10');
        partners.put('Type_of_Price__c', '0002');
        partners.put('Name_of_Price__c', '95折');
        partners.put('Amount__c', '2457');
        partners.put('Currency__c', 'CNY');
        partners.put('Quantity__c', '4500');
        partners.put('Uom__c', 'Uom');
        partners.put('Value_of_Price__c', '15.5');
        details.put('partners', new List<Map<String,String>>{partners});

        Map<String,String> headers = new Map<String,String>();
        headers.put('PF__c','BP');
        headers.put('Functionally__c','02');
        headers.put('Number_Partner__c','10002345');
        headers.put('LastName','张三丰');
        headers.put('Description_of_Partner__c','测试销售订单合伙人');
        details.put('headers', new List<Map<String,String>>{headers});

        con.details = details;
        args.status = '1';
        args.message = '成功';
        args.keyno = '10004';
        args.approval = SapApprovalEnum.SALEORDER;
        args.content = con;

        SyncFromSapToSfSchedule.syncSaleOrder(args);

        List<Map<String,String>> keys = new List<Map<String,String>>();
        Map<String,String> key = new Map<String,String>();
        key.put('keyno', '121232323');
        key.put('status', '0');
        keys.add(key);
        SyncFromSapToSfSchedule.createSapSynchronousResult(keys);

        Test.stopTest();
    }
}