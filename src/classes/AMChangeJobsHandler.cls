/**
 * @Process 岗位变更流程
 * @author  杨旺
 * @Time   2018/4/19
 * 
 */

public without sharing class AMChangeJobsHandler  implements Triggers.Handler{
   
    public void handle() {
         Map<Decimal,Organizational__c>  mapSpecify = null;
     		   Id rtId = HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.CHANGEJOBS,'Approval_Managed1__c');
     		   if (Trigger.isBefore && Trigger.isInsert) {
       		     for (Approval_Managed1__c cam : (List<Approval_Managed1__c>)Trigger.new) {
       		         if (cam.RecordTypeId == rtId) {
               	     	if(mapSpecify == null){
                        	mapSpecify = Utils.getApprovalStepByAPIName(SapApprovalEnum.CHANGEJOBS);
                   	 	}
                    	setApprovalUser(mapSpecify,cam);
                	}
               	 }
               }
       
    

			if (Trigger.isBefore && Trigger.isUpdate) {
			            for (Approval_Managed1__c cam : (List<Approval_Managed1__c>)Trigger.new) {
			                if (cam.RecordTypeId == rtId && cam.Is_Reset_Approvaler__c) {
			                    if(mapSpecify == null){
			                        mapSpecify = Utils.getApprovalStepByAPIName(SapApprovalEnum.CHANGEJOBS);
			                    }
			                	setApprovalUser(mapSpecify,cam); 
			                    cam.Is_Reset_Approvaler__c = false;
			                    
			                }
			               
			            }
			}
			    
	}

            public void setApprovalUser(Map<Decimal,Organizational__c> mapSpecify,Approval_Managed1__c cam){

            	//节点一：一阶主管审批
            	cam.Approval_User1__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(1),cam.Applicant__c),0);
            	//节点二：HR人事专员
            	cam.Approval_User2__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(2),null),0);
            	//节点三：HR经理
            	cam.Approval_User3__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(3),cam.Applicant__c),0);
            	//节点四：副总经理
            	cam.Approval_User4__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(4),cam.Applicant__c),0);
              //节点五：财务经理
              cam.Approval_User5__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(5),null),0);
              //节点六：HR人事专员
              cam.Approval_User6__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(6),null),0);
              //节点七：HR人事主管
              cam.Approval_User7__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(7),null),0);
            }

}