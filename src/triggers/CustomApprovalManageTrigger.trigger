/*
蓝岭开发流程：                新莱开发；                    台灣

费用报销流程                  废料处理流程              資訊需求服務單
预付款申请流程                供应商主数据维护流程      供應商索賠流程
员工异动管理流程              采购信息记录维护流程
资产购置流程                  标准采购订单作业流程
品质异常单                    采购询价作业流程
员工主动离职管理流程
员工出差管理流程 
客戶主数据维护流程
成本中心发料作业流程
销售订单审批流程
*/
trigger CustomApprovalManageTrigger on Custom_Approval_Managed__c(before insert, after update,before update, after insert) {
    new Triggers()
    //用户是否有编辑权限一定放在最前面，请不要移动代码位置
    .bind (Triggers.Evt.beforeUpdate, new ApprovalPermissionHandler())
    //节点同步检测
    .bind (Triggers.Evt.beforeUpdate, new ApprovalSyncCheckHandler())
    //流程数据同步到SAP
    .bind (Triggers.Evt.beforeUpdate, new PushApprovalDataToSapHandler())
    //计算国家省市地区
    .bind (Triggers.Evt.beforeInsert, new UpdateCustomerVendorHandler())
    .bind (Triggers.Evt.beforeUpdate, new UpdateCustomerVendorHandler())
    //处理审批流程头信息
    .bind (Triggers.Evt.beforeinsert,new UpdateBillHeaderInfoHandler())
    //设置供应商主数据审批流程各节点审批人
    .bind (Triggers.Evt.beforeinsert,new AMVendorHandler())
    .bind (Triggers.Evt.beforeUpdate,new AMVendorHandler())
    //设置客户主数据审批流程各节点审批人
    .bind (Triggers.Evt.beforeinsert,new AMCustomerHandler())
    .bind (Triggers.Evt.beforeUpdate,new AMCustomerHandler())
    //设置出差管理审批流程各节点审批人
    .bind (Triggers.Evt.beforeinsert,new AMBusinessTravelHandler())
    .bind (Triggers.Evt.beforeUpdate,new AMBusinessTravelHandler())
    //设置废料处理审批流程各节点审批人
    .bind (Triggers.Evt.beforeinsert,new AMWasteDisposeHandler())
    .bind (Triggers.Evt.beforeUpdate,new AMWasteDisposeHandler())
    //设置成本中心发料作业审批流程各节点审批人
    .bind (Triggers.Evt.beforeinsert,new AMCostCenterSendHandler())
    .bind (Triggers.Evt.beforeUpdate,new AMCostCenterSendHandler())
    //设置采购信息记录维护审批流程各节点审批人
    .bind (Triggers.Evt.beforeinsert,new AMPurchaseInformationHandler())
    .bind (Triggers.Evt.beforeUpdate,new AMPurchaseInformationHandler())
    //设置销售订单审批流程各节点审批人
    .bind (Triggers.Evt.beforeinsert,new AMSaleOrderHandler())
    .bind (Triggers.Evt.beforeUpdate,new AMSaleOrderHandler())
    //设置RFQ业务询价流程各节点审批人
    .bind (Triggers.Evt.beforeinsert,new AMRFQHandler())
    .bind (Triggers.Evt.beforeUpdate,new AMRFQHandler())
    //供應商索賠流程 當insert執行時觸發塞審批人進指定欄位的動作
    .bind (Triggers.Evt.beforeinsert,new AMVendorClaimHandler())
    .bind (Triggers.Evt.beforeUpdate,new AMVendorClaimHandler())
    
    //SCC供应商索赔申请流程流程
    .bind (Triggers.Evt.beforeinsert,new AMSCCSupplierClaimHandler())
    .bind (Triggers.Evt.beforeupdate,new AMSCCSupplierClaimHandler())

    //退货申请流程
    .bind (Triggers.Evt.beforeinsert,new AMSalesReturnhandler())
    .bind (Triggers.Evt.beforeupdate,new AMSalesReturnhandler())
    
    //设置记录共享
    .bind (Triggers.Evt.afterinsert,new ApprovalManualShareHandler())
    .bind (Triggers.Evt.afterupdate,new ApprovalManualShareHandler())
    .manage();      
}