/**********************************************************************
 名    称：员工主动离职审批流程
 目    的：设置员工主动离职审批流程各节点审批人
 作    者：刘文俊(liuwenjun@bluelinksys.com)
 创建日期：2017-04-25
 修 改 人：
 修改日期：
 修改原因：
 备    注：
 
 
 **********************************************************************/
public without sharing class AMStaffLeaveOfficeHandler implements Triggers.Handler {
    public void handle() {
        //获取员工异动管理流程各节点配置
        Map<Decimal,Organizational__c>  mapSpecify = null;
        Id rtId = HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.STAFFLEAVEOFFICE,'Approval_Managed__c');
        if (Trigger.isBefore && Trigger.isInsert) {
            for (Approval_Managed__c cam : (List<Approval_Managed__c>)Trigger.new) {
                if (cam.RecordTypeId == rtId) {
                    if(mapSpecify == null){
                        mapSpecify = Utils.getApprovalStepByAPIName(SapApprovalEnum.STAFFLEAVEOFFICE);
                    }
                    setApprovalUser(mapSpecify,cam);
                }
            }
        }
        if (Trigger.isBefore && Trigger.isUpdate) {
            for (Approval_Managed__c cam : (List<Approval_Managed__c>)Trigger.new) {
                if (cam.RecordTypeId == rtId && cam.Is_Reset_Approvaler__c) {
                    if(mapSpecify == null){
                        mapSpecify = Utils.getApprovalStepByAPIName(SapApprovalEnum.STAFFLEAVEOFFICE);
                    }
                    setApprovalUser(mapSpecify,cam);
                    cam.Is_Reset_Approvaler__c = false;
                }
                cam.head_description__c  = cam.Reason_of_Purchase__c;
            }
        }
    }
    public void setApprovalUser(Map<Decimal,Organizational__c> mapSpecify,Approval_Managed__c cam){
        //节点一
        cam.Approval_User1__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(1),cam.Employee__c),0);
        //节点二
        cam.Approval_User2__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(2),cam.Employee__c),0);
        //节点三
        cam.Approval_User3__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(3),null),0);
        //节点四
        cam.Approval_User4__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(4),null),0);
        //节点五
        cam.Approval_User5__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(5),null),0);
        //节点六
        cam.Approval_User6__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(6),null),0);
        //节点七
        cam.Approval_User7__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(7),null),0);
        //节点八
        cam.Approval_User8__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(8),null),0);
        //节点九
        cam.Approval_User9__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(9),null),0);
        //节点十
        cam.Approval_User10__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(10),null),0);

        cam.Approval_User11__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(11),null),0);

        cam.Approval_User20__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(20),null),0);
    }
}