/**********************************************************************
 名    称：从SAP同步数据到SF 
 目    的：把SAP放在同步队列中的数据同步到SF
 作    者：刘文俊(liuwenjun@bluelinksys.com)
 创建日期：2017-05-12
 修 改 人：zhonghui
 修改日期：5-20
 修改原因：处理同步来的数据
 备    注：

 执行脚本：
 SyncFromSapToSfSchedule sc = new SyncFromSapToSfSchedule();
 String fmt = '5 5 10 20 5 ? 2017';//指定时间执行一次(2017-05-20 10:05:05)执行
 System.schedule('SF同步数据到SAP；'+ Datetime.now().format('yyyyMMddHHmmss'), fmt, sc);
 
 脚本执行步骤：
  1、通知SAP上次记录同步结果
  2、发送同步请求到SAP，SAP返回要同步的数据
  3、接收到同步返回结果后分类处理返回结果
  4、生成新的同步任务
 **********************************************************************/
global class SyncFromSapToSfSchedule implements Schedulable {
    global void execute(SchedulableContext sc) {
        try{
            System_Setting__c ssc = System_Setting__c.getValues('Setting');
            Integer count = Integer.valueOf(ssc.SAP_Sync_Count__c);
            // 1、通知SAP上次记录同步结果
            syncResultToSap();
            // 2、发送同步请求到SAP，SAP返回要同步的数据
            syncFromSAP(count);

        }catch(Exception ex){
            System.debug('从SAP同步数据到SF时出错：' + ex.getMessage() + ex.getStackTraceString());
        }
        finally{
            // ４、生成新的同步任务
            createNewSchedule();
        }
    }
    //同步上一次的数据同步结果给SAP
    @Future(callout=true)
    private static void syncResultToSap(){
        List<Metadata__c> jobs = [
            SELECT Id,ApprovalID__c,Is_Send_Succeed__c,Is_Notify_Sap__c 
            FROM Metadata__c 
            WHERE Is_Notify_Sap__c = false  
            AND ApprovalID__c != '' 
            AND ApprovalID__c != null 
            AND Send_Direction__c = 'SAP_TO_SF' 
            AND RecordType.DeveloperName = 'SF_To_SAP_Queue'];
        if(jobs.size() > 0){
            try{
                List<Map<String,String>> keys = new List<Map<String,String>>();
                Set<String> setKeys = new Set<String>();
                for(Metadata__c md : jobs){
                    md.Is_Notify_Sap__c = true;
                    if(!String.isBlank(md.ApprovalID__c)){
                        if(!setKeys.contains(md.ApprovalID__c)){
                            Map<String,String> key = new Map<String,String>();
                            key.put('keyno', md.ApprovalID__c);
                            key.put('status', md.Is_Send_Succeed__c?'1':'0');
                            keys.add(key);
                            setKeys.add(md.ApprovalID__c);
                        }
                    }
                }
                if(keys.size() > 0){
                    System.debug(LoggingLevel.INFO, '*** : 推送成功或失败标记给SAP:' +createSapSynchronousResult(keys));
                    String strOutPut = Utils.postToSAP(createSapSynchronousResult(keys));
                }
            }catch(Exception ex){
                System.debug('*** 出错：' + ex.getMessage() + '\n' + ex.getStackTraceString());
            }finally{
                //更新数据,下次不要再同步结果
                UPDATE jobs;
            }
        }
    }
    private static void syncFromSap(Integer count){
        for(Integer i = 0; i < count; i++){
            syncFromSap();
        }
    }
    @Future(callout=true)
    public static void syncFromSap(){
        syncFromSap('');
    }
    public static Boolean syncFromSap(String sapKeyno){
        String keyno = '';
        String approval = '';
        Boolean isSuccess = false;
        String message = '';
        try{
            //１、发送同步请求到SAP，SAP返回要同步的数据
            String sapJson = Utils.postToSAP(createSapSynchronousArg(sapKeyno));
            //２、接收到同步返回结果后分类处理返回结果
            SyncSapToSfReturnArgs args = (SyncSapToSfReturnArgs)JSON.deserialize(sapJson,SyncSapToSfReturnArgs.class);
            keyno = args.keyno;
            approval = args.approval;
            //从SAP数据读取成功
            if(args.status == '1'){
                try{
                    syncToSF(args);
                    approval = args.approval;
                    isSuccess = true;
                    message = '成功';
                }catch(Exception ex){
                    isSuccess = false;
                    message = ex.getMessage() + '; ' + ex.getStackTraceString();
                    System.debug('*** 从SAP同步【' + args.approval + '/' + args.keyno + '】时出错：' + ex.getMessage() + '\n' + ex.getStackTraceString());
                }
            }else{
                isSuccess = false;
                message = args.message;
                System.debug('从SAP创建同步数据出错：' + args.message);
            }
        }catch(Exception ex){
            isSuccess = false;
            System.debug('*** 出错：' + ex.getMessage() + '\n' + ex.getStackTraceString());
        }finally{
            //记录操作同步日志
            Utils.addToSyncQueue(approval,keyno, isSuccess, message);
        }
        return isSuccess;
    }
    private static void syncToSF(SyncSapToSfReturnArgs arg){
        if(arg.approval == SapApprovalEnum.ADVANCECHARGE){
            syncAdvanceCharge(arg);   //预付款申请
        }else if(arg.approval == SapApprovalEnum.ABNORMALQUALITY){
            syncAbnormalQuality(arg);   //品质异常单
        }else if(arg.approval == SapApprovalEnum.PURCHASEINFORMATION){
            syncPurchaseInformation(arg);   //采购信息记录维护(新莱IT人员处理)
        }else if(arg.approval == SapApprovalEnum.PURCHASEORDER){
            syncPurchaseOrder(arg);   //标准采购订单(新莱IT人员处理)
        }else if(arg.approval == SapApprovalEnum.SALEORDER){
            syncSaleOrder(arg);   //销售订单
        }else if(arg.approval == SapApprovalEnum.RFQ){
            syncRFQ(arg);    //采购询价作业流程(新莱IT人员处理)
        }else if(arg.approval == SapApprovalEnum.PURCHASEAPPLICATION){
            syncPurchaseRequest(arg);    //采购申请作业流程(新莱IT人员处理)
        }else if(arg.approval == SapApprovalEnum.PMTICKET){
            syncPMTicket(arg);   //PM通知单
        }else if(arg.approval == SapApprovalEnum.SALESPRICE){
            syncSalesPrice(arg);   //销售定价业务流程 
        }else if(arg.approval == SapApprovalEnum.CUSTOMERCREDITLOAN){
            syncCustomerCreditLoan(arg);   //客户信用贷款主数据申请
        }else{    //以后有其它的流程请加在这里上面
            System.debug('*** 同步时出现未协商好的流程名称：' + arg.approval);
        }
    }
    //预付款申请
    public static void syncAdvanceCharge(SyncSapToSfReturnArgs args){
        //预付款流程
        Approval_Managed__c main = (Approval_Managed__c)JSON.deserialize(JSON.serialize(args.content.main), Approval_Managed__c.class);
        System.debug(LoggingLevel.INFO, '*** main: ' + main);
         Id recordTypeID = HarryUtils.getRecordTypeIdByDevNameAndObjName('AdvanceCharge','Approval_Managed__c');
         main.RecordTypeId = recordTypeID;
         // main.SAPID__c = main.Purchase__c;//args.keyno;
         if (!String.isBlank(main.Applicant_Code__c)) {
            List<Contact> lstCon = [SELECT Id, Name, Number__c FROM Contact WHERE number__c = :main.Applicant_Code__c];
            if (lstCon.size()>0) {
                main.Applicant__c = lstCon[0].Id;
                //预付款申请人
                 main.Applicant_Cost__c = main.Applicant__c;
                 main.Applicant_Code_Cost__c = lstCon[0].Number__c;
                 main.Applicant_Name_Cost__c = lstCon[0].Name;
            }
         }
         if (!String.isBlank(main.Supplier_Number__c)) {
             List<Account> lstCon = [SELECT Id, Vendor_Number__c FROM Account 
            WHERE Vendor_Number__c =:main.Supplier_Number__c AND RecordType.DeveloperName = 'Vendor'];
            if (lstCon.size()>0) {
                main.Vendor__c = lstCon[0].Id;
            }
         }
         Id userid = Utils.getUserIdByContactID(main.Applicant__c);
         main.OwnerId = userid!=null?userid:UserInfo.getUserId();
         insert main;
         System.debug(LoggingLevel.INFO, '*** main.Id: ' + main.Id);
          
        try{
            //自动提交数据待审批
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setObjectId(main.Id);
            req.setComments('SAP同步数据，系统自动提交，等待审批!');
            Approval.ProcessResult result = Approval.process(req);
            if(!result.isSuccess()){
                System.debug('*** 自动提交预付款审批出错(出差)：' + result.getErrors());
            }
        }catch(Exception ex){
            System.debug('*** 自动提交预付款审批出错(出差)：' + ex.getMessage());
        }
    }

    //品质异常单
    public static void syncAbnormalQuality(SyncSapToSfReturnArgs args){
        Approval_Managed__c main = (Approval_Managed__c)JSON.deserialize(JSON.serialize(args.content.main), Approval_Managed__c.class);
        System.debug(LoggingLevel.INFO, '*** main: ' + main);
        List<Approval_Managed_Item__c> problems = new List<Approval_Managed_Item__c> ();
        if(args.content.details.containsKey('problems')){
            problems = (List<Approval_Managed_Item__c>)JSON.deserialize(JSON.serialize(args.content.details.get('problems')), List<Approval_Managed_Item__c>.class);
            System.debug(LoggingLevel.INFO, '*** problems: ' + problems);
        }
         Id recordTypeID = HarryUtils.getRecordTypeIdByDevNameAndObjName('AbnormalQuality','Approval_Managed__c');
         main.RecordTypeId = recordTypeID;
         // main.SAPID__c = main.Abnormal_Code__c;//args.keyno;
         if (!String.isBlank(main.Applicant_Code__c)) {
            List<Contact> lstCon = [SELECT Id FROM Contact WHERE number__c = :main.Applicant_Code__c];
            if (lstCon.size()>0) {
                main.Applicant__c = lstCon[0].Id;
            }
         }
         Id userid = Utils.getUserIdByContactID(main.Applicant__c);
         main.OwnerId = userid!=null?userid:UserInfo.getUserId();
         try {
             insert main;
            System.debug(LoggingLevel.INFO, '*** main.Id: ' + main.Id);
         }
         catch (DMLException e) {
             System.debug(' DML Exception: ' + e);
         }
         List<Approval_Managed_Item__c> lstAddItems = new List<Approval_Managed_Item__c>();
         for (Approval_Managed_Item__c cami : problems) {
            //子表对应查找字段
            cami.Abnormal_Problem__c = main.Id;
            cami.RecordTypeId = HarryUtils.getRecordTypeIdByDevNameAndObjName('Quality_Problems','Approval_Managed_Item__c');
            lstAddItems.add(cami);
         }
         if (lstAddItems.size()>0) {
             try {
                System.debug(LoggingLevel.INFO, '*** lstAddItems: ' + lstAddItems);
                 insert lstAddItems;
             }
             catch (DMLException e) {
                 System.debug(' DML Exception: ' + e);
             }
         }
        try{
            //自动提交数据待审批
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setObjectId(main.Id);
            req.setComments('SAP同步数据，系统自动提交，等待审批!');
            Approval.ProcessResult result = Approval.process(req);
            if(!result.isSuccess()){
                System.debug('*** 自动提交品质异常单审批出错(出差)：' + result.getErrors());
            }
        }catch(Exception ex){
            System.debug('*** 自动提交品质异常单审批出错(出差)：' + ex.getMessage());
        }
    }

    //采购信息记录维护(新莱IT人员处理)
    public static void syncPurchaseInformation(SyncSapToSfReturnArgs args){
        Custom_Approval_Managed__c main = (Custom_Approval_Managed__c)JSON.deserialize(JSON.serialize(args.content.main), Custom_Approval_Managed__c.class);
        System.debug(LoggingLevel.INFO, '*** main: ' + main);
        List<Custom_Approval_Managed_item__c> items = new List<Custom_Approval_Managed_item__c> ();
        List<Custom_Approval_Managed_item__c> zrows = new List<Custom_Approval_Managed_item__c> ();
        if(args.content.details.containsKey('items')){
            items = (List<Custom_Approval_Managed_item__c>)JSON.deserialize(JSON.serialize(args.content.details.get('items')), List<Custom_Approval_Managed_item__c>.class);
            System.debug(LoggingLevel.INFO, '*** items: ' + items);
        }
        if(args.content.details.containsKey('zrows')){
            zrows = (List<Custom_Approval_Managed_item__c>)JSON.deserialize(JSON.serialize(args.content.details.get('zrows')), List<Custom_Approval_Managed_item__c>.class);

        }
        Id recordTypeSaleOrderID = HarryUtils.getRecordTypeIdByDevNameAndObjName('PurchaseInformation','Custom_Approval_Managed__c');
        main.RecordTypeId = recordTypeSaleOrderID;
        // main.SAPID__c = main.Number_of_Purchase_Info__c;//args.keyno;
        if (!String.isBlank(main.Applicant_Code__c)) {
            List<Contact> lstCon = [SELECT Id FROM Contact WHERE number__c = :main.Applicant_Code__c];
            if (lstCon.size()>0) {
                main.Applicant__c = lstCon[0].Id;
            }
        }
        Id userid = Utils.getUserIdByContactID(main.Applicant__c);
         main.OwnerId = userid!=null?userid:UserInfo.getUserId();
         insert main;
         System.debug(LoggingLevel.INFO, '*** main.Id: ' + main.Id);
       
       Set<String>  setVendorNumber = new Set<String>();
       Map<String,Id>  mapVendor= new Map<String,Id>();
       for (Custom_Approval_Managed_Item__c cami : items) {
           setVendorNumber.add(cami.Vendor_Number__c);
       }
       for (Custom_Approval_Managed_Item__c cami : zrows) {
           setVendorNumber.add(cami.Vendor_Number__c);
       }
       List<Account> lstCon = [SELECT Id, Vendor_Number__c FROM Account 
            WHERE Vendor_Number__c IN :setVendorNumber AND recordTypeID = :HarryUtils.getRecordTypeIdByDevNameAndObjName('Vendor','Account')];
       if (lstCon.size()>0) {
           for (Account acc : lstCon) {
               mapVendor.put(acc.Vendor_Number__c, acc.Id);
           }
       }
       //zrows为items的子表
       Map<String,Custom_Approval_Managed_Item__c> mapItems = new Map<String,Custom_Approval_Managed_Item__c>();
       List<Custom_Approval_Managed_Item__c>  lstAddRows= new List<Custom_Approval_Managed_Item__c>();
       for (Custom_Approval_Managed_Item__c cami : items) {
            cami.Purchase_Info_Inquiry__c = main.Id;
            cami.RecordTypeId = HarryUtils.getRecordTypeIdByDevNameAndObjName('Purchase_Info_Price_Result','Custom_Approval_Managed_Item__c');
            if (mapVendor.containsKey(cami.Vendor_Number__c)) {
                cami.Vendor__c = mapVendor.get(cami.Vendor_Number__c);
            }else{
                cami.Vendor__c = null;
            }
            mapItems.put(cami.Row_Index__c, cami);
        }
        insert mapItems.values();
        System.debug(LoggingLevel.INFO, '*** mapItems.values(): ' + mapItems.values());

        for (Custom_Approval_Managed_Item__c cami : zrows) {
            if (mapItems.containsKey(cami.Index_Item__c)) {
              cami.Purchase_Info_Row__c = mapItems.get(cami.Index_Item__c).Id;
              cami.Purchase_Info_Inquiry_Row__c = main.Id;
            }
            cami.RecordTypeId = HarryUtils.getRecordTypeIdByDevNameAndObjName('Purchase_Info_Result_Detail','Custom_Approval_Managed_Item__c');
            if (mapVendor.containsKey(cami.Vendor_Number__c)) {
                cami.Vendor__c = mapVendor.get(cami.Vendor_Number__c);
            }else{
                cami.Vendor__c = null;
            }
            lstAddRows.add(cami);
        }
        if (lstAddRows.size()>0) {
            System.debug(LoggingLevel.INFO, '*** lstAddItems: ' + lstAddRows);
            insert lstAddRows;
        }
        try{
            //自动提交数据待审批
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setObjectId(main.Id);
            req.setComments('SAP同步数据，系统自动提交，等待审批!');
            Approval.ProcessResult result = Approval.process(req);
            if(!result.isSuccess()){
                System.debug('*** 自动提交采购信息记录出错(出差)：' + result.getErrors());
            }
        }catch(Exception ex){
            System.debug('*** 自动提交采购信息记录出错(出差)：' + ex.getMessage());
        }
    }

    //标准采购订单(新莱IT人员处理)
    public static void syncPurchaseOrder(SyncSapToSfReturnArgs args){
        Approval_Managed__c main = (Approval_Managed__c)JSON.deserialize(JSON.serialize(args.content.main), Approval_Managed__c.class);
        List<Approval_Managed_Item__c> items = new List<Approval_Managed_Item__c> ();
        List<Approval_Managed_Item__c> prices = new List<Approval_Managed_Item__c> ();

        if(args.content.details.containsKey('items')){
                items = (List<Approval_Managed_Item__c>)JSON.deserialize(JSON.serialize(args.content.details.get('items')), List<Approval_Managed_Item__c>.class);

            }
        if(args.content.details.containsKey('prices')){
                prices = (List<Approval_Managed_Item__c>)JSON.deserialize(JSON.serialize(args.content.details.get('prices')), List<Approval_Managed_Item__c>.class);

            }

         Id recordTypeID = HarryUtils.getRecordTypeIdByDevNameAndObjName('PurchaseOrder','Approval_Managed__c');
         main.RecordTypeId = recordTypeID;
         // main.SAPID__c = main.Bill_No__c;//args.keyno;
         if (!String.isBlank(main.Applicant_Code__c)) {
            List<Contact> lstCon = [SELECT Id FROM Contact WHERE number__c = :main.Applicant_Code__c];
            if (lstCon.size()>0) {
                main.Applicant__c = lstCon[0].Id;
            }
         }
         Id userid = Utils.getUserIdByContactID(main.Applicant__c);
         main.OwnerId = userid!=null?userid:UserInfo.getUserId();
         if (!String.isBlank(main.vendor_number__c)) {
            List<Account> lstCon = [SELECT Id FROM Account 
            WHERE Vendor_Number__c = :main.vendor_number__c AND recordTypeID = :HarryUtils.getRecordTypeIdByDevNameAndObjName('Vendor','Account')];
            if (lstCon.size()>0) {
                main.Vendor__c = lstCon[0].Id;
            }
         }
         //标准采购采购price类型为PBXX/PB00的定价值写入主记录的定价值中
         for (Approval_Managed_Item__c cami : prices) {
            String szType = cami.Type_of_Price__c;
            if (!String.isBlank(szType) && szType.substring(0,2).containsIgnoreCase('PB')) {
                main.price__c = Decimal.valueOf(cami.Value_of_Price__c.trim());
                break;
            }
         }
         insert main;
        System.debug(LoggingLevel.INFO, '*** main.Id: ' + main.Id);
         List<Approval_Managed_Item__c> lstAddItems = new List<Approval_Managed_Item__c>();
         for (Approval_Managed_Item__c cami : items) {
            //字表对应查找字段
            cami.Purchase_Order__c = main.Id;
            cami.RecordTypeId = HarryUtils.getRecordTypeIdByDevNameAndObjName('Purchase_Detail','Approval_Managed_Item__c');
            lstAddItems.add(cami);
         }
         for (Approval_Managed_Item__c cami : prices) {
            //字表对应查找字段
            cami.Purchase_Order_Price__c = main.Id;
            cami.RecordTypeId = HarryUtils.getRecordTypeIdByDevNameAndObjName('Purchase_Price','Approval_Managed_Item__c');
            lstAddItems.add(cami);
         }

         if (lstAddItems.size()>0) {
            System.debug(LoggingLevel.INFO, '*** lstAddItems: ' + lstAddItems);
             insert lstAddItems;
         }
        try{
            //自动提交数据待审批
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setObjectId(main.Id);
            req.setComments('SAP同步数据，系统自动提交，等待审批!');
            Approval.ProcessResult result = Approval.process(req);
            if(!result.isSuccess()){
                System.debug('*** 自动提交标准采购订单出错(出差)：' + result.getErrors());
            }
        }catch(Exception ex){
            System.debug('*** 自动提交标准采购订单出错(出差)：' + ex.getMessage());
        }         
    }
    
    //销售订单审批流程
    public static void syncSaleOrder(SyncSapToSfReturnArgs args){
        //在这时把arg.main数据转化为你想要的类型
        //销售订单
        Custom_Approval_Managed__c main = (Custom_Approval_Managed__c)JSON.deserialize(JSON.serialize(args.content.main), Custom_Approval_Managed__c.class);
        System.debug(LoggingLevel.INFO, '*** main: ' + main);
        Map<String,Custom_Approval_Managed_Item__c> mapItems = new Map<String,Custom_Approval_Managed_Item__c>();
        List<Custom_Approval_Managed_item__c> items = new List<Custom_Approval_Managed_item__c> ();
        List<Custom_Approval_Managed_item__c> zrows = new List<Custom_Approval_Managed_item__c> ();
        List<Custom_Approval_Managed_item__c> headers = new List<Custom_Approval_Managed_item__c> ();
        List<Contact> partners = new List<Contact> ();
        if(args.content.details.containsKey('items')){
            items = (List<Custom_Approval_Managed_item__c>)JSON.deserialize(JSON.serialize(args.content.details.get('items')), List<Custom_Approval_Managed_item__c>.class);

        }
        if(args.content.details.containsKey('zrows')){
            zrows = (List<Custom_Approval_Managed_item__c>)JSON.deserialize(JSON.serialize(args.content.details.get('zrows')), List<Custom_Approval_Managed_item__c>.class);

        }
        if(args.content.details.containsKey('partners')){
           partners = (List<Contact>)JSON.deserialize(JSON.serialize(args.content.details.get('partners')), List<Contact>.class);

       }
       if(args.content.details.containsKey('headers')){
        headers = (List<Custom_Approval_Managed_item__c>)JSON.deserialize(JSON.serialize(args.content.details.get('headers')), List<Custom_Approval_Managed_item__c>.class);
        }
        Id recordTypeSaleOrderID = HarryUtils.getRecordTypeIdByDevNameAndObjName('SaleOrder','Custom_Approval_Managed__c');
        main.RecordTypeId = recordTypeSaleOrderID;
        // main.SAPID__c = main.Bill_No__c;//args.keyno;
        if (!String.isBlank(main.Applicant_Code__c)) {
            List<Contact> lstCon = [SELECT Id FROM Contact WHERE number__c = :main.Applicant_Code__c];
            if (lstCon.size()>0) {
                main.Applicant__c = lstCon[0].Id;
            }
        }
        Id userid = Utils.getUserIdByContactID(main.Applicant__c);
         main.OwnerId = userid!=null?userid:UserInfo.getUserId();
        //销售订单头条件明细里价格类型为NETW的定价值写入主记录的定价值中  Goods_Price__c  Discount_Rate__c   Amount__c Value_of_Price__c
        //销售订单头条件明细里价格类型为ZXXX的金额写入主记录的折扣率中  Goods_Price__c  Discount_Rate__c
         for (Custom_Approval_Managed_item__c cami : headers) {
            String szType = cami.Type_of_Price__c;
            if (!String.isBlank(szType) && szType.containsIgnoreCase('NETW')) {
                main.Goods_Price__c = cami.Value_of_Price__c;
            }
            else if (!String.isBlank(szType) && szType.containsIgnoreCase('ZXXX')) {
                main.Discount_Rate__c = cami.Amount__c;
            }
         }
       insert main;
       System.debug(LoggingLevel.INFO, '*** main.Id: ' + main.Id);
       List<Custom_Approval_Managed_Item__c> lstAddItems = new List<Custom_Approval_Managed_Item__c>();
       for (Custom_Approval_Managed_Item__c cami : items) {
        cami.Sales_Order__c = main.Id;
        cami.RecordTypeId = HarryUtils.getRecordTypeIdByDevNameAndObjName('Sale_Order_Detail','Custom_Approval_Managed_Item__c');
        mapItems.put(cami.Index_Item__c, cami);
        }
        insert mapItems.values();

        List<Contact> lstAddContacts = new List<Contact>();
        for (Contact cami : partners) {
            cami.Sales_Order_Partner__c = main.Id;
            cami.RecordTypeId = HarryUtils.getRecordTypeIdByDevNameAndObjName('Account_Partner','Contact');
            lstAddContacts.add(cami);
        }
        for (Custom_Approval_Managed_Item__c cami : headers) {
            cami.Sales_Order_Header__c = main.Id;
            cami.RecordTypeId = HarryUtils.getRecordTypeIdByDevNameAndObjName('Sale_Order_Detail_Header','Custom_Approval_Managed_Item__c');
            lstAddItems.add(cami);
        }
        for (Custom_Approval_Managed_Item__c cami : zrows) {
            cami.Sales_Order_Detail__c = main.Id;
            if (mapItems.containsKey(cami.Index_Item__c)) {
                cami.Sales_Order_Row_Detail__c = mapItems.get(cami.Index_Item__c).Id;
            }
            cami.RecordTypeId = HarryUtils.getRecordTypeIdByDevNameAndObjName('Sale_Order_Detail_Row','Custom_Approval_Managed_Item__c');

            lstAddItems.add(cami);
        }
        if (lstAddItems.size()>0) {
            try {
            System.debug(LoggingLevel.INFO, '*** lstAddItems: ' + lstAddItems);
            insert lstAddItems;
            System.debug(LoggingLevel.INFO, '*** lstAddContacts: ' + lstAddContacts);
              insert lstAddContacts;
            }
            catch (DmlException e) {
                System.debug(LoggingLevel.INFO, '*** DML exception: ' + e.getStackTraceString());
            }
            
        }

        try{
            //自动提交数据待审批
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setObjectId(main.Id);
            req.setComments('SAP同步数据，系统自动提交，等待审批!');
            Approval.ProcessResult result = Approval.process(req);
            if(!result.isSuccess()){
                System.debug('*** 自动提交销售订单审批出错(出差)：' + result.getErrors());
            }
        }catch(Exception ex){
            System.debug('*** 自动提交销售订单审批出错(出差)：' + ex.getMessage());
        }
    }

    //采购申请审批流程
    public static void syncPurchaseRequest(SyncSapToSfReturnArgs args){
      //处理返回结果
        Approval_Managed__c main = (Approval_Managed__c)JSON.deserialize(JSON.serialize(args.content.main), 
               Approval_Managed__c.class);
        System.debug(LoggingLevel.INFO, '*** main: ' + main);
        List<Approval_Managed_Item__c> items = new List<Approval_Managed_Item__c> ();
        if(args.content.details.containsKey('items')){
            items = (List<Approval_Managed_Item__c>)JSON.deserialize(JSON.serialize(args.content.details.get('items')), List<Approval_Managed_Item__c>.class);
            System.debug(LoggingLevel.INFO, '*** items: ' + items);
        }
        //PurchaseApplication 对应的记录类型
         Id recordTypeID = HarryUtils.getRecordTypeIdByDevNameAndObjName('PurchaseApplication','Approval_Managed__c');
         main.RecordTypeId = recordTypeID;
         // main.SAPID__c = main.Abnormal_Code__c;//args.keyno;
         if (!String.isBlank(main.Applicant_Code__c)) {
            List<Contact> lstCon = [SELECT Id FROM Contact WHERE number__c = :main.Applicant_Code__c];
            if (lstCon.size()>0) {
                main.Applicant__c = lstCon[0].Id;
            }
         }

         Id userid = Utils.getUserIdByContactID(main.Applicant__c);
         //List<User> lstUser = [SELECT Id FROM User WHERE isactive = true AND Id = :userid];
         //if (lstUser.size()>0) {
          main.OwnerId = userid!=null?userid:UserInfo.getUserId();
         //}else {
         // main.OwnerId = UserInfo.getUserId();
         //}

         try {
             insert main;
            System.debug(LoggingLevel.INFO, '*** main.Id: ' + main.Id);
         }
         catch (DMLException e) {
             System.debug(' DML Exception: ' + e);
         }
         List<Approval_Managed_Item__c> lstAddItems = new List<Approval_Managed_Item__c>();
         for (Approval_Managed_Item__c cami : items) {
            //子表对应查找字段 这个要注意
            cami.Purchasing_Request__c = main.Id;
            //PurchaseApp_Detail 对应的记录类型
            cami.RecordTypeId = HarryUtils.getRecordTypeIdByDevNameAndObjName('PurchaseApp_Detail','Approval_Managed_Item__c');
            lstAddItems.add(cami);
         }
         if (lstAddItems.size()>0) {
             try {
                System.debug(LoggingLevel.INFO, '*** lstAddItems: ' + lstAddItems);
                 insert lstAddItems;
             }
             catch (DMLException e) {
                 System.debug(' DML Exception: ' + e);
             }
         }
        try{
            //自动提交数据待审批
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setObjectId(main.Id);
            req.setComments('SAP同步数据，系统自动提交，等待审批!');
            Approval.ProcessResult result = Approval.process(req);
            if(!result.isSuccess()){
                System.debug('*** 自动提交采购申请审批出错(出差)：' + result.getErrors());
            }
        }catch(Exception ex){
            System.debug('*** 自动提交采购申请审批出错(出差)：' + ex.getMessage());
        }
    }





    //PM通知单
    public static void syncPMTicket(SyncSapToSfReturnArgs args){
      //处理返回结果
        Approval_Managed__c main = (Approval_Managed__c)JSON.deserialize(JSON.serialize(args.content.main), 
               Approval_Managed__c.class);
        System.debug(LoggingLevel.INFO, '*** main: ' + main);
        /*List<Approval_Managed_Item__c> items = new List<Approval_Managed_Item__c> ();
        if(args.content.details.containsKey('items')){
            items = (List<Approval_Managed_Item__c>)JSON.deserialize(JSON.serialize(args.content.details.get('items')), List<Approval_Managed_Item__c>.class);
            System.debug(LoggingLevel.INFO, '*** items: ' + items);
        }*/
        //PurchaseApplication 对应的记录类型
         Id recordTypeID = HarryUtils.getRecordTypeIdByDevNameAndObjName('PMTicket','Approval_Managed__c');
         main.RecordTypeId = recordTypeID;
         // main.SAPID__c = main.Abnormal_Code__c;//args.keyno; 
         if (!String.isBlank(main.Applicant_Code__c)) {
            List<Contact> lstCon = [SELECT Id FROM Contact WHERE number__c = :main.Applicant_Code__c];
            if (lstCon.size()>0) {
                main.Applicant__c = lstCon[0].Id;
            }
         }

         Id userid = Utils.getUserIdByContactID(main.Applicant__c);
         //List<User> lstUser = [SELECT Id FROM User WHERE isactive = true AND Id = :userid];
         //if (lstUser.size()>0) {
          main.OwnerId = userid!=null?userid:UserInfo.getUserId();
         //}else {
         // main.OwnerId = UserInfo.getUserId();
         //}

         try {
             insert main;
            System.debug(LoggingLevel.INFO, '*** main.Id: ' + main.Id);
         }
         catch (DMLException e) {
             System.debug(' DML Exception: ' + e);
         }
         /*List<Approval_Managed_Item__c> lstAddItems = new List<Approval_Managed_Item__c>();
         for (Approval_Managed_Item__c cami : items) {
            //子表对应查找字段 这个要注意
            cami.Purchasing_Request__c = main.Id;
            //PurchaseApp_Detail 对应的记录类型
            cami.RecordTypeId = HarryUtils.getRecordTypeIdByDevNameAndObjName('PurchaseApp_Detail','Approval_Managed_Item__c');
            lstAddItems.add(cami);
         }
         if (lstAddItems.size()>0) {
             try {
                System.debug(LoggingLevel.INFO, '*** lstAddItems: ' + lstAddItems);
                 insert lstAddItems;
             }
             catch (DMLException e) {
                 System.debug(' DML Exception: ' + e);
             }
         }*/
        try{
            //自动提交数据待审批
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setObjectId(main.Id);
            req.setComments('SAP同步数据，系统自动提交，等待审批!');
            Approval.ProcessResult result = Approval.process(req);
            if(!result.isSuccess()){
                System.debug('*** 自动提交采购申请审批出错(出差)：' + result.getErrors());
            }
        }catch(Exception ex){
            System.debug('*** 自动提交采购申请审批出错(出差)：' + ex.getMessage());
        }
    }
    



    //销售定价业务流程  
    public static void syncSalesPrice(SyncSapToSfReturnArgs args){
        //在这时把arg.main数据转化为你想要的类型
       
        Approval_Managed__c main = (Approval_Managed__c)JSON.deserialize(JSON.serialize(args.content.main), Approval_Managed__c.class);
        List<Approval_Managed_Item__c> items = new List<Approval_Managed_Item__c> ();
        List<Approval_Managed_Item__c> prices = new List<Approval_Managed_Item__c> ();

        if(args.content.details.containsKey('items')){
                items = (List<Approval_Managed_Item__c>)JSON.deserialize(JSON.serialize(args.content.details.get('items')), List<Approval_Managed_Item__c>.class);

            }
        if(args.content.details.containsKey('prices')){
                prices = (List<Approval_Managed_Item__c>)JSON.deserialize(JSON.serialize(args.content.details.get('prices')), List<Approval_Managed_Item__c>.class);

            }

         Id recordTypeID = HarryUtils.getRecordTypeIdByDevNameAndObjName('SalesPrice','Approval_Managed__c');
         main.RecordTypeId = recordTypeID;
         // main.SAPID__c = main.Bill_No__c;//args.keyno;
         if (!String.isBlank(main.Applicant_Code__c)) {
            List<Contact> lstCon = [SELECT Id FROM Contact WHERE number__c = :main.Applicant_Code__c];
            if (lstCon.size()>0) {
                main.Applicant__c = lstCon[0].Id;
            }
         }
         Id userid = Utils.getUserIdByContactID(main.Applicant__c);
         main.OwnerId = userid!=null?userid:UserInfo.getUserId();
         
         insert main;
        System.debug(LoggingLevel.INFO, '*** main.Id: ' + main.Id);
         List<Approval_Managed_Item__c> lstAddItems = new List<Approval_Managed_Item__c>();
         for (Approval_Managed_Item__c cami : items) {
            //字表对应查找字段
            cami.Material_Number__c = main.Id;
            cami.RecordTypeId = HarryUtils.getRecordTypeIdByDevNameAndObjName('SalesPricing_son','Approval_Managed_Item__c');
            lstAddItems.add(cami);
         }
         for (Approval_Managed_Item__c cami : prices) {
            //字表对应查找字段
            cami.LevelNumber__c = main.Id;
            cami.RecordTypeId = HarryUtils.getRecordTypeIdByDevNameAndObjName('SalesPricing_son2','Approval_Managed_Item__c');
            lstAddItems.add(cami);
         }

         if (lstAddItems.size()>0) {
            System.debug(LoggingLevel.INFO, '*** lstAddItems: ' + lstAddItems);
             insert lstAddItems;
         }
        try{
            //自动提交数据待审批
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setObjectId(main.Id);
            req.setComments('SAP同步数据，系统自动提交，等待审批!');
            Approval.ProcessResult result = Approval.process(req);
            if(!result.isSuccess()){
                System.debug('*** 自动提交销售定价业务流程出错(出差)：' + result.getErrors());
            }
        }catch(Exception ex){
            System.debug('*** 自动提交销售定价业务流程出错(出差)：' + ex.getMessage());
        }         
    }




//客户信用贷款主数据申请
    public static void syncCustomerCreditLoan(SyncSapToSfReturnArgs args){
      //处理返回结果
        Approval_Managed__c main = (Approval_Managed__c)JSON.deserialize(JSON.serialize(args.content.main), 
               Approval_Managed__c.class);
        System.debug(LoggingLevel.INFO, '*** main: ' + main);
        /*List<Approval_Managed_Item__c> items = new List<Approval_Managed_Item__c> ();
        if(args.content.details.containsKey('items')){
            items = (List<Approval_Managed_Item__c>)JSON.deserialize(JSON.serialize(args.content.details.get('items')), List<Approval_Managed_Item__c>.class);
            System.debug(LoggingLevel.INFO, '*** items: ' + items);
        }*/
        //CustomerCreditLoan 对应的记录类型
         Id recordTypeID = HarryUtils.getRecordTypeIdByDevNameAndObjName('CustomerCreditLoan','Approval_Managed__c');
         main.RecordTypeId = recordTypeID;
         // main.SAPID__c = main.Abnormal_Code__c;//args.keyno; 
         if (!String.isBlank(main.Applicant_Code__c)) {
            List<Contact> lstCon = [SELECT Id FROM Contact WHERE number__c = :main.Applicant_Code__c];
            if (lstCon.size()>0) {
                main.Applicant__c = lstCon[0].Id;
            }
         }

         Id userid = Utils.getUserIdByContactID(main.Applicant__c);
         //List<User> lstUser = [SELECT Id FROM User WHERE isactive = true AND Id = :userid];
         //if (lstUser.size()>0) {
          main.OwnerId = userid!=null?userid:UserInfo.getUserId();
         //}else {
         // main.OwnerId = UserInfo.getUserId();
         //}

         try {
             insert main;
            System.debug(LoggingLevel.INFO, '*** main.Id: ' + main.Id);
         }
         catch (DMLException e) {
             System.debug(' DML Exception: ' + e);
         }
         /*List<Approval_Managed_Item__c> lstAddItems = new List<Approval_Managed_Item__c>();
         for (Approval_Managed_Item__c cami : items) {
            //子表对应查找字段 这个要注意
            cami.Purchasing_Request__c = main.Id;
            //PurchaseApp_Detail 对应的记录类型
            cami.RecordTypeId = HarryUtils.getRecordTypeIdByDevNameAndObjName('PurchaseApp_Detail','Approval_Managed_Item__c');
            lstAddItems.add(cami);
         }
         if (lstAddItems.size()>0) {
             try {
                System.debug(LoggingLevel.INFO, '*** lstAddItems: ' + lstAddItems);
                 insert lstAddItems;
             }
             catch (DMLException e) {
                 System.debug(' DML Exception: ' + e);
             }
         }*/
        try{
            //自动提交数据待审批
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setObjectId(main.Id);
            req.setComments('SAP同步数据，系统自动提交，等待审批!');
            Approval.ProcessResult result = Approval.process(req);
            if(!result.isSuccess()){
                System.debug('*** 自动提交采购申请审批出错(出差)：' + result.getErrors());
            }
        }catch(Exception ex){
            System.debug('*** 自动提交采购申请审批出错(出差)：' + ex.getMessage());
        }
    }
    


    //销售报价单审批流程(同销售订单一样，只是记录类型不一样)
    public static void syncRFQ(SyncSapToSfReturnArgs arg){
        //在这时把arg.main数据转化为你想要的类型
        Custom_Approval_Managed__c main = (Custom_Approval_Managed__c)JSON.deserialize(JSON.serialize(arg.content.main), Custom_Approval_Managed__c.class);
        //处理数据并保存到数据库
    }
    private static String createSapSynchronousArg(String keyno){
        Map<String,String> arg = new Map<String,String>();
        arg.put('approval', 'Synchronous');
        arg.put('keyno', keyno);
        //本次同步1条记录
        arg.put('count', '1');
        return JSON.serialize(arg);
    }
    public static String createSapSynchronousResult(List<Map<String,String>> keys){
        sfSyncResultToSap arg = new sfSyncResultToSap();
        arg.keys = keys;
        return JSON.serialize(arg);
    }
    private class sfSyncResultToSap{
        public String approval = 'SynchronousResult';
        //keyno : SAP的同步keyno
        //status : 1 - 成功, 0 - 失败
        public List<Map<String,String>> keys;
    }
    private void createNewSchedule(){
        SyncFromSapToSfSchedule sc = new SyncFromSapToSfSchedule();
        System_Setting__c ssc = System_Setting__c.getValues('Setting');
        Datetime dt = Datetime.now().addMinutes(Integer.valueOf(ssc.SAP_Interval_Minutes__c));
        List<String> args = new List<String>();
        args.add(String.valueOf(dt.minute()));
        args.add(String.valueOf(dt.hour()));
        args.add(String.valueOf(dt.day()));
        args.add(String.valueOf(dt.month()));
        args.add(String.valueOf(dt.year()));
        String fmt = String.format('30 {0} {1} {2} {3} ? {4}',args);//指定时间执行一次
        System.debug('*** 执行时间：' + fmt);
        Id sid = System.schedule('SAP同步数据到SF_'+ dt.format('yyMMddHHmmss.SSS'), fmt, sc);
    }

}