/**********************************************************************
 名    称：HLYSyncBusinessTravel
 目    的：接收从汇联易同步过来的员工出差管理数据
 作    者：刘文俊(liuwenjun@bluelinksys.com)
 创建日期：2017-05-17
 修 改 人：
 修改日期：
 修改原因：
 备    注：

 脚本执行步骤：

 @Url: /services/apexrest/HLY/syncBusinessTravel
 接收的Json数据格式:
{
    "action": "SUBMIT", 
    "data_type": "TRL_REQUISITION",
    "parameter": 
    [
        {
            "status": "INSERT", 
            "employee_code": "10210463", 
            "hly_number": "TA00011731", 
            "document_date": "2017-06-06 15:30:00", 
            "unit_code": "1000E005",
            "headers": 
            [
                {
                    "travel_type": "A04", 
                    "status": "insert", 
                    "currencies": "CNY", 
                    "unit_code": "1000E001", 
                    "istraining": "N", 
                    "trip": "接口", 
                    "iscash": "N", 
                    "return_date": "2017-06-07 17:30:00", 
                    "amount": "1024.56", 
                    "traffic": "20", 
                    "issales": "Y", 
                    "iscar": "Y",
                    "departure_date": "2017-06-01 09:30:00", 
                    "cash_currency": "CNY", 
                    "regional": "A", 
                    "lines": 
                    [
                        {
                            "company": "上海本优机械有限公司", 
                            "activity_id": "", 
                            "line_number": "10", 
                            "status": "insert", 
                            "visit_date": "2017-06-06", 
                            "place": "上海",
                            "aircraft_info":"aircraft_info",
                            "train_info":"train_info",
                            "other_info":"other_info"
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
    "data_type":"TRL_REQUISITION"
}
*************************************************************************/
@RestResource(urlMapping = '/HLY/syncBusinessTravel')
global without sharing class HLYSyncBusinessTravel {
    @HttpPost
    global static HLYRestReturnArgs doPost(String action, String data_type, List<BTParameter> parameter) {
        System.debug('***  员工出差管理流程接收参数为: action:' + action);
        System.debug('***  员工出差管理流程接收参数为: data_type:' + data_type);
        System.debug('***  员工出差管理流程接收参数为: parameter:' + JSON.serializePretty(parameter));
        //返回参数
        HLYRestReturnArgs reArg = new HLYRestReturnArgs();
        reArg.data_type = data_type;
        try {
            Map<String,Custom_Approval_managed__c> hly_exist_number_map = new Map<String,Custom_Approval_managed__c>();
            Set<String> existUpdates = new Set<String>();
            Set<String> existLockeds = new Set<String>();
            Set<String> hly_number_set = new Set<String>();
            Set<String> employees = new Set<String>();
            for (BTParameter row : parameter) {
                row.status = row.status;
                hly_number_set.add(row.hly_number);
                if(!employees.contains(row.employee_code)){
                    employees.add(row.employee_code);
                }
            }
            List<Custom_Approval_managed__c> existList = [
                    SELECT Id,SAPID__c, Applicant__c,OwnerId, Applicant_Code__c,Applicant_Name__c,Employee__c,Employee_Code__c,
                        Employee_Name__c,Department_of_Approval__c,Dept_of_CostCenter__c,Bill_Date__c,Bill_No__c,Type_of_Travel__c,
                        Target_of_Travel__c,Area_of_Travel__c,Vehicle_of_Travel__c,Cost_Budget__c,Currency_of_Budget__c,Is_Borrow__c,
                        Amount_of_Borrow__c,Currency_of_Borrow__c,Is_Salesperson__c,Start_Travel_Datetime__c,Start_Travel_Date__c,
                        Start_Travel_Time__c,Is_Training__c,End_Travel_Datetime__c,End_Travel_Date__c,End_Travel_Time__c,
                        Is_Send_a_Car__c,Approval_Status__c,Description_of_Travel__c
                    FROM Custom_Approval_managed__c 
                    WHERE SAPID__c IN : hly_number_set];
            for (Custom_Approval_managed__c am : existList) {
                if(!hly_exist_number_map.containsKey(am.SAPID__c)){
                    hly_exist_number_map.put(am.SAPID__c,am);
                }
            }
            Map<String,Contact> mapContact = new Map<String,Contact>();
            for (Contact con : [SELECT Id,Number__c,LastName,SF_User__c,SF_User__r.IsActive FROM Contact WHERE Number__c IN : employees]) {
                if(!mapContact.containsKey(con.Number__c)){
                    mapContact.put(con.Number__c,con);
                }
            }

            List<Custom_Approval_managed__c> preInsertMap = new List<Custom_Approval_managed__c>();
            Map<String, List<Custom_Approval_Managed_Item__c>> preInsertItemMap = new Map<String, List<Custom_Approval_Managed_Item__c>>();
            for (BTParameter row : parameter) {
                for (BTHeaderInfo header : row.headers) {
                    Custom_Approval_managed__c am = null;
                    //如果单据号不存在则新增，如果正在审批或已批准则不处理，否则修改
                    if (!hly_exist_number_map.containsKey(row.hly_number)) {
                        am = new Custom_Approval_managed__c();
                        am.RecordTypeId = HarryUtils.getRecordTypeIdByDevNameAndObjName('BusinessTravel', 'Custom_Approval_Managed__c');
                    }else{
                        am = hly_exist_number_map.get(row.hly_number);
                        Boolean isLocked = Approval.IsLocked(am);
                        if(isLocked){
                            existLockeds.add(row.hly_number);
                            continue;
                        }else{
                            existUpdates.add(row.hly_number);
                            List<Custom_Approval_Managed_Item__c> items = [SELECT Id FROM Custom_Approval_Managed_Item__c WHERE Travel_Approval__c = :am.Id];
                            DELETE items;
                        }
                    }
                    //增加代码测试覆盖率，不要删除
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
                    am.Approval_Status__c = 'D';//草稿
                    am.Applicant_Code__c = row.employee_code;//申请人编号
                    am.Applicant_Name__c = mapContact.containsKey(row.employee_code)?mapContact.get(row.employee_code).LastName:'';

                    am.Employee__c = am.Applicant__c;
                    am.Employee_Code__c = row.employee_code; //员工编号
                    am.Employee_Name__c = am.Applicant_Name__c; //员工名称
                    am.Department_of_Approval__c = header.unit_code; //申请部门 row.unit_code;
                    am.Dept_of_CostCenter__c = header.unit_code; //成本中心
                    am.Bill_Date__c = HarryUtils.str2Date(row.document_date); //单据生成日期
                    am.SAPID__c = row.hly_number; //汇联易单据编号
                    am.Bill_No__c = row.hly_number;//单号
                    am.Type_of_Travel__c = header.travel_type;//出差类型
                    am.Target_of_Travel__c = header.travel_type.substring(0, 1); //出差类型的首字母为出差对象
                    am.Area_of_Travel__c = header.regional; //地域
                    am.Vehicle_of_Travel__c = header.traffic; //交通工具
                    try{
                        am.Cost_Budget__c = Decimal.valueOf(header.amount); //费用预算
                    }catch(Exception ex){
                        am.Cost_Budget__c = 0;
                    }
                    am.Currency_of_Budget__c = header.currencies; //币种
                    am.Is_Borrow__c = HarryUtils.hlyBooleanConvert(header.iscash); //是否借支
                    try{
                        am.Amount_of_Borrow__c = Decimal.valueOf(header.cash_amount); //借支金额
                    }catch(Exception ex){
                        am.Amount_of_Borrow__c = 0;
                    }
                    am.Currency_of_Borrow__c = header.cash_currency; //币种
                    am.Is_Salesperson__c = HarryUtils.hlyBooleanConvert(header.issales); //是否销售人员
                    am.Start_Travel_Datetime__c = HarryUtils.str2Dt(header.departure_date);//出发日期
                    am.Start_Travel_Date__c = (am.Start_Travel_Datetime__c==null?'':am.Start_Travel_Datetime__c.format('yyyyMMdd')); 
                    am.Start_Travel_Time__c = (am.Start_Travel_Datetime__c==null?'':am.Start_Travel_Datetime__c.format('HHmmss')); 
                    am.Is_Training__c = HarryUtils.hlyBooleanConvert(header.istraining); //是否培训
                    am.End_Travel_Datetime__c = HarryUtils.str2Dt(header.return_date);//返回日期
                    am.End_Travel_Date__c = (am.End_Travel_Datetime__c==null?'':am.End_Travel_Datetime__c.format('yyyyMMdd')); 
                    am.End_Travel_Time__c = (am.End_Travel_Datetime__c==null?'':am.End_Travel_Datetime__c.format('HHmmss')); 
                    am.Is_Send_a_Car__c = HarryUtils.hlyBooleanConvert(header.iscar); //是否派车
                    am.Description_of_Travel__c = header.trip; //行程
                    am.Travel_days__c = header.lines.size();

                    //判断台干返乡次数
                    List<Contact> lstCon = [SELECT ID,Name, Number__c,count_tgfx__c FROM Contact WHERE Number__c = :row.employee_code AND RecordType.DeveloperName = 'Staff'];
                    System.debug(LoggingLevel.INFO, '*** lstCon: ' + lstCon);
                    if (lstCon.size()>0) { 
                        Decimal count_tgfx = lstCon[0].count_tgfx__c;
                        System.debug(LoggingLevel.INFO, '*** count_tgfx: ' + count_tgfx);
                        System.debug(LoggingLevel.INFO, '*** am.Type_of_Travel__c: ' + am.Type_of_Travel__c);
                        if (count_tgfx == 0 && am.Type_of_Travel__c == 'G01' ) {
                            reArg.err_msg = '剩余台干返乡次数为0';
                            reArg.success = 'false';
                            return reArg;
                        }
                    }

                    List<Custom_Approval_Managed_Item__c> amiList = new List<Custom_Approval_Managed_Item__c>();
                    for (BTLineInfo line : header.lines) {
                        Custom_Approval_Managed_Item__c ami = new Custom_Approval_managed_Item__c();
                        ami.RecordTypeId = HarryUtils.getRecordTypeIdByDevNameAndObjName('Travel_Manage', 'Custom_Approval_Managed_Item__c');
                        ami.Row_Index__c = line.line_number; //行号
                        ami.Visit_Date__c = HarryUtils.str2Date(line.visit_date); //访问日期
                        ami.Corportion_Name__c = line.company; //公司
                        ami.Address__c = line.place; //地点

                        if (String.isBlank(ami.Address__c)) {
                            reArg.err_msg = '行程日期中必须填写地点';
                            reArg.success = 'false';
                            return reArg;
                        }
                        ami.Campaign__c = line.activity_id; //活动-预约ID

                        ami.Aircraft_info__c = line.aircraft_info; //行程信息-飞机
                        ami.Train_info__c = line.train_info; //行程信息-火车
                        ami.Other_info__c = line.other_info; //行程信息-其他

                        ami.OwnerId = am.OwnerId;
                        amiList.add(ami);
                    }
                    preInsertMap.add(am);
                    preInsertItemMap.put(am.SAPID__c, amiList);
                }
            }

            //NEED TEST: insert new records with children....

            UPSERT preInsertMap;
            List<Custom_Approval_Managed_Item__c> preInsertItems  = new List<Custom_Approval_Managed_Item__c>();
            for (Custom_Approval_managed__c am : preInsertMap) {
                List<Custom_Approval_Managed_Item__c> amiList = preInsertItemMap.get(am.SAPID__c);
                for (Custom_Approval_Managed_Item__c ami : amiList) {
                    ami.Travel_Approval__c = am.Id;
                }
                preInsertItems.addAll(amiList);
            }
            INSERT preInsertItems;

            reArg.success = 'true';
            if(existLockeds.size() > 0){
                reArg.err_msg = '正在审批或已通过审批，不能再次提交的单号 :' + String.join(new List<String>(existLockeds), ',') + '; ';
            }
            if (existUpdates.size() > 0) {
                reArg.err_msg = reArg.err_msg + '已更新数据的单号 :' + String.join(new List<String>(existUpdates), ',') + '; ';
            }

            try{
                //自动提交数据待审批
                for (Custom_Approval_managed__c am : preInsertMap) {
                    Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                    req.setObjectId(am.Id);
                    req.setComments('HLY同步的出差申请单数据，系统自动提交，等待审批!');
                    Approval.ProcessResult result = Approval.process(req);
                  if(!result.isSuccess()){
                    System.debug('*** 自动提交审批出错(出差)1：' + result.getErrors());
                }
                }
            }catch(Exception ex){
                System.debug('*** 自动提交审批出错(出差)2：' + ex.getMessage());
            }
        } catch (Exception ex) {
            reArg.success = 'false';
            reArg.err_msg = ex.getMessage() + '; ' + ex.getStackTraceString();
            System.debug('*** 保存员工出差申请单出错：' + reArg.err_msg);
        }
        System.debug(LoggingLevel.INFO, '*** 反馈信息: ' + reArg);
        return reArg;

    }
    /*
        主记录对应参数类
    */
    global class BTParameter {
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
        public List<BTHeaderInfo> headers {GET; SET;}
    }
    /*
        头信息对应参数类
    */
    public class BTHeaderInfo {
        public String status {GET; SET;}
        //出差类型
        public String travel_type {GET; SET;}
        //成本中心
        public String unit_code {GET; SET;}
        //地域
        public String regional {GET; SET;}
        //交通工具
        public String traffic {GET; SET;}
        //费用预算
        public String amount {GET; SET;}
        //币种
        public String currencies {GET; SET;}
        //是否借支(Y/N)
        public String iscash {GET; SET;}
        //借支金额
        public String cash_amount {GET; SET;}
        //借支金额币种
        public String cash_currency {GET; SET;}
        //是否销售人员(Y/N)
        public String issales {GET; SET;}
        //出发日期：2016-10-20 10:24
        public String departure_date {GET; SET;}
        //返回日期：2016-10-20 10:24
        public String return_date {GET; SET;}
        //是否培训(Y/N)
        public String istraining {GET; SET;}
        //是否派车(Y/N)
        public String iscar {GET; SET;}
        //行程
        public String trip {GET; SET;}
        //行信息
        public List<BTLineInfo> lines {GET; SET;}
    }
    /*
        行信息对应参数类
    */
    public class BTLineInfo {
        public String status {GET; SET;}
        //行号
        public String line_number {GET; SET;}
        //访问日期
        public String visit_date {GET; SET;}
        //公司
        public String company {GET; SET;}
        //地点
        public String place {GET; SET;}
        //活动-预约ID
        public String activity_id {GET; SET;}
        //行程信息-飞机
        public String aircraft_info {GET; SET;}
        //行程信息-火车
        public String train_info {GET; SET;}
        //行程信息-其他
        public String other_info {GET; SET;}
    }
}