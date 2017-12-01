public with sharing class AMQTW_CustomerComplaintHandler implements Triggers.Handler{
	public void handle() {
        Map<Decimal,Organizational__c>  mapSpecify = null;
        Id rtId = HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.QTW_CUSTOMERCOMPLAINT,'Approval_Managed2__c');
        if (Trigger.isBefore && Trigger.isInsert) {
            for (Approval_Managed2__c cam : (List<Approval_Managed2__c>)Trigger.new) {
                if (cam.RecordTypeId == rtId) {
                    if(mapSpecify == null){
                        mapSpecify = Utils.getApprovalStepByAPIName(SapApprovalEnum.QTW_CUSTOMERCOMPLAINT);
                    }
                    setApprovalUser(mapSpecify,cam);
                }
            }
        }
        if (Trigger.isBefore && Trigger.isUpdate) {
            for (Approval_Managed2__c cam : (List<Approval_Managed2__c>)Trigger.new) {
                if (cam.RecordTypeId == rtId && cam.Is_Reset_Approvaler__c) {
                    if(mapSpecify == null){
                        mapSpecify = Utils.getApprovalStepByAPIName(SapApprovalEnum.QTW_CUSTOMERCOMPLAINT);
                    }
                    setApprovalUser(mapSpecify,cam);
                    cam.Is_Reset_Approvaler__c = false;
                }
            }
        }
    }
    public void setApprovalUser(Map<Decimal,Organizational__c> mapSpecify, Approval_Managed2__c cam){
		//节点一：申請人主管
		cam.Approval_User1__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(1),cam.Applicant__c),0);
		//节点二：權責單位
		cam.Approval_User2__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(2),null),0);
		//节点三：成效確認
		cam.Approval_User3__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(3),null),0);
		//節點四：品保主管
		cam.Approval_User4__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(3),null),0);
		//節點五：業務簽核
		cam.Approval_User5__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(3),null),0);
		//節點六：發行通知
		cam.Approval_User6__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(3),null),0);
 	}
}