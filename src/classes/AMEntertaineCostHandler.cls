/**********************************************************************
 名    称：交际应酬费申请单流程
 目    的：计算审批节点对应人员
 作    者：DINGP
 创建日期：2017-06-06
 修 改 人：
 修改日期：
 修改原因：
 备    注：  
            节点1   稽核单位审批          Related User: *审批用户1：Approval_User1__c 
            节点2   一阶主管审批          Related User: *审批用户2：Approval_User2__c 
            节点3   总经理室审批          Related User: *审批用户3：Approval_User3__c 
            节点4   预定人员作业-礼品     Related User: *审批用户4：Approval_User4__c 
            节点5   预定人员作业-宴客     Related User: *审批用户5：Approval_User5__c 
            节点6   预定人员作业-其他     Related User: *审批用户6：Approval_User6__c 
 **********************************************************************/
public without sharing class AMEntertaineCostHandler implements Triggers.Handler {
    public void handle() {
        //获取交际应酬费申请单流程各节点配置
        Map<Decimal,Organizational__c>  mapSpecify = null;
        Id rtId = HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.ENTERTAINECOST,'Approval_Managed__c');
        if (Trigger.isBefore && Trigger.isInsert) {
            for (Approval_Managed__c cam : (List<Approval_Managed__c>)Trigger.new) {
                if (cam.RecordTypeId == rtId) {
                    if(mapSpecify == null){
                        mapSpecify = Utils.getApprovalStepByAPIName(SapApprovalEnum.ENTERTAINECOST);
                    }
                    setApprovalUser(mapSpecify,cam);
                }
            }
        }
        if (Trigger.isBefore && Trigger.isUpdate) {
            for (Approval_Managed__c cam : (List<Approval_Managed__c>)Trigger.new) {
                if (cam.RecordTypeId == rtId && cam.Is_Reset_Approvaler__c) {
                    if(mapSpecify == null){
                        mapSpecify = Utils.getApprovalStepByAPIName(SapApprovalEnum.ENTERTAINECOST);
                    }
                    setApprovalUser(mapSpecify,cam);
                    cam.Is_Reset_Approvaler__c = false;
                }
            }
        }
    }
    public void setApprovalUser(Map<Decimal,Organizational__c> mapSpecify,Approval_Managed__c cam){
                //cam.Applicant__c 为与SALESFORCE帐号相关的申请人
        //cam.Employee__c  为界面上新增的员工字段，与SALESFORCE账号无关

        //节点1 稽核单位审批
        cam.Approval_User1__c     = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(1),null),0);

        //节点2 一阶主管
        cam.Approval_User2__c     = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(2),cam.Applicant__c),0);

        //节点3 总经理室审批
        cam.Approval_User3__c     = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(3),null),0);

        //节点4 预定人员作业-礼品
        cam.Approval_User4__c     = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(4),null),0);

        //节点5 预定人员作业-宴客
        cam.Approval_User5__c     = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(5),null),0);

        //节点6 预定人员作业-其他
        cam.Approval_User6__c     = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(6),null),0);

        cam.Approval_User7__c     = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(7),cam.Applicant__c),0);


        //cam.Applicant__c 为与SALESFORCE帐号相关的申请人
        //cam.Employee__c  为界面上新增的员工字段，与SALESFORCE账号无关
        //指定申请人部门主管，一阶主管，上级主管
        //cam.Approval_User2__c     = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(2),cam.指定申请人字段),0);

        //指定作业人
        //cam.Approval_User2__c     = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(2),cam.指定作业人字段),0);

        //其他审批人规则
        //cam.Approval_User4__c     = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(4),null),0);

        cam.Approval_User20__c     = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(20),null),0);
    }
}