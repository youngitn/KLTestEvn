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
    	// cam.Approval_User2__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(2),cam.申请人),0);  cam.Applicant__c
        //节点一：主管审核 
        cam.Approval_User1__c  = cam.user001__c;
        
        if (cam.Approval_User2__c == null) {
            cam.Approval_User2__c = cam.user001__c;
        }
         if (cam.Approval_User3__c == null) {
            cam.Approval_User3__c = cam.user001__c;
        }
        //节点二: 采购确认
        cam.Approval_User4__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(2),null),0);
        //节点三: 采购确认
        cam.Approval_User7__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(3),null),0);
        //节点四: 仓库主管
        cam.Approval_User10__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(4),null),0);
        //节点五: 成本中心核算
        cam.Approval_User11__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(5),null),0);
       	//节点六: 采购扣款处理
        cam.Approval_User12__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(6),null),0);
        //节点七: 采购经理/SQE确认
        cam.Approval_User13__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(7),null),0);
        //节点八: 业务确认
        cam.Approval_User14__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(8),null),0);        
        //节点九: 财务确认
        cam.Approval_User15__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(9),null),0);

    }   
    
}