public with sharing class ApprovalQueryExtension {
    public String selectedModelGroupValue {GET; SET;}
    public String selectedApprovalValue {GET; SET;}
    public String selectedApprovalName {GET; SET;}
    public String selectedStatusValue {GET; SET;}
    public String selectApprover {GET; SET;}
    public String selectAprrovalDate {GET; SET;}

    //流程分类(每个流程在哪个对象中保存)
    //Approval_Managed__c
    Set<String> approval_Standard = new Set<String>();
    //Custom_Approval_Managed__c
    Set<String> approval_Custom = new Set<String>();
    //Approval_Managed1__c
    Set<String> am1 = new Set<String>();
    //Approval_Managed2__c
    Set<String> am2 = new Set<String>();

    public ApprovalQueryExtension() {
        //Object = Custom_Approval_Managed__c, approval counts = 16
        approval_Custom.add(SapApprovalEnum.CUSTOMER);//客户主数据维护流程
        approval_Custom.add(SapApprovalEnum.VENDOR);//供应商主数据维护流程
        approval_Custom.add(SapApprovalEnum.BUSINESSTRAVEL);//出差管理流程
        approval_Custom.add(SapApprovalEnum.SALEORDER);//销售订单审批流程
        approval_Custom.add(SapApprovalEnum.COSTCENTERSEND);//成本中心发料作业流程
        approval_Custom.add(SapApprovalEnum.WASTEDISPOSE);//废料处理流程
        approval_Custom.add(SapApprovalEnum.PURCHASEINFORMATION);//采购信息记录维护流程
        approval_Custom.add(SapApprovalEnum.RFQ);//RFQ作业流程
        approval_Custom.add(SapApprovalEnum.SALESAPPLICATION);//标准销售申请流程
        approval_Custom.add(SapApprovalEnum.OVERTIMEWORK);//加班管理流程
        approval_Custom.add(SapApprovalEnum.MODIFYPAY);//员工调薪管理流程
        approval_Custom.add(SapApprovalEnum.INTERNALCONTACT);//内部联络单流程
        approval_Custom.add(SapApprovalEnum.HR_MANPOWERSUPPLEMENT);//HR人力补充申请流程
        approval_Custom.add(SapApprovalEnum.PERIODOFPROBATION);//员工试用期转正管理流程
        approval_Custom.add(SapApprovalEnum.CUSTOMERDISPATCH);//客户派车申请流程
        approval_Custom.add(SapApprovalEnum.SALESPRICING);//销售定价业务流程

        //Object = Approval_Managed__c, approval counts = 16
        approval_Standard.add(SapApprovalEnum.STAFFTRANSFER); //员工异动管理流程
        approval_Standard.add(SapApprovalEnum.STAFFLEAVEOFFICE);//员工主动离职流程
        approval_Standard.add(SapApprovalEnum.ABNORMALQUALITY);//品质异常单流程
        approval_Standard.add(SapApprovalEnum.PURCHASEORDER);//标准采购订单作业流程
        approval_Standard.add(SapApprovalEnum.EXPENSEREIMBURSE);//费用报销流程
        approval_Standard.add(SapApprovalEnum.ASSETPURCHASE);//资产购置流程
        approval_Standard.add(SapApprovalEnum.ADVANCECHARGE);//预付款申请流程
        approval_Standard.add(SapApprovalEnum.PURCHASEAPPLICATION);//采购申请作业流程
        approval_Standard.add(SapApprovalEnum.IT_SERVICEAPPLICATION);//IT服务申请流程
        approval_Standard.add(SapApprovalEnum.ABNORMALATTENCE);//考勤异常处理申请流程
        approval_Standard.add(SapApprovalEnum.LEAVE);//请假管理流程
        approval_Standard.add(SapApprovalEnum.ASSETSTRANSFER);//资产转移报废停用申请流程
        approval_Standard.add(SapApprovalEnum.ASSETLIQUIDATIONSALE);//资产清理出售流程
        approval_Standard.add(SapApprovalEnum.ASSETSALE);//资产出售流程
        approval_Standard.add(SapApprovalEnum.ORGANIZATIONALCHANGE);//组织架构变更调整流程
        approval_Standard.add(SapApprovalEnum.ENTERTAINECOST);//交际应酬费申请流程

        //Object = Approval_Managed1__c, approval counts = 16
        am1.add(SapApprovalEnum.TRAINING);//教育训练申请流程
        am1.add(SapApprovalEnum.VISITORHOSTS);//来宾接待流程
        am1.add(SapApprovalEnum.IRS_INFORMATIONSERVICE);//IRS资讯需求服务流程
        am1.add(SapApprovalEnum.INTERNALLYPILOTING);//内控不符合项流程
        am1.add(SapApprovalEnum.SEALAPPLICATION);//用印申请流程
        am1.add(SapApprovalEnum.EXPORTAPPLICATION);//出口申请流程
        am1.add(SapApprovalEnum.CREWSCHEDULING);//排班管理流程
        am1.add(SapApprovalEnum.RETURNHOME);//台干返乡探视申请流程
        am1.add(SapApprovalEnum.CREDITAUDITING);//客户单笔信货核发申请流程
        am1.add(SapApprovalEnum.TECHNICALSUPPORT);//技术支持流程
        am1.add(SapApprovalEnum.PIPELINESAMPLE);//管道样品申请流程
        am1.add(SapApprovalEnum.CREDITLOAN);//客戶信用贷款主数据申请流程
        am1.add(SapApprovalEnum.QUOTEAPPLICATION);//报价申请流程
        am1.add(SapApprovalEnum.BOOKDINNER);//订餐申请流程
        am1.add(SapApprovalEnum.VENDORCLAIM);//供应商索赔流程
        am1.add(SapApprovalEnum.SHIFTCHANGE);//班次变更申请流程
        
        //Object = Approval_Managed2__c, approval counts = 15
        am2.add(SapApprovalEnum.INVENTORYAPPLICATION);//盘盈亏申请流程
        am2.add(SapApprovalEnum.CANCELTECO);//SAP生产工单取消TECO申请流程
        am2.add(SapApprovalEnum.SCRAPAPPLICATION);//报废申请流程
        am2.add(SapApprovalEnum.PM_NOTICE);//PM通知流程
        am2.add(SapApprovalEnum.INVENTORYPROCESS);//盘盈盘亏流程
        am2.add(SapApprovalEnum.MR_SAMPLE);//MR模具申请流程
        am2.add(SapApprovalEnum.STOCKALLOCATION);//库存调拨申请流程
        am2.add(SapApprovalEnum.PRIMECOST);//成本要素主数据维护流程
        am2.add(SapApprovalEnum.BUDGETCHANGE);//部门预算金额变更申请流程
        am2.add(SapApprovalEnum.QTW_CUSTOMERCOMPLAINT);//QTW客诉流程
        am2.add(SapApprovalEnum.INACTIVEMATERIALTRANSFER);//呆滞物料转用工作流程
        am2.add(SapApprovalEnum.SAP_PROJECTCODE);//SAP专案代号申请流程
        am2.add(SapApprovalEnum.SEV1_VENDORPERIODICASSESSMENT);//SEV1供应商定期评核流程
        am2.add(SapApprovalEnum.SEV2_VENDOREVALUATION);//SEV2供应商评鉴流程
        am2.add(SapApprovalEnum.EXP_APPLICATIONFEE);//EXP费用申请流程

    }
    //内部类
    public class AllApprovalData{
        public Id Id{GET;SET;}
        public String Name{GET;SET;}
        public String Approval_Name{GET;SET;}
        public String Applicant_Id{GET;SET;}
        public String Applicant_Name{GET;SET;}
        public String Dept_Name{GET;SET;}
        public String Bill_Date{GET;SET;}
    }

    public PageReference queryApproval() {
        return null;
    }
}