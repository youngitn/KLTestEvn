@isTest
private class SapApprovalEnumTest {
    static testMethod void testMethod1() {
     String a = '';
    a = SapApprovalEnum.CUSTOMER;
	//供应商主数据维护流程
	a = SapApprovalEnum.VENDOR;
	//费用报销流程
	a = SapApprovalEnum.EXPENSEREIMBURSE;
	//预付款申请流程
	a = SapApprovalEnum.ADVANCECHARGE;
	//员工异动管理流程
	a = SapApprovalEnum.STAFFTRANSFER;
	//资产购置流程
	a = SapApprovalEnum.ASSETPURCHASE;
	//员工主动离职流程
	a = SapApprovalEnum.STAFFLEAVEOFFICE;
	//出差管理流程
	a = SapApprovalEnum.BUSINESSTRAVEL;
	//销售订单审批流程
	a = SapApprovalEnum.SALEORDER;
	//标准采购订单作业流程
	a = SapApprovalEnum.PURCHASEORDER;
	//成本中心发料作业流程
	a = SapApprovalEnum.COSTCENTERSEND;
	//废料处理流程
	a = SapApprovalEnum.WASTEDISPOSE;
	//采购信息记录维护流程
	a = SapApprovalEnum.PURCHASEINFORMATION;
	//品质异常单流程
	a = SapApprovalEnum.ABNORMALQUALITY;
	//采购询价作业流程
	a = SapApprovalEnum.RFQ;
	//采购申请作业流
	a = SapApprovalEnum.PURCHASEAPPLICATION;
	//标准销售申请流程
	a = SapApprovalEnum.SALESAPPLICATION;
	//加班管理流程
	a = SapApprovalEnum.OVERTIMEWORK;
	//员工调薪管理流程	
	a = SapApprovalEnum.MODIFYPAY;
	//内部联络单流程		
	a = SapApprovalEnum.INTERNALCONTACT;
	//IT服务申请流程			
	a = SapApprovalEnum.IT_SERVICEAPPLICATION;
	//考勤异常处理申请流程				
	a = SapApprovalEnum.ABNORMALATTENCE;
	//请假管理流程					
	a = SapApprovalEnum.LEAVE;
	//客户派车申请流程						
	a = SapApprovalEnum.CUSTOMERDISPATCH;
	//用印申请流程							
	a = SapApprovalEnum.SEALAPPLICATION;
	//销售定价业务流程								
	a = SapApprovalEnum.SALESPRICING;
	//出口申请流程									
	a = SapApprovalEnum.EXPORTAPPLICATION;
	//交际应酬费申请流程										
	a = SapApprovalEnum.ENTERTAINECOST;
	//台干返乡探视申请流程											
	a = SapApprovalEnum.RETURNHOME;
	//客户单笔信货核发申请流程												
	a = SapApprovalEnum.CREDITAUDITING;
	//技术支持流程													
	a = SapApprovalEnum.TECHNICALSUPPORT;
	//管道样品申请流程														
	a = SapApprovalEnum.PIPELINESAMPLE;
	//客戶信用贷款主数据申请流程															
	a = SapApprovalEnum.CREDITLOAN ;
	//报价申请流程																
	a = SapApprovalEnum.QUOTEAPPLICATION ;
	//订餐申请流程																	
	a = SapApprovalEnum.BOOKDINNER ;
	//运货车辆申请流程
	a = SapApprovalEnum.FREIGHT_VEHICLES ;
	//供应商索赔流程																		
	a = SapApprovalEnum.VENDORCLAIM ;
	//班次变更申请流程																			
	a = SapApprovalEnum.SHIFTCHANGE;
	//盘盈亏申请流程																				
	a = SapApprovalEnum.INVENTORYAPPLICATION;
	//SAP生产工单取消TECO申请流程																					
	a = SapApprovalEnum.CANCELTECO;
	//报废申请流程																						
	a = SapApprovalEnum.SCRAPAPPLICATION;
	//PM通知流程																							
	a = SapApprovalEnum.PM_NOTICE ;
	//盘盈盘亏流程																								
	a = SapApprovalEnum.INVENTORYPROCESS;
	//MR模具申请流程																									
	a = SapApprovalEnum.MR_SAMPLE;
	//库存调拨申请流程																										
	a = SapApprovalEnum.STOCKALLOCATION;
	//成本要素主数据维护流程																											
	a = SapApprovalEnum.PRIMECOST;
	//资产转移报废停用申请流程																												
	a = SapApprovalEnum.ASSETSTRANSFER;
	//资产清理出售流程																													
	a = SapApprovalEnum.ASSETLIQUIDATIONSALE;
	//资产出售流程																														
	a = SapApprovalEnum.ASSETSALE;
	//组织架构变更调整流程																															
	a = SapApprovalEnum.ORGANIZATIONALCHANGE;
	//员工试用期转正管理流程																																
	a = SapApprovalEnum.PERIODOFPROBATION;
	//排班管理流程																																	
	a = SapApprovalEnum.CREWSCHEDULING;
	//HR人力补充申请流程																																		
	a = SapApprovalEnum.HR_MANPOWERSUPPLEMENT;
	//教育训练申请流程																																			
	a = SapApprovalEnum.TRAINING;
	//来宾接待流程																																				
	a = SapApprovalEnum.VISITORHOSTS;
	//IRS資訊需求服務流程																																					
	a = SapApprovalEnum.IRS_INFORMATIONSERVICE;
	//内控不符合项流程																																						
	a = SapApprovalEnum.INTERNALLYPILOTING;
	//部门预算金额变更申请流程																																							
	a = SapApprovalEnum.BUDGETCHANGE;
	//QTW客诉流程																																								
	a = SapApprovalEnum.QTW_CUSTOMERCOMPLAINT;
	//呆滞物料转用工作流程																																									
	a = SapApprovalEnum.INACTIVEMATERIALTRANSFER;
	//SAP专案代号申请流程																																										
	a = SapApprovalEnum.SAP_PROJECTCODE;
	//SEV1供应商定期评核流程																																											
	a = SapApprovalEnum.SEV1_VENDORPERIODICASSESSMENT;
	//SEV2供应商评鉴流程																																												
	a = SapApprovalEnum.SEV2_VENDOREVALUATION;
	//EXP费用申请流程																																													
	a = SapApprovalEnum.EXP_APPLICATIONFEE;
	//內部連絡單																																												
	a = SapApprovalEnum.INTERNALMEMO;
	//售后服务简化流程
	a = SapApprovalEnum.POSTSALESERVICE;
	//计量器具申请流程
	a = SapApprovalEnum.MEASURINGINSTREQUEST;
	//用印流程
	a = SapApprovalEnum.SIGNETUSE;
	//HR人力补充申请流程流程
	a = SapApprovalEnum.MANPOWERREPLENISHMENT;
	//加班管理流程
	a = SapApprovalEnum.OVERTIMEMANAGER;
	//PM通知单
	a = SapApprovalEnum.PMTICKET;
	//退货申请流程
	a = SapApprovalEnum.SALESRETURN;
	//盘盈盘亏申请流程
	a = SapApprovalEnum.INVENTORYKINGLAI;  
	//销售定价业务流程 
	a = SapApprovalEnum.SALESPRICE;  
	//MR模具申请流程
	a = SapApprovalEnum.MRDIEREQUEST;
	//教育訓練申請流程
	a = SapApprovalEnum.EDUCATIONTRAININGREQUEST;  
    }
}