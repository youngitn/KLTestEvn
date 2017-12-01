/**********************************************************************
 名    称：HLYSyncEntertaineCost
 目    的：接收从汇联易同步过来的交际应酬费申请单数据
 作    者：刘文俊(liuwenjun@bluelinksys.com)
 创建日期：2017-05-17
 修 改 人：
 修改日期：
 修改原因：
 备    注：

 脚本执行步骤：

 @Url: /services/apexrest/HLY/syncEntertaineCost
 接收的Json数据格式:
{
    "action": "SUBMITTED",
    "data_type": "JYC_REQUISITION",
    "parameter":
    [
        {
            "status": "insert",
            "document_date": "2016-11-15 15:53",
            "hly_number": "HLY-201160404",
            "unit_code": "1468",
            "employee_code": "1251",
            "headers":
            [
                {
                    "status": "insert",
                    "arrangement": "前台报餐",
                    "note": "新莱销售",
                    "expense_type": "1",
                    "amount": "1024",
                    "ddate": "2016-11-14 13:58:00",
                    "unit": "AAA",
                    "trip": "aaaa",
                    "place": "江苏省昆山市陆家镇",
                    "customer_code": "0001005095",
                    "currencies": "CNY",
                    "customer": "测试客户名称"
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
    "data_type":"JYC_REQUISITION"
}
*************************************************************************/
@RestResource(urlMapping = '/HLY/syncEntertaineCost')
global without sharing class HLYSyncEntertaineCost {
    @HttpPost
    global static HLYRestReturnArgs doPost(String action, String data_type, List<ECParameter> parameter) {
        System.debug('***  交际应酬费申请单接收参数为: action:' + action);
        System.debug('***  交际应酬费申请单接收参数为: data_type:' + data_type);
        System.debug('***  交际应酬费申请单接收参数为: parameter:' + JSON.serializePretty(parameter));
        //返回参数
        HLYRestReturnArgs reArg = new HLYRestReturnArgs();
        reArg.data_type = data_type;

        try {
            List<Approval_Managed__c> amList = new List<Approval_Managed__c>();

            Set<String> headerNumberSet = new Set<String>();
            Set<String> employees = new Set<String>();
            for (ECParameter row : parameter) {
                row.status = row.status;
                headerNumberSet.add(row.hly_number);
                if(!employees.contains(row.employee_code)){
                    employees.add(row.employee_code);
                }
            }

            Map<String,Approval_Managed__c> hly_number_exist_map = new Map<String,Approval_Managed__c>();
            Set<String> existUpdates = new Set<String>();
            Set<String> existLockeds = new Set<String>();
            List<Approval_Managed__c> existList = [
                    SELECT Id,SAPID__c,RecordTypeId,Applicant__c,OwnerId,Approval_Status__c,Applicant_Code__c,
                        Employee__c,Employee_Code__c,Employee_Name__c,Supplier_Number__c,Dept_Code__c,Applicant_Name__c,
                        Bill_Date__c,Kind_of_Cost__c,Estimate_Cost__c,Occur_Datetime__c,Currency__c,Dept_Name__c,
                        Account_Name__c,Place__c,Description_of_Travel__c,Staff_of_Both__c,Arrangement__c 
                    FROM Approval_Managed__c 
                    WHERE SAPID__c IN : headerNumberSet];
            for (Approval_Managed__c am : existList) {
                hly_number_exist_map.put(am.SAPID__c,am);
            }
            Map<String,Contact> mapContact = new Map<String,Contact>();
            for (Contact con : [SELECT Id,Number__c,LastName,SF_User__c,SF_User__r.IsActive FROM Contact WHERE Number__c IN : employees]) {
                if(!mapContact.containsKey(con.Number__c)){
                    mapContact.put(con.Number__c,con);
                }
            }
            for (ECParameter row : parameter) {
                for (ECHeaderInfo header : row.headers) {
                    Approval_Managed__c am = null;
                    //如果单据号不存在则新增，如果正在审批或已批准则不处理，否则修改
                    if (!hly_number_exist_map.containsKey(row.hly_number)) {
                        am = new Approval_Managed__c();
                        am.RecordTypeId = HarryUtils.getRecordTypeIdByDevNameAndObjName('EntertaineCost', 'Approval_Managed__c');
                    }else{
                        am = hly_number_exist_map.get(row.hly_number);
                        Boolean isLocked = Approval.IsLocked(am);
                        if(isLocked){
                            existLockeds.add(row.hly_number);
                            continue;
                        }else{
                            existUpdates.add(row.hly_number);
                        }
                    }
                    header.status = header.status;
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
                    am.Is_HLY_ExpenseReimburse__c = true;
                    am.Approval_Status__c = 'D';//草稿
                    am.Applicant_Code__c = row.employee_code;//申请人编号
                    am.Applicant_Name__c = mapContact.containsKey(row.employee_code)?mapContact.get(row.employee_code).LastName:'';
                    am.Employee__c = am.Applicant__c;
                    am.Employee_Code__c = row.employee_code; //员工编号
                    am.Employee_Name__c = am.Applicant_Name__c; //员工名称
                    am.Supplier_Number__c = header.customer_code;//厂商编码
                    am.Dept_Code__c = row.unit_code; //部门代码
                    am.Bill_Date__c = HarryUtils.str2Date(row.document_date); //单据生成日期
                    am.SAPID__c = row.hly_number; //汇联易单据编号
                    am.Approval_Entertained_Code__c = row.hly_number; 
                    am.Kind_of_Cost__c = header.expense_type; //费用类型
                    try{
                        am.Estimate_Cost__c = Decimal.valueOf(header.amount); //费用预估（RMB）
                    }catch(Exception ex){
                        am.Estimate_Cost__c = 0;
                    }
                    am.Occur_Datetime__c = HarryUtils.str2Dt(header.ddate); //发生时间
                    am.Currency__c = header.currencies; //币种
                    am.Account_Name__c = header.customer; //客户名称
                    am.Place__c = header.place; //地点
                    am.Description_of_Travel__c = header.trip; //行程
                    am.Staff_of_Both__c = header.note; //双方人员及应酬内容
                    am.Arrangement__c = header.arrangement; //安排方式
                    am.Approval_DeptName__c = header.unit; //部门

                    amList.add(am);
                }
            }

            UPSERT amList;
            reArg.success = 'true';
            if(existLockeds.size() > 0){
                reArg.err_msg = '正在审批或已通过审批，不能再次提交的单号 :' + String.join(new List<String>(existLockeds), ',') + '; ';
            }
            if (existUpdates.size() > 0) {
                reArg.err_msg = reArg.err_msg + '已更新数据的单号 :' + String.join(new List<String>(existUpdates), ',') + '; ';
            }

            try{
                //自动提交数据待审批
                for (Approval_Managed__c am : amList) {
                    Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                    //req.setProcessDefinitionNameOrId('EntertaineCost');
                    req.setObjectId(am.Id);
                    req.setComments('HLY同步数据，系统自动提交，等待审批!');
                    Approval.ProcessResult result = Approval.process(req);
                    if(!result.isSuccess()){
                        System.debug('*** 自动提交审批出错(交际应酬费申请单)1：' + result.getErrors());
                    }
                }
            }catch(Exception ex){
                System.debug('*** 自动提交审批出错(交际应酬费申请单)2：' + ex.getMessage());
            }
        } catch (Exception ex) {  
            reArg.success = 'false';
            reArg.err_msg = ex.getMessage() + '; ' + ex.getStackTraceString();
            System.debug('*** 保存交际应酬费申请单出错：' + reArg.err_msg);
        }
        System.debug(LoggingLevel.INFO, '*** 反馈信息: ' + reArg);
        return reArg;
    }
    /*
        主记录对应参数类
    */
    global class ECParameter {
        public String status {GET; SET;}
        //员工编号
        public String employee_code {GET; SET;}
        //单据日期：2016-10-20 10:24
        public String document_date {GET; SET;}
        //汇联易单据编号
        public String hly_number {GET; SET;}
        //申请部门代码
        public String unit_code {GET; SET;}
        //头信息
        public List<ECHeaderInfo> headers {GET; SET;}
    }
    /*
        头信息对应参数类
    */
    public class ECHeaderInfo {
        public String status {GET; SET;}
        //费用类型
        public String expense_type {GET; SET;}
        //费用预估（RMB）
        public String amount {GET; SET;}
        //发生时间
        public String ddate {GET; SET;}
        //币种
        public String currencies {GET; SET;}
        //客户代码
        public String customer_code {GET; SET;}
        //客户名称
        public String customer {GET; SET;}
        //地点
        public String place {GET; SET;}
        //双方人员及应酬内容
        public String note {GET; SET;}
        //行程
        public String trip {GET; SET;}
        //安排方式
        public String arrangement {GET; SET;}
        //部门
        public String unit {GET; SET;}
    }
}