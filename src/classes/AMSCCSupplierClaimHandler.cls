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
        //节点一：申请人部门主管
        cam.Approval_User1__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(1),cam.Applicant__c),0);
        //节点二: 一阶主管
        cam.Approval_User2__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(2),cam.Applicant__c),0);
        //节点三: 总经理室  
        cam.Approval_User3__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(3),null),0);
        //节点四: 申请人确认
        cam.Approval_User4__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(4),cam.Applicant__c),0);
       		
    }         
    
}