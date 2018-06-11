/**********************************************************************
 名    称：标准采购订单作业审批流程
 目    的：设置标准采购订单作业审批流程各节点审批人
 作    者：刘文俊(liuwenjun@bluelinksys.com)
 创建日期：2017-04-25
 修 改 人：
 修改日期：
 修改原因：
 备    注：

 **********************************************************************/
public without sharing class AMPurchaseOrderHandler implements Triggers.Handler {


	public void handle() {
        //获取标准采购订单流程各节点配置
        Map<Decimal,Organizational__c>  mapSpecify = null;
        Id rtId = HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.PURCHASEORDER,'Approval_Managed__c');
        if (Trigger.isBefore && Trigger.isInsert) {
            for (Approval_Managed__c cam : (List<Approval_Managed__c>)Trigger.new) {
                if (cam.RecordTypeId == rtId) {
                    if(mapSpecify == null){
                        mapSpecify = Utils.getApprovalStepByAPIName(SapApprovalEnum.PURCHASEORDER);
                    }
                    setApprovalUser(mapSpecify,cam);
                }
            }
        }
        if (Trigger.isBefore && Trigger.isUpdate) {
            for (Approval_Managed__c cam : (List<Approval_Managed__c>)Trigger.new) {
                if (cam.RecordTypeId == rtId && cam.Is_Reset_Approvaler__c) {
                    if(mapSpecify == null){
                        mapSpecify = Utils.getApprovalStepByAPIName(SapApprovalEnum.PURCHASEORDER);
                    }
                    setApprovalUser(mapSpecify,cam);
                    cam.Is_Reset_Approvaler__c = false;  
                }
            }
        }
    }
    public void setApprovalUser(Map<Decimal,Organizational__c> mapSpecify,Approval_Managed__c cam){
		//节点一 采购课长-指定人员
		cam.Approval_User1__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(1),null),0);
		//节点二 采购课长DM采购组--岗位
		cam.Approval_User2__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(2),null),0);
		//节点三 
		cam.Approval_User3__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(3),null),0);
		//节点四 采购经理-岗位
		cam.Approval_User4__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(4),cam.Applicant__c),0);
		//节点五 管理层_3000-指定人员
		cam.Approval_User5__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(5),null),0);
		//节点六 管理层_1000-指定人员
		cam.Approval_User6__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(6),null),0);
		//节点七 指定审批人_一阶主管申请-岗位
		cam.Approval_User7__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(7),null),0);
		//节点八 指定审批人_标准采单:ZFY/ZPM-岗位
		cam.Approval_User8__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(8),null),0);
		//节点九 决策层-岗位
		cam.Approval_User9__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(9),null),0);
		//节点十 供应商交期回复-指定人员
		cam.Approval_User10__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(10),null),0);

        cam.Approval_User11__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(11),null),0);

        cam.Approval_User12__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(12),null),0);
    }
}