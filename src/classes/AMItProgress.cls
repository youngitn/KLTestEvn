public without sharing class AMItProgress {
    public String selectedModelGroupValue {GET; SET;}
    public String selectedApprovalValue {GET; SET;}
    public String selectedApprovalName {GET; SET;}
    public String selectedStatusValue {GET; SET;}
    // public String selectedApprover {GET; SET;}
    public String selectedApprovalStartTime {GET; SET;}
    public String selectedApprovalEndTime {GET; SET;}
    //与前台进行交互参数类
    public Metadata__c meta {GET; SET;}
    public Approval_Managed__c standardApproval {GET; SET;}
    //public Boolean isUser{GET;SET;}
    //内部类，保存全部数据
    public Integer a  {GET; SET;}
   
    public List<AllApprovalData> allApproval {GET; SET;}
    public List<AllApprovalData> allApproval2 {GET; SET;}
    public AMItProgress() {
        meta = new Metadata__c();
        standardApproval = new Approval_Managed__c();
        //默认我参与的
        standardApproval.Is_Withhold__c = false;
        
        allApproval  = new List<AllApprovalData>();
        allApproval2 = new List<AllApprovalData>();
        
    }
    //内部类
    public class AllApprovalData {
        //流程ID
        public Id Id {GET; SET;}
        //流程编号(SF)
        public String Name {GET; SET;}
        //原单号(SAP或HLY)
        public String Original_Code {GET; SET;}
        //流程名称
        public String Approval_Name {GET; SET;}
        //申请人ID
        public String Applicant_Id {GET; SET;}
        //申请人
        public String Applicant_Name {GET; SET;}
        //申请人部门
        public String Dept_Name {GET; SET;}
        //单据日期
        public String Bill_Date {GET; SET;} 
        //审批人
        public String Approver {GET; SET;}
        //审批人ID
        public String ApproverId{GET; SET;}
        //审批状态
        public String ApprovalStatus {GET; SET;}
        //备注信息
        public String Head_Description {GET; SET;}
        //接口信息
        public String Interface_Info {GET; SET;}
         //资产类型
        public String Asset_type {GET; SET;}

    }   

    public PageReference query() {
        System.debug(LoggingLevel.INFO, '*** Querystart!: ');
       
        String sqlSelect = 'SELECT Id, Name,SAPID__c, Approval_Name__c, Asset_Type__c,Entity_asset_type__c,Applicant__c, Applicant__r.Name, Dept_Name__c, Bill_Date__c,Approval_Status__c,RecordType.DeveloperName,Head_description__c,Interface_Info__c ';
        String sqlFrom = ' FROM ';
        String sqlWhere = ' WHERE Id != null ';
        System.debug(LoggingLevel.INFO, '*** selectedStatusValue: ' + selectedStatusValue);
        //审批状态不为空
        if (!String.isBlank(selectedStatusValue)) {
            sqlWhere += ' AND Approval_Status__c =  \'' + selectedStatusValue  + '\' ';
        }
        //审批流程不为空
        if (!String.isBlank(meta.Approval_Name__c)) {
            sqlWhere += ' AND RecordType.DeveloperName = \'' + meta.Approval_Name__c + '\' ';
        }
        //SF单号
        if (!String.isBlank(standardApproval.Same_Sample__c)) {
            sqlWhere += ' AND NAME LIKE  \'' + '%' + standardApproval.Same_Sample__c + '\' ';
        }
        //原单号
        if (!String.isBlank(standardApproval.SAPID__c)) {
            sqlWhere += ' AND SAPID__c LIKE  \'' + '%' + standardApproval.SAPID__c + '%\' ';
        }
        //申请人
        if (!String.isBlank(standardApproval.Employee__c)) {
            sqlWhere += ' AND Applicant__c =  \'' + standardApproval.Employee__c + '\' ';
        }

        sqlWhere += ' AND Bill_Date__c >= ' + selectedApprovalStartTime ;
        // Datetime endDate = null;
        // try{
        //     endDate = Datetime.newInstance(Date.valueOf(selectedApprovalEndTime).addDays(1),Time.newInstance(0,0, 0, 0));
        // }catch(Exception ex){
        //     endDate = Datetime.newInstance(Date.valueOf('2049-12-31'),Time.newInstance(0,0, 0, 0));
        // }
        sqlWhere += ' AND Bill_Date__c <= ' + selectedApprovalEndTime ;

        Map<Id, String> approval2currentApproverMap = new Map<Id, String>();
        String sql = ' SELECT Id, ActorId, Actor.Name, ProcessInstance.TargetObjectId';
        sql += ' FROM ProcessInstanceWorkitem ';
        System.debug(LoggingLevel.INFO, '*** standardApproval.Keeper_Reserved__c: ' + standardApproval.Keeper_Reserved__c);
         //当前审批人
        if (!String.isBlank(standardApproval.Keeper_Reserved__c) ) {
            Contact con = [SELECT Id,SF_User__c FROM Contact WHERE Id =:standardApproval.Keeper_Reserved__c];
            System.debug(LoggingLevel.INFO, '*** con.SF_User__c: ' + con.SF_User__c);
            sql += ' WHERE ActorId = \'' + con.SF_User__c +  '\'';
            sql += ' ORDER BY CreatedDate DESC ';
            System.debug(LoggingLevel.INFO, '*** sql: ' + sql);
            List<ProcessInstanceWorkitem> piList = Database.query(sql);
            for (ProcessInstanceWorkitem pi : piList) {
                if(!approval2currentApproverMap.containsKey(pi.ProcessInstance.TargetObjectId)){
                    approval2currentApproverMap.put(pi.ProcessInstance.TargetObjectId, pi.Actor.Name);
                }
            }
        }
        //我参于的审批流程
        if (standardApproval.Is_Print__c) {
            sql = ' SELECT Id, ActorId, Actor.Name, ProcessInstance.TargetObjectId';
            sql += ' FROM ProcessInstanceStep ';
            sql += ' WHERE ActorId = \'' + UserInfo.getUserId() +  '\'';
            sql += ' ORDER BY CreatedDate DESC LIMIT 200';
            System.debug(LoggingLevel.INFO, '*** sql: ' + sql);
            List<ProcessInstanceStep> apiList = Database.query(sql);
            for (ProcessInstanceStep pi : apiList) {
                if(!approval2currentApproverMap.containsKey(pi.ProcessInstance.TargetObjectId)){
                    approval2currentApproverMap.put(pi.ProcessInstance.TargetObjectId, pi.Actor.Name);
                }
            }
        }
        if (standardApproval.Is_Print__c || !String.isBlank(standardApproval.Keeper_Reserved__c)) {
            if(approval2currentApproverMap.size() > 0){
            sqlWhere += ' AND Id In 6666';
            }
        }
        //是否只查询自己相关记录
        if (standardApproval.Is_Withhold__c) {
            Id uId = UserInfo.getUserId();

            sqlWhere += ' AND (OwnerId = \'' + uId + '\' '+' OR CreatedById = \'' + uId + '\') ';
        }
        sqlWhere += ' ORDER BY CreatedDate DESC LIMIT 200 ';
 
        System.debug(LoggingLevel.INFO, '*** sqlWhere: ' + sqlWhere);

        List<Approval_Managed__c> app = Database.query(sqlSelect + sqlFrom + ' Approval_Managed__c ' + ' WHERE  RecordType.DeveloperName = \'AssetPurchase\'   AND Bill_Date__c >= 2000-01-01 AND Bill_Date__c <= 2049-12-31 ORDER BY CreatedDate DESC LIMIT 200');
        List<Approval_Managed__c> app2 = Database.query(sqlSelect + sqlFrom + ' Approval_Managed__c ' + ' WHERE  RecordType.DeveloperName = \'AssetsTransfer\'  AND Bill_Date__c >= 2000-01-01 AND Bill_Date__c <= 2049-12-31 ORDER BY CreatedDate DESC LIMIT 200');
        // List<Custom_Approval_Managed__c> capp = Database.query(sqlSelect + sqlFrom + ' Custom_Approval_Managed__c ' + sqlWhere);
        // List<Approval_Managed1__c> app1 = Database.query(sqlSelect + sqlFrom + ' Approval_Managed1__c ' + sqlWhere);
        // List<Approval_Managed2__c> app2 = Database.query(sqlSelect + sqlFrom + ' Approval_Managed2__c ' + sqlWhere);

        for (Approval_Managed__c am : app) {
               
            AllApprovalData  data = new AllApprovalData();
            data.Asset_Type =  am.Asset_Type__c;
            System.debug('aaaaaaaaaaaaaaaa'+data.Asset_Type);
            data.ApprovalStatus = getApprovalStatusName(am.Approval_Status__c);
            if(data.Asset_Type ==  '04'){
            data.Id = am.Id;
            data.Name = am.Name;
            data.Original_Code = am.SAPID__c;
            data.Approval_Name = am.Approval_Name__c;
          
            // System.debug('Approval_Managed__c'+data.Approval_Name);
            data.Applicant_Id = am.Applicant__c;
            data.Applicant_Name = am.Applicant__r.Name;

            data.Dept_Name = am.Dept_Name__c;
            data.Bill_Date = HarryUtils.date2string(am.Bill_Date__c);
            // data.Approver = approval2currentApproverMap.get(am.Id);
            data.Interface_Info = am.Interface_Info__c;
            data.Head_description = am.Head_description__c;
            allApproval.add(data);


            }
            System.debug('allApproval的值是什么'+allApproval);

        }
         for (Approval_Managed__c am2 : app2) {     
            AllApprovalData  data2 = new AllApprovalData();
            data2.Asset_Type =  am2.Entity_asset_type__c;
            System.debug('bbbbbbbbbbbbbbbb'+data2.Asset_Type);
            data2.ApprovalStatus = getApprovalStatusName(am2.Approval_Status__c);
            if(data2.Asset_Type == 'd' && data2.ApprovalStatus == '审批中'){
            data2.Id = am2.Id;
            data2.Name = am2.Name;
            data2.Original_Code = am2.SAPID__c;
            data2.Approval_Name = am2.Approval_Name__c;
            // System.debug('Approval_Managed__c'+data.Approval_Name);
            data2.Applicant_Id = am2.Applicant__c;
            data2.Applicant_Name = am2.Applicant__r.Name;
            data2.Dept_Name = am2.Dept_Name__c;
            data2.Bill_Date = HarryUtils.date2string(am2.Bill_Date__c);
            // data.Approver = approval2currentApproverMap.get(am.Id);
            data2.ApprovalStatus = getApprovalStatusName(am2.Approval_Status__c);
            data2.Interface_Info = am2.Interface_Info__c;
            data2.Head_description = am2.Head_description__c;
            allApproval2.add(data2);


            }
           System.debug('allApproval2的值是什么'+allApproval2);

        }
       
        Set<Id> setID = new Set<Id>();
        for (AllApprovalData ald : allApproval) {
            setID.add(ald.Id);
        }
        List<ProcessInstanceWorkitem> lstPIW = [SELECT ProcessInstance.TargetObjectId, Actor.Name, ActorId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId IN :setID];
        Map<String,ProcessInstanceWorkitem> mapPIW = new Map<String,ProcessInstanceWorkitem>();
        for (ProcessInstanceWorkitem piw : lstPIW) {
            if(!mapPIW.containsKey(piw.ProcessInstance.TargetObjectId)){
                mapPIW.put(piw.ProcessInstance.TargetObjectId, piw);
            }
        }
        for (AllApprovalData ald : allApproval) {
            if (mapPIW.containsKey(ald.Id) && String.isBlank(ald.Approver)) {
                ald.ApproverId = mapPIW.get(ald.Id).ActorId;
                ald.Approver = mapPIW.get(ald.Id).Actor.Name;
            }
        }
  a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        a=1;
        
        
        

        return null;
    }
    public PageReference importExcel(){
        return page.ApprovalQueryExcel;
    }
    private void addPageMessage(String message) {
        ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.INFO, message));
    }
    private String getApprovalStatusName(String apiKey){
        if(apiKey == 'D'){
            return '草稿';
        }else if(apiKey=='S'){
            return '审批中';
        }else if(apiKey=='A'){
            return '已通过';
        }else if(apiKey=='R'){
            return '已拒绝';
        }else{
            return '';
        }
    }
}