/**********************************************************************
 名    称：HLYSyncApprovalStatus
 目    的：同步员工出差申请单/交际应酬申请单/费用报销单的审批信息到HLY
 作    者：zhonghui
 创建日期：2017-05-20
 修 改 人：
 修改日期：
 修改原因：
 备    注：

 脚本执行步骤：
 1、查找出满足条件的审批结点
 2、处理分页
 3、
 4、
 5、

 @Url: /services/apexrest/HLY/syncApprovalStatus
 接收的Json数据格式:
{
    "action": "QUERY", 
    "data_type": "APPROVAL",
    "begin_date": "2016-09-01",
    "end_date": "2016-10-21",
    "hly_number": "HLY-20161122",
    "pagenum": "10",
    "pagesize": "2",
    "fetchall": "false"

}
 返回的Json数据格式：
{
    "success": true, 
    "source_code": "Salesforce", 
    "data_type": "APPROVAL",
    "result": {
        "pageCount": "1", 
        "totalCount": "2",
        "record": [
            {
                "status": "APPROVED",//审批通过
                "invoice_flag": "N", //是否开发票
                "bpm_number": "MM-170100067", //SF单据号
                "hly_number": "MM-170100067", //HLY单号
                "approval_date": "2017-01-19 09:42:16", //审批日期
                "employee_code": "10210880", //审批人工号
                "approval_user": "邵光凯",//审批人姓名
                "note": "[自动通过]",//通过或拒绝原因
                "action":"",//动作
                "action_type":"1" //辅助判断审批状态
            }, 
            {
                "status": "REJECTED",//审批拒绝
                "invoice_flag": "Y", //是否开发票
                "hly_number": "MM-170100067", //HLY单号
                "bpm_number": "MM-170100067", //SF单据号
                "approval_date": "2017-01-19 09:42:16", //审批日期
                "employee_code": "10210880", //审批人工号
                "approval_user": "邵光凯",//审批人姓名
                "note": "费用报销太多",//通过或拒绝原因
                "action":"",//动作
                "action_type":"-1" //辅助判断审批状态
            }
        ]
    }
}

*************************************************************************/
@RestResource(urlMapping='/HLY/syncApprovalStatus')
global without sharing class HLYSyncApprovalStatus {
    @HttpPost
    global static MainInfo doPost(  String action,
                                    String data_type,
                                    String begin_date,
                                    String end_date,
                                    String pagenum,
                                    String pagesize,
                                    String fetchall) {
        System.debug('***  审批状态查询接口参数: action:' + action
            +'\n' + 'data_type:' + data_type
            +'\n' + 'begin_date:' + begin_date
            +'\n' + 'end_date:' + end_date
            +'\n' + 'pagenum:' + pagenum
            +'\n' + 'pagesize:' + pagesize
            +'\n' + 'fetchall:' + fetchall);
        
        MainInfo main = new MainInfo();
        ResultInfo rstInfo = new ResultInfo();
        List<APParameter> record = new List<APParameter>();
        rstInfo.record  = record;
        main.result = rstInfo;
        main.data_type = data_type;
        
        //当前页
        Integer pNum = 1;
        //每页记录数
        Integer pSize = 10000;
        try{
            pNum = Integer.valueOf(pagenum);
        }catch(Exception ex){}
        try{
            pSize = Integer.valueOf(pagesize);
        }catch(Exception ex){}
        //当前取数据开始位置
        Integer index = (pNum - 1) * pSize;
        try{
            //1、查找出满足条件的审批结点
            begin_date = begin_date.trim().length() < 17 ? begin_date.trim() + ':00.' : begin_date.trim();
            end_date = end_date.trim().length() < 17 ? end_date.trim() + ':00' : end_date.trim();
            System.debug(LoggingLevel.INFO, '*** begin_date: ' + begin_date);
            System.debug(LoggingLevel.INFO, '*** end_date: ' + end_date);
            Datetime startDate = Datetime.valueOf(begin_date);
            Datetime endDate = Datetime.valueOf(end_date);

            //流程名称
            Set<String> approvalNames = new Set<String>();
            //查找包含特定流程的批准过程名称
            for (ProcessInstanceStep pi : [SELECT ProcessInstance.ProcessDefinition.DeveloperName FROM ProcessInstanceStep
                //WHERE ProcessDefinition.State = 'Active'
                WHERE CreatedDate >= :startDate 
                AND CreatedDate <= :endDate 
                AND ProcessInstance.ProcessDefinition.DeveloperName!=null]) {
                    String szDeveloperName = pi.ProcessInstance.ProcessDefinition.DeveloperName;
                    if ((szDeveloperName.contains('ExpenseReimburse') 
                        ||szDeveloperName.contains('BusinessTravel')
                        || szDeveloperName.contains('EntertaineCost'))
                        &&!approvalNames.contains(szDeveloperName)
                        ) {
                        approvalNames.add(szDeveloperName);
                }
            }

            //查找审批结点         
            List<ProcessInstanceStep> nodes = 
                [SELECT Id, ProcessInstanceId, StepStatus, OriginalActorId, ActorId,Comments,StepNodeId, CreatedDate, 
                    CreatedById,ProcessInstance.TargetObjectId,ProcessInstance.ProcessDefinition.DeveloperName 
                FROM ProcessInstanceStep 
                //WHERE ProcessInstance.ProcessDefinition.State = 'Active' 
                WHERE StepNodeId != null 
                AND ProcessInstance.ProcessDefinition.DeveloperName IN : approvalNames 
                AND CreatedDate >= :startDate 
                AND CreatedDate <= :endDate 
                ORDER BY ProcessInstance.TargetObjectId,CreatedDate];
                 
            System.debug(LoggingLevel.INFO, '*** :nodes ' + nodes);
            //结点名称
            Map<Id,ProcessNode> mapNodes = new Map<Id,ProcessNode>([SELECT Id,Name,ProcessDefinition.DeveloperName FROM ProcessNode]);
            Set<String> objIds = new Set<String>();
            for(ProcessInstanceStep nd : nodes){
                if(!objIds.contains(nd.ProcessInstance.TargetObjectId)){
                    objIds.add(nd.ProcessInstance.TargetObjectId);
                }
            }
            List<Approval_Managed__c> amlist = [SELECT Id,Name,SAPID__c,Is_Invoice__c,Is_Print__c,Approval_Status__c FROM Approval_Managed__c WHERE Id IN :objIds AND Is_HLY_ExpenseReimburse__c = true];
            List<Custom_Approval_Managed__c> camlist = [SELECT Id,Name,SAPID__c,Approval_Status__c FROM Custom_Approval_Managed__c WHERE Id IN :objIds];
            //交际应酬费申请流程、费用报销流程
            Map<String,Approval_Managed__c> mapAM = new Map<String,Approval_Managed__c>();
            for(Approval_Managed__c am : amlist){
                if(!mapAM.containsKey(am.Id)){
                    mapAM.put(am.Id,am);
                }
            }
            //出差管理流程
            Map<String,Custom_Approval_Managed__c> mapCAM = new Map<String,Custom_Approval_Managed__c>();
            for(Custom_Approval_Managed__c am : camlist){
                if(!mapCAM.containsKey(am.Id)){
                    mapCAM.put(am.Id,am);
                }
            }

            //排除非HLY创建的审批记录后计算总审批记录数
            Integer totalCount = 0;
            Integer nodeCount = nodes.size() - 1;
            for(Integer i = nodeCount; i >=0; i--){
                ProcessInstanceStep nd = nodes[i];
                if(mapAM.containsKey(nd.ProcessInstance.TargetObjectId) ||
                    mapCAM.containsKey(nd.ProcessInstance.TargetObjectId)){
                    totalCount = totalCount + 1;
                }else{
                    nodes.remove(i);
                }
            }
            System.debug('*** 记录总数：' + totalCount);
            System.debug('*** 记录：' + JSON.serialize(nodes));
            System.debug(LoggingLevel.INFO, '*** :ooooo ' + 'oooooooo');
            rstInfo.pageCount = String.valueOf((Integer)Math.ceil((Decimal)totalCount/(Decimal)pSize));
            rstInfo.totalCount = String.valueOf(totalCount);
            if(index >= totalCount ){
                main.success = 'true';
                main.err_msg = '错误的分页值(pagenum/pagesize),当前记录数不足！';
                return main;
            }
            if(index + pSize <= totalCount){
                totalCount = index + pSize;
            }
            //审批用户
            Set<String> userIds = new Set<String>();
            //本次要返回的审批结点记录
            List<ProcessInstanceStep> returnNodes = new List<ProcessInstanceStep>();
            for(Integer i = index; i < totalCount ; i++){
                returnNodes.add(nodes[i]);
                if(!userIds.contains(nodes[i].ActorId)){
                    userIds.add(nodes[i].ActorId);
                }
            }
            System.debug('*** 返回记录：' + JSON.serialize(returnNodes));
            //联系人
            Map<String,Contact> mapUsers = new Map<String,Contact>();
            System.debug('*** 审批用户ID:' + userIds);
            List<Contact> cons = [SELECT Id,Number__c,LastName,SF_User__c FROM Contact WHERE SF_User__c IN :userIds];
            for(Contact con : cons){
                if(!mapUsers.containsKey(con.SF_User__c)){
                    mapUsers.put(con.SF_User__c,con);
                }
            }

            //生成返回参数
            for(ProcessInstanceStep nd : returnNodes){
/*                //是否存在,不存在继续下一个
                if(nd.ProcessInstance.ProcessDefinition.DeveloperName.contains(SapApprovalEnum.EXPENSEREIMBURSE) ||
                    nd.ProcessInstance.ProcessDefinition.DeveloperName.contains(SapApprovalEnum.ENTERTAINECOST) ||
                    nd.ProcessInstance.ProcessDefinition.DeveloperName.contains(SapApprovalEnum.BUSINESSTRAVEL)){
                    if(!mapAM.containsKey(nd.ProcessInstance.TargetObjectId)){
                        continue;
                    }
                }*/
                APParameter para = new APParameter();
                para.approval_date = nd.CreatedDate.format('yyyy-MM-dd HH:mm:ss');//审批日期
                para.approval_user = mapUsers.containsKey(nd.ActorId) ?mapUsers.get(nd.ActorId).LastName:'';//审批人
                para.action = mapNodes.get(nd.StepNodeId).Name;//动作
                para.note = nd.Comments;//备注
                para.employee_code = mapUsers.containsKey(nd.ActorId) ?mapUsers.get(nd.ActorId).Number__c:'';//审批员工编码
                if (String.isBlank( para.approval_user)) {
                    para.employee_code = '10210225';
                    para.approval_user = '遗漏信息补充';
                }
                //已批准: Approved
                //已拒绝: Rejected
                //已调回: Removed
                //已重新分配: Reassigned
                //已提交: Started
                //待处理: Pending
                //暂停: Held
                //无响应: NoResponse
                //故障: Fault
                String status = nd.StepStatus;
                //单据状态
                if(status == 'Approved' || 
                   status == 'Reassigned' || 
                   status == 'Started' || 
                   status == 'Pending' || 
                   status == 'Held'){
                    para.status = 'SUBMITTED';
                    para.action_type = '1';
                }else if(status == 'Rejected' ||
                         status == 'NoResponse' || 
                         status == 'Fault'){
                    para.status = 'REJECTED';
                    para.action_type = '-1';
                }else if(status == 'Removed'){
                    para.status = 'TAKEN_BACK';
                    para.action_type = '1';
                }
                //出差管理流程
                if(nd.ProcessInstance.ProcessDefinition.DeveloperName.contains(SapApprovalEnum.BUSINESSTRAVEL)){
                    Custom_Approval_Managed__c cam = mapCAM.get(nd.ProcessInstance.TargetObjectId);
                    para.invoice_flag = 'N';//是否需要开票
                    para.bpm_number = cam.Name;//BPM单据编号
                    para.hly_number = cam.SAPID__c;//HLY单号
                    //流程审批通过
                    if(cam.Approval_Status__c == 'A'){
                        para.status = 'COMPLETELY_APPROVED';
                        para.action_type = '1';
                    }

                }else{//交际应酬费申请流程、费用报销流程
                    Approval_Managed__c am = mapAM.get(nd.ProcessInstance.TargetObjectId);
                    para.invoice_flag = am.Is_Invoice__c?'Y':'N';//是否需要开票
                    para.bpm_number = am.Name;//BPM单据编号
                    para.hly_number = am.SAPID__c;//HLY单号
                    if(am.Is_Print__c){
                        para.status = 'AUDIT';
                        para.action_type = '1';
                    }
                    //流程审批通过
                    if(am.Approval_Status__c == 'A'){
                        para.status = 'COMPLETELY_APPROVED';
                        para.action_type = '1';
                    }
                }
                record.add(para);
            }

        }catch(Exception ex){
            main.success = 'false';
            main.err_msg = ex.getMessage() + '; ' + ex.getStackTraceString();
        }
        System.debug(LoggingLevel.INFO, '*** 反馈信息: ' + main);
        return main;
    }
    /*
        主信息对应参数类
    */
    global class MainInfo{
        public String success = 'true'; //true/false
        public String err_msg = ''; //成功或失败时的信息
        public String source_code = 'Salesforce';
        public String data_type = 'APPROVAL';
        public ResultInfo result {GET;SET;}
    }
    /*
        result对应参数类
    */
    private class ResultInfo{
        //pageCount
        public String pageCount = '1';
        //totalCount
        public String totalCount = '10000';
        //各审批节点记录
        public List<APParameter> record {GET;SET;}
    }
    /*
        审批状态参数类
    */
    private class APParameter{
        //BPM单据编号
        public String bpm_number = '';
        //HLY单号
        public String hly_number = '';
        //审批日期
        public String approval_date = '';
        //审批人
        public String approval_user = '';
        //动作
        public String action = '';
        //备注
        public String note = '';
        //审批员工编码
        public String employee_code = '';
        //单据状态
        public String status = '';
        //是否需要开票
        public String invoice_flag = 'N';
        //辅助判断审批状态
        public String action_type = '1';
    }
}