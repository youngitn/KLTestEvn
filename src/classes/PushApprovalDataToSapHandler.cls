/*
* Name                 : Custom_Approval_Managed__c Trigger
* Object               : PushApprovalDataToSapHander
* Requirement          :审批通过的流程数据添加到同步数据到SAP的队列中
* Refer classes        :
* Author               :zhonghui
* Create Date          :2017年5月12日
* Modified History     :代码优化
* ModifiedBy		   :刘文俊
* Modified Date 	   :2017-06-19
*/
public without sharing class PushApprovalDataToSapHandler implements Triggers.Handler{
	public void handle()  {
		if (Trigger.isBefore && Trigger.isUpdate) {	
			System.debug('*** 进入触发器：PushApprovalDataToSapHandler');
			Map<Id,RecordType> rtMap = null;
			Set<String> types = new Set<String>();
			for(SObject obj : Trigger.new){
				String ty = String.valueOf(obj.getSObjectType());
				if(!types.contains(ty)){
					types.add(ty);
				}
			}
			for(SObject obj : Trigger.new){
				Boolean IsPushSap = Boolean.valueOf(obj.get('Is_Push_Sap__c'));
				if(IsPushSap){
					String rtId = String.valueOf(obj.get('RecordTypeId'));
					if(rtMap == null){
						rtMap = new Map<Id,RecordType>([SELECT Id,DeveloperName FROM RecordType WHERE SObjectType IN:types]);
					}
					String approvalName = rtMap.get(rtId).DeveloperName;
					String targetId = String.valueOf(obj.get('Id'));
					String status = String.valueOf(obj.get('Status__c'));
					Utils.addToSendQueue(approvalName, targetId, status);
					obj.put('Is_Push_Sap__c',false);
				}

				Boolean IsPushSapOnce = Boolean.valueOf(obj.get('Is_Push_Sap_Once__c'));
				//单条记录只推送一次
				if (IsPushSapOnce) {
				    String rtId = String.valueOf(obj.get('RecordTypeId'));
					if(rtMap == null){
						rtMap = new Map<Id,RecordType>([SELECT Id,DeveloperName FROM RecordType WHERE SObjectType IN:types]);
					}
					String approvalName = rtMap.get(rtId).DeveloperName;
					String targetId = String.valueOf(obj.get('Id'));
					List<Metadata__c> lstMeta = [SELECT Id FROM Metadata__c 
								WHERE RecordType.DeveloperName = 'SF_To_SAP_Queue' AND Send_Direction__c = 'SF_TO_SAP' AND ApprovalID__c =:targetId];
					String status = String.valueOf(obj.get('Status__c'));
					if (lstMeta.size()<1) {
					 	Utils.addToSendQueue(approvalName, targetId, status);

					}
					obj.put('Is_Push_Sap_Once__c',false);
				}
			} 
		}
	}
}