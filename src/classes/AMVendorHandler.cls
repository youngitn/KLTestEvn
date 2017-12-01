/**********************************************************************
 名    称：供应商主数据审批流程
 目    的：设置供应商主数据审批流程各节点审批人
 作    者：刘文俊(liuwenjun@bluelinksys.com)
 创建日期：2017-04-25
 修 改 人：
 修改日期：
 修改原因：
 备    注：
 **********************************************************************/
public without sharing class AMVendorHandler implements Triggers.Handler {
    public void handle() {
        Map<Decimal,Organizational__c>  mapSpecify = null;
        Id rtId = HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.VENDOR,'Custom_Approval_Managed__c');
        if (Trigger.isBefore && Trigger.isInsert) {
            for (Custom_Approval_Managed__c cam : (List<Custom_Approval_Managed__c>)Trigger.new) {
                if (cam.RecordTypeId == rtId) {
                    if(mapSpecify == null){
                        mapSpecify = Utils.getApprovalStepByAPIName(SapApprovalEnum.VENDOR);
                    }
                    setApprovalUser(mapSpecify,cam);
                }
            }
        }
        if (Trigger.isBefore && Trigger.isUpdate) {
            for (Custom_Approval_Managed__c cam : (List<Custom_Approval_Managed__c>)Trigger.new) {
                if (cam.RecordTypeId == rtId && cam.Is_Reset_Approvaler__c) {
                    if(mapSpecify == null){
                        mapSpecify = Utils.getApprovalStepByAPIName(SapApprovalEnum.VENDOR);
                    }
                    setApprovalUser(mapSpecify,cam);
                    cam.Is_Reset_Approvaler__c = false;
                }
            }
        }
    }

        public void setApprovalUser(Map<Decimal,Organizational__c> mapSpecify,Custom_Approval_Managed__c cam){
		//节点一 相关部门一阶主管 _物流服务	 指定人员
		cam.Approval_User1__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(1),null),0);
		//节点二 相关部门一阶主管_台灣限定3000 指定人员
		cam.Approval_User2__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(2),null),0);
		//节点三 相关部门一阶主管_QA 指定人员
		cam.Approval_User3__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(3),null),0);
		//节点四 相关部门一阶主管_采购 指定人员
		cam.Approval_User4__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(4),null),0);
		//节点五 相关部门一阶主管_设备 指定人员
		cam.Approval_User5__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(5),null),0);
		//节点六 相关部门一阶主管_IT 指定人员
		cam.Approval_User6__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(6),null),0);
		//节点七 相关部门一阶主管_资材 指定人员
		cam.Approval_User7__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(7),null),0);
		//节点八 相关部门一阶主管_管理部 指定人员
		cam.Approval_User8__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(8),null),0);
		//节点九 采购经理_主管 指定岗位
		cam.Approval_User9__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(9),null),0);
		//节点十 采购经理_台湾主管 指定人员
		cam.Approval_User10__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(10),null),0);
		//节点十一 财务人员_台湾 指定人员
		cam.Approval_User11__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(11),null),0);
		// 节点十二 财务课长_昆山新莱 指定人员
		cam.Approval_User12__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(12),null),0);
		// 节点十三 财务课长_台湾 指定人员
		cam.Approval_User13__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(13),null),0);
		// 节点十四 申请人确认 指定特殊人员
		cam.Approval_User14__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(14),cam.Applicant__c),0);
    }
}