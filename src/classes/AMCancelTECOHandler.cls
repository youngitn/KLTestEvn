public with sharing class AMCancelTECOHandler implements Triggers.Handler {
           
     public void handle() {         
        Map<Decimal,Organizational__c>  mapSpecify = null;
        Id rtId = HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.CANCELTECO,'Approval_Managed2__c');
        if (Trigger.isBefore && Trigger.isInsert) {
            for (Approval_Managed2__c cam : (List<Approval_Managed2__c>)Trigger.new) {
                if (cam.RecordTypeId == rtId) {
                    if(mapSpecify == null){
                        mapSpecify = Utils.getApprovalStepByAPIName(SapApprovalEnum.CANCELTECO);
                    }
                    setApprovalUser(mapSpecify,cam);
                }
            }
        }        
        if (Trigger.isBefore && Trigger.isUpdate) {
            for (Approval_Managed2__c cam : (List<Approval_Managed2__c>)Trigger.new) {
                if (cam.RecordTypeId == rtId ){
                    
                    //System.debug('cam.Approval_Status__c:xxxxxx '+cam.Approval_Status__c);
                     //System.debug('-------------->cam.id '+cam.id);
                    
                    
                    //Reject
                    //Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                    //req.setAction('Reject');
                    //ProcessInstanceWorkitem pItem = [Select Id from ProcessInstanceWorkitem where ProcessInstance.TargetObjectId ='a07O000000F32Px' ];
                    //req.setWorkitemId('a07O000000F32Px');
                    //RejectRecord(cam);
                    if ( cam.Is_Reset_Approvaler__c ) {
                        if(mapSpecify == null){
                            mapSpecify = Utils.getApprovalStepByAPIName(SapApprovalEnum.CANCELTECO);
                        }
                        setApprovalUser(mapSpecify,cam);
                        cam.Is_Reset_Approvaler__c = false;
                    }
                }
            }
            
        }
    }
    
    /*public void RejectRecord(Approval_Managed2__c opp)
     {
         //Class used for Approving Record
         Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
         req.setComments('Approving request for Opportunity');
         
         //Approve or Reject Record
         req.setAction('Reject');
         
         //Getting Work Item Id
         ProcessInstanceWorkitem pItem = [Select Id from ProcessInstanceWorkitem 
         where ProcessInstance.TargetObjectId =: opp.id];
        
         req.setWorkitemId(pItem.Id);
         // Submit the request for approval
         Approval.ProcessResult result = Approval.process(req);
         
     }*/
    
    
    
            //获取內部連絡單流程各节点配置
    public void setApprovalUser(Map<Decimal,Organizational__c> mapSpecify,Approval_Managed2__c cam){
                    
                    
                    //節點一：申請人部門主管
                    cam.Approval_User1__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(1),cam.Applicant__c),0);
                    //節點二：指定人員
                    cam.Approval_User2__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(2),null),0);
                    //節點三：申請人自己
                    cam.Approval_User3__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(3),cam.Applicant__c),0);
    }
}