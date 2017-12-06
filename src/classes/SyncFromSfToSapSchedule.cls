/**********************************************************************
 名    称：SF同步数据到SAP
 目    的：把SF放在同步队列中的数据同步到SAP
 作    者：刘文俊(liuwenjun@bluelinksys.com) 
 创建日期：2017-05-12
 修 改 人：
 修改日期：
 修改原因：
 备    注：

 执行脚本：
 SyncFromSfToSapSchedule sc = new SyncFromSfToSapSchedule();
 String fmt = '5 5 10 20 5 ? 2017';//指定时间执行一次(2017-05-20 10:05:05)执行
 System.schedule('SF同步数据到SAP；'+ Datetime.now().format('yyyyMMddHHmmss'), fmt, sc);
 
 脚本执行步骤：
 １、删除已同步数据
 ２、删除上一个定时任务
 ３、查找要同步的数据进行同步
 ４、接收到同步返回结果后设置本记录已同步标记
 ５、更新同步记录ＩＤ对应数据的SAPID
 ６、生成新的同步任务
 **********************************************************************/
global class SyncFromSfToSapSchedule implements Schedulable {
    global void execute(SchedulableContext sc) {
        try{
            //1、删除上一个定时任务
            //deletePrevTask();
            //2、查找要同步的数据进行同步
            //3、接收到同步返回结果后设置本记录已同步标记
            //4、更新同步记录ＩＤ对应数据的SAPID
            System.debug('*** 开始从SF同步数据到SAP');
            syncToSAP();
            System.debug('*** 同步完成');
        }catch(Exception ex){
            System.debug('*** 从SF同步数据到SAP时出现错误：' + ex.getMessage() + '\n' + ex.getStackTraceString());
        }
        /*finally{
            //5、生成新的同步任务
            createNewSchedule();
        }*/
    }
    private static void syncToSAP(){
        System_Setting__c ssc = System_Setting__c.getValues('Setting');
        Boolean succeed = false;
        //每次同步记录数
        Integer count = Integer.valueOf(ssc.SF_Sync_Count__c);
        //最多同步次数
        Integer maxSendCount = Integer.valueOf(ssc.SF_Send_Count__c);
        
        List<Metadata__c> jobs = [
            SELECT Id, Approval_Name__c,ApprovalID__c,Operate__c,Is_Send_Succeed__c,Send_Count__c,
                Send_Error_Message__c,Send_DateTime__c,Send_Direction__c   
            FROM Metadata__c 
            WHERE Is_Send_Succeed__c = :succeed 
            AND Send_Count__c < :maxSendCount 
            AND Send_Direction__c = 'SF_TO_SAP' 
            AND RecordType.DeveloperName = 'SF_To_SAP_Queue' 
            LIMIT :count];
        if(jobs.size() > 0){
            for(Metadata__c job : jobs){
                job.Is_Send_Succeed__c = true;
                UPDATE job;
                syncToSAP(JSON.serialize(job));
            }
        }
    }
    @Future(callout=true)
    private static void syncToSAP(String jsonJob){
        Metadata__c job = (Metadata__c)JSON.deserialize(jsonJob, Metadata__c.class);
        syncToSAP(job,true);
    }
    public static Boolean syncToSAP(String syncQueueId,Boolean autoUpdate){
        List<Metadata__c> jobs = [
            SELECT Id, Approval_Name__c,ApprovalID__c,Operate__c,Is_Send_Succeed__c,
                Send_Count__c,Send_Error_Message__c,Send_DateTime__c,Send_Direction__c   
            FROM Metadata__c 
            WHERE Id =:syncQueueId];
        if(jobs.size() > 0){
            return syncToSAP(jobs[0],autoUpdate);
        }
        return true;
    }
    public static Boolean syncToSAP(Metadata__c job,Boolean autoUpdate){
        String returnJson = '';
        System_Setting__c ssc = System_Setting__c.getValues('Setting');
        String szSkipNextNodeApproval = ssc.Approve_Auto_Approval__c; 
        Integer maxSendCount = Integer.valueOf(ssc.SF_Send_Count__c);
        String emailAddr = ssc.Error_Message_Email__c;
        String sapID = '';
        try{
            if(job.Approval_Name__c == SapApprovalEnum.CUSTOMER){
                //客户主数据
                returnJson = Utils.postToSAP(SapInputArgCreate.createSapCustomerInputArgs(job.ApprovalID__c));
            }else if(job.Approval_Name__c == SapApprovalEnum.BUSINESSTRAVEL){
                //员工出差管理
                returnJson = Utils.postToSAP(SapInputArgCreate.createSapBusinessTravelInputArgs(job.ApprovalID__c));
            }else if(job.Approval_Name__c == SapApprovalEnum.COSTCENTERSEND){
                //成本中心发料作业
                returnJson = Utils.postToSAP(SapInputArgCreate.createSapCostCenterSendInputArgs(job.ApprovalID__c));
            }else if(job.Approval_Name__c == SapApprovalEnum.SALEORDER){
                //销售订单
                returnJson = Utils.postToSAP(SapInputArgCreate.createSapSaleOrderInputArgs(job.ApprovalID__c));
            }else if(job.Approval_Name__c == SapApprovalEnum.ABNORMALQUALITY){
                //品质异常单
                returnJson = Utils.postToSAP(SapInputArgCreate.createSapAbnormalQualityInputArgs(job.ApprovalID__c));
            }else if(job.Approval_Name__c == SapApprovalEnum.STAFFTRANSFER){
                //员工异动管理
                returnJson = Utils.postToSAP(SapInputArgCreate.createSapStaffTransferInputArgs(job.ApprovalID__c));
            }else if(job.Approval_Name__c == SapApprovalEnum.STAFFLEAVEOFFICE){
                //员工主动离职
                returnJson = Utils.postToSAP(SapInputArgCreate.createSapStaffLeaveOfficeInputArgs(job.ApprovalID__c));
            }else if(job.Approval_Name__c == SapApprovalEnum.ADVANCECHARGE){
                //预付款申请
                returnJson = Utils.postToSAP(SapInputArgCreate.createSapAdvanceChargeInputArgs(job.ApprovalID__c));
            }else if(job.Approval_Name__c == SapApprovalEnum.ASSETPURCHASE){
                //资产购置
                returnJson = Utils.postToSAP(SapInputArgCreate.createSapAssetPurchaseInputArgs(job.ApprovalID__c));
            }else if(job.Approval_Name__c == SapApprovalEnum.EXPENSEREIMBURSE){
                //费用报销
                returnJson = Utils.postToSAP(SapInputArgCreate.createSapExpenseReimburseInputArgs(job.ApprovalID__c));
            }else if(job.Approval_Name__c == SapApprovalEnum.PURCHASEINFORMATION){
                //采购信息记录维护
                returnJson = Utils.postToSAP(SapInputArgCreate.createSapPurchaseInformationInputArgs(job.ApprovalID__c));
            }else if(job.Approval_Name__c == SapApprovalEnum.VENDOR){
                //供应商主数据
                returnJson = Utils.postToSAP(SapInputArgCreate.createSapVendorInputArgs(job.ApprovalID__c));
            }else if(job.Approval_Name__c == SapApprovalEnum.WASTEDISPOSE){
                //废料处理
                returnJson = Utils.postToSAP(SapInputArgCreate.createSapWasteDisposeInputArgs(job.ApprovalID__c));
            }else if(job.Approval_Name__c == SapApprovalEnum.PURCHASEAPPLICATION){
                //采购申请单(新莱IT人员处理)
                returnJson = Utils.postToSAP(SapInputArgCreate.createSapPurchaseRequestInputArgs(job.ApprovalID__c));
            }else if(job.Approval_Name__c == SapApprovalEnum.LEAVE){ 
                //员工请假
                returnJson = Utils.postToSAP(SapInputArgCreate.createSapAmleaveInputArgs(job.ApprovalID__c));

            }else if(job.Approval_Name__c == SapApprovalEnum.PMTICKET){
                //PM通知单
                returnJson = Utils.postToSAP(SapInputArgCreate.createSapPMTicketInputArgs(job.ApprovalID__c));

            }else if(job.Approval_Name__c == SapApprovalEnum.SALESPRICE){
                //销售定价业务流程 
                returnJson = Utils.postToSAP(SapInputArgCreate.createSapSalesPriceInputArgs(job.ApprovalID__c));

            }else if(job.Approval_Name__c == SapApprovalEnum.CUSTOMERCREDITLOAN){
                //客户信用贷款主数据申请
                returnJson = Utils.postToSAP(SapInputArgCreate.createSapCustomerCreditLoanInputArgs(job.ApprovalID__c));

            }else if(job.Approval_Name__c == SapApprovalEnum.PURCHASEORDER){
                //标准采购订单
                returnJson = Utils.postToSAP(SapInputArgCreate.createSapPurchaseOrderInputArgs(job.ApprovalID__c));
                
            }else if(job.Approval_Name__c == SapApprovalEnum.RFQ){
                //RFQ作业流程(新莱IT人员处理)
                //returnJson = Utils.postToSAP(SapInputArgCreate.你的函数名(job.ApprovalID__c));
            }else if(job.Approval_Name__c == SapApprovalEnum.IT_SERVICEAPPLICATION){
                //IT服务申请单(新莱IT人员处理)
                //returnJson = Utils.postToSAP(SapInputArgCreate.你的函数名(job.ApprovalID__c));
            }else{//以后有其它的流程请加在这里上面
                System.debug('*** SF同步数据到SAP,出现未协商好的流程名称：' + job.Approval_Name__c);
                return true;
            }
            SapWebServiceReturnResult sr = (SapWebServiceReturnResult)JSON.deserialize(returnJson, SapWebServiceReturnResult.class);
            job.Send_Datetime__c = Datetime.now();
            //同步成功
            if(sr.status == '1'){
                sapID = sr.SAPID;
                job.Is_Send_Succeed__c = true;
                job.Send_Error_Message__c = sr.message;
                job.Send_Count__c = job.Send_Count__c + 1;
                try{
                    if(job.Approval_Name__c == SapApprovalEnum.CUSTOMER){
                        updateCustomerCode(job.ApprovalID__c,sr.SAPID);
                    }else if(job.Approval_Name__c == SapApprovalEnum.VENDOR){
                        updateVendorCode(job.ApprovalID__c,sr.SAPID);
                    }else if(job.Approval_Name__c == SapApprovalEnum.EXPENSEREIMBURSE){
                        updateExpenseReimburseVoucherCode(job.ApprovalID__c,sr.SAPID);
                    }else if(job.Approval_Name__c == SapApprovalEnum.COSTCENTERSEND){
                        updateCostCenterSendVoucherCode(job.ApprovalID__c,sr.SAPID);
                    }else if(job.Approval_Name__c == SapApprovalEnum.ASSETPURCHASE){
                        updateAssetPurchaseVoucherCode(job.ApprovalID__c,sr.SAPID);
                    }
                    //自动批准操作,有些流程接口执行成功是不需要自动审批的,在自定义配置里面可以设置
                    if (szSkipNextNodeApproval.containsIgnoreCase(job.Approval_Name__c)) {
                        AutoApproval(job.ApprovalID__c,true,job.Send_Error_Message__c);
                    }
                }catch(Exception ex){
                    System.debug('*** 从SF同步数据到SAP成功，回写数据时SF出错：' + ex.getMessage() + '; ' + ex.getStackTraceString());
                }
            }else{
                    job.Is_Send_Succeed__c = false;
                    job.Send_Error_Message__c = sr.message;
                    job.Send_Count__c = job.Send_Count__c + 1;

                    if(job.Send_Count__c >= maxSendCount){
                    //自动拒绝操作,有些流程接口执行成功是不需要自动审批的,在自定义配置里面可以设置
                    if (szSkipNextNodeApproval.containsIgnoreCase(job.Approval_Name__c)) {
                        AutoApproval(job.ApprovalID__c,false,job.Send_Error_Message__c);
                    }
                    //AutoApproval(job.ApprovalID__c,false,job.Send_Error_Message__c);
                    
                    Messaging.SingleEmailMessage el = new Messaging.SingleEmailMessage();
                    //发送地址
                    List<String> address = new List<String>();
                    address.add(emailAddr);
                    el.setToAddresses(address);
                    el.setSubject('从Salesforce同步数据到SAP出错');
                    String urlink = URL.getSalesforceBaseUrl().toExternalForm();
                    if(urlink.startsWith('https://')){
                        urlink = urlink + '/' + job.ApprovalID__c;
                    }else{
                        urlink = 'https://' + urlink + '/' + job.ApprovalID__c;
                    }
                    el.setHtmlBody('管理员：<br/> ' + job.Approval_Name__c +'从Salesforce同步到SAP时出错，请处理!<br/>点击链接查看详细信息：<a href="' + urlink + '">' + job.ApprovalID__c + '</a>');
                    //发送邮件
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] {el});
                }
            }
        }catch(Exception ex){
            job.Is_Send_Succeed__c = false;
            job.Send_Error_Message__c = ex.getMessage() + '; ' + ex.getStackTraceString();
            job.Send_Count__c = job.Send_Count__c + 1;
            job.Send_Datetime__c = Datetime.now();
            System.debug('*** 从SF同步数据到SAP时出现错误：' + ex.getMessage() + '\n' + ex.getStackTraceString());
        }finally{
            if(autoUpdate){
                job.Send_Direction__c = 'SF_TO_SAP';
                UPDATE job;
                UpdateInterfaceExcuteInfo(job.ApprovalID__c,job.Send_Error_Message__c,sapID);
            }
            //失败后重新发送
            //if(!job.Is_Send_Succeed__c){
                //如果失败，重新生成下一计划任务去执行
            //   createNewSchedule();
            //}
        }
        return job.Is_Send_Succeed__c;
    }

      /*
        目的：回写接口成功或失败信息到相关记录
        参数：targetId - 记录ID
        参数： message - 接口执行信息
        参数3：SAPID
    */
    private static void UpdateInterfaceExcuteInfo(String targetId,String message, String sapID){
        if (String.isBlank(targetId)) {
            return;
        }
        for (Approval_Managed__c am : [SELECT Id,Interface_Info__c,SAPID__c FROM Approval_Managed__c WHERE Id = :targetId]) {
            Approval_Managed__c s =  am;
            s.Interface_Info__c = message;
            if (String.isBlank(am.SAPID__c)&&String.isNotBlank(sapID)) {
                s.SAPID__c = sapID;
            }
            Update s;
            System.debug(LoggingLevel.INFO, '*** s: ' + s);
            return;
        }
        for (Custom_Approval_Managed__c am : [SELECT Id,Interface_Info__c,SAPID__c FROM Custom_Approval_Managed__c WHERE Id = :targetId]) {
            Custom_Approval_Managed__c s = am;
            s.Interface_Info__c = message;
            if (String.isBlank(am.SAPID__c)&&String.isNotBlank(sapID)) {
                s.SAPID__c = sapID;
            }
            Update s;
            return;
        }
        for (Approval_Managed1__c am : [SELECT Id,Interface_Info__c,SAPID__c FROM Approval_Managed1__c WHERE Id = :targetId]) {
            Approval_Managed1__c s =  am;
            s.Interface_Info__c = message;
            if (String.isBlank(am.SAPID__c)&&String.isNotBlank(sapID)) {
                s.SAPID__c = sapID;
            }
            Update s;
            return;
        }
        for (Approval_Managed2__c am : [SELECT Id,Interface_Info__c,SAPID__c FROM Approval_Managed2__c WHERE Id = :targetId]) {
            Approval_Managed2__c s = am;
            s.Interface_Info__c = message;
            if (String.isBlank(am.SAPID__c)&&String.isNotBlank(sapID)) {
                s.SAPID__c = sapID;
            }
            Update s;
            return;
        }

    }

      /* 
        目的：接口执行成功自动批准或拒绝
        参数：targetId - 记录ID
        参数：isApprove - ture:批准操作 false:拒绝操作
        参数：message 批准信息
    */
    private static void AutoApproval(String targetId,Boolean isApprove,String message){
        List<ProcessInstanceWorkitem> lstWorkItem =  [SELECT Id, ProcessInstanceId, OriginalActorId, ActorId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId = :targetId];
        if (lstWorkItem.size()>0) {
            Approval.ProcessWorkitemRequest  req1 = new Approval.ProcessWorkitemRequest();
            if (isApprove) {
                req1.setComments('接口执行成功，系统自动批准!');
                req1.setAction('Approve');
            }else{
                req1.setComments('接口执行失败，系统自动拒绝!\n具体信息:'+message);
                req1.setAction('Reject');
            }
            //req2.setNextApproverIds(new Id[] {UserInfo.getUserId()});
            req1.setWorkitemId(lstWorkItem[0].Id);
            // Submit the request for approval
            Approval.ProcessResult result1 =  Approval.process(req1);
            if (!result1.isSuccess()) {
                System.debug(LoggingLevel.INFO, '*** 自动提交发生错误: ' + result1.getErrors());
                }
        }else{
            System.debug(LoggingLevel.INFO, '*** 不存在待处理节点: ');
        }
    }  
  /*
        目的：更新客户编号
        参数：customerID - 客户ID
        参数：customerCode - 客户编号(SAP生成返回)
    */
    private static void updateCustomerCode(String customerID,String customerCode){
        Custom_Approval_Managed__c customer = [
                SELECT Id,Account_Name__c,Account_Number__c,Status__c,Corp_Address__c,Tax_Number__c,
                    Sales_Employee__c,Billing_Address1__c,Shopping_Address1__c,Subject_Group__c 
                FROM Custom_Approval_Managed__c 
                WHERE Id = :customerID];
        customer.Account_Number__c = customerCode;

        if(customer.Status__c == '新建'){
            customer.Status__c = '修改';
        }

        UPDATE customer;
        /*/科目组不等ZOO2的客户数据不需要存入客户表中
        if (customer.Subject_Group__c != 'Z002') {
            return;
        }
        */
        //得到客户号后把客户写入Account表中
        List<Account> acclist = [
                SELECT Id,Name,Customer_Number__c,SAPID__c,Corp_Address__c,Tax_Number__c,AccountNumber,
                       Sales_Employee__c,Billing_Address1__c,Shopping_Address1__c,RecordTypeId  
                FROM Account 
                WHERE Customer_Number__c=:customerCode];
        Account acc = new Account();
        if(acclist.size() > 0){
            acc = acclist[0];
        }else{
            //acc.Customer_Password__c = 'customer';
            acc.RecordTypeId = HarryUtils.getRecordTypeIdByDevNameAndObjName('Customer','Account');
        }
        acc.Customer_Password__c = 'customer';
        acc.Name = customer.Account_Name__c;
        acc.Customer_Number__c = customer.Account_Number__c;
        acc.AccountNumber =  customer.Account_Number__c;
        acc.SAPID__c = customer.Account_Number__c;
        acc.Corp_Address__c = customer.Corp_Address__c;
        acc.Tax_Number__c = customer.Tax_Number__c;
        acc.Sales_Employee__c = customer.Sales_Employee__c;
        acc.Shopping_Address1__c = customer.Shopping_Address1__c;
        acc.Billing_Address1__c = customer.Billing_Address1__c;
        UPSERT acc;
    }
    /*
        目的：更新供应商编号
        参数：vendorID - 供应商ID
        参数：vendorCode - 供应商编号(SAP生成返回)
    */
    private static void updateVendorCode(String vendorID,String vendorCode){
        Custom_Approval_Managed__c vendor = [
                SELECT Id,Vendor_Name__c,Vendor_Number__c,Status__c,
                    Tax_Number__c,Registered_Capital__c , Account_Group__c 
                FROM Custom_Approval_Managed__c 
                WHERE Id = :vendorID];
        vendor.Vendor_Number__c = vendorCode;
        if(vendor.Status__c == '新建'){
            vendor.Status__c = '修改';
        }
        UPDATE vendor;
        //账户组不等ZOO1的供应商数据不需要存入供应商表中
        //if (vendor.Account_Group__c != 'Z001') {
        //    return;
        //}
        //得到供应商编号后把供应商写入Account表中
        List<Account> acclist = [
                SELECT Id,Name,Vendor_Number__c,SAPID__c,Tax_Number__c,Registered_Capital__c,RecordTypeId,AccountNumber    
                FROM Account 
                WHERE Vendor_Number__c=:vendorCode];
        Account acc = new Account();
        if(acclist.size() > 0){
            acc = acclist[0];
        }else{
            //acc.Customer_Password__c = 'vendor';
            acc.RecordTypeId = HarryUtils.getRecordTypeIdByDevNameAndObjName('Vendor','Account');
        }
        acc.Customer_Password__c = 'vendor';
        acc.Name = vendor.Vendor_Name__c;
        acc.Vendor_Number__c = vendor.Vendor_Number__c;
        acc.AccountNumber = vendor.Vendor_Number__c;
        acc.SAPID__c = vendor.Vendor_Number__c;
        acc.Registered_Capital__c = vendor.Registered_Capital__c;
        acc.Tax_Number__c = vendor.Tax_Number__c;

        UPSERT acc;
    }
    /*
        目的：更新费用报销凭证号
        参数：expenseReimburseID - 费用报销ID
        参数：voucherCode - 凭证号(SAP生成返回)
    */
    private static void updateExpenseReimburseVoucherCode(String expenseReimburseID,String voucherCode){
        Approval_Managed__c er = [SELECT Id,Voucher_Code__c,Status__c FROM Approval_Managed__c WHERE Id = :expenseReimburseID];
        er.Voucher_Code__c = voucherCode;
        if(er.Status__c == '新建'){
            er.Status__c = '修改';
        }
        UPDATE er;
    }
    /*
        目的：更新成本中心发料作业物料凭证号
        参数：costCenterSendID - 成本中心发料作业ID
        参数：voucherCode - 物料凭证号(SAP生成返回)
    */
    private static void updateCostCenterSendVoucherCode(String costCenterSendID,String voucherCode){
        Custom_Approval_Managed__c ccs = [SELECT Id,Material_Voucherno__c,Status__c FROM Custom_Approval_Managed__c WHERE Id = :costCenterSendID];
        ccs.Material_Voucherno__c = voucherCode;
        if(ccs.Status__c == '新建'){
            ccs.Status__c = '修改';
        }
        UPDATE ccs;
    }
    /*
        目的：更新资产编号
        参数：assetID- 成本中心发料作业ID
        参数：voucherCode - 物料凭证号(SAP生成返回)
    */
    private static void updateAssetPurchaseVoucherCode(String assetID,String voucherCode){
        Approval_Managed__c ccs = [SELECT Id,Asset_Code__c,Status__c FROM Approval_Managed__c WHERE Id = :assetID];
        ccs.Asset_Code__c = voucherCode;
        if(ccs.Status__c == '新建'){
            ccs.Status__c = '修改';
        }
        UPDATE ccs;
    }
    //删除已同步数据
    private void deleteSyncCompletedData(){
        Boolean succeed = true;
        List<Metadata__c> jobs = [SELECT Id FROM Metadata__c WHERE Is_Send_Succeed__c = :succeed];
        if(jobs.size() > 0){
            DELETE jobs;
        }
    }
    //删除不需要执行的定时任务
    private void deletePrevTask(){
        List<CronTrigger> jobs = [SELECT Id,NextFireTime FROM CronTrigger WHERE NextFireTime=null];
        if(jobs.size() > 0){
            for(CronTrigger ct : jobs){
                System.abortJob(ct.Id);
            }
        }
    }
    //生成新的同步任务
    public static void createNewSchedule(){
        SyncFromSfToSapSchedule sc = new SyncFromSfToSapSchedule();
        //System_Setting__c ssc = System_Setting__c.getValues('Setting');
        //Datetime dt = Datetime.addMinutes(Integer.valueOf(ssc.SF_Interval_Minutes__c));
        Datetime dt = Datetime.now().addSeconds(5);
        List<String> args = new List<String>();
        args.add(String.valueOf(dt.second()));
        args.add(String.valueOf(dt.minute()));
        args.add(String.valueOf(dt.hour()));
        args.add(String.valueOf(dt.day()));
        args.add(String.valueOf(dt.month()));
        args.add(String.valueOf(dt.year()));
        String fmt = String.format('{0} {1} {2} {3} {4} ? {5}',args);//指定时间执行一次
        System.debug('*** 执行时间：' + fmt);
        Id sid = System.schedule('SF同步数据到SAP_'+ dt.format('yyMMddHHmmss.SSS'), fmt, sc);
    }
}