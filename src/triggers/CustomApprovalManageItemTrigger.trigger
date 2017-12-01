trigger CustomApprovalManageItemTrigger on Custom_Approval_Managed_Item__c(before insert, after update,before update, after insert) {
	new Triggers()
	//用户是否有编辑权限一定放在最前面，请不要移动代码位置
    .bind (Triggers.Evt.beforeUpdate, new ApprovalPermissionItemHandler())
	.bind (Triggers.Evt.beforeInsert, new UpdateLookupInfoHandler())
    .bind (Triggers.Evt.beforeUpdate, new UpdateLookupInfoHandler())
    //如果有任务ID,则从CRM取相关信息
    .bind(Triggers.Evt.afterInsert, new GetTaskInfoFromCRMHandler())
    //如果有任务ID,则从CRM取相关信息
    .bind(Triggers.Evt.afterUpdate, new GetTaskInfoFromCRMHandler())
    .manage(); 
}