public without sharing class AMSCCSupplierClaimHandler implements Triggers.Handler {
    public void handle() {
        Map<Decimal,Organizational__c>  mapSpecify = null;
        Id rtId = HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.SCCSUPPLIERCLAIM,'Custom_Approval_Managed__c');
        if (Trigger.isBefore && Trigger.isInsert) {
            for (Custom_Approval_Managed__c cam : (List<Custom_Approval_Managed__c>)Trigger.new) {
                if (cam.RecordTypeId == rtId) {
                    if(mapSpecify == null){
                        mapSpecify = Utils.getApprovalStepByAPIName(SapApprovalEnum.SCCSUPPLIERCLAIM);
                    }
                    setApprovalUser(mapSpecify,cam);
                }
            }
        }
        
        if (Trigger.isBefore && Trigger.isUpdate) {
            for (Custom_Approval_Managed__c cam : (List<Custom_Approval_Managed__c>)Trigger.new) {
                if (cam.RecordTypeId == rtId && cam.Is_Reset_Approvaler__c) {
                    if(mapSpecify == null){
                        mapSpecify = Utils.getApprovalStepByAPIName(SapApprovalEnum.SCCSUPPLIERCLAIM);
                    }
                    setApprovalUser(mapSpecify,cam);
                    cam.Is_Reset_Approvaler__c = false; 
                }
            }
        }
    }

    public void setApprovalUser(Map<Decimal,Organizational__c> mapSpecify,Custom_Approval_Managed__c cam){ 
    	// cam.Approval_User2__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(2),cam.指定申请人字段),0);
        // cam.Approval_User2__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(2),cam.Applicant__c),0);
        //节点一：主管审核
        cam.Approval_User1__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(1),cam.Applicant__c),0);
        //节点二: 生产/业务单位
        cam.Approval_User2__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(2),cam.Approval_User2__c),0);
        //节点二: 生产/业务单位
        cam.Approval_User3__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(3),cam.Applicant__c),0);
        //节点四: 成本中心核算
        cam.Approval_User4__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(4),null),0);
       	//节点四: 采购扣款处理
        cam.Approval_User5__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(5),cam.Applicant__c),0);
        //节点四: 采购经理/SQE确认
        cam.Approval_User6__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(6),null),0);
        //节点四: 财务确认
        cam.Approval_User7__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(7),cam.Applicant__c),0);
    }         
    
}