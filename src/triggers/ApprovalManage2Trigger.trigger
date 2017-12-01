trigger ApprovalManage2Trigger on Approval_Managed2__c (before insert,before update,after insert,after update) {
	new Triggers()	
	//用户是否有编辑权限一定放在最前面，请不要移动代码位置
    .bind (Triggers.Evt.beforeUpdate, new ApprovalPermissionHandler())
    //节点同步检测
    .bind (Triggers.Evt.beforeUpdate, new ApprovalSyncCheckHandler())
    //流程数据同步到SAP
    .bind (Triggers.Evt.beforeUpdate, new PushApprovalDataToSapHandler())
    //写入单据头信息
    .bind (Triggers.Evt.beforeinsert,new UpdateBillHeaderInfoHandler())//记录保存时触发计算审批人
    //解除TECO审批流程各节点审批人
    .bind (Triggers.Evt.beforeinsert,new AMCancelTECOHandler())
    .bind (Triggers.Evt.beforeupdate,new AMCancelTECOHandler())
     //盤盈虧审批流程各节点审批人
    .bind (Triggers.Evt.beforeinsert,new AMInventoryProcessHandler())
    .bind (Triggers.Evt.beforeupdate,new AMInventoryProcessHandler())
    //EXP費用申請單批流程各节点审批人
  //  .bind (Triggers.Evt.beforeinsert,new AMEXP_ApplicationFeeHandler())
  //  .bind (Triggers.Evt.beforeupdate,new AMEXP_ApplicationFeeHandler())
    //SEV2供应商评鉴流程
  //  .bind (Triggers.Evt.beforeinsert,new AMSEV2_VendorEvaluationHandler())
  //  .bind (Triggers.Evt.beforeupdate,new AMSEV2_VendorEvaluationHandler())
    //QTW客訴申請流程
  //  .bind (Triggers.Evt.beforeinsert,new AMQTW_CustomerComplaintHandler())
  //  .bind (Triggers.Evt.beforeupdate,new AMQTW_CustomerComplaintHandler())
    //设置记录共享
    .bind (Triggers.Evt.afterinsert,new ApprovalManualShareHandler())
    .bind (Triggers.Evt.afterupdate,new ApprovalManualShareHandler())
    .manage(); 
}