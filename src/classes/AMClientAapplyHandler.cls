/**
 * @Process 客户单笔信贷核发申请
 * @author  杨旺
 * @Time   2018/4/19
 * 
 */

public without sharing class AMClientAapplyHandler  implements Triggers.Handler{
   
    public void handle() {
         Map<Decimal,Organizational__c>  mapSpecify = null;
     		   Id rtId = HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.CLIENTAPPLY,'Approval_Managed__c');
     		   if (Trigger.isBefore && Trigger.isInsert) {
       		     for (Approval_Managed__c cam : (List<Approval_Managed__c>)Trigger.new) {
       		         if (cam.RecordTypeId == rtId) {
               	     	if(mapSpecify == null){
                        	mapSpecify = Utils.getApprovalStepByAPIName(SapApprovalEnum.CLIENTAPPLY);
                   	 	}
                    	setApprovalUser(mapSpecify,cam);
                	}
               	 }
               }
       
    
    

			if (Trigger.isBefore && Trigger.isUpdate) {
			            for (Approval_Managed__c cam : (List<Approval_Managed__c>)Trigger.new) {
			                if (cam.RecordTypeId == rtId && cam.Is_Reset_Approvaler__c) {
			                    if(mapSpecify == null){
			                        mapSpecify = Utils.getApprovalStepByAPIName(SapApprovalEnum.CLIENTAPPLY);
			                    }
			                	setApprovalUser(mapSpecify,cam); 
			                    cam.Is_Reset_Approvaler__c = false;
			                    
			                }
			               
			            }
			}
			    
	}

            public void setApprovalUser(Map<Decimal,Organizational__c> mapSpecify,Approval_Managed__c cam){

            	//节点一：信控部
            	cam.Approval_User1__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(1),cam.Applicant__c),0);
            	//节点二：财务部
            	cam.Approval_User2__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(2),null),0);
            	//节点三：信控部/售服部
            	cam.Approval_User3__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(3),cam.Applicant__c),0);
    
            }

}