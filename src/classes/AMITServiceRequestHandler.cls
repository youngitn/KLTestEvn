/*
節點一.單位主管
節點二.資訊主管
*/

public with sharing class AMITServiceRequestHandler implements Triggers.Handler{
    public void handle(){
    	if (Trigger.isBefore && Trigger.isInsert) {
        	//資訊需求單
        	RecordType recTypeAcc = [SELECT Id, DeveloperName, Name 
                                     FROM RecordType Where SObjectType = 'Approval_Managed1__c' 
                                     AND DeveloperName ='VisitorHosts'];
        	Map<Decimal,Organizational__c>  mapSpecify = Utils.getApprovalStepByAPIName(SapApprovalEnum.VISITORHOSTS);
        	for (Approval_Managed1__c cam : (List<Approval_Managed1__c>)Trigger.new) {
        		if (cam.RecordTypeId == recTypeAcc.Id) {
        			//節點一：申請人部門主管
        			cam.Approval_User1__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(1),cam.Applicant__c),0);
        			//節點二：指定人員
        			cam.Approval_User2__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(2),null),0);
        			//節點三：指定人員
        			cam.Approval_User3__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(3),null),0);
        		}
        	}
            System.debug('*** 退出節點配置: '  + '');
        }    
    }
}