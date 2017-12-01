public with sharing class CancelTECOHandler implements Triggers.Handler {
    public void handle() {
        if (Trigger.isBefore && Trigger.isInsert) {
        	//
        	RecordType recTypeAcc = [SELECT Id, DeveloperName, Name 
                                     FROM RecordType Where SObjectType = 'Approval_Managed2__c' 
                                     AND DeveloperName ='CancelTECO'];
        	Map<Decimal,Organizational__c>  mapSpecify = Utils.getApprovalStepByAPIName(SapApprovalEnum.CANCELTECO);
        	for (Approval_Managed2__c cam : (List<Approval_Managed2__c>)Trigger.new) {
        		if (cam.RecordTypeId == recTypeAcc.Id) {
        			//节点一：申请人部门主管
        			cam.Approval_User1__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(1),cam.Applicant__c),0);
        			//节点二：指定人员
        			cam.Approval_User2__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(2),null),0);
        			//节点三：指定人员
        			cam.Approval_User3__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(3),null),0);
        		}
        	}
            System.debug('*** 退出节点配置: '  + '');
        }    
    }
}