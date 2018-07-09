/**********************************************************************
 名    称：审批流程名称
 目    的：通知Sap接收到数据时，应以何种逻辑处理数据
 作    者：刘文俊(liuwenjun@bluelinksys.com)
 创建日期：2017-04-17
 修 改 人：
 修改日期：
 修改原因：
 备    注：
 **********************************************************************/
public without sharing class SapApprovalEnum {
	//客户主数据维护流程
	public static final String CUSTOMER = 'Customer';
	//供应商主数据维护流程
	public static final String VENDOR = 'Vendor';
	//费用报销流程
	public static final String EXPENSEREIMBURSE = 'ExpenseReimburse';
	//预付款申请流程
	public static final String ADVANCECHARGE = 'AdvanceCharge';
	//员工异动管理流程
	public static final String STAFFTRANSFER = 'StaffTransfer';
	//资产购置流程
	public static final String ASSETPURCHASE = 'AssetPurchase';
	//员工主动离职流程
	public static final String STAFFLEAVEOFFICE = 'StaffLeaveOffice';
	//出差管理流程
	public static final String BUSINESSTRAVEL = 'BusinessTravel';
	//銷售訂單流程
	public static final String SALEORDERDATATABLE = 'SaleOrderDatatable';
	//销售订单流程
	public static final String SALEORDER = 'SaleOrder';
	//标准采购订单作业流程
	public static final String PURCHASEORDER = 'PurchaseOrder';
	//成本中心发料作业流程
	public static final String COSTCENTERSEND = 'CostCenterSend';
	//废料处理流程
	public static final String WASTEDISPOSE = 'WasteDispose';
	//采购信息记录维护流程
	public static final String PURCHASEINFORMATION = 'PurchaseInformation';
	//品质异常单流程
	public static final String ABNORMALQUALITY = 'AbnormalQuality';
	//采购询价作业流程
	public static final String RFQ = 'RFQ';
	//采购申请作业流程
	public static final String PURCHASEAPPLICATION = 'PurchaseApplication';
	//标准销售申请流程
	public static final String SALESAPPLICATION = 'SalesApplication';
	//加班管理流程
	public static final String OVERTIMEWORK = 'OvertimeWork';
	//员工调薪管理流程	
	public static final String MODIFYPAY = 'ModifyPay';
	//内部联络单流程		
	public static final String INTERNALCONTACT = 'InternalContact';
	//IT服务申请流程			
	public static final String IT_SERVICEAPPLICATION = 'IT_ServiceApplication';
	//考勤异常处理申请流程				
	public static final String ABNORMALATTENCE = 'AbnormalAttence';
	//请假管理流程					
	public static final String LEAVE = 'Leave';
	//客户派车申请流程						
	public static final String CUSTOMERDISPATCH = 'CustomerDispatch';
	//用印申请流程							
	public static final String SEALAPPLICATION = 'SealApplication';
	//销售定价业务流程								
	public static final String SALESPRICING = 'SalesPricing';
	//出口申请流程									
	public static final String EXPORTAPPLICATION = 'ExportApplication';
	//交际应酬费申请流程										
	public static final String ENTERTAINECOST = 'EntertaineCost';
	//台干返乡探视申请流程											
	public static final String RETURNHOME = 'ReturnHome';
	//客户单笔信货核发申请流程												
	public static final String CREDITAUDITING = 'CreditAuditing';
	//技术支持流程													
	public static final String TECHNICALSUPPORT = 'TechnicalSupport';
	//管道样品申请流程														
	public static final String PIPELINESAMPLE = 'PipelineSample';
	//客戶信用贷款主数据申请流程															
	public static final String CREDITLOAN = 'CreditLoan';
	//报价申请流程																
	public static final String QUOTEAPPLICATION = 'QuoteApplication';
	//订餐申请流程																	
	public static final String BOOKDINNER = 'BookDinner';
	//运货车辆申请流程
	public static final String FREIGHT_VEHICLES = 'Freight_Vehicles';
	//供应商索赔流程																		
	public static final String VENDORCLAIM = 'VendorClaim';
	//班次变更申请流程																			
	public static final String SHIFTCHANGE = 'ShiftChange';
	//盘盈亏申请流程																				
	public static final String INVENTORYAPPLICATION = 'InventoryApplication';
	//SAP生产工单取消TECO申请流程																					
	public static final String CANCELTECO = 'CancelTECO';
	//报废申请流程																						
	public static final String SCRAPAPPLICATION = 'ScrapApplication';
	//PM通知流程																							
	public static final String PM_NOTICE = 'PM_Notice';
	//盘盈盘亏流程																								
	public static final String INVENTORYPROCESS = 'InventoryProcess';
	//MR模具申请流程																									
	public static final String MR_SAMPLE = 'MR_Sample';
	//库存调拨申请流程																										
	public static final String STOCKALLOCATION = 'StockAllocation';
	//成本要素主数据维护流程																											
	public static final String PRIMECOST = 'PrimeCost';
	//资产清理出售流程																													
	public static final String ASSETLIQUIDATIONSALE = 'AssetLiquidationSale';
	//资产出售流程																														
	public static final String ASSETSALE = 'AssetSale';
	//组织架构变更调整流程																															
	public static final String ORGANIZATIONALCHANGE = 'OrganizationalChange';
	//员工试用期转正管理流程																																
	public static final String PERIODOFPROBATION = 'PeriodofProbation';
	//排班管理流程																																	
	public static final String CREWSCHEDULING = 'CrewScheduling';
	//HR人力补充申请流程																																		
	public static final String HR_MANPOWERSUPPLEMENT = 'HR_ManpowerSupplement';
	//教育训练申请流程																																			
	public static final String TRAINING = 'Training';
	//来宾接待流程																																				
	public static final String VISITORHOSTS = 'VisitorHosts';
	//IRS資訊需求服務流程																																					
	public static final String IRS_INFORMATIONSERVICE = 'IRS_InformationService';
	//内控不符合项流程																																						
	public static final String INTERNALLYPILOTING = 'InternallyPiloting';
	//部门预算金额变更申请流程																																							
	public static final String BUDGETCHANGE = 'BudgetChange';
	//QTW客诉流程																																								
	public static final String QTW_CUSTOMERCOMPLAINT = 'QTW_CustomerComplaint';
	//呆滞物料转用工作流程																																									
	public static final String INACTIVEMATERIALTRANSFER = 'InactiveMaterialTransfer';
	//SAP专案代号申请流程																																										
	public static final String SAP_PROJECTCODE = 'SAP_ProjectCode';
	//SEV1供应商定期评核流程																																											
	public static final String SEV1_VENDORPERIODICASSESSMENT = 'SEV1_VendorPeriodicAssessment';
	//SEV2供应商评鉴流程																																												
	public static final String SEV2_VENDOREVALUATION = 'SEV2_VendorEvaluation';
	//EXP费用申请流程																																													
	public static final String EXP_APPLICATIONFEE = 'EXP_ApplicationFee';
	//內部連絡單																																												
	public static final String INTERNALMEMO = 'Internalmemo';
	//售后服务简化流程
	public static final String POSTSALESERVICE = 'PostsaleService';
	//计量器具申请流程
	public static final String MEASURINGINSTREQUEST = 'MeasuringInstRequest';
	//用印流程
	public static final String SIGNETUSE = 'SignetUse';
	//HR人力补充申请流程流程
	public static final String MANPOWERREPLENISHMENT = 'ManpowerReplenishment';
	//加班管理流程
	public static final String OVERTIMEMANAGER = 'OvertimeWork';
	//PM通知单
	public static final String PMTICKET = 'PMTicket';
	//退货申请流程
	public static final String SALESRETURN = 'SALESRETURN';
	//盘盈盘亏申请流程
	public static final String INVENTORYKINGLAI = 'InventoryKinglai';  
	//销售定价业务流程 
	public static final String SALESPRICE = 'SalesPrice';    
	//MR模具申请流程
	public static final String MRDIEREQUEST = 'MRDieRequest';
	//教育訓練申請流程
	public static final String EDUCATIONTRAININGREQUEST = 'EducationTraining';
	//客户信用贷款主数据申请
	public static final String CUSTOMERCREDITLOAN = 'CustomerCreditLoan';
	//請假申請流程
	public static final String LEAVEAPPLICATION = 'LeaveApplication';
	//QCC客诉申请流程
	public static final String QCC = 'Qcc';
	//SCC供应商索赔申请流程
	public static final String SCCSUPPLIERCLAIM = 'SCCSupplierClaim';
	//样品申请流程
	public static final String SAMPLEREQUEST = 'SampleRequest';
	//资产转移报废停用申请流程																												
	public static final String ASSETSTRANSFER = 'AssetsTransfer';
    //岗位变更流程
    public static final String  CHANGEJOBS='changejobs';
    //客户单笔信贷核发申请
    public static final String  CLIENTAPPLY='ClientApply';
    //補考勤申請
    public static final String  CLOCKINANDOUTAPPLICATION='AMClockInAndOutApplication';
    public static final String  SAMPLEMASTER='SampleMaster';
}