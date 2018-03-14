public without sharing class AMSalesReturnhandler implements Triggers.Handler {
	    public void handle() {
        Map<Decimal,Organizational__c>  mapSpecify = null;
        Id rtId = HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.SALESRETURN,'Custom_Approval_Managed__c');
        if (Trigger.isBefore && Trigger.isInsert) {
            for (Custom_Approval_Managed__c cam : (List<Custom_Approval_Managed__c>)Trigger.new) {
                if (cam.RecordTypeId == rtId) {
                    if(mapSpecify == null){
                        mapSpecify = Utils.getApprovalStepByAPIName(SapApprovalEnum.SALESRETURN);
                    }
                    setApprovalUser(mapSpecify,cam);
                }
            }
        }
        if (Trigger.isBefore && Trigger.isUpdate) {
            for (Custom_Approval_Managed__c cam : (List<Custom_Approval_Managed__c>)Trigger.new) {
                if (cam.RecordTypeId == rtId && cam.Is_Reset_Approvaler__c) {
                    if(mapSpecify == null){
                        mapSpecify = Utils.getApprovalStepByAPIName(SapApprovalEnum.SALESRETURN);
                    }
                    setApprovalUser(mapSpecify,cam);
                    cam.Is_Reset_Approvaler__c = false;
                }
            }
        }
    
    }
        //请假管理流程各节点配置
    public void setApprovalUser(Map<Decimal,Organizational__c> mapSpecify,Custom_Approval_Managed__c cam){
        //USER1
        //cam.Approval_User1__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(1),null),0);
        //USER2
        //cam.Approval_User2__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(2),cam.Employee__c),0);
        //USER3
        //cam.Approval_User3__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(3),cam.Employee__c),0);
        //USER4
        //cam.Approval_User4__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(4),cam.Employee__c),0);
        //USER5
        //cam.Approval_User5__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(5),null),0);
        //USER6
        //cam.Approval_User6__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(6),null),0);
        //USER7
        cam.Approval_User7__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(7),cam.Applicant__c),0);
    }
}