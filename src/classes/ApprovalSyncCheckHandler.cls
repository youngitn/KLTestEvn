/**********************************************************************
 名    称：ApprovalSyncCheckHandler
 目    的：检测是否有后须跳过节点需要同步数据
 作    者：刘文俊(liuwenjun@bluelinksys.com)
 创建日期：2017-06-23
 修 改 人：
 修改日期：
 修改原因：
 备    注：
*************************************************************************/
public without sharing class ApprovalSyncCheckHandler implements Triggers.Handler {
    public void handle() {
        if (Trigger.isBefore && Trigger.isUpdate) {
        	for(SObject obj : Trigger.new){
    			Boolean sync = Boolean.valueOf(obj.get('Approval_SyncCheck__c'));
    			//需要检测是否有后须跳过节点需要同步数据
        		if(sync){
        			obj.put('Approval_SyncCheck__c', false);
        			Metadata__c md = new Metadata__c();
        			md.ApprovalID__c = String.valueOf(obj.get('Id'));
        			md.Is_Send_Succeed__c = false;
        			md.RecordTypeId = HarryUtils.getRecordTypeIdByDevNameAndObjName('Approval_SyncCheck','Metadata__c');
        			INSERT md;

        			ApprovalSyncCheckSchedule.runApprovalSyncCheckSchedule();
        		}
        	}
        }
    }
}