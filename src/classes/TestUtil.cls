/**
	目的：创建测试数据的工具类
	作者：Lily
	创建时间：2017-05-31
**/
public without sharing class TestUtil {
    /*
        创建基础数据
    */
    public static void createBasicData(){
        //系统配置信息
        System_Setting__c ssc = new System_Setting__c();
        ssc.Name = 'Setting';
        ssc.SAP_Sync_Count__c = '5';
        ssc.SAP_Interval_Minutes__c = '5';
        ssc.SF_Sync_Count__c = '5';
        ssc.SF_Interval_Minutes__c = '5';
        ssc.SF_Send_Count__c = '5';
        ssc.PageSize__c='20';
        ssc.Specify_Approval__c = '10210006,60210001';
        ssc.Specify_Approal_Employee__c = '10210000';
        ssc.Error_Message_Email__c = 'error@kinglai.com';
        ssc.Approve_Auto_Approval__c = 'ExpenseReimburse,Customer,Vendor,CostCenterSend,';
        ssc.No_Permission_Fields__c = 'Approval_Status__c,Is_Push_Sap__c,Is_Invoice_Success__c';
        ssc.Can_Create_BusinessTravel__c = '1000,3000';
        ssc.Can_Create_ExpenseReimburse__c = '1000,3000';
        INSERT ssc;

        SAP_Interface_Setting__c sis = new SAP_Interface_Setting__c();
        sis.Name = 'SapSetting';
        sis.Timeout__c = '120000';
        sis.EndPoint__c = 'http://59.120.231.208:8000/sap/bc/srt/rfc/sap/zwb_sf/620/zwb_sf/zwb_sf';
        sis.Password__c = 'sexrabbits';
        sis.UserName__c = 'ZSAP03';
        sis.Max_Repeat_Time__c = '5';
        INSERT sis;

        SAP_Interface_Setting__c sis1 = new SAP_Interface_Setting__c();
        sis1.Name = 'CRMSetting';
        sis1.Timeout__c = '120000';
        sis1.EndPoint__c = 'https://cagu.crm.ap2.oraclecloud.com:443/salesApi/resources/11.12.1.0/activities';
        sis1.Password__c = 'd0de8ad2-4bb2-58ad-7d29-160369b9098c';
        sis1.UserName__c = 'Basic bHVjeWd1bzpXZXN0MDIwMg==';
        sis1.Max_Repeat_Time__c = '5';
        INSERT sis1;

        //1.创建组织架构（部门）
        List<Map<String,String>> orgs = new List<Map<String,String>>();
        List<Organizational__c> depts = Test.loadData(Organizational__c.SobjectType, 'TD_Department');
        for(Organizational__c org:depts){
        	Map<String,String> data = new Map<String,String>();
        	data.put('Dept_Number__c', org.Dept_Number__c);
        	data.put('Corp_Number__c', org.Corp_Number__c);
        	data.put('Dept_Post_Number__c', org.Dept_Post_Number__c);
        	data.put('Description__c', org.Description__c);
        	data.put('Parent_Number__c', org.Approval_Special_Field__c);
        	orgs.add(data);
        }
        String deptJson = '{"status":"1","organizationals":' + JSON.serialize(orgs)+'}';
        System.debug('*** 部门测试数据生成成功！');
        SynchronousOrganization.actionDMLOrganiztaion(deptJson);

        //2.创建组织架构(岗位)
        List<Map<String,String>> roles = new List<Map<String,String>>();
        List<Organizational__c> jobs = Test.loadData(Organizational__c.SobjectType, 'TD_JobTitle');
        for(Organizational__c org:jobs){
        	Map<String,String> data = new Map<String,String>();
        	data.put('Post_Number__c', org.Post_Number__c);
        	data.put('Corp_Number__c', org.Corp_Number__c);
        	data.put('Post_Description__c', org.Post_Description__c);
        	data.put('Post_Manager_Number__c', org.Post_Manager_Number__c);
        	data.put('Post_Dept_Number__c', org.Approval_Special_Field__c);
        	roles.add(data);
        }
        String jobJson = '{"status":"1","roles":' + JSON.serialize(roles)+'}';
        System.debug('*** 岗位测试数据生成成功！');
        SynchronousOrganization.actionDMLJob(jobJson);

        //3.创建联系人（员工）
        List<Map<String,String>> staffs = new List<Map<String,String>>();
        List<Contact> employees = Test.loadData(Contact.SobjectType, 'TD_Staff');
        for(Contact emp:employees){
        	Map<String,String> data = new Map<String,String>();
        	data.put('email', emp.email);
        	data.put('mobilephone', emp.mobilephone);
        	data.put('lastname', emp.lastname);
        	data.put('birthdate', emp.birthdate!= null?Datetime.newInstance(emp.birthdate,Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd'):null);
        	data.put('job_title_level__c', emp.job_title_level__c);
        	data.put('corp_code__c', emp.corp_code__c);
        	data.put('sex__c', emp.sex__c);
        	data.put('staff_group__c', emp.staff_group__c);
        	data.put('end_date_contract__c', emp.end_date_contract__c!= null?Datetime.newInstance(emp.end_date_contract__c,Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd'):null);
        	data.put('is_sf_account__c', emp.is_sf_account__c?'true':'false');
        	data.put('salary_manager__c', emp.salary_manager__c);
        	data.put('human_range__c', emp.human_range__c);
        	data.put('sap_dept_number__c', emp.sap_dept_number__c);
        	data.put('sap_post_number__c', emp.sap_post_number__c);
        	data.put('number__c', emp.number__c);
        	data.put('staff_sub_group__c', emp.staff_sub_group__c);
        	data.put('take_office_date__c', emp.take_office_date__c!= null?Datetime.newInstance(emp.take_office_date__c,Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd'):null);
        	data.put('post_category__c', emp.post_category__c);
        	data.put('is_manager__c', emp.is_manager__c?'true':'false');
        	staffs.add(data);
        }
        String employeeJson = '{"status":"1","staffs":' + JSON.serialize(staffs)+'}';
        System.debug('*** 员工测试数据生成成功！');
        SynchronousOrganization.actionDMLStaff(employeeJson);

        //4.创建用户
        SynchronousOrganization.actionDMLUser();

        //5.创建国家
        Id cId = Utils.getRecordTypeId('Metadata__c', 'Country');
        List<Metadata__c> countries = Test.loadData(Metadata__c.SobjectType, 'TD_Country');
        for(Metadata__c md : countries){
        	md.Id = null;
        	md.RecordTypeId = cId;
        }
        INSERT countries;

        Map<String,String> mapCountry = new Map<String,String>();
        for(Metadata__c md : countries){
        	if(!mapCountry.containsKey(md.Country_Code__c)){
        		mapCountry.put(md.Country_Code__c, md.Id);
        	}
        }

        //6.创建省
        Id pId = Utils.getRecordTypeId('Metadata__c', 'Privince');
        List<Metadata__c> privinces = Test.loadData(Metadata__c.SobjectType, 'TD_Privince');
        for(Metadata__c md : privinces){
        	md.Id = null;
        	md.RecordTypeId = pId;
        	md.Country__c = mapCountry.containsKey(md.Country_Code__c)?mapCountry.get(md.Country_Code__c):null;
        }
        INSERT privinces;
        System.debug('*** 省测试数据生成成功！');

        Map<String,String> mapPrivince = new Map<String,String>();
        for(Metadata__c md : privinces){
        	if(!mapPrivince.containsKey(md.Privince_Code__c)){
        		mapPrivince.put(md.Privince_Code__c, md.Id);
        	}
        }

        //7.创建市
        Id rId = Utils.getRecordTypeId('Metadata__c', 'City');
        List<Metadata__c> cities = Test.loadData(Metadata__c.SobjectType, 'TD_City');
        for(Metadata__c md : cities){
        	md.Id = null;
        	md.RecordTypeId = rId;
        	md.Country__c = mapCountry.containsKey(md.Country_Code__c)?mapCountry.get(md.Country_Code__c):null;
        	md.Privince__c = mapPrivince.containsKey(md.Privince_Code__c)?mapPrivince.get(md.Privince_Code__c):null;
        }
        INSERT cities;
        System.debug('*** 市测试数据生成成功！');

        //8.创建地区
        Id aId = Utils.getRecordTypeId('Metadata__c', 'Area');
        List<Metadata__c> areas = Test.loadData(Metadata__c.SobjectType, 'TD_Area');
        for(Metadata__c md : areas){
        	md.Id = null;
        	md.RecordTypeId = aId;
        	md.Country__c = mapCountry.containsKey(md.Country_Code__c)?mapCountry.get(md.Country_Code__c):null;
        }
        INSERT areas;
        System.debug('*** 地区测试数据生成成功！');
        
        //9.创建流程查询SQL
        Id qId = Utils.getRecordTypeId('Metadata__c', 'Query_SQL');
        List<Metadata__c> sqls = Test.loadData(Metadata__c.SobjectType, 'TD_QuerySQL');
        for(Metadata__c md : sqls){
        	md.Id = null;
        	md.RecordTypeId = qId;
        }
        INSERT sqls;
        System.debug('*** 流程查询SQL测试数据生成成功！');

        //10.流程结点审批人
		List<Organizational__c> lstDepts = [SELECT Id,Dept_Number__c FROM Organizational__c WHERE RecordType.DeveloperName='Organizational'];
		Map<String,String> mapDepts = new Map<String,String>();
        for(Organizational__c md : lstDepts){
        	if(!mapDepts.containsKey(md.Dept_Number__c)){
        		mapDepts.put(md.Dept_Number__c, md.Id);
        	}
        }
        List<Organizational__c> lstJobs = [SELECT Id,Post_Number__c FROM Organizational__c WHERE RecordType.DeveloperName='Job_Title'];
		Map<String,String> mapJobs = new Map<String,String>();
        for(Organizational__c md : lstJobs){
        	if(!mapJobs.containsKey(md.Post_Number__c)){
        		mapJobs.put(md.Post_Number__c, md.Id);
        	}
        }
        List<Contact> lstStaffs = [SELECT Id,Number__c FROM Contact WHERE RecordType.DeveloperName='Staff'];
		Map<String,String> mapStaffs = new Map<String,String>();
        for(Contact md : lstStaffs){
        	if(!mapStaffs.containsKey(md.Number__c)){
        		mapStaffs.put(md.Number__c, md.Id);
        	}
        }
        Id acId = Utils.getRecordTypeId('Organizational__c', 'Approval_Config');
        String str1 = '[{"C":"10210169","E":"指定人员","F":"1","G":"稽核单位审批","H":"ExpenseReimburse","N":"稽核单位审批"},{"E":"指定岗位","F":"2","G":"部门主管审批 30003401","H":"ExpenseReimburse","N":"部门主管审批 30003401"},{"C":"10210177","E":"指定人员","F":"3","G":"售后部门主管审批","H":"ExpenseReimburse","N":"售后部门主管审批"},{"E":"指定人一阶主管","F":"4","G":"一阶主管审批-供应商","H":"ExpenseReimburse","N":"一阶主管审批-供应商"},{"E":"指定人一阶主管","F":"5","G":"一阶主管审批-个人报销","H":"ExpenseReimburse","N":"一阶主管审批-个人报销"},{"C":"10210950","E":"指定人员","F":"6","G":"业务审批-个人报销","H":"ExpenseReimburse","N":"业务审批-个人报销"},{"E":"指定人一阶主管","F":"1","G":"调出部门一阶主管审批","H":"StaffTransfer","N":"调出部门一阶主管审批"},{"E":"特殊计算","F":"2","G":"调入部门二阶主管审批","H":"StaffTransfer","N":"调入部门二阶主管审批"},{"E":"特殊计算","F":"3","G":"调入部门一阶主管审批","H":"StaffTransfer","N":"调入部门一阶主管审批"},{"A":"30000035","E":"指定岗位","F":"4","G":"HR经理-非3000","H":"StaffTransfer","N":"HR经理-非3000"},{"E":"指定人员","F":"5","G":"HR经理-3000","H":"StaffTransfer","N":"HR经理-3000"},{"E":"指定人部门主管","F":"1","G":"部门主管审批","H":"Customer","N":"部门主管审批"},{"C":"10210166","E":"指定人员","F":"2","G":"应收会计审批","H":"Customer","N":"应收会计审批"},{"C":"10210352","E":"指定人员","F":"3","G":"业务后端审批","H":"Customer","N":"业务后端审批"},{"E":"指定人部门主管","F":"1","G":"部门主管审批","H":"StaffLeaveOffice","N":"a05O000000Cxins"},{"E":"指定人一阶主管","F":"2","G":"一阶主管审批","H":"StaffLeaveOffice","N":"a05O000000Cxint"},{"C":"10211065","E":"指定人员","F":"3","G":"人事专员审批","H":"StaffLeaveOffice","N":"a05O000000Cxinu"},{"A":"30000035","E":"指定岗位","F":"4","G":"人事经理审批","H":"StaffLeaveOffice","N":"a05O000000Cxinv"},{"C":"10210001","E":"指定人员","F":"5","G":"副总审批","H":"StaffLeaveOffice","N":"a05O000000Cxinw"},{"D":"Applicant__c","E":"指定人具体字段","F":"1","G":"申请人确认-上传附件","H":"AbnormalQuality","N":"a05O000000Cxir1"},{"D":"Applicant__c","E":"指定人部门主管","F":"2","G":"部门主管审批","H":"AbnormalQuality","N":"a05O000000Cxir2"},{"D":"Operator_Abnormal__c","E":"指定人具体字段","F":"3","G":"作业人审批","H":"AbnormalQuality","N":"a05O000000Cxir3"},{"D":"Operator_Abnormal__c","E":"指定人部门主管","F":"4","G":"作业人部门主管审批","H":"AbnormalQuality","N":"a05O000000Cxir4"},{"D":"Operator_Abnormal__c","E":"指定人一阶主管","F":"5","G":"作业人一阶主管审批","H":"AbnormalQuality","N":"a05O000000Cxir5"},{"A":"30000035","E":"指定岗位","F":"1","G":"稽核单位审批","H":"BusinessTravel","N":"a05O000000Cxhd3"},{"E":"指定人部门主管","F":"2","G":"部门主管单位审批","H":"BusinessTravel","N":"a05O000000Cxhd4"},{"A":"30000263","E":"指定岗位","F":"3","G":"市场部审批","H":"BusinessTravel","N":"a05O000000Cxhd5"},{"E":"指定人一阶主管","F":"4","G":"一阶主管审批","H":"BusinessTravel","N":"a05O000000Cxhd6"},{"A":"30000035","E":"指定岗位","F":"5","G":"交通工具-飞机1","H":"BusinessTravel","N":"a05O000000Cxhd7"},{"E":"指定人部门主管","F":"1","G":"部门主管审批","H":"CostCenterSend","N":"a05O000000Cxkom"},{"E":"指定人一阶主管","F":"2","G":"一阶主管审批","H":"CostCenterSend","N":"a05O000000Cxkon"},{"C":"10210194","E":"指定人员","F":"3","G":"生管员审批","H":"CostCenterSend","N":"a05O000000Cxkoo"},{"C":"10210089","E":"指定人员","F":"4","G":"品管员审批","H":"CostCenterSend","N":"a05O000000Cxkop"},{"E":"特殊计算","F":"5","G":"仓库帐管员审批","H":"CostCenterSend","N":"a05O000000Cxkoq"},{"E":"特殊计算","F":"6","G":"库管员审批","H":"CostCenterSend","N":"a05O000000Cxkor"},{"C":"10210861","E":"指定人员","F":"6","G":"交通工具-飞机2","H":"BusinessTravel","N":"a05O000000DB4oD"},{"C":"30210002","E":"指定人员","F":"7","G":"总经理-3000","H":"BusinessTravel","N":"a05O000000DB4oE"},{"C":"10210000","E":"指定人员","F":"8","G":"总经理-非台湾","H":"BusinessTravel","N":"a05O000000DB4oF"},{"E":"指定人员","F":"9","G":"培训专员-3000","H":"BusinessTravel","N":"a05O000000DB4oG"},{"C":"10210384","E":"指定人员","F":"10","G":"培训专员-非3000","H":"BusinessTravel","N":"a05O000000DB4oH"},{"A":"30000035","E":"指定岗位","F":"11","G":"HR经理","H":"BusinessTravel","N":"a05O000000DB4oI"},{"C":"10210166","E":"指定人员","F":"12","G":"借支审批","H":"BusinessTravel","N":"a05O000000DB4oJ"},{"C":"10210861","E":"指定人员","F":"13","G":"派车1-审批","H":"BusinessTravel","N":"a05O000000DB4oK"},{"C":"20210063","E":"指定人员","F":"14","G":"派车2-审批","H":"BusinessTravel","N":"a05O000000DB4oL"},{"E":"指定人员","F":"15","G":"HR考勤专员3000","H":"BusinessTravel","N":"a05O000000DB4oM"},{"C":"10210156","E":"指定人员","F":"16","G":"HR考勤专员非3000","H":"BusinessTravel","N":"a05O000000DB4oN"},{"C":"10210714","E":"指定人员","F":"17","G":"自驾公里数填写","H":"BusinessTravel","N":"a05O000000DB4oO"},{"C":"10210714","E":"指定人员","F":"18","G":"自驾公里数2填写","H":"BusinessTravel","N":"a05O000000DB4oP"},{"E":"指定人员","F":"19","G":"HR经理3000","H":"BusinessTravel","N":"a05O000000DB4oQ"},{"C":"10210001","E":"指定人员","F":"6","G":"副总经理-非3000","H":"StaffTransfer","N":"副总经理-非3000"},{"C":"30210002","E":"指定人员","F":"7","G":"副总经理-3000","H":"StaffTransfer","N":"副总经理-3000"},{"C":"10210288","E":"指定人员","F":"8","G":"HR人事-非3000","H":"StaffTransfer","N":"HR人事-非3000"},{"E":"指定人员","F":"9","G":"HR人事-3000","H":"StaffTransfer","N":"HR人事-3000"},{"C":"10211065","E":"指定人员","F":"6","G":"人事专员确认","H":"StaffLeaveOffice","N":"a05O000000DBJwM"},{"C":"30210131","E":"指定人员","F":"7","G":"HR人事專員-3000","H":"StaffLeaveOffice","N":"a05O000000DBJwv"},{"E":"指定人员","F":"8","G":"人事經理-3000 30210136","H":"StaffLeaveOffice","N":"a05O000000DBJww"},{"C":"30210002","E":"指定人员","F":"9","G":"副總-3000","H":"StaffLeaveOffice","N":"a05O000000DBJwx"},{"C":"30210131","E":"指定人员","F":"10","G":"人事專員確認","H":"StaffLeaveOffice","N":"a05O000000DBJwy"},{"F":"1","G":"1","H":"SealApplication","N":"a05O000000CzTel"},{"F":"2","G":"2","H":"SealApplication","N":"a05O000000CzTem"},{"C":"10210911","E":"指定人员","F":"10","G":"申请人确认","H":"ExpenseReimburse","N":"申请人确认"},{"F":"1","G":"管理部主管审核","H":"WasteDispose","N":"管理部主管审核"},{"F":"2","G":"警卫复核数量及上传出入图片","H":"WasteDispose","N":"警卫复核数量及上传出入图片"},{"F":"3","G":"填写收款金额-2000","H":"WasteDispose","N":"填写收款金额-2000"},{"F":"4","G":"BU主管审核-1000","H":"WasteDispose","N":"BU主管审核-1000"},{"F":"5","G":"BU主管审核-2000","H":"WasteDispose","N":"BU主管审核-2000"},{"F":"6","G":"采购填入供应商","H":"WasteDispose","N":"采购填入供应商"},{"D":"Applicant__c","E":"指定人具体字段","F":"7","G":"申请人填写数量","H":"WasteDispose","N":"申请人填写数量"},{"F":"8","G":"采购填入相关数据","H":"WasteDispose","N":"采购填入相关数据"},{"F":"9","G":"仓管员入库-1000","H":"WasteDispose","N":"仓管员入库-1000"},{"F":"10","G":"仓管员入库-2000","H":"WasteDispose","N":"仓管员入库-2000"},{"F":"11","G":"财务确认收款-1000","H":"WasteDispose","N":"财务确认收款-1000"},{"F":"12","G":"财务确认收款-2000","H":"WasteDispose","N":"财务确认收款-2000"},{"F":"13","G":"入系统订单-1000","H":"WasteDispose","N":"入系统订单-1000"},{"F":"14","G":"入系统订单-2000","H":"WasteDispose","N":"入系统订单-2000"},{"F":"15","G":"确认出货过账-1000","H":"WasteDispose","N":"确认出货过账-1000"},{"F":"16","G":"确认出货过账-2000","H":"WasteDispose","N":"确认出货过账-2000"},{"F":"17","G":"确认开票-不锈钢","H":"WasteDispose","N":"确认开票-不锈钢"},{"F":"18","G":"填写收款金额-1000","H":"WasteDispose","N":"填写收款金额-1000"},{"C":"10210588","E":"指定人员","F":"1","G":"采购课长","H":"PurchaseOrder","N":"采购课长"},{"A":"30003355","E":"指定岗位","F":"2","G":"采购课长-DM采购组","H":"PurchaseOrder","N":"采购课长-DM采购组"},{"A":"30003354","E":"指定岗位","F":"3","G":"采购课长-IM采购组","H":"PurchaseOrder","N":"采购课长-IM采购组"},{"A":"30000735","E":"指定岗位","F":"4","G":"采购经理","H":"PurchaseOrder","N":"采购经理"},{"C":"30210002","E":"指定人员","F":"5","G":"管理层_3000","H":"PurchaseOrder","N":"管理层_3000"},{"C":"10210016","E":"指定人员","F":"6","G":"管理层_1000","H":"PurchaseOrder","N":"管理层_1000"},{"A":"30002576","E":"指定岗位","F":"7","G":"指定人员审批_一阶主管申请:指定审批人","H":"PurchaseOrder","N":"指定人员审批_一阶主管申请:指定审批人"},{"A":"30002576","E":"指定岗位","F":"8","G":"指定人员审批_标准采单:ZFY/ZPM","H":"PurchaseOrder","N":"指定人员审批_标准采单:ZFY/ZPM"},{"A":"30000494","E":"指定岗位","F":"9","G":"决策层","H":"PurchaseOrder","N":"决策层"},{"C":"10210018","E":"指定人员","F":"10","G":"供应商交期回复","H":"PurchaseOrder","N":"供应商交期回复"},{"C":"10210018","E":"指定人员","F":"10","G":"物控部","H":"SaleOrder","N":"物控部"},{"C":"10210588","E":"指定人员","F":"11","G":"采购部","H":"SaleOrder","N":"采购部"},{"A":"30002754","E":"指定岗位","F":"12","G":"外勤确认原因及财务核算成本","H":"SaleOrder","N":"外勤确认原因及财务核算成本"},{"C":"10210216","E":"指定人员","F":"13","G":"外勤确认原因及财务核算成本2","H":"SaleOrder","N":"外勤确认原因及财务核算成本2"},{"C":"10210194","E":"指定人员","F":"9","G":"生管部","H":"SaleOrder","N":"生管部"},{"C":"10210000","E":"指定人员","F":"14","G":"总经理确认","H":"SaleOrder","N":"总经理确认"},{"D":"Applicant__c","E":"指定人具体字段","F":"15","G":"备料单取消拒绝原因","H":"SaleOrder","N":"备料单取消拒绝原因"},{"D":"Applicant__c","E":"指定人具体字段","F":"1","G":"上传附件/协议","H":"SaleOrder","N":"上传附件/协议"},{"D":"Applicant__c","E":"指定人部门主管","F":"2","G":"直接销售主管","H":"SaleOrder","N":"直接销售主管"},{"A":"30002326","E":"指定岗位","F":"3","G":"凭保主管","H":"SaleOrder","N":"凭保主管"},{"D":"Applicant__c","E":"指定人一阶主管","F":"4","G":"部门经理","H":"SaleOrder","N":"部门经理"},{"C":"10210105","E":"指定人员","F":"5","G":"总经理室-备料单","H":"SaleOrder","N":"总经理室-备料单"},{"C":"10210169","E":"指定人员","F":"6","G":"总经理室-纯补货","H":"SaleOrder","N":"总经理室-纯补货"},{"C":"10210016","E":"指定人员","F":"7","G":"总经理室-退换补货","H":"SaleOrder","N":"总经理室-退换补货"},{"C":"10210841","E":"指定人员","F":"8","G":"成本中心主管","H":"SaleOrder","N":"成本中心主管"},{"A":"30002576","E":"指定岗位","F":"5","G":"预定人员作业-宴客","H":"EntertaineCost","N":"a05O000000DBa8T"},{"C":"10210861","E":"指定人员","F":"6","G":"预定人员作业-其他","H":"EntertaineCost","N":"a05O000000DBa8U"},{"C":"10210348","E":"指定人员","F":"7","G":"财务确认","H":"ExpenseReimburse","N":"财务确认"},{"C":"10211750","E":"指定人员","F":"8","G":"费用审批人员-1000 10211750","H":"ExpenseReimburse","N":"费用审批人员-1000 10211750"},{"C":"10210971","E":"指定人员","F":"9","G":"费用报销人员-非1000","H":"ExpenseReimburse","N":"费用报销人员-非1000"},{"A":"30003355","E":"指定岗位","F":"1","G":"采购课长-指定岗位1-30003355","H":"PurchaseInformation","N":"采购课长-指定岗位1-30003355"},{"A":"30003354","E":"指定岗位","F":"2","G":"采购课长-指定岗位2-30003354","H":"PurchaseInformation","N":"采购课长-指定岗位2-30003354"},{"A":"30000735","E":"指定岗位","F":"3","G":"采购经理-指定岗位","H":"PurchaseInformation","N":"采购经理-指定岗位"},{"E":"指定人员","F":"4","G":"采购经理-指定人员","H":"PurchaseInformation","N":"采购经理-指定人员"},{"E":"特殊计算","F":"5","G":"成本中心稽核","H":"PurchaseInformation","N":"成本中心稽核"},{"C":"30210033","E":"指定人员","F":"6","G":"成本管理师","H":"PurchaseInformation","N":"成本管理师"},{"D":"Applicant__c","E":"指定人部门主管","F":"6","G":"申请人部门主管确认","H":"AbnormalQuality","N":"a05O000000DBhZI"},{"D":"Applicant__c","E":"指定人一阶主管","F":"7","G":"申请人一阶主管确认","H":"AbnormalQuality","N":"a05O000000DBhZJ"},{"E":"指定人具体字段","F":"4","G":"客户号确认","H":"Customer","N":"客户号确认"},{"B":"20000010","E":"指定部门","F":"3","G":"HR CLERK","H":"VisitorHosts","N":"HR CLERK"},{"B":"20000010","E":"指定部门","F":"2","G":"HR MANAGER APPROVAL","H":"VisitorHosts","N":"HR MANAGER APPROVAL"},{"E":"指定人一阶主管","F":"1","G":"Manager_Approval","H":"VisitorHosts","N":"Manager_Approval"},{"E":"指定人一阶主管","F":"1","G":"Manager_Approval","H":"Internalmemo","N":"Manager_Approval"},{"B":"20000010","E":"指定部门","F":"2","G":"Receiving_Unit","H":"Internalmemo","N":"Receiving_Unit"},{"D":"Applicant__c","E":"指定人具体字段","F":"1","G":"申请人编辑及上传附件","H":"AdvanceCharge","N":"申请人编辑及上传附件"},{"C":"10210169","E":"指定人员","F":"2","G":"稽核单位审批","H":"AdvanceCharge","N":"稽核单位审批"},{"A":"30003401","E":"指定岗位","F":"3","G":"部门主管审批","H":"AdvanceCharge","N":"部门主管审批"},{"E":"指定人一阶主管","F":"4","G":"一阶主管审批","H":"AdvanceCharge","N":"一阶主管审批"},{"A":"30002576","E":"指定岗位","F":"5","G":"指定人员审批","H":"AdvanceCharge","N":"指定人员审批"},{"C":"10210000","E":"指定人员","F":"6","G":"总经理审批","H":"AdvanceCharge","N":"总经理审批"},{"C":"10210348","E":"指定人员","F":"7","G":"应付会计审批","H":"AdvanceCharge","N":"应付会计审批"},{"C":"10210166","E":"指定人员","F":"8","G":"财务主管审批","H":"AdvanceCharge","N":"财务主管审批"},{"D":"Applicant__c","E":"指定人具体字段","F":"9","G":"申请人冲账","H":"AdvanceCharge","N":"申请人冲账"},{"C":"10210348","E":"指定人员","F":"10","G":"应付冲账确认","H":"AdvanceCharge","N":"应付冲账确认"},{"C":"10210703","E":"指定人员","F":"1","G":"稽核单位审批","H":"EntertaineCost","N":"a05O000000Cz97g"},{"E":"指定人一阶主管","F":"2","G":"一阶主管审批","H":"EntertaineCost","N":"a05O000000Cz97h"},{"C":"10210000","E":"指定人员","F":"3","G":"总经理室审批","H":"EntertaineCost","N":"a05O000000Cz97l"},{"C":"10210703","E":"指定人员","F":"4","G":"预定人员作业-礼品","H":"EntertaineCost","N":"a05O000000Cz97m"},{"C":"10210016","E":"指定人员","F":"1","G":"稽核单位审批","H":"AssetPurchase","N":"稽核单位审批"},{"E":"指定人一阶主管","F":"2","G":"一阶主管审批","H":"AssetPurchase","N":"一阶主管审批"},{"E":"特殊计算","F":"3","G":"评估单位","H":"AssetPurchase","N":"评估单位"},{"C":"10211652","E":"指定人员","F":"4","G":"采购员议价-非6000","H":"AssetPurchase","N":"采购员议价-非6000"},{"E":"指定人员","F":"5","G":"采购员议价-6000 10211751","H":"AssetPurchase","N":"采购员议价-6000 10211751"},{"C":"10210588","E":"指定人员","F":"6","G":"采购主管审批-非6000","H":"AssetPurchase","N":"采购主管审批-非6000"},{"A":"30000735","E":"指定岗位","F":"7","G":"采购主管审批","H":"AssetPurchase","N":"采购主管审批"},{"C":"10210169","E":"指定人员","F":"8","G":"总经理室审批","H":"AssetPurchase","N":"总经理室审批"},{"C":"10210900","E":"指定人员","F":"9","G":"资产会计-1000","H":"AssetPurchase","N":"资产会计-1000"},{"C":"10210971","E":"指定人员","F":"10","G":"资产会计-其他","H":"AssetPurchase","N":"资产会计-其他"},{"F":"11","G":"采购下单-非6000","H":"AssetPurchase","N":"采购下单-非6000"},{"F":"12","G":"采购下单-6000","H":"AssetPurchase","N":"采购下单-6000"},{"F":"13","G":"评估单位验收","H":"AssetPurchase","N":"评估单位验收"},{"C":"10210408","E":"指定人员","F":"14","G":"采购确认回厂-模具","H":"AssetPurchase","N":"采购确认回厂-模具"},{"C":"10211652","E":"指定人员","F":"15","G":"采购确认回厂-非模具","H":"AssetPurchase","N":"采购确认回厂-非模具"},{"C":"10210408","E":"指定人员","F":"16","G":"仓库103收货-1000","H":"AssetPurchase","N":"仓库103收货-1000"},{"C":"10211357","E":"指定人员","F":"17","G":"仓库103收货-2000","H":"AssetPurchase","N":"仓库103收货-2000"},{"C":"10210350","E":"指定人员","F":"18","G":"设备部安装1","H":"AssetPurchase","N":"设备部安装1"},{"C":"10211101","E":"指定人员","F":"19","G":"设备部安装2","H":"AssetPurchase","N":"设备部安装2"},{"F":"20","G":"使用部门验收","H":"AssetPurchase","N":"使用部门验收"},{"F":"21","G":"设备验收","H":"AssetPurchase","N":"设备验收"},{"C":"10211000","E":"指定人员","F":"22","G":"仓库105收货-1000","H":"AssetPurchase","N":"仓库105收货-1000"},{"F":"23","G":"仓库105收货-2000","H":"AssetPurchase","N":"仓库105收货-2000"},{"F":"24","G":"资产会计确认-1000","H":"AssetPurchase","N":"资产会计确认-1000"},{"F":"25","G":"资产会计确认-其他","H":"AssetPurchase","N":"资产会计确认-其他"},{"C":"10210841","E":"指定人员","F":"26","G":"IE部门统计","H":"AssetPurchase","N":"IE部门统计"}]';
        str1 = str1.replace('"A"', '"Post_Number__c"');
        str1 = str1.replace('"B"', '"Dept_Number__c"');
        str1 = str1.replace('"C"', '"Description__c"');
        str1 = str1.replace('"D"', '"Approval_Special_Field__c"');
        str1 = str1.replace('"E"', '"Approval_Rule__c"');
        str1 = str1.replace('"F"', '"Approval_Step__c"');
        str1 = str1.replace('"G"', '"Approval_Step_Name__c"');
        str1 = str1.replace('"H"', '"Approval_Name__c"');
        str1 = str1.replace('"N"', '"Name"');
        List<Organizational__c> configs = (List<Organizational__c>)JSON.deserialize(str1,List<Organizational__c>.class);

        //List<Organizational__c> configs = Test.loadData(Organizational__c.SobjectType, 'TD_ApprovalConfig');
        //System.debug(JSON.serialize(configs));
        for(Organizational__c md : configs){
            md.Id = null;
        	md.RecordTypeId = acId;
           	if(!String.isBlank(md.Description__c)){
        		md.Approval_Personnel__c = mapStaffs.containsKey(md.Description__c)?mapStaffs.get(md.Description__c):null;
        	}else{
        		md.Approval_Personnel__c = null;
        	}
        	if(!String.isBlank(md.Dept_Number__c)){
        		md.Approval_Department__c = mapDepts.containsKey(md.Dept_Number__c)?mapDepts.get(md.Dept_Number__c):null;
        	}else{
	        	md.Approval_Department__c = null;
        	}
        	if(!String.isBlank(md.Post_Number__c)){
        		md.Approval_Post__c = mapJobs.containsKey(md.Post_Number__c)?mapJobs.get(md.Post_Number__c):null;
        	}else{
	        	md.Approval_Post__c = null;
        	}
            md.Description__c = null;
            md.Dept_Number__c = null;
            md.Post_Number__c = null;
        }
        INSERT configs;
        System.debug('*** 流程结点测试数据生成成功！');
    }
    /*
        创建客户测试数据
    */
    public static Custom_Approval_Managed__c createCustomerData(){
        Custom_Approval_Managed__c cam = new Custom_Approval_Managed__c();
        List<Contact> cons = [SELECT Id FROM Contact WHERE RecordType.DeveloperName='Staff' LIMIT 10];
        cam.RecordTypeId = HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.CUSTOMER, 'Custom_Approval_Managed__c');
        cam.Applicant__c = cons[0].Id;
        cam.Dept_Name__c = '系统运维课';
        cam.Applicant_Code__c = '10210911';
        cam.Fax__c = '0571-25784513';
        cam.Product_Group__c = '10';
        cam.Shopping_Address1__c = '昆山市陆家镇友谊路412号';
        cam.Country_Name__c = '中国';
        cam.Province_Code_of_Shopping__c = '3';
        cam.Mobile_Phone__c = '13899995566';
        cam.Distribution_Channel__c = '10';
        cam.Sales_Dept__c = '0001';
        cam.Currency__c = 'CNY';
        cam.Corp_Address__c = '陆家镇友谊路412号';
        cam.City_Name_of_Shopping__c = '苏州市';
        cam.Delivery_Priority__c = '01';
        cam.Delivery_Factory__c = '1000';
        cam.Customer_Group__c = '30';
        cam.Engrave_Type__c = '1';
        cam.City_Code_of_Shopping__c = '3005';
        cam.Fax_Extension_Number__c = '228';
        cam.Retrieve_Item1__c = 'DD';
        cam.Tax_Number__c = '02548789545645M';
        cam.Approval_Status__c = 'D';
        cam.Term_of_Payment__c = 'YB30';
        cam.Country_Code__c = 'CN';
        cam.Title__c = '0001';
        cam.Province_Name_of_Shopping__c = '江苏省';
        cam.Account_Allot_Group__c = '01';
        cam.Language__c = '1';
        cam.Account_Number__c = '20004567';
        cam.Area_Name__c = '江苏省';
        cam.Sales_Group__c = '002';
        cam.Shipping_Term__c = '01';
        cam.Price_Group__c = '24';
        cam.Control_Subject__c = '1121000000';
        cam.Sales_Area__c = '00012';
        cam.Province_Code__c = '3';
        cam.Phone_Extension_Number__c = '126';
        cam.Term_of_Payment1__c = 'YZ27';
        cam.Postcode__c = '524000';
        cam.City_Name__c = '苏州市';
        cam.Phone__c = '0571-25784512';
        cam.Corporation__c = '1000';
        cam.City_Additional__c = '江苏';
        cam.City_Code__c = '3005';
        cam.Email__c = '10004567@qq.com';
        cam.Industry__c = '0020';
        cam.Subject_Group__c = 'Z002';
        cam.Is_Order_Portfolio__c = false;
        cam.Status__c = '新建';
        cam.Province_Name__c = '江苏省';
        cam.Account_Name__c = '江苏省第一人民医院';
        cam.Approval_Name__c = '客户主数据维护';
        cam.Sales_Org__c = '1000';
        INSERT cam;

        //创建银行细目
        Custom_Approval_Managed_Item__c bank = new Custom_Approval_Managed_Item__c();
        bank.RecordTypeId = HarryUtils.getRecordTypeIdByDevNameAndObjName('Custmer_Bank_Detail','Custom_Approval_Managed_Item__c');
        bank.Customer_Bank__c = cam.Id;
        bank.Country_Code__c = 'CN';
        bank.Country_Name__c = '中国';
        bank.Account_of_Bank__c = '9999999999';
        bank.Account_Name__c = '测试名';
        bank.Name_of_Bank__c = '3433';
        bank.IBANValue__c = '343';
        bank.SWIFT_Code__c = '232232';
        bank.Validate_Date__c = Date.newInstance(2049, 12, 31);
        INSERT bank;

        //创建客户联系人
        Contact con = new Contact();
        con.RecordTypeId = HarryUtils.getRecordTypeIdByDevNameAndObjName('Account_Contact','Contact');
        con.Customer_Contact__c = cam.Id;
        con.LastName = '张三';
        con.Phone = '020-56484785';
        con.Extension_Number__c = '222';
        con.Department = '测试部';
        con.Department__c = '0001';
        con.Functionally__c = '01';
        con.MobilePhone = '13567895686';
        con.Fax = '020-35689546';
        con.Extension_Number_Fax__c = '555';
        con.Email = 'testContact@kl.com';
        INSERT con;

        //客户税收类别
        Custom_Approval_Managed_Item__c tax = new Custom_Approval_Managed_Item__c();
        tax.RecordTypeId = HarryUtils.getRecordTypeIdByDevNameAndObjName('Tax_Type','Custom_Approval_Managed_Item__c');
        tax.Customer_Tax__c = cam.Id;
        tax.Country_Code__c = 'CN';
        tax.Country_Name__c = '中国';
        tax.Category_of_Tax__c = 'MWST';
        tax.Type_of_Tax__c = '1';
        INSERT tax;

        //客户合伙人功能
        Contact partner = new Contact();
        partner.RecordTypeId = HarryUtils.getRecordTypeIdByDevNameAndObjName('Account_Partner','Contact');
        partner.Customer_Partner__c = cam.Id;
        partner.PF__c = 'BP';
        partner.Functionally__c = '02';
        partner.Number__c = '10002345';
        partner.LastName = '张三丰';
        partner.Description_of_Partner__c = '测试客户合伙人';
        INSERT partner;

        return cam;
    }
    /*
        创建供应商测试数据
    */
    public static Custom_Approval_Managed__c createVendorData(){
        Custom_Approval_Managed__c cam = new Custom_Approval_Managed__c();
        List<Contact> cons = [SELECT Id FROM Contact WHERE RecordType.DeveloperName='Staff' LIMIT 10];
        cam.RecordTypeId = HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.VENDOR,'Custom_Approval_Managed__c');
        cam.Applicant__c = cons[6].Id;
        cam.SAPID__c = 'V8976542';
        cam.Status__c = '新建';
        cam.Approval_Status__c = 'D';
        cam.Type__c = 'I';
        cam.Corporation__c = '1000';
        cam.Purchase_Org__c = '1000';
        cam.Account_Group__c = 'Z001';
        cam.Vendor_Number__c = 'V20085648';
        cam.Title__c = '0003';
        cam.Vendor_Name__c = '江苏来来不锈钢厂';
        cam.Reserved_Street__c = '苏州市东风路488号';
        cam.House_Number__c = '488号';
        cam.Postcode__c = '500000';
        cam.Language__c = '1';
        cam.Standard_Contac_Method__c = 'INT';
        cam.Mobile_Phone__c = '15865487854';
        cam.Phone__c = '0758-25487958';
        cam.Phone_Extension_Number__c = '128';
        cam.Fax__c = '0758-25487959';
        cam.Fax_Extension_Number__c = '168';
        cam.Email__c = 'Test@kinglai.com';
        cam.Tax_Number__c = 'NO.258145144554';
        cam.Tax_Number_Additional__c = '25451';
        cam.Is_Based_Invoice__c = true;
        cam.Purchase_Group__c = '100';
        cam.Plan_Delivery_Days__c = 7;
        cam.Control_Subject__c = '1123000000';
        cam.Cash_Manage_Group__c = 'A4';
        cam.Term_of_Payment_Vendor__c = 'XA30';
        cam.Currency__c = 'CNY';
        cam.Num_Min_Order__c = 100;
        cam.International_Trade_Term__c = 'DDP';
        cam.Remark__c = '测试供应商';
        cam.Term_of_Payment_Corp__c = 'XY30';

        INSERT cam;

        //创建供应商银行细目
        Custom_Approval_Managed_Item__c bank = new Custom_Approval_Managed_Item__c();
        bank.RecordTypeId = HarryUtils.getRecordTypeIdByDevNameAndObjName('Vendor_Bank_Info','Custom_Approval_Managed_Item__c');
        bank.Vendor_Bank__c = cam.Id;
        bank.Country_Code__c = 'CN';
        bank.Country_Name__c = '中国';
        bank.Bank_of_Code__c = 'ICCB';
        bank.Account_of_Bank__c = '9999999999';
        bank.Account_Name__c = '测试名';
        bank.Name_of_Bank__c = '中国工商银行';
        bank.IBANValue__c = '343';
        bank.SWIFT_Code__c = '232232';
        bank.Validate_Date__c = Date.newInstance(2049, 12, 31);
        INSERT bank;

        //创建供应商联系人
        Contact con = new Contact();
        con.RecordTypeId = HarryUtils.getRecordTypeIdByDevNameAndObjName('Vendor_Contact','Contact');
        con.Vendor_Contact__c = cam.Id;
        con.LastName = '张三';
        con.Phone = '020-56484785';
        con.Extension_Number__c = '222';
        con.Department = '测试部';
        con.Department__c = '0001';
        con.Functionally__c = '01';
        con.MobilePhone = '13567895686';
        con.Fax = '020-35689546';
        con.Extension_Number_Fax__c = '555';
        con.Email = 'testContact@kl.com';
        INSERT con;

        //客户供应商功能
        Contact partner = new Contact();
        partner.RecordTypeId = HarryUtils.getRecordTypeIdByDevNameAndObjName('Vendor_Partner','Contact');
        partner.Vendor_Partner__c = cam.Id;
        partner.PF__c = 'BP';
        partner.Functionally__c = '02';
        partner.Number__c = '10002345';
        partner.LastName = '张三丰';
        partner.Description_of_Partner__c = '测试客户合伙人';
        INSERT partner;

        return cam;
    }
    /*
        创建员工出差测试数据
    */
    public static void createBusinessTravel(){
        //出差：TA00011731
        String jsonStr = '[{"status":"INSERT","employee_code":"10210463","hly_number":"TA00011731","document_date":"2017-06-06 15:30:00","unit_code":"1000E005","headers":[{"cash_amount":"0.00","travel_type":"A04","status":"insert","currencies":"CNY","unit_code":"1000E001","istraining":"N","trip":"接口","iscash":"N","return_date":"2017-06-07 17:30:00","amount":"1024.56","traffic":"20","issales":"Y","iscar":"Y","departure_date":"2017-06-01 09:30:00","cash_currency":"CNY","regional":"A","lines":[{"company":"上海本优机械有限公司","activity_id":"","line_number":"10","status":"insert","visit_date":"2017-06-06","place":"上海"}]}]}]';
        List<HLYSyncBusinessTravel.BTParameter> arg = (List<HLYSyncBusinessTravel.BTParameter>)JSON.deserialize(jsonStr,List<HLYSyncBusinessTravel.BTParameter>.class);
        HLYSyncBusinessTravel.doPost('SUBMIT' ,'TRL_REQUISITION' ,arg);
    }
    public static void createBusinessTravel2(){
        String jsonStr = '[{"status":"INSERT","employee_code":"10210464","hly_number":"TA00011732","document_date":"2017-06-06 15:30:00","unit_code":"1000E005","headers":[{"cash_amount":"dddd","travel_type":"A04","status":"insert","currencies":"CNY","unit_code":"1000E001","istraining":"N","trip":"接口","iscash":"N","return_date":"2017-06-07 17:30:00","amount":"dss","traffic":"20","issales":"Y","iscar":"Y","departure_date":"2017-06-01 09:30:00","cash_currency":"CNY","regional":"A","lines":[{"company":"上海本优机械有限公司","activity_id":"","line_number":"10","status":"insert","visit_date":"yyyy-MM-dd","place":"上海"}]}]}]';
        List<HLYSyncBusinessTravel.BTParameter> arg = (List<HLYSyncBusinessTravel.BTParameter>)JSON.deserialize(jsonStr,List<HLYSyncBusinessTravel.BTParameter>.class);
        HLYSyncBusinessTravel.doPost('SUBMIT' ,'TRL_REQUISITION' ,arg);
        HLYSyncBusinessTravel.doPost('SUBMIT' ,'TRL_REQUISITION' ,arg);
    }
    /*
        创建交际应酬费测试数据
    */
    public static void createEntertaineCost(){
        //交际：EA10007155
        String jsonStr = '[{"status":"INSERT","document_date":"2017-06-07 08:50:26","unit_code":"10000140","employee_code":"10210463","hly_number":"EA10007155","headers":[{"ddate":"2017-06-08 09:50:00","trip":"这是一次胜利的会议","note":"新莱销售","currencies":"CNY","customer_code":"0001005095","status":"insert","expense_type":"1","unit":"销售","amount":"2034.85","place":"江苏省昆山市陆家镇","arrangement":"前台报餐","customer":"浙江纳爱斯集团"}]}]';
        List<HLYSyncEntertaineCost.ECParameter> arg = (List<HLYSyncEntertaineCost.ECParameter>)JSON.deserialize(jsonStr,List<HLYSyncEntertaineCost.ECParameter>.class);
        HLYSyncEntertaineCost.doPost('SUBMIT' ,'JYC_REQUISITION' ,arg);
    }
    public static void createEntertaineCost2(){
        String jsonStr = '[{"status":"INSERT","document_date":"2017-06-07 08:50:26","unit_code":"10000140","employee_code":"10210463","hly_number":"EA10007156","headers":[{"ddate":"2017-06-08 09:50:00","trip":"这是一次胜利的会议","note":"新莱销售","currencies":"CNY","customer_code":"0001005095","status":"insert","expense_type":"1","unit":"销售","amount":"lkjh","place":"江苏省昆山市陆家镇","arrangement":"前台报餐","customer":"浙江纳爱斯集团"}]}]';
        List<HLYSyncEntertaineCost.ECParameter> arg = (List<HLYSyncEntertaineCost.ECParameter>)JSON.deserialize(jsonStr,List<HLYSyncEntertaineCost.ECParameter>.class);
        HLYSyncEntertaineCost.doPost('SUBMIT' ,'JYC_REQUISITION' ,arg);
        HLYSyncEntertaineCost.doPost('SUBMIT' ,'JYC_REQUISITION' ,arg);
    }
    /*
        创建费用报销单测试数据
    */
    public static void createExpenseReimburse(){
        //费用报销 ER10008001
        String jsonStr = '[{"status":"INSERT","hly_number":"ER12008001","document_date":"2017-06-09 08:52:26","unit_code":"10000140","employee_code":"10210463","headers":[{"employee_code":"10219018","trl_requisition":"TA00011731","jyc_requisition":"EA10007155","total_amount":"1618.0","note":"kvc","cost_center":"1000E001","currencies":"CNY","status":"insert","company_code":"1000","activity_id":"300000003138831","posting_unit":"001","report_type":"sales_travel_report","lines":[{"status":"INSERT","line_number":"","price":"820","account_code":"8000180000","amount":"1024.85","reference_mileage":"","quantity":"10","enter_mileage":"","note":"新莱销售","expense_type":"Y","attachments":[{"attachmentOID":"K09877-22832"}]}]}]}]';
        List<HLYSyncExpenseReimburse.ERParameter> arg = (List<HLYSyncExpenseReimburse.ERParameter>)JSON.deserialize(jsonStr,List<HLYSyncExpenseReimburse.ERParameter>.class);
        HLYSyncExpenseReimburse.doPost('SUBMIT' ,'REPORT' ,arg);
    }
    public static void createExpenseReimburse2(){
        //费用报销 ER10008001
        String jsonStr = '[{"status":"INSERT","hly_number":"ER10008002","document_date":"2017-06-09 08:52:26","unit_code":"10000140","employee_code":"10210463","headers":[{"employee_code":"10219018","trl_requisition":"TA00011731","jyc_requisition":"EA10007155","total_amount":"dsdsd","note":"kvc","cost_center":"1000E001","currencies":"CNY","status":"insert","company_code":"1000","activity_id":"","posting_unit":"001","report_type":"travel_report","lines":[{"status":"INSERT","line_number":"","price":"dsd","account_code":"8000180000","amount":"ddd","reference_mileage":"","quantity":"d","enter_mileage":"","note":"新莱销售","expense_type":"N","attachments":[{"attachmentOID":"K09877-22832"}]}]}]}]';
        List<HLYSyncExpenseReimburse.ERParameter> arg = (List<HLYSyncExpenseReimburse.ERParameter>)JSON.deserialize(jsonStr,List<HLYSyncExpenseReimburse.ERParameter>.class);
        HLYSyncExpenseReimburse.doPost('SUBMIT' ,'REPORT' ,arg);
        HLYSyncExpenseReimburse.doPost('SUBMIT' ,'REPORT' ,arg);
    }
    /*
        创建预付款申请单测试数据
    */
    public static Approval_Managed__c createAdvanceCharge(){
        Id rtID = Utils.getRecordTypeId('Approval_Managed__c',SapApprovalEnum.ADVANCECHARGE);
        List<Contact> cons = [SELECT Id FROM Contact WHERE RecordType.DeveloperName='Staff' LIMIT 10];
        Approval_Managed__c am = new Approval_Managed__c();
        am.Applicant__c = cons[0].Id;
        am.RecordTypeId = rtID;
        am.SAPID__c = 'AC10082345';
        am.Status__c = '新建';
        am.Approval_Status__c = 'D';
        am.Expense_Type_Prepay__c = '10';//20
        am.Corporation__c = '1000';
        am.Applicant_Cost__c = cons[1].Id;
        am.Dept_PR_Approval__c = '1000E001';
        am.Supplier_Number__c = '87348389';
        am.Supplier_Name__c = '测试厂商';
        am.Dept_of_CostCenter__c = '1000E007';
        am.Term_of_Payment__c = 'T120';
        am.Amount_of_Purchase__c = '62560.58';
        am.Percent_Pay__c = 0.5;
        am.Amount_Prepay__c = 62560.58;
        am.Remark_Vendor_Prepay__c = '无欠款';
        am.Num_Unfinished__c = 0;
        am.Amount_Offset__c = 0;
        am.Type_of_Payment__c = '02';
        am.Amount_Confirm__c = 62560.58;

        INSERT am;
        return am;
    }
    /*
        创建员工异动申请单测试数据
    */
    public static Approval_Managed__c createStaffTransfer(){
        Approval_Managed__c am = new Approval_Managed__c();
        List<Contact> cons = [SELECT Id FROM Contact WHERE RecordType.DeveloperName='Staff' LIMIT 10];
        am.Applicant__c = cons[4].Id;
        am.Employee__c = cons[0].Id;
        am.RecordTypeId = Utils.getRecordTypeId('Approval_Managed__c',SapApprovalEnum.STAFFTRANSFER);
        am.Status__c = '新建';
        am.Approval_Status__c = 'D';
        am.Employee_Code__c = '12345678';
        am.Employee_Name__c = 'messi';
        am.Staff_Group_New__c = '2';
        am.Staff_Sub_Group_New__c = '01';
        am.Job_Title_Level_New__c = '03.2';
        am.Reason_of_Operate__c = 'A1';
        am.Validate_Date__c = Date.newInstance(2017,8,1);
        am.Is_Salary_Adjust__c = true;
        am.Is_Work_Transfered__c = true;
        am.Handover_Man1__c = 'ne';
        am.Supervisor1__c = 'messi king';
        am.Transfer_Date__c = Date.newInstance(2017,7,1);
        INSERT am;
        return am;
    }
    /*
        创建品质异常单测试数据
    */
    public static Approval_Managed__c createAbnormalQuality(){
        List<Contact> cons = [SELECT Id FROM Contact WHERE RecordType.DeveloperName='Staff' LIMIT 10];
        Approval_Managed__c am = new Approval_Managed__c();
        am.RecordTypeId = Utils.getRecordTypeId('Approval_Managed__c', SapApprovalEnum.ABNORMALQUALITY);
        am.Applicant__c = cons[1].Id;
        am.Status__c = '新建';
        am.Approval_Status__c = 'D';
        am.Abnormal_Code__c = 'QA452165874';
        am.Abnormal_Type__c = 'Z4';
        am.Status_Abnormal__c = '起泡';
        am.Description__c = '表面有气泡';
        am.Dept_of_Discovery__c = 'QA部';
        am.Num_Order__c = '5000';
        am.Num_Unqualified__c = 58;
        am.Rate_Unqualified__c = 0.012;
        am.Material_Number__c = 'M2154845';
        am.Material_Name__c = '弯头450';
        am.Dept_of_Duty__c = 'D602';
        am.Manager_of_Duty__c = '张三有';
        am.Person_Liable__c = '李四元';
        am.Operator_Abnormal__c = cons[3].Id;
        am.Is_Withhold__c = true;
        am.Cause_of_Analysis1__c = '工作不认真';
        am.Description_of_Effect__c = '';
        am.Confirmor_of_Effect__c = '张三有';
        am.Confirm_Date_of_Effect__c = Date.newInstance(2017,7, 1);

        INSERT am;

        //品质异常问题列表
        Approval_Managed_Item__c ami = new Approval_Managed_Item__c();
        ami.RecordTypeId = HarryUtils.getRecordTypeIdByDevNameAndObjName('Quality_Problems', 'Approval_Managed_Item__c');
        ami.Abnormal_Problem__c = am.Id;
        ami.Row_Index__c = '0001';
        ami.Project__c = '江苏省第一人民医院项目';
        ami.Project_No__c = 'P.2548754';
        ami.Code_Group__c = '01';
        ami.Type_of_Bug__c = '02';
        ami.Type_Description_Bug__c = '有气泡';
        INSERT ami;

        //品质异常纠正措施
        Approval_Managed_Item__c amh = new Approval_Managed_Item__c();
        amh.RecordTypeId = HarryUtils.getRecordTypeIdByDevNameAndObjName('Corrective_Action', 'Approval_Managed_Item__c');
        amh.Abnormal_Header__c = am.Id;
        amh.Abnormal_Rectify__c = ami.Id;
        amh.Parent_Row_Index__c = ami.Row_Index__c;
        amh.Row_Index__c = '0001';
        amh.Plan_Completed_Date__c = Date.newInstance(2017,7, 8);
        amh.Header__c = cons[4].Id;

        INSERT amh;

        //品质异常围堵措施
        Approval_Managed_Item__c amca = new Approval_Managed_Item__c();
        amca.RecordTypeId = HarryUtils.getRecordTypeIdByDevNameAndObjName('Containment_Action', 'Approval_Managed_Item__c');
        amca.Abnormal_Containment__c = am.Id;
        amca.Row_Index__c = '0001';
        amca.Header__c = cons[5].Id;

        INSERT amca;

        return am;
    }
    /*
        创建采购信息记录测试数据
    */
    public static Custom_Approval_Managed__c createPurchaseInformation(){
        Custom_Approval_Managed__c cam = new Custom_Approval_Managed__c();
        List<Contact> cons = [SELECT Id FROM Contact WHERE RecordType.DeveloperName='Staff' LIMIT 10];
        cam.RecordTypeId = Utils.getRecordTypeId('Custom_Approval_Managed__c', SapApprovalEnum.PURCHASEINFORMATION);
        cam.Applicant__c = cons[1].Id;
        cam.Status__c = '新建';
        cam.Approval_Status__c = 'D';
        cam.Number_of_Purchase_Info__c = '24554515';
        cam.Status_of_Purchase_Info__c = 'A';
        cam.Kind_of_Material__c = '003';
        INSERT cam;

        Custom_Approval_Managed_Item__c item = new Custom_Approval_Managed_Item__c();
        item.RecordTypeId = Utils.getRecordTypeId('Custom_Approval_Managed_Item__c','Purchase_Info_Price_Result');
        item.Purchase_Info_Inquiry__c = cam.Id;
        item.Row_Index__c = '10';
        item.Selected__c = '是';
        item.Quote__c = 'Q.12488554544';
        item.Quote_Item__c = '10';
        item.Number_of_Purchase__c = 'P.545455551';
        item.Number_of_Item__c = '20';
        item.Vendor_Number__c = '10005648';
        item.Vendor_Name__c = '江苏来来不锈钢厂';
        item.Material_Number__c = 'M55845855';
        item.Material_Name__c = '测试物料名称';
        item.Material_Number_of_Vendor__c = 'QM578545554';
        item.Category_Text__c = '005';
        item.Quote_Request_Date__c = Date.newInstance(2017, 7, 4);
        item.Factory__c = '1000';
        item.Request_Track_No__c = '10';
        item.Material_Group__c = '02';
        item.Purchase_Info_Number__c = '24554515';
        item.Price_of_Purchase_Voucher__c = 12.5;
        item.Price_of_Quantity__c = 50;
        item.End_Date__c = Date.newInstance(2017, 7, 25);
        item.Currency__c = 'CNY';
        item.Exchange_Rate__c = 1.0;
        item.Price_of_Last__c = 12.5;
        item.Date_of_Last_Trade__c = Date.newInstance(2017, 5, 5);
        item.Type_of_Tax__c = '1';
        item.Tax_Number__c = 'J1';
        item.Price_of_Moving_Average__c = 12.10;
        item.Quantity_of_Min_Order__c = 50;
        item.Days_of_Validity__c = 90;
        item.Kind_of_Material__c = '01';
        item.Days_of_Delivery_Period__c = 7;
        item.Quantity_of_RFQ__c = 580;
        INSERT item;

        Custom_Approval_Managed_Item__c itemRow = new Custom_Approval_Managed_Item__c();
        itemRow.RecordTypeId = Utils.getRecordTypeId('Custom_Approval_Managed_Item__c','Purchase_Info_Result_Detail');
        itemRow.Purchase_Info_Row__c = item.Id;
        itemRow.Purchase_Info_Inquiry_Row__c = cam.Id;
        itemRow.Row_Index__c = '10';
        itemRow.Index_Item__c = '10';
        itemRow.Vendor__c = null;
        itemRow.Vendor_Number__c = '';
        itemRow.Vendor_Name__c = '';
        itemRow.Purchase_Org__c = '1000';
        itemRow.Factory__c = '1000';
        itemRow.Purchase_Info_Number__c = '24554515';
        itemRow.Created_Date__c = Date.newInstance(2017, 7, 1);
        itemRow.Price__c = 12.5;
        itemRow.Currency__c = 'CNY';
        itemRow.Price_of_Quantity__c = 50;
        itemRow.Term_Unit__c = '0001';
        itemRow.Start_Date__c = Date.newInstance(2017, 7, 1);
        itemRow.End_Date__c = Date.newInstance(2017, 9, 30);
        itemRow.Term_Number__c = 'NO.68754455';
        INSERT itemRow;

        return cam;   
    }
    /*
        创建销售订单测试数据
    */
    public static Custom_Approval_Managed__c createSaleOrder(){
        Custom_Approval_Managed__c cam = new Custom_Approval_Managed__c();
        List<Contact> cons = [SELECT Id FROM Contact WHERE RecordType.DeveloperName='Staff' LIMIT 10];
        cam.RecordTypeId = Utils.getRecordTypeId('Custom_Approval_Managed__c', SapApprovalEnum.SALEORDER);
        cam.Applicant__c = cons[5].Id;
        cam.Status__c = '新建';
        cam.Approval_Status__c = 'D';
        cam.Kind_of_Order__c = 'Z001';
        cam.Bill_No__c = 'ORD.5487122';
        cam.Is_Agree_Refund__c = true;
        cam.Type_of_Approval__c = '01';
        cam.Customer_Code__c = 'CUR.588445565';
        cam.Customer_Name__c = '测试客户名称';
        cam.Delivery_Party_Code__c = '0001';
        cam.Delivery_Party_Name__c = '圆通快递';
        cam.Weight_Total__c = 14512;
        cam.Opportunity_Code__c = 'OP.94941551';
        cam.Sales_Org__c = '1000';
        cam.Product_Group__c = '11';
        cam.Price_Group__c = '14';
        cam.Customer_Group__c = '50';
        cam.Sales_Area__c = '00001';
        cam.Sales_Office_Area__c = '上海';
        cam.Sales_Group__c = '001';
        cam.Is_Based_Quotation__c = true;
        cam.Code_Reference__c = 'Q.564845224';
        cam.Currency_Reference__c = 'CNY';
        cam.Amount_Reference__c = 54424;
        cam.Info_of_Discount__c = '95折';
        cam.Text1_Additional__c = '补充文本1';
        cam.Term_of_Contract__c = '合同附文';
        cam.Remark__c = '备注信息';
        cam.NotStandard_Price_Flag__c = '非标件价格判定标记';
        cam.Prepare_Feed_Protocol__c = '备料单协议';
        cam.Sales_Employee__c = '销售员1';
        INSERT cam;

        //销售订单明细
        Custom_Approval_Managed_Item__c item = new Custom_Approval_Managed_Item__c();
        item.RecordTypeId = Utils.getRecordTypeId('Custom_Approval_Managed_Item__c', 'Sale_Order_Detail');
        item.Sales_Order__c = cam.Id;
        item.Row_Index__c = '10';
        item.Index_Item__c = '10';
        item.Material_Number__c = 'M1245782';
        item.Material_Name__c = '测试物料名称';
        item.Quantity__c = 4500;
        item.Unit__c = '个';
        item.Status_Overview__c = '总揽状态';
        item.Material_of_Customer__c = '245784155';
        item.Schedule_Date__c = Date.newInstance(2017, 7, 5);
        item.Price_Net__c = 12.8;
        item.Currency__c = 'CNY';
        item.Reason__c = '原因';
        item.Your_Reference__c = '你的参考';
        item.Material_Cost__c = 12.8;
        item.Operate_Flag__c = '操作标记 ';
        item.Operate_Type__c = '操作类型';

        //销售订单头条件明细
        Custom_Approval_Managed_Item__c itemH = new Custom_Approval_Managed_Item__c();
        itemH.RecordTypeId = Utils.getRecordTypeId('Custom_Approval_Managed_Item__c', 'Sale_Order_Detail_Header');
        itemH.Sales_Order_Header__c = cam.Id;
        itemH.Type_of_Price__c = '0002';
        itemH.Name_of_Price__c = '95折';
        itemH.Amount__c = 1245;
        itemH.Currency__c = 'CNY';
        itemH.Quantity__c = 4500;
        itemH.Uom__c = 'Uom';
        itemH.Value_of_Price__c = 12.8;
        //销售订单行条件明细
        Custom_Approval_Managed_Item__c itemDR = new Custom_Approval_Managed_Item__c();
        itemDR.RecordTypeId = Utils.getRecordTypeId('Custom_Approval_Managed_Item__c', 'Sale_Order_Detail_Row');
        itemDR.Sales_Order_Detail__c = cam.Id;
        itemDR.Row_Index__c = '10';
        itemDR.Index_Item__c = '10';
        itemDR.Type_of_Price__c = '0002';
        itemDR.Name_of_Price__c = '95折';
        itemDR.Amount__c = 2457;
        itemDR.Currency__c = 'CNY';
        itemDR.Quantity__c = 4500;
        itemDR.Uom__c = 'Uom';
        itemDR.Value_of_Price__c = 15.5;

        //销售订单合伙人
        Contact partner = new Contact();
        partner.RecordTypeId = HarryUtils.getRecordTypeIdByDevNameAndObjName('Sale_Order_Partner','Contact');
        partner.Sales_Order_Partner__c = cam.Id;
        partner.PF__c = 'BP';
        partner.Functionally__c = '02';
        partner.Number_Partner__c = '10002345';
        partner.LastName = '张三丰';
        partner.Description_of_Partner__c = '测试销售订单合伙人';
        INSERT partner;
        
        return cam;   
    }
    /*
        创建标准采购订单测试数据
    */
    public static Approval_Managed__c createPurchaseOrder(){
        Approval_Managed__c am = new Approval_Managed__c();
        List<Contact> cons = [SELECT Id FROM Contact WHERE RecordType.DeveloperName='Staff' LIMIT 10];
        am.RecordTypeId = Utils.getRecordTypeId('Approval_Managed__c', SapApprovalEnum.PURCHASEORDER);
        am.Applicant__c = cons[4].Id;
        am.Status__c = '新建';
        am.Approval_Status__c = 'D';
        am.Applicant__c = cons[7].Id;
        am.Kind_of_Order__c = 'NB';
        am.Bill_No__c = 'NB.58741464';
        am.Purchase_Date__c = Date.newInstance(2017, 7, 12);
        am.Purchase_Org__c = '1000';
        am.Purchase_Group__c = '100';
        am.Corporation__c = '1000';
        am.Currency__c = 'CNY';
        am.Days_of_Payment__c = 7;
        am.Percent_of_Payment__c = 0.5;
        am.Exchange_Rate__c = 1;
        am.Term_of_Payment__c = 'XA07';
        am.Days_of_Payment_Term__c = 7;
        am.Percent_of_Payment_Term__c = 0.5;
        am.Amount_Net_Days__c = 15.6;
        am.International_Trade_Term__c = 'CIF';
        am.Required_date__c = Date.newInstance(2017, 7, 15);
        am.Is_Receipt_Info__c = true;
        INSERT am;
        //采购订单明细
        Approval_Managed_Item__c item = new Approval_Managed_Item__c();
        item.RecordTypeId = Utils.getRecordTypeId('Approval_Managed_Item__c', 'Purchase_Detail');
        item.Row_Index__c = '10';
        item.Index_Item__c = '0001';
        item.Purchase_Order__c = am.Id;
        item.Material_Number__c = 'M12457545';
        item.Material_Name__c = '测试物料名称';
        item.Quantity__c = 1000;
        item.Unit__c = '个';
        item.Delivery_Date__c = Date.newInstance(2017, 7, 13);
        item.Price_Net__c = 12.5;
        item.Currency__c = 'CNY';
        item.Price_Tax__c = 13.8;
        item.Currency_Tax__c = 'CNY';
        item.Vendor_Response__c = '2017-07-18';
        item.Remark__c = '';
        item.Last_Pick_Date__c = Date.newInstance(2017, 6, 5);
        item.Last_Pick_Price__c = 13.7;
        item.Last_Pick_Currency__c = 'CNY';
        item.Per__c = 500;
        item.Unit3__c = '个';
        item.Factory__c = '1000';
        item.Applicant__c = cons[1].Id;
        item.Is_Free__c = false;
        item.Purchase_Order_Number__c = 'PO1244444';
        item.Applicant_Row__c = '10';
        item.Amount_Price__c = 13.8;
        item.Last_Pick_Number__c = 'PO1223441';
        item.Dept_of_CostCenter__c = '1000E005';
        item.Item__c = '0002';
        item.Sales_Amount_Total__c = 15643;
        item.Ledger_Account__c = '8000190000';
        INSERT item;
        //采购订单定价元素
        Approval_Managed_Item__c itemP = new Approval_Managed_Item__c();
        itemP.RecordTypeId = Utils.getRecordTypeId('Approval_Managed_Item__c', 'Purchase_Price');
        itemP.Row_Index__c = '10';
        itemP.Index_Item__c = '10';
        itemP.Purchase_Order_Price__c = am.Id;
        itemP.Type_of_Price__c = '研发';
        itemP.Name_of_Price__c = '研发';
        itemP.Value_of_Price__c = '15.8';
        itemP.Currency__c = 'CNY';
        INSERT itemP;

        return am;   
    }
    /*
        创建费料处理测试数据
    */
    public static Custom_Approval_Managed__c createWasteDispose(){
        Custom_Approval_Managed__c cam = new Custom_Approval_Managed__c();
        List<Contact> cons = [SELECT Id FROM Contact WHERE RecordType.DeveloperName='Staff' LIMIT 10];
        cam.RecordTypeId = Utils.getRecordTypeId('Custom_Approval_Managed__c', SapApprovalEnum.WASTEDISPOSE);
        cam.Applicant__c = cons[6].Id;

        INSERT cam;
        return cam;   
    }
    /*
        创建成本中心发料作业测试数据
    */
    public static Custom_Approval_Managed__c createCostCenterSend(){
        Custom_Approval_Managed__c cam = new Custom_Approval_Managed__c();
        List<Contact> cons = [SELECT Id FROM Contact WHERE RecordType.DeveloperName='Staff' LIMIT 10];
        cam.RecordTypeId = Utils.getRecordTypeId('Custom_Approval_Managed__c', SapApprovalEnum.COSTCENTERSEND);
        cam.Applicant__c = cons[2].Id;
        cam.Factory__c = '1000';
        cam.Option_of_Operate__c = '201';
        cam.Address_of_Stock__c = 'A00';
        cam.Dept_of_CostCenter__c = '1000L001';
        INSERT cam;

        cam.Id = null;
        cam.Option_of_Operate__c = 'Z61';
        cam.Address_of_Stock__c = 'D03';
        cam.Order_of_Production__c = '1021111';
        INSERT cam;
        
        return cam;   
    }

     /*
        创建盘盈盘亏测试数据
    */
    public static Approval_Managed__c createInventoryKinglai(){
        Approval_Managed__c am = new Approval_Managed__c();
        List<Contact> cons = [SELECT Id FROM Contact WHERE RecordType.DeveloperName='Staff' LIMIT 10];
        am.RecordTypeId = Utils.getRecordTypeId('Approval_Managed__c', SapApprovalEnum.INVENTORYKINGLAI);
        am.Applicant__c = cons[2].Id;
        am.Factory__c = '1000';
        am.Dept_of_CostCenter__c = '1000E004';
        am.InventoryType__c = '1'; 
        am.Remark__c = 'sdsdsd';
        am.Total_Price__c = 456445;
        INSERT am;
        
        return am;   
    }

    /*
        创建资产购置单测试数据
    */
    public static Approval_Managed__c createAssetPurchase(){
        Approval_Managed__c am = new Approval_Managed__c();
        List<Contact> cons = [SELECT Id FROM Contact WHERE RecordType.DeveloperName='Staff' LIMIT 10];
        am.RecordTypeId = Utils.getRecordTypeId('Approval_Managed__c', SapApprovalEnum.ASSETPURCHASE);
        am.Applicant__c = cons[3].Id;
        am.Asset_Type__c = '01';
        am.Status__c = '新建';
        am.Approval_Status__c = 'D';
        am.Factory__c = '1000';
        am.Dept_of_CostCenter__c = '1000E003';
        am.Required_date__c = Date.newInstance(2017, 7, 5);
        am.Asset_Code__c = 'AP.5412478';
        am.Responsible_CostCenter__c = '1000E005';
        am.Placement__c = 'KSD';
        am.Amount_of_Budget__c = 2531;
        am.Currcency_Budget__c = 'CNY';
        am.Quantity__c = 500;
        am.Amount_of_Paid__c = '1254';
        am.Amount_of_Forecast__c = 1234;
        am.Material_Number__c = 'M.21487556';
        am.Work_Center__c = '1000A008';
        am.Is_Budgeted__c = true;
        am.Price_Purchase__c = 24.65;
        am.Currency__c = 'CNY';
        am.Period_Delivery__c = 7;
        am.Is_Ok_Factory_Burthen__c = true;
        am.Stock_Number__c = '1524';
        am.Model_of_Asset__c = '03';
        am.Amount_Asset__c = 2456;
        am.Device_Number__c = 'DC2457895';

        INSERT am;

        am.Id = null;
        am.Asset_Type__c = '02';
        am.Applicant__c = cons[4].Id;
        INSERT am;

        am.Id = null;
        am.Asset_Type__c = '03';
        am.Applicant__c = cons[5].Id;
        INSERT am;

        return am;   
    }
    public static Approval_Managed__c createAssetPurchase2(){
        Approval_Managed__c am = new Approval_Managed__c();
        List<Contact> cons = [SELECT Id FROM Contact WHERE RecordType.DeveloperName='Staff' LIMIT 10];
        am.RecordTypeId = Utils.getRecordTypeId('Approval_Managed__c', SapApprovalEnum.ASSETPURCHASE);
        am.Applicant__c = cons[3].Id;
        am.Asset_Type__c = '04';
        am.Status__c = '新建';
        am.Approval_Status__c = 'D';
        am.Factory__c = '1000';
        am.Dept_of_CostCenter__c = '1000E003';
        am.Required_date__c = Date.newInstance(2017, 7, 5);
        am.Asset_Code__c = 'AP.5412478';
        am.Responsible_CostCenter__c = '1000E005';
        am.Placement__c = 'KSD';
        am.Amount_of_Budget__c = 2531;
        am.Currcency_Budget__c = 'CNY';
        am.Quantity__c = 500;
        am.Amount_of_Paid__c = '1254';
        am.Amount_of_Forecast__c = 1234;
        am.Material_Number__c = 'M.21487556';
        am.Work_Center__c = '1000A008';
        am.Is_Budgeted__c = true;
        am.Price_Purchase__c = 24.65;
        am.Currency__c = 'CNY';
        am.Period_Delivery__c = 7;
        am.Is_Ok_Factory_Burthen__c = true;
        am.Stock_Number__c = '1524';
        am.Model_of_Asset__c = '03';
        am.Amount_Asset__c = 2456;
        am.Device_Number__c = 'DC2457895';

        INSERT am;

        am.Id = null;
        am.Asset_Type__c = '05';
        am.Applicant__c = cons[4].Id;
        INSERT am;

        am.Id = null;
        am.Asset_Type__c = '06';
        am.Applicant__c = cons[5].Id;
        INSERT am;

        return am;   
    }
    public static Approval_Managed__c createAssetPurchase3(){
        Approval_Managed__c am = new Approval_Managed__c();
        List<Contact> cons = [SELECT Id FROM Contact WHERE RecordType.DeveloperName='Staff' LIMIT 10];
        am.RecordTypeId = Utils.getRecordTypeId('Approval_Managed__c', SapApprovalEnum.ASSETPURCHASE);
        am.Applicant__c = cons[1].Id;
        am.Asset_Type__c = '07';
        am.Status__c = '新建';
        am.Approval_Status__c = 'D';
        am.Factory__c = '1000';
        am.Dept_of_CostCenter__c = '1000E003';
        am.Required_date__c = Date.newInstance(2017, 7, 5);
        am.Asset_Code__c = 'AP.5412478';
        am.Responsible_CostCenter__c = '1000E005';
        am.Placement__c = 'KSD';
        am.Amount_of_Budget__c = 2531;
        am.Currcency_Budget__c = 'CNY';
        am.Quantity__c = 500;
        am.Amount_of_Paid__c = '1254';
        am.Amount_of_Forecast__c = 1234;
        am.Material_Number__c = 'M.21487556';
        am.Work_Center__c = '1000A008';
        am.Is_Budgeted__c = true;
        am.Price_Purchase__c = 24.65;
        am.Currency__c = 'CNY';
        am.Period_Delivery__c = 7;
        am.Is_Ok_Factory_Burthen__c = true;
        am.Stock_Number__c = '1524';
        am.Model_of_Asset__c = '03';
        am.Amount_Asset__c = 2456;
        am.Device_Number__c = 'DC2457895';

        INSERT am;

        am.Id = null;
        am.Asset_Type__c = '08';
        am.Applicant__c = cons[7].Id;
        INSERT am;

        return am;   
    }
    /*
        创建员工主动离职单测试数据
    */
    public static Approval_Managed__c createStaffLeaveOffice(){
        Approval_Managed__c am = new Approval_Managed__c();
        List<Contact> cons = [SELECT Id FROM Contact WHERE RecordType.DeveloperName='Staff' LIMIT 10];
        am.RecordTypeId = Utils.getRecordTypeId('Approval_Managed__c', SapApprovalEnum.STAFFLEAVEOFFICE);
        am.Applicant__c = cons[8].Id;

        INSERT am;
        return am;   
    }

    //员工请假
    public static Approval_Managed__c createAmleave(){
    Approval_Managed__c am = new Approval_Managed__c();
    List<Contact> cons = [SELECT Id FROM Contact WHERE RecordType.DeveloperName='Staff' LIMIT 10];
    am.RecordTypeId = Utils.getRecordTypeId('Approval_Managed__c', SapApprovalEnum.LEAVE);
    am.Applicant__c = cons[8].Id;
    am.Employee__c = cons[8].Id;
    INSERT am;
    return am;   
    }


}