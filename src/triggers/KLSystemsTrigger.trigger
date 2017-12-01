/*
新莱开发；

3D打印记录
电话簿
投票结果查询
會議記錄
*/
trigger KLSystemsTrigger on KL_Systems__c (before insert, after update, before update, after insert) {
  new Triggers()

/*
    //用户是否有编辑权限一定放在最前面，请不要移动代码位置
    .bind (Triggers.Evt.beforeupdate, new ApprovalPermissionHandler())
    //节点同步检测
    .bind (Triggers.Evt.beforeUpdate, new ApprovalSyncCheckHandler())
    //流程数据同步到SAP
    .bind (Triggers.Evt.beforeupdate, new PushApprovalDataToSapHandler())
    //写入单据头信息
    .bind (Triggers.Evt.beforeinsert,new UpdateBillHeaderInfoHandler())//记录保存时触发计算审批人
    //设置记录共享
    .bind (Triggers.Evt.afterinsert,new ApprovalManualShareHandler())
    .bind (Triggers.Evt.afterupdate,new ApprovalManualShareHandler())
*/

    //會議記錄
 //   .bind (Triggers.Evt.afterinsert,new AMMeetingMinutesManualShareHandler())
 //   .bind (Triggers.Evt.afterupdate,new AMMeetingMinutesManualShareHandler())

    .manage(); 
}