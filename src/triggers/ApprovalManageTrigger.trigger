/*
蓝岭开发流程：                新莱开发；

费用报销流程                  废料处理流程
预付款申请流程                供应商主数据维护流程
员工异动管理流程              采购信息记录维护流程
资产购置流程                  标准采购订单作业流程
品质异常单                    采购询价作业流程
员工主动离职管理流程          请假管理流程
员工出差管理流程 
客戶主数据维护流程
成本中心发料作业流程
销售订单审批流程
*/
trigger ApprovalManageTrigger on Approval_Managed__c(before insert, after update, before update, after insert) {
    new Triggers()
    //用户是否有编辑权限一定放在最前面，请不要移动代码位置
    .bind (Triggers.Evt.beforeupdate, new ApprovalPermissionHandler())
    //节点同步检测
    .bind (Triggers.Evt.beforeUpdate, new ApprovalSyncCheckHandler())
    //流程数据同步到SAP
    .bind (Triggers.Evt.beforeupdate, new PushApprovalDataToSapHandler())
    //写入单据头信息
    .bind (Triggers.Evt.beforeinsert,new UpdateBillHeaderInfoHandler())//记录保存时触发计算审批人
//**********************************************************************************
    
//FICO
    //费用报销审批流程各节点审批人
    .bind (Triggers.Evt.beforeinsert,new AMExpenseReimburseHandler())
    .bind (Triggers.Evt.beforeupdate,new AMExpenseReimburseHandler())

     //盘盈盘亏申请流程
    .bind (Triggers.Evt.beforeinsert,new AMInventoryKinglaiHandler())
    .bind (Triggers.Evt.beforeupdate,new AMInventoryKinglaiHandler())

    //设置预付款申请单审批流程各节点审批人
    .bind (Triggers.Evt.beforeinsert,new AMAdvanceChargeHandler())
    .bind (Triggers.Evt.beforeupdate,new AMAdvanceChargeHandler())

    //设置资产购置审批流程各节点审批人
    .bind (Triggers.Evt.beforeinsert,new AMAssetPurchaseHandler())
    .bind (Triggers.Evt.beforeupdate,new AMAssetPurchaseHandler())

    //设置交际应酬审批流程各节点审批人
    .bind (Triggers.Evt.beforeinsert,new AMEntertaineCostHandler())
    .bind (Triggers.Evt.beforeupdate,new AMEntertaineCostHandler())

//QM

    //设置品质异常单审批流程各节点审批人
    .bind (Triggers.Evt.beforeinsert,new AMAbnormalQualityHandler())
    .bind (Triggers.Evt.beforeupdate,new AMAbnormalQualityHandler())//更新时重新计算审批人

    //设置计量器具申请审批流程各节点审批人
    .bind (Triggers.Evt.beforeinsert,new AMMeasuringInstRequestHandler())
    .bind (Triggers.Evt.beforeupdate,new AMMeasuringInstRequestHandler())

//PM


    //设置PM通知单各节点审批人
    .bind (Triggers.Evt.beforeinsert,new AMPMTicketHandler())
    .bind (Triggers.Evt.beforeupdate,new AMPMTicketHandler())



//MM
    //设置标准采购订单作业审批流程各节点审批人
    .bind (Triggers.Evt.beforeinsert,new AMPurchaseOrderHandler())
    .bind (Triggers.Evt.beforeupdate,new AMPurchaseOrderHandler())

    //设置采购申请作业审批流程各节点审批人
    .bind (Triggers.Evt.beforeinsert,new AMPurchaseApplicationHandler())
    .bind (Triggers.Evt.beforeupdate,new AMPurchaseApplicationHandler())

//SD
    //用印流程
    .bind (Triggers.Evt.beforeinsert,new AMSignetUseHandler())
    .bind (Triggers.Evt.beforeupdate,new AMSignetUseHandler())

    //销售定价业务流程各节点审批人
    .bind (Triggers.Evt.beforeinsert,new AMSalesPricingHandler())
    .bind (Triggers.Evt.beforeupdate,new AMSalesPricingHandler())

     //客户信用贷款主数据申请流程各节点审批人
    .bind (Triggers.Evt.beforeinsert,new AMCustomerCreditLoanHandler()) 
    .bind (Triggers.Evt.beforeupdate,new AMCustomerCreditLoanHandler())
     
//HR
    //HR人力补充申请流程
    .bind (Triggers.Evt.beforeinsert,new AMManpowerReplenishmentHandler())
    .bind (Triggers.Evt.beforeupdate,new AMManpowerReplenishmentHandler())

    //加班管理流程
    .bind (Triggers.Evt.beforeinsert,new AMOvertimeManagerHandler())
    .bind (Triggers.Evt.beforeupdate,new AMOvertimeManagerHandler())

    //请假管理流程
    .bind (Triggers.Evt.beforeinsert,new AMLeaveHander())
    .bind (Triggers.Evt.beforeupdate,new AMLeaveHander())

    //员工异动管理审批流程各节点审批人
    .bind (Triggers.Evt.beforeinsert,new AMStaffTransferHandler())
    .bind (Triggers.Evt.beforeupdate,new AMStaffTransferHandler())

    //员工主动离职审批流程各节点审批人
    .bind (Triggers.Evt.beforeinsert,new AMStaffLeaveOfficeHandler())
    .bind (Triggers.Evt.beforeupdate,new AMStaffLeaveOfficeHandler())

    //請假申請流程
    .bind (Triggers.Evt.beforeinsert,new AMLeaveApplicationHandler())
    .bind (Triggers.Evt.beforeupdate,new AMLeaveApplicationHandler())
//MR
    //设置MR模具申请流程各节点审批人
    .bind (Triggers.Evt.beforeinsert,new AMMRDieRequestHandler())
    .bind (Triggers.Evt.beforeupdate,new AMMRDieRequestHandler())

//**********************************************************************************
    //设置记录共享
    .bind (Triggers.Evt.afterinsert,new ApprovalManualShareHandler())
    .bind (Triggers.Evt.afterupdate,new ApprovalManualShareHandler())

    .manage(); 
}