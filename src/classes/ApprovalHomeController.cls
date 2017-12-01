public with sharing class ApprovalHomeController
{
    public String selectedApprovalValue {GET; SET;}
    public String selectedApprovalName {GET; SET;}
    public List<SelectOption> approvalNames {GET; SET;}
    public Metadata__c meta {GET; SET;}
    //流程数据保存在Approval_Managed__c表中
    public List<Approval_Managed__c> lstApproval {GET; SET;}
    //流程数据保存在Custom_Approval_Managed__c表中
    public List<Custom_Approval_Managed__c> lstCustomApproval {GET; SET;}
    //流程数据保存在Approval_Managed1__c表中
    public List<Approval_Managed1__c> am1Approval {GET; SET;}
    //流程数据保存在Approval_Managed2__c表中
    public List<Approval_Managed2__c> am2Approval {GET; SET;}
    //当前流程记录总数
    public Integer totalCount {GET; SET;}
    //每页显示记录条数
    public Integer pageSize {GET; SET;}
    //当前页
    public Integer pageCurr {GET; SET;}
    //总页数
    public Integer pageCount {GET; SET;}

    //流程分类(每个流程在哪个对象中保存)
    //Approval_Managed__c
    Set<String> approval_Standard = new Set<String>();
    //Custom_Approval_Managed__c
    Set<String> approval_Custom = new Set<String>();
    //Approval_Managed1__c
    Set<String> am1 = new Set<String>();
    //Approval_Managed2__c
    Set<String> am2 = new Set<String>();
    //可以在Salesforce中创建的流程
    Set<String> canCreateApproval = new Set<String>();
    public ApprovalHomeController()
    {
        totalCount = 0;
        pageCurr = 1;
        pageCount = 1;
        System_Setting__c ssc = System_Setting__c.getValues('Setting');
        pageSize  = Integer.valueOf(ssc.PageSize__c);

        meta = new Metadata__c();
        //可以在Salesforce中创建的流程 counts = 9
        canCreateApproval.add(SapApprovalEnum.ADVANCECHARGE); //预付款申请流程
        canCreateApproval.add(SapApprovalEnum.COSTCENTERSEND); //成本中心发料作业流程
        canCreateApproval.add(SapApprovalEnum.STAFFTRANSFER); //员工异动管理流程
        canCreateApproval.add(SapApprovalEnum.CUSTOMER); //客户主数据维护流程
        canCreateApproval.add(SapApprovalEnum.VENDOR); //供应商主数据维护流程
        canCreateApproval.add(SapApprovalEnum.ASSETPURCHASE); //资产购置流程
        canCreateApproval.add(SapApprovalEnum.STAFFLEAVEOFFICE); //员工主动离职流程
        canCreateApproval.add(SapApprovalEnum.WASTEDISPOSE); //废料处理流程
        canCreateApproval.add(SapApprovalEnum.RFQ); //RFQ作业流程
        canCreateApproval.add(SapApprovalEnum.VISITORHOSTS);//来宾接待流程
        canCreateApproval.add(SapApprovalEnum.IRS_INFORMATIONSERVICE);//IT服务申请流程
        canCreateApproval.add(SapApprovalEnum.INTERNALMEMO);//內部联络申请流程
        canCreateApproval.add(SapApprovalEnum.EXPENSEREIMBURSE);//费用报销
        canCreateApproval.add(SapApprovalEnum.BUSINESSTRAVEL);//员工出差管理流程
        canCreateApproval.add(SapApprovalEnum.INVENTORYPROCESS);//盤盈虧申請單
        canCreateApproval.add(SapApprovalEnum.CANCELTECO);//解除TECO
        canCreateApproval.add(SapApprovalEnum.SEV2_VENDOREVALUATION);//SEV2供應商評鑑表
        canCreateApproval.add(SapApprovalEnum.EXP_APPLICATIONFEE);//EXP費用申請單
        canCreateApproval.add(SapApprovalEnum.CREDITAUDITING);//客户单笔信货核发申请流程
        canCreateApproval.add(SapApprovalEnum.CREDITLOAN);//客户信用货款申请流程
        canCreateApproval.add(SapApprovalEnum.LEAVE);//请假管理流程
        canCreateApproval.add(SapApprovalEnum.BOOKDINNER);//订餐&派车申请流程
        canCreateApproval.add(SapApprovalEnum.POSTSALESERVICE);//售后服务简化流程
        canCreateApproval.add(SapApprovalEnum.FREIGHT_VEHICLES);//运货车辆申请流程
        canCreateApproval.add(SapApprovalEnum.MEASURINGINSTREQUEST);//计量器具请购申请流程
        canCreateApproval.add(SapApprovalEnum.SIGNETUSE);//用章流程
        canCreateApproval.add(SapApprovalEnum.MANPOWERREPLENISHMENT);//HR人力补充申请流程
        canCreateApproval.add(SapApprovalEnum.OVERTIMEMANAGER);//加班管理流程
        canCreateApproval.add(SapApprovalEnum.PMTICKET);//PM通知单
        canCreateApproval.add(SapApprovalEnum.INVENTORYKINGLAI);//盘盈盘亏申请流程
        canCreateApproval.add(SapApprovalEnum.SALESPRICE);//销售定价业务流程
        canCreateApproval.add(SapApprovalEnum.MRDIEREQUEST);//MR模具申请流程
        canCreateApproval.add(SapApprovalEnum.EDUCATIONTRAININGREQUEST);//教育訓練申請流程
        canCreateApproval.add(SapApprovalEnum.CUSTOMERCREDITLOAN);//客户信用贷款主数据申请



        //Object = Custom_Approval_Managed__c, approval counts = 16
        approval_Custom = Utils.getCAMApprovalName();
        //Object = Approval_Managed__c, approval counts = 16
        approval_Standard = Utils.getAMApprovalName();
        //Object = Approval_Managed1__c, approval counts = 16
        am1 = Utils.getAM1ApprovalName();
        //Object = Approval_Managed2__c, approval counts = 15
        am2 = Utils.getAM2ApprovalName();
    }
    public PageReference UpdateApprovalData()
    {
        if(String.isBlank(selectedApprovalValue))
        {
            return null;
        }
        String sql = '';
        Integer offset = 0;
        //Approval_Managed__c
        if(approval_Standard.contains(selectedApprovalValue))
        {
            totalCount = [SELECT COUNT() FROM Approval_Managed__c WHERE RecordType.DeveloperName = :selectedApprovalValue];
            pageCount = (Integer)Math.ceil((Decimal)totalCount / (Decimal)pageSize);
            offset = (pageCurr - 1 ) * pageSize;
            sql = Utils.getApprovalSQL(selectedApprovalValue, true);
            if(String.isBlank(sql))
            {
                addPageMessage('【' + selectedApprovalName + '/' + selectedApprovalValue + '】没有设置查询SQL');
            }
            else
            {
                sql += ' WHERE RecordType.DeveloperName=\'' + selectedApprovalValue + '\' ORDER BY Name DESC LIMIT ' + pageSize + ' OFFSET ' + offset;
                lstApproval = Database.query(sql);
            }
        }//Custom_Approval_Managed__c
        else if(approval_Custom.contains(selectedApprovalValue))
        {
            totalCount = [SELECT COUNT() FROM Custom_Approval_Managed__c WHERE RecordType.DeveloperName = :selectedApprovalValue];
            pageCount = (Integer)Math.ceil((Decimal)totalCount / (Decimal)pageSize);
            offset = (pageCurr - 1 ) * pageSize;
            sql = Utils.getApprovalSQL(selectedApprovalValue, true);
            if(String.isBlank(sql))
            {
                addPageMessage('【' + selectedApprovalName + '/' + selectedApprovalValue + '】没有设置查询SQL');
            }
            else
            {
                sql += ' WHERE RecordType.DeveloperName=\'' + selectedApprovalValue + '\' ORDER BY Name DESC LIMIT ' + pageSize + ' OFFSET ' + offset;
                lstCustomApproval = Database.query(sql);
            }
        }//Approval_Managed1__c
        else if(am1.contains(selectedApprovalValue))
        {
            totalCount = [SELECT COUNT() FROM Approval_Managed1__c WHERE RecordType.DeveloperName = :selectedApprovalValue];
            pageCount = (Integer)Math.ceil((Decimal)totalCount / (Decimal)pageSize);
            offset = (pageCurr - 1 ) * pageSize;
            sql = Utils.getApprovalSQL(selectedApprovalValue, true);
            if(String.isBlank(sql))
            {
                addPageMessage('【' + selectedApprovalName + '/' + selectedApprovalValue + '】没有设置查询SQL');
            }
            else
            {
                sql += ' WHERE RecordType.DeveloperName=\'' + selectedApprovalValue + '\' ORDER BY Name DESC LIMIT ' + pageSize + ' OFFSET ' + offset;
                am1Approval = Database.query(sql);
            }
        }//Approval_Managed2__c
        else if(am2.contains(selectedApprovalValue))
        {
            totalCount = [SELECT COUNT() FROM Approval_Managed2__c WHERE RecordType.DeveloperName = :selectedApprovalValue];
            pageCount = (Integer)Math.ceil((Decimal)totalCount / (Decimal)pageSize);
            offset = (pageCurr - 1 ) * pageSize;
            sql = Utils.getApprovalSQL(selectedApprovalValue, true);
            if(String.isBlank(sql))
            {
                addPageMessage('【' + selectedApprovalName + '/' + selectedApprovalValue + '】没有设置查询SQL');
            }
            else
            {
                sql += ' WHERE RecordType.DeveloperName=\'' + selectedApprovalValue + '\' ORDER BY Name DESC LIMIT ' + pageSize + ' OFFSET ' + offset;
                am2Approval = Database.query(sql);
            }
        }
        System.debug('*** 查询SQL:' + sql);
        return null;
    }
    public PageReference NextPage()
    {
        if(pageCurr < pageCount)
        {
            pageCurr = pageCurr + 1;
        }
        return UpdateApprovalData();
    }
    public PageReference PrevPage()
    {
        if(pageCurr > 1)
        {
            pageCurr = pageCurr - 1;
        }
        return UpdateApprovalData();
    }
    public PageReference GotoPage()
    {
        if(pageCurr > pageCount)
        {
            pageCurr = pageCount;
        }
        else if(pageCurr < 1)
        {
            pageCurr = 1;
        }
        return UpdateApprovalData();
    }

    public PageReference CreateNewApproval()
    {
        String pageName = '';
        if(canCreateApproval.contains(selectedApprovalValue))
        {
            if(selectedApprovalValue == SapApprovalEnum.CUSTOMER)
            {
                //客户主数据维护流程
                pageName = '/apex/AMCustomer';
            }
            else if(selectedApprovalValue == SapApprovalEnum.VENDOR)
            {
                //供应商主数据维护流程
                pageName = '/apex/AMVendor';
            }
            else if(selectedApprovalValue == SapApprovalEnum.COSTCENTERSEND)
            {
                //成本中心发料作业流程
                pageName = '/apex/AMCostCenterSend';
            }
            else if(selectedApprovalValue == SapApprovalEnum.WASTEDISPOSE)
            {
                //废料处理流程
                pageName = '/apex/AMWasteDispose';
            }
            else if(selectedApprovalValue == SapApprovalEnum.STAFFTRANSFER)
            {
                //员工异动管理流程(自定义页面)
                // String prefix = SobjectType.Approval_Managed__c.getKeyPrefix();
                // String rId = HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.STAFFTRANSFER, 'Approval_Managed__c');
                // pageName = '/' + prefix + '/e?RecordType=' + rid ;
                pageName = '/apex/AMStaffTransfer';

            }
            else if(selectedApprovalValue == SapApprovalEnum.STAFFLEAVEOFFICE)
            {
                //员工主动离职流程
                pageName = '/apex/AMStaffLeaveOffice';
            }
            else if(selectedApprovalValue == SapApprovalEnum.ASSETPURCHASE)
            {
                //资产购置流程(使用标准页面)
                String prefix = SobjectType.Approval_Managed__c.getKeyPrefix();
                String rId = HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.ASSETPURCHASE, 'Approval_Managed__c');
                pageName = '/' + prefix + '/e?RecordType=' + rid ;//'/apex/AMStaffTransfer';
            }
            else if(selectedApprovalValue == SapApprovalEnum.ADVANCECHARGE)
            {
                //预付款申请流程
                pageName = '/apex/AMAdvanceCharge';
            }
            else if(selectedApprovalValue == SapApprovalEnum.POSTSALESERVICE)
            {
                //售后服务简化流程(使用标准页面)
                String prefix = SobjectType.Approval_Managed1__c.getKeyPrefix();
                String rId = HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.POSTSALESERVICE, 'Approval_Managed1__c');
                pageName = '/' + prefix + '/e?RecordType=' + rid ;//'/apex/AMStaffTransfer';
            }
            else if(selectedApprovalValue == SapApprovalEnum.RFQ)
            {
                //RFQ作业流程
                pageName = '/apex/AMRFQ';
            }
            else if(selectedApprovalValue == SapApprovalEnum.VISITORHOSTS)
            {
                //來賓接待申請流程
                pageName = '/apex/AMVisitorHosts';
            }
            else if(selectedApprovalValue == SapApprovalEnum.BOOKDINNER)
            {
                //订餐&派车申请流程
                pageName = '/apex/AMBookDinner';
            }
            else if(selectedApprovalValue == SapApprovalEnum.IRS_INFORMATIONSERVICE)
            {
                //IT服务申请流程
                pageName = '/apex/AMITServiceRequest';
            }
            else if(selectedApprovalValue == SapApprovalEnum.MEASURINGINSTREQUEST)
            {
                //计量器具申请流程
                pageName = '/apex/AMMeasuringInstRequest';
            }
            else if(selectedApprovalValue == SapApprovalEnum.MRDIEREQUEST)
            {
                //MR模具申请流程
                pageName = '/apex/AMDieRequest';
            }
            else if(selectedApprovalValue == SapApprovalEnum.SIGNETUSE)
            {
                //用印流程
                pageName = '/apex/AMSignetUse';
            }
            else if(selectedApprovalValue == SapApprovalEnum.MANPOWERREPLENISHMENT)
            {
                //HR人力补充申请流程
                pageName = '/apex/AMManpowerReplenishment';
            }
            else if(selectedApprovalValue == SapApprovalEnum.OVERTIMEMANAGER)
            {
                //加班管理流程
                pageName = '/apex/AMOvertimeManager';
            }
            else if(selectedApprovalValue == SapApprovalEnum.PMTICKET)
            {
                //PM通知单
                pageName = '/apex/AMPMTicket';
            }
            else if(selectedApprovalValue == SapApprovalEnum.INVENTORYKINGLAI)
            {
                //盘盈盘亏申请流程
                pageName = '/apex/AMInventoryKinglai';
            }
            else if(selectedApprovalValue == SapApprovalEnum.SALESPRICE)
            {
                //销售定价业务流程
                pageName = '/apex/AMSalesPricing';
            }
            else if(selectedApprovalValue == SapApprovalEnum.SALESPRICE){
                //客户信用贷款主数据申请
                pageName = '/apex/AMCustomerCreditLoan';
            }
            else if(selectedApprovalValue == SapApprovalEnum.FREIGHT_VEHICLES)
            {
                //运货车辆申请流程(使用标准页面)
                String prefix = SobjectType.Approval_Managed1__c.getKeyPrefix();
                String rId = HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.FREIGHT_VEHICLES, 'Approval_Managed1__c');
                pageName = '/' + prefix + '/e?RecordType=' + rid ;//'/apex/AMStaffTransfer';
            }
            else if(selectedApprovalValue == SapApprovalEnum.INTERNALMEMO)
            {
                //內部联络申请流程

                //    String prefix = SobjectType.Approval_Managed1__c.getKeyPrefix();
                //  String rId = HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.INTERNALMEMO, 'Approval_Managed1__c');
                //  pageName = '/' + prefix + '/e?RecordType=' + rid ;

                pageName = '/apex/AMInternalmemo';
            }
            else if(selectedApprovalValue == SapApprovalEnum.CANCELTECO)
            {
                //解除TECO
                pageName = '/apex/AMCancelTECO';
            }
            else if(selectedApprovalValue == SapApprovalEnum.INVENTORYPROCESS)
            {
                //盤盈虧申請單
                pageName = '/apex/AMInventoryProcess';
            }
            else if (selectedApprovalValue == SapApprovalEnum.SEV2_VENDOREVALUATION)
            {
                //SEV2供應商評鑑表
                pageName = '/apex/AMSEV2_VendorEvaluation';
            }
            else if (selectedApprovalValue == SapApprovalEnum.EXP_APPLICATIONFEE)
            {
                //EXP費用申請單
                pageName = '/apex/AMEXP_ApplicationFee';
            }
            else if (selectedApprovalValue == SapApprovalEnum.CREDITLOAN)
            {
                //客戶信用贷款主数据申请流程
                pageName = '/apex/AMCREDITLOAN';
            }
            else if (selectedApprovalValue == SapApprovalEnum.CUSTOMERCREDITLOAN)
            {
                //客户单笔信货核发申请流程
                pageName = '/apex/AMCustomerCreditLoan';
            }
            else if(selectedApprovalValue == SapApprovalEnum.EXPENSEREIMBURSE)
            {
                //费用报销
                if(canCreateExpenseReimburse())
                {
                    pageName = '/apex/AMExpenseReimburse';
                }
                else
                {
                    return null;
                }
            }
            else if(selectedApprovalValue == SapApprovalEnum.LEAVE)
            {
                //请假管理流程
                pageName = '/apex/AMLeave';
            }
            else if(selectedApprovalValue == SapApprovalEnum.BUSINESSTRAVEL)
            {
                //员工出差管理
                if(canCreateBusinessTravel())
                {
                    pageName = '/apex/AMBusinessTravel';
                }
                else
                {
                    return null;
                }
            }
            else if(selectedApprovalValue == SapApprovalEnum.EDUCATIONTRAININGREQUEST)
            {
                //教育訓練申請單

                pageName = '/apex/AMEducationTraining';

            }
            else
            {
                //页码维护中
                pageName = '/apex/AMPageMaintain';
            }
            PageReference pr = new PageReference(pageName);
            pr.setRedirect(true);
            return pr;
        }
        else
        {
            addPageMessage('不能从Salesforce创建此类流程！');
            return null;
        }
    }
    private Boolean canCreateExpenseReimburse()
    {
        return true;
    }
    private Boolean canCreateBusinessTravel()
    {
        System_Setting__c ssc = System_Setting__c.getValues('Setting');
        String corpCode = ssc.Can_Create_BusinessTravel__c;
        String uId = UserInfo.getUserId();
        User u = [SELECT Id, CompanyName FROM User WHERE Id = : uId];
        if(String.isBlank(corpCode))
        {
            addPageMessage('未设置创建出差申请单公司，请先在自定义设置中设置！');
            return false;
        }
        if(String.isBlank(u.CompanyName))
        {
            addPageMessage('用户公司未设置！');
            return false;
        }
        if(corpCode.contains(u.CompanyName))
        {
            return true;
        }
        else
        {
            addPageMessage('非[' + corpCode + ']员工，不能创建！');
            return false;
        }
    }
    private void addPageMessage(String message)
    {
        ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.INFO, message));
    }
}