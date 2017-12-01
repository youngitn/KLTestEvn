public without sharing class AMVisitorHostsHandler implements Triggers.Handler {
    public void handle() {
        if (Trigger.isBefore && Trigger.isInsert) {
        	//來賓接待记录类型
        	RecordType recTypeAcc = [SELECT Id, DeveloperName, Name 
                                     FROM RecordType Where SObjectType = 'Approval_Managed1__c' 
                                     AND DeveloperName ='VisitorHosts'];
        	Map<Decimal,Organizational__c>  mapSpecify = Utils.getApprovalStepByAPIName(SapApprovalEnum.VISITORHOSTS);
        	for (Approval_Managed1__c cam : (List<Approval_Managed1__c>)Trigger.new) {
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