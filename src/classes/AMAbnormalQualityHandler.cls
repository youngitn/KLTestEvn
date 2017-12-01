/**********************************************************************
 名    称：品质异常单审批流程
 目    的：设置品质异常单审批流程各节点审批人
 作    者：刘文俊(liuwenjun@bluelinksys.com)
 创建日期：2017-04-25
 修 改 人：
 修改日期：
 修改原因：
 备    注：
                节点1 申请人确认-上传附件          相关用户：*审批用户01    最终拒绝
                节点2 部门主管审批                相关用户：*审批用户02    最终拒绝
                节点3 指定部门审批                相关用户：*审批用户03    最终拒绝
                节点4 作业人审批                  相关用户：*审批用户04    最终拒绝
                节点5 作业人部门主管审批           相关用户：*审批用户05    返回1 步
                节点6 作业人一阶主管审批           相关用户：*审批用户06    返回1 步
                节点7 申请人部门主管确认           相关用户：*审批用户07    返回1 步
                节点8 申请人一阶主管确认           相关用户：*审批用户08    返回1 步
 **********************************************************************/
public without sharing class AMAbnormalQualityHandler implements Triggers.Handler {
    public void handle() {
        //获取品质异常单流程各节点配置
        Map<Decimal,Organizational__c>  mapSpecify = null;
        Id rtId = HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.ABNORMALQUALITY,'Approval_Managed__c');
        if (Trigger.isBefore && Trigger.isInsert) {
        	for (Approval_Managed__c cam : (List<Approval_Managed__c>)Trigger.new) {
                System.debug(LoggingLevel.INFO, '*** cam: ' + cam);
        		if (cam.RecordTypeId == rtId) {
                    if(mapSpecify == null){
                        mapSpecify = Utils.getApprovalStepByAPIName(SapApprovalEnum.ABNORMALQUALITY);
                    }
                    setApprovalUser(mapSpecify,cam);
                }
            }
       	}
        if (Trigger.isBefore && Trigger.isUpdate) {
            Map<Id,Approval_Managed__c> mapOld = (Map<Id,Approval_Managed__c>)Trigger.oldMap;
            for (Approval_Managed__c cam : (List<Approval_Managed__c>)Trigger.new) {
                if (cam.RecordTypeId == rtId && cam.Is_Reset_Approvaler__c) {
                    if(mapSpecify == null){
                        mapSpecify = Utils.getApprovalStepByAPIName(SapApprovalEnum.ABNORMALQUALITY);
                    }
                    setApprovalUser(mapSpecify,cam);
                    cam.Is_Reset_Approvaler__c = false;
                }
            }
        }
    }
    public void setApprovalUser(Map<Decimal,Organizational__c> mapSpecify,Approval_Managed__c cam){
        //节点一
        cam.Approval_User1__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(1),cam.Applicant__c),0);
        //节点二
        cam.Approval_User2__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(2),cam.Applicant__c),0);
        //节点三
        cam.Approval_User3__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(3),cam.Applicant_Cost__c),0);
        //节点四
        cam.Approval_User4__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(4),cam.Operator_Abnormal__c),0);
        //节点五
        cam.Approval_User5__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(5),cam.Operator_Abnormal__c),0);
        //节点六
        cam.Approval_User6__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(6),cam.Operator_Abnormal__c),0);
        //节点七
        cam.Approval_User7__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(7),cam.Applicant__c),0);
        //节点八
        cam.Approval_User8__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(8),cam.Applicant__c),0);
    }
}