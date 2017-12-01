/**********************************************************************
 名    称：预付款申请单审批流程
 目    的：设置预付款申请单审批流程各节点审批人
 作    者：刘文俊(liuwenjun@bluelinksys.com)
 创建日期：2017-04-25
 修 改 人：zhonghui
 修改日期：5/2
 修改原因：添加相关逻辑
 备    注：
 			    1   申请人编辑及上传附件         相关用户：*审批用户01    最终拒绝
                2   稽核单位审批        相关用户：*审批用户02    最终拒绝
                3   部门主管审批        相关用户：*审批用户03    最终拒绝
                4   一阶主管审批         相关用户：*审批用户04    最终拒绝
                5   指定人员审批         相关用户：*审批用户05    最终拒绝
                6   总经理审批           相关用户：*审批用户06    最终拒绝
                7   应付会计审批          相关用户：*审批用户07    最终拒绝
                8   财务主管审批          相关用户：*审批用户08    最终拒绝
                9   申请人冲账            相关用户：*审批用户09    最终拒绝
                10  应付冲账确认          相关用户：*审批用户10    最终拒绝
 **********************************************************************/
public without sharing class AMAdvanceChargeHandler implements Triggers.Handler {
    public void handle() {
        //获取预付款管理流程各节点配置
        Map<Decimal,Organizational__c>  mapSpecify = null;
        Id rtId = HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.ADVANCECHARGE,'Approval_Managed__c');
        if (Trigger.isBefore && Trigger.isInsert) {
            for (Approval_Managed__c cam : (List<Approval_Managed__c>)Trigger.new) {
                if (cam.RecordTypeId == rtId) {
                    if(mapSpecify == null){
                        mapSpecify = Utils.getApprovalStepByAPIName(SapApprovalEnum.ADVANCECHARGE);
                    }
                    setApprovalUser(mapSpecify,cam);
                }
            }
        }
        if (Trigger.isBefore && Trigger.isUpdate) {
            for (Approval_Managed__c cam : (List<Approval_Managed__c>)Trigger.new) {
                if (cam.RecordTypeId == rtId && cam.Is_Reset_Approvaler__c) {
                    if(mapSpecify == null){
                        mapSpecify = Utils.getApprovalStepByAPIName(SapApprovalEnum.ADVANCECHARGE);
                    }
                    setApprovalUser(mapSpecify,cam);
                    cam.Is_Reset_Approvaler__c = false;
                }
            }
        }
    }
    public void setApprovalUser(Map<Decimal,Organizational__c> mapSpecify,Approval_Managed__c cam){
        //节点1 
        cam.Approval_User1__c     = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(1),cam.Applicant__c),0);
        //节点2 
        cam.Approval_User2__c     = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(2),null),0);
        //节点3 
        cam.Approval_User3__c     = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(3),null),0);
        //节点4 
        cam.Approval_User4__c     = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(4),cam.Applicant__c),0);
        //节点5 
        cam.Approval_User5__c     = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(5),null),0);
        //节点6 
        cam.Approval_User6__c     = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(6),null),0);
        //节点7
        cam.Approval_User7__c     = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(7),null),0);
        //节点8
        cam.Approval_User8__c     = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(8),null),0);
        //节点9
        cam.Approval_User9__c     = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(9),cam.Applicant__c),0);
        //节点10
        cam.Approval_User10__c     = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(10),null),0);
    }
}