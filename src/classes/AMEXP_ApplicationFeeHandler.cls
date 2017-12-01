public with sharing class AMEXP_ApplicationFeeHandler implements Triggers.Handler {
     public void handle() {
        Map<Decimal,Organizational__c>  mapSpecify = null;
        Id rtId = HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.EXP_APPLICATIONFEE,'Approval_Managed2__c');
        if (Trigger.isBefore && Trigger.isInsert) {
            for (Approval_Managed2__c cam : (List<Approval_Managed2__c>)Trigger.new) {
                if (cam.RecordTypeId == rtId) {
                    if(mapSpecify == null){
                        mapSpecify = Utils.getApprovalStepByAPIName(SapApprovalEnum.EXP_APPLICATIONFEE);
                    }
                    setApprovalUser(mapSpecify,cam);
                }
            }
        }
        if (Trigger.isBefore && Trigger.isUpdate) {
            for (Approval_Managed2__c cam : (List<Approval_Managed2__c>)Trigger.new) {
                if (cam.RecordTypeId == rtId && cam.Is_Reset_Approvaler__c) {
                    if(mapSpecify == null){
                        mapSpecify = Utils.getApprovalStepByAPIName(SapApprovalEnum.CANCELTECO);
                    }
                    setApprovalUser(mapSpecify,cam);
                    cam.Is_Reset_Approvaler__c = false;
                }
            }
        }
    }
            //获取內部連絡單流程各节点配置
    public void setApprovalUser(Map<Decimal,Organizational__c> mapSpecify,Approval_Managed2__c cam){
       				//節點一：申請人部門主管
        			cam.Approval_User1__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(1),cam.Applicant__c),0);
        			//節點二：指定人員
        			cam.Approval_User2__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(2),null),0);
        			//節點三：指定人員
        			cam.Approval_User3__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(3),null),0);
    }
}