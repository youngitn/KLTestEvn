trigger ApprovalManage1Trigger on Approval_Managed1__c (before insert,before update,after insert,after update) {
	new Triggers()
    //用户是否有编辑权限一定放在最前面，请不要移动代码位置
    .bind (Triggers.Evt.beforeUpdate, new ApprovalPermissionHandler())
    //节点同步检测
    .bind (Triggers.Evt.beforeUpdate, new ApprovalSyncCheckHandler())
    //流程数据同步到SAP
    .bind (Triggers.Evt.beforeUpdate, new PushApprovalDataToSapHandler())
    //写入单据头信息
    .bind (Triggers.Evt.beforeinsert,new UpdateBillHeaderInfoHandler())//记录保存时触发计算审批人
    //设置內部連絡單审批流程各节点审批人
    .bind (Triggers.Evt.beforeinsert,new AMInternalmemoHandler())
    .bind (Triggers.Evt.beforeupdate,new AMInternalmemoHandler())
    //IT服务申请流程
    .bind (Triggers.Evt.beforeinsert,new AMInformationServiceHandler())
    .bind (Triggers.Evt.beforeupdate,new AMInformationServiceHandler())
    //客户单笔信货核发申请流程
    .bind (Triggers.Evt.beforeinsert,new AMCreditAuditingHandler())
    .bind (Triggers.Evt.beforeupdate,new AMCreditAuditingHandler())
    //客戶信用贷款主数据申请 
    .bind (Triggers.Evt.beforeinsert,new AMCreditAuditingHandler())
    .bind (Triggers.Evt.beforeupdate,new AMCreditAuditingHandler())
    //订餐&派车申请流程 
    .bind (Triggers.Evt.beforeinsert,new AMBookDinnerHander())
    .bind (Triggers.Evt.beforeupdate,new AMBookDinnerHander())
    //运货车辆申请流程
    .bind (Triggers.Evt.afterinsert,new AMFreightVehiclesHandler())
    .bind (Triggers.Evt.afterupdate,new AMFreightVehiclesHandler())
    //售后服务简化流程
    .bind (Triggers.Evt.beforeinsert,new AMPostSaleServiceHandler())
    .bind (Triggers.Evt.beforeupdate,new AMPostSaleServiceHandler())
    //设置來賓接待审批流程各节点审批人
    .bind (Triggers.Evt.beforeinsert,new AMVisitorHostsHandler())
     //教育訓練申請流程
    .bind (Triggers.Evt.beforeinsert,new AMEducationTrainingHandler())
    .bind (Triggers.Evt.beforeupdate,new AMEducationTrainingHandler())
    //设置记录共享
    .bind (Triggers.Evt.afterinsert,new ApprovalManualShareHandler())
    .bind (Triggers.Evt.afterupdate,new ApprovalManualShareHandler())
    .manage(); 
}