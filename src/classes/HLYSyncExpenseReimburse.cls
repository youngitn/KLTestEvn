/**********************************************************************
 名    称：HLYSyncExpenseReimburse
 目    的：接收从汇联易同步过来的费用报销单
 作    者：刘文俊(liuwenjun@bluelinksys.com)
 创建日期：2017-05-17
 修 改 人：
 修改日期：
 修改原因：
 备    注：

 脚本执行步骤：

 @Url: /services/apexrest/HLY/syncExpenseReimburse
 接收的Json数据格式:
{
    "action":"SUBMIT",
    "data_type":"REPORT",
    "parameter":
    [
        {
            "status":"INSERT",
            "document_date":"2017-04-17 12:05:25",
            "hly_number":"ER00011643",
            "unit_code":"10000001",
            "employee_code":"10210280",
            "headers":
            [
                {
                    "status":"INSERT",
                    "report_type":"sales_travel_report",
                    "posting_unit":"013",
                    "jyc_requisition":"",
                    "employee_code":"10210033",
                    "note":"kvc",
                    "cost_center":"1000F002",
                    "total_amount":"1618.0",
                    "trl_requisition":"TA00011731",
                    "activity_id":"",
                    "company_code":"2000",
                    "currencies":"CNY",
                    "lines":
                    [
                        {
                            "status":"INSERT",
                            "amount":"820",
                            "quantity":"1",
                            "line_number":"",
                            "price":"820",
                            "account_code":"8000070000",
                            "note":"KKK",
                            "expense_type":"Y",
                            "reference_mileage":"",
                            "enter_mileage":"",
                            "attachments":
                            [
                                {"attachmentOID":"K09877-22832"}
                            ]
                        }
                    ]
                }
            ]
        }
    ]
}
 返回的Json数据格式：
{
    "success":"true OR false",
    "err_msg":"成功或失败信息",
    "source_code":"Salesforce",
    "data_type":"REPORT"
}
*************************************************************************/
@RestResource(urlMapping = '/HLY/syncExpenseReimburse')
global without sharing class HLYSyncExpenseReimburse {
    @HttpPost
    global static HLYRestReturnArgs doPost(String action, String data_type, List<ERParameter> parameter) {
        System.debug('***  费用报销流程接收参数为: action:' + action);
        System.debug('***  费用报销流程接收参数为: data_type:' + data_type);
        System.debug('***  费用报销流程接收参数为: parameter:' + JSON.serializePretty(parameter));

        //返回参数
        HLYRestReturnArgs reArg = new HLYRestReturnArgs();
        reArg.data_type = data_type;
        try {
            //汇联易单据编号
            Set<String> headerNumberSet = new Set<String>();
            //出差申请编号
            Set<String> travelCodeSet = new Set<String>();
            //交际应酬申请编号
            Set<String> entertainedCodeSet = new Set<String>();
            Set<String> employees = new Set<String>();
            for (ERParameter row : parameter) {
                headerNumberSet.add(row.hly_number);
                if(!employees.contains(row.employee_code)){
                    employees.add(row.employee_code);
                }
                for (ERHeaderInfo header : row.headers) {
                    if(!travelCodeSet.contains(header.trl_requisition)){
                        travelCodeSet.add(header.trl_requisition);
                    }
                    if(!entertainedCodeSet.contains(header.jyc_requisition)){
                        entertainedCodeSet.add(header.jyc_requisition);
                    }
                    if(!employees.contains(header.employee_code)){
                        employees.add(header.employee_code);
                    }
                }
            }
            //记录类型
            //费用报销
            Id rtID = HarryUtils.getRecordTypeIdByDevNameAndObjName('ExpenseReimburse','Approval_Managed__c');
            //费用报销明细
            Id rtIID = HarryUtils.getRecordTypeIdByDevNameAndObjName('Payment_Detail', 'Approval_Managed_Item__c');
            //费用报销凭证行信息
            Id rtPID = HarryUtils.getRecordTypeIdByDevNameAndObjName('Payment_Certificate', 'Approval_Managed_Item__c');
            //存在的记录
            Map<String,Approval_Managed__c> hly_number_exist_map = new Map<String,Approval_Managed__c>();
            Set<String> existUpdates = new Set<String>();
            Set<String> existLockeds = new Set<String>();
            List<Approval_Managed__c> existList = [
                    SELECT Id,SAPID__c,RecordTypeId,Approval_Status__c,Dept_Name__c,Bill_Date__c,Bill_No__c,Applicant__c,Applicant_Code__c,
                        Applicant_Name__c,Employee__c,Employee_Code__c,Employee_Name__c,Corporation__c,Dept_of_CostCenter__c,
                        Currency__c,Expense_Type_Cost__c,Posting_of_Company__c,Amount_of_Total__c,Remark_of_Explain__c,
                        Approval_Travel_Code__c,Approval_Travel__c,Approval_Entertained_Code__c,Approval_Entertained__c,OwnerId,
                        Estimate_Cost__c,Occur_Datetime__c,Staff_of_Both__c,Place__c,Description_of_Travel__c,
                        Invoice_Amount_Total__c,Kind_of_Cost__c  
                    FROM Approval_Managed__c WHERE RecordTypeId =: rtID 
                    AND SAPID__c IN : headerNumberSet];
            for (Approval_Managed__c am : existList) {
                hly_number_exist_map.put(am.SAPID__c,am);
            }
            Map<String,Contact> mapContact = new Map<String,Contact>();
            for (Contact con : [SELECT Id,Number__c,LastName,SF_User__c,SF_User__r.IsActive FROM Contact WHERE Number__c IN : employees]) {
                if(!mapContact.containsKey(con.Number__c)){
                    mapContact.put(con.Number__c,con);
                }
            }
            //交际应酬申请单
            Map<String,Approval_Managed__c> mapEntertained = new Map<String,Approval_Managed__c>();
            List<Approval_Managed__c> lstEntertained = 
                    [SELECT Id,Estimate_Cost__c,Occur_Datetime__c,Staff_of_Both__c,Place__c,
                        Description_of_Travel__c,SAPID__c,Approval_Entertained_Code__c,Kind_of_Cost__c  
                     FROM Approval_Managed__c 
                     WHERE RecordType.DeveloperName = 'EntertaineCost' 
                     AND SAPID__c IN : entertainedCodeSet];
            for (Approval_Managed__c am : lstEntertained) {
                if(!mapEntertained.containsKey(am.SAPID__c)){
                    mapEntertained.put(am.SAPID__c, am);
                }
            }
            //出差申请单
            Map<String,String> mapTravel = new Map<String,String>();
            List<Custom_Approval_Managed__c> lstTravel = [SELECT Id,SAPID__c FROM Custom_Approval_Managed__c WHERE RecordType.DeveloperName = 'BusinessTravel' AND SAPID__c IN : travelCodeSet];
            for (Custom_Approval_Managed__c am : lstTravel) {
                if(!mapTravel.containsKey(am.SAPID__c)){
                    mapTravel.put(am.SAPID__c, am.Id);
                }
            }
            List<Approval_Managed__c> preInsertMap = new List<Approval_Managed__c>();
            Map<String, List<Approval_Managed_Item__c>> preInsertItemMap = new Map<String,List<Approval_Managed_Item__c>>();
            for (ERParameter row : parameter) {
                for (ERHeaderInfo header : row.headers) {
                    Approval_Managed__c am = null;
                    //如果单据号不存在则新增，如果正在审批或已批准则不处理，否则修改
                    if (!hly_number_exist_map.containsKey(row.hly_number)) {
                        am = new Approval_Managed__c();
                        am.RecordTypeId = rtID;
                    }else{
                        am = hly_number_exist_map.get(row.hly_number);
                        Boolean isLocked = Approval.IsLocked(am);
                        if(isLocked){
                            existLockeds.add(row.hly_number);
                            continue;
                        }else{
                            existUpdates.add(row.hly_number);
                            List<Approval_Managed_Item__c> items = [SELECT Id FROM Approval_Managed_Item__c WHERE Purchase_Info_Inquiry__c=:am.Id OR Voucher_Info__c = :am.Id];
                            DELETE items;
                        }
                    }
                    //标记单据可以提交
                    am.Is_Reject_Submit__c = false;
                    //标记为汇联易同步过来单据
                    am.Is_HLY_ExpenseReimburse__c = true;
                    am.Approval_Status__c = 'D';//草稿
                    am.Bill_Date__c = HarryUtils.str2Date(row.document_date); //单据生成日期
                    am.SAPID__c = row.hly_number; //汇联易单据编号
                    am.Bill_No__c = row.hly_number;
                    am.Applicant__c = mapContact.containsKey(row.employee_code)?mapContact.get(row.employee_code).Id:null;
                    if(am.Applicant__c != null){
                        Contact con = mapContact.get(row.employee_code);
                        if(con.SF_User__c != null && con.SF_User__r.IsActive){
                            am.OwnerId = con.SF_User__c;
                        }else{
                            am.OwnerId = UserInfo.getUserId();
                        }
                    }else{
                        am.OwnerId = UserInfo.getUserId();
                    }
                    am.Applicant_Code__c = row.employee_code;//申请人编号
                    am.Applicant_Name__c = mapContact.containsKey(row.employee_code)?mapContact.get(row.employee_code).LastName:'';

                    //2017-08-05号修正汇联易同步员工数据
                    /*旧代码
                    am.Employee__c = am.Applicant__c;
                    am.Employee_Code__c = row.employee_code; //员工编号
                    am.Employee_Name__c = am.Applicant_Name__c; //员工名称
                    */
                    //新代码
                    am.Employee__c = mapContact.containsKey(header.employee_code)?mapContact.get(header.employee_code).Id:null;
                    am.Employee_Code__c = header.employee_code; //员工编号
                    am.Employee_Name__c = mapContact.containsKey(header.employee_code)?mapContact.get(header.employee_code).LastName:''; //员工名称

                    am.Corporation__c = header.company_code; //公司代码
                    am.Dept_of_CostCenter__c = header.cost_center; //成本中心
                    am.Currency__c = header.currencies; //币种
                    //个人报销      01
                    //供应商报销    02
                    am.Expense_Type_Cost__c = '01';//header.report_type; //报销单类型
                    //非销售差旅报销单：     travel_report
                    //销售差旅报销单:        sales_travel_report
                    //非销售费用报销单：     expense_report
                    //销售费用报销单：       sales_expense_report
                    //福利报销单：           welfare_report
                    //  013 非业务
                    //  001 业务
                    String unit = header.report_type !=null ?header.report_type.toLowerCase():'';
                    if(unit == 'sales_travel_report' || unit == 'sales_expense_report'){
                        am.Posting_of_Company__c = '001';//header.posting_unit; //过账单位
                    }else{
                        am.Posting_of_Company__c = '013';//header.posting_unit; //过账单位
                    }

                    try{
                        am.Amount_of_Total__c = Decimal.valueOf(header.total_amount); //金额汇总
                    }catch(Exception ex){
                        am.Amount_of_Total__c = 0;
                    }
                    am.Remark_of_Explain__c = header.note; //说明
                    //出差申请编号
                    am.Approval_Travel_Code__c = header.trl_requisition; 
                    am.Approval_Travel__c = mapTravel.containsKey(header.trl_requisition)?mapTravel.get(header.trl_requisition):null;
                    //交际应酬申请编号
                    am.Approval_Entertained_Code__c = header.jyc_requisition;
                    if(mapEntertained.containsKey(header.jyc_requisition)){
                        Approval_Managed__c ent = mapEntertained.get(header.jyc_requisition);
                        am.Approval_Entertained__c = ent.Id;
                        am.Estimate_Cost__c = ent.Estimate_Cost__c;
                        am.Kind_of_Cost__c = ent.Kind_of_Cost__c;
                        am.Occur_Datetime__c = ent.Occur_Datetime__c;
                        am.Staff_of_Both__c = ent.Staff_of_Both__c;
                        am.Place__c = ent.Place__c;
                        am.Description_of_Travel__c = ent.Description_of_Travel__c;
                    }

                    List<Approval_Managed_Item__c> amiList = new List<Approval_Managed_Item__c>();
                    Integer rowIndex = 1;
                    Decimal totalAmount = 0;
                    for (ERLineInfo line : header.lines) {
                        //费用报销明细rtIID
                        Approval_Managed_Item__c ami  = new Approval_Managed_Item__c();
                        ami.RecordTypeId = rtIID;
                        ami.TaskID__c = header.activity_id; //任务单ID（销售人员报销单会传任务单ID，非销售人员为空）
                        ami.Row_Index__c = String.valueOf(rowIndex); //行号
                        ami.Dept_of_CostCenter__c = header.cost_center;
                        ami.Ledger_Account__c = line.account_code; //总账科目
                        ami.Expense_Type__c = line.expense_type; //费用类型，非滴滴类型费用金额需要汇总到主记录中
                        ami.OwnerId = am.OwnerId;
                        try{
                            ami.Quantity__c = Decimal.valueOf(line.quantity); //数量（默认为1）
                        }catch(Exception ex){
                            ami.Quantity__c = 1;
                        }
                        try{
                            ami.Price__c = Decimal.valueOf(line.price); //单价（默认为金额）
                        }catch(Exception ex){
                            ami.Price__c = 0;
                        }
                        try{
                            ami.Amount__c = Decimal.valueOf(line.amount); //金额
                        }catch(Exception ex){
                            ami.Amount__c = 0;
                        }
                        if (line.expense_type=='N') {
                            totalAmount += ami.Amount__c;
                        }

                        try{
                            ami.Reference_mileage__c = line.reference_mileage;//参考里程数
                        }catch(Exception ex){
                            ami.Reference_mileage__c = '0';
                        }

                        try{
                            ami.Enter_mileage__c = line.enter_mileage;//实际里程数
                        }catch(Exception ex){
                            ami.Enter_mileage__c = '0';
                        }

                        ami.Remark__c = line.note; //备注
                        //附件信息

                        String attachment = '';
                        if (line.attachments != null) {
                            for(ERAttachment attr : line.attachments){
                                attachment = attachment + '<img src="' + attr.attachmentOID + '"></img>' + '<br/>';
                            }
                            ami.Attachment__c = attachment; 
                        }


                        amiList.add(ami);

                        if (line.expense_type == 'N') {
                            //费用报销凭证行信息rtPID
                            Approval_Managed_Item__c amh  = new Approval_Managed_Item__c();
                            amh.RecordTypeId = rtPID;
                            amh.Row_Index__c = String.valueOf(rowIndex);//行号
                            amh.Accounting_Code__c  = '40';//记账码
                            amh.Subject__c = line.account_code;//科目
                            amh.Amount__c = ami.Quantity__c * ami.Price__c;//金额
                            amh.Dept_of_CostCenter__c  = header.cost_center; //成本中心

                            if (line.note != null) {
                                line.note = line.note.replaceAll('\\[', '');
                                line.note = line.note.replaceAll('\\]', '');

                                if (line.note.contains(',费用类型')){
                                    amh.Text__c = line.note.substring(0, line.note.indexOf(',费用类型'));//文本
                                }else{
                                    amh.Text__c = line.note;
                                }
                                //amh.Text__c = line.note.substring(1, line.note.indexOf(',费用类型'));//文本
                                //amh.Text__c = line.note.substring(1, line.note.length() - 1);//文本
                                //amh.Text__c = amh.Text__c.replaceall(':',',');
                            }
                            else{
                                amh.Text__c = '';//文本 
                            }
                            //amh.Text__c = line.note.substring(1, line.note.length() - 1);//文本
                            //amh.Allocation__c  = '';//分配
                            //amh.Reason_Code__c = '';//原因代码
                            //amh.SGL__c = '';//SGL标识
                            //amh.Type_of_Affair__c  = '';//事务类型

                            amh.Remark__c = amh.Text__c; //备注
                            amiList.add(amh);
                        }
                        rowIndex = rowIndex + 1;
                    }
                    //汇总非滴滴发票类型的金额
                    am.Invoice_Amount_Total__c = totalAmount;
                    preInsertMap.add(am);
                    preInsertItemMap.put(am.SAPID__c, amiList);
                }
            }

            UPSERT preInsertMap;

            List<Approval_Managed_Item__c> preInsertList = new List<Approval_Managed_Item__c>();

            for (Approval_Managed__c am : preInsertMap) {
                List<Approval_Managed_Item__c> amiList = preInsertItemMap.get(am.SAPID__c);
                for (Approval_Managed_Item__c ami : amiList ) {
                    if(ami.RecordTypeId == rtIID){
                        ami.Purchase_Info_Inquiry__c = am.Id;//费用报销明细
                    }else{
                        ami.Voucher_Info__c = am.Id;//费用报销凭证行信息
                    }
                }
                preInsertList.addAll(amiList);
            }

            INSERT preInsertList;

            reArg.success = 'true';
            if(existLockeds.size() > 0){
                reArg.err_msg = '正在审批或已通过审批，不能再次提交的单号 :' + String.join(new List<String>(existLockeds), ',') + '; ';
            }
            if (existUpdates.size() > 0) {
                reArg.err_msg = reArg.err_msg + '已更新数据的单号 :' + String.join(new List<String>(existUpdates), ',') + '; ';
            }
            System.debug('*** 费用报销单数据保存成功！');

            try{
                //自动提交数据待审批
                for (Approval_Managed__c am : preInsertMap) {
                    Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                    req.setObjectId(am.Id);
                    req.setComments('HLY同步的费用报销单，系统自动提交，等待审批!');
                    Approval.ProcessResult result = Approval.process(req);
                    if(result.getErrors().size()>0){
                        System.debug('*** 1.自动提交审批出错(费用报销)：' + result.getErrors());
                    }
                }
            }catch(Exception ex){
                System.debug('*** 2. 自动提交审批出错(费用报销)：' + ex.getMessage() + '; ' + ex.getStackTraceString());
            }

        } catch (Exception ex) {
            reArg.success = 'false';
            reArg.err_msg = ex.getMessage() + '; ' + ex.getStackTraceString();
            System.debug('*** 保存费用报销单出错：' + reArg.err_msg);
        }
        System.debug(LoggingLevel.INFO, '*** 反馈信息: ' + reArg);
        return reArg;
    }
    
    /*
        主记录对应参数类
    */
    global class ERParameter {
        public String status {GET; SET;}
        //员工编号
        public String employee_code {GET; SET;}
        //单据日期：2016-10-20 10:24
        public String document_date {GET; SET;}
        //汇联易单据编号
        public String hly_number {GET; SET;}
        //申请部门
        public String unit_code {GET; SET;}
        //头信息
        public List<ERHeaderInfo> headers {GET; SET;}
    }
    /*
        头信息对应参数类
    */
    public class ERHeaderInfo {
        public String status {GET; SET;}
        //公司代码
        public String company_code {GET; SET;}
        //员工代码/厂商代码
        public String employee_code {GET; SET;}
        //报销单类型(区分五种报销单类型)
        public String report_type {GET; SET;}
        //成本中心(SAP所属部门代码)
        public String cost_center {GET; SET;}
        //币种
        public String currencies {GET; SET;}
        //过账单位：以报销单类型为区分，销售类报销单为业务，非销售类报销单为非业务
        public String posting_unit {GET; SET;}
        //任务单ID（销售人员报销单会传任务单ID，非销售人员报销单为空）
        public String activity_id {GET; SET;}
        //金额汇总
        public String total_amount {GET; SET;}
        //说明
        public String note {GET; SET;}
        //出差申请编号
        public String trl_requisition {GET; SET;}
        //交际应酬申请编号
        public String  jyc_requisition {GET; SET;}
        //行信息
        public List<ERLineInfo> lines {GET; SET;}
    }
    /*
        行信息对应参数类
    */
    public class ERLineInfo {
        public String status {GET; SET;}
        //行号
        public String line_number {GET; SET;}
        //总账科目
        public String account_code {GET; SET;}
        //数量(默认为1)
        public String quantity {GET; SET;}
        //单价(默认为金额)
        public String price {GET; SET;}
        //金额
        public String amount {GET; SET;}
        //费用类型(是否滴滴费Y/N)
        public String expense_type {GET; SET;}
        //备注
        public String note {GET; SET;}
        //参考里程(私车公用费用)
        public String reference_mileage {GET; SET;}
        //里程(私车公用费用)
        public String enter_mileage {GET; SET;}
        //附件信息
        public List<ERAttachment> attachments;
    }
    /*
        行附件
    */
    public class ERAttachment {
        //附件ID
        public String attachmentOID {GET; SET;}
    }
}