/*
    目    的：主动推送数据给SAP时，生成SAP接收参数 
    作    者：刘文俊(liuwenjun@bluelinksys.com)
    创建日期：2017-04-29
    修 改 人：
    修改日期：
    修改原因：
    备    注：在把数据主动推送给SAP时，要生成的参数功能都放在这
*/
public without sharing class SapInputArgCreate {
    /*
        目  的：创建传送给SAP Web Service的Salesforce用户简档
        返回值：SapWebServiceInputArgs类实例序列化后的Json字符串：
                {
                    "approval":"profile",
                    "profiles":
                    [
                        {
                            "ID":"简档ID",
                            "Name":"简档名称"
                        },
                        {
                            "ID":"简档ID",
                            "Name":"简档名称"
                        },
                        {...}
                    ]
                }

    */
    public static String createSapProfileInputArgs(){
        List<Profile> pfs = [SELECT Id,Name FROM Profile];
        List<Map<String,String>> lstProfile = new List<Map<String,String>>();
        for(Profile pf : pfs){
            Map<String,String> row = new Map<String,String>();
            row.put('ID',pf.Id);
            row.put('Name',pf.Name);
            lstProfile.add(row);
        }
        Map<String,Object> pro = new Map<String,Object>();
        pro.put('profiles',lstProfile);
        pro.put('approval','profile');
        String strArgs = JSON.serialize(pro);
        System.debug(strArgs);
        return strArgs;
    }
    /*
        目  的：创建传送给SAP Web Service的Salesforce角色
        返回值：SapWebServiceInputArgs类实例序列化后的Json字符串：
                {
                    "approval":"role",
                    "roles":
                    [
                        {
                            "ID":"角色ID",
                            "Name":"角色名称",
                            "ParentRoleId":"上级角色ID",
                        },
                        {
                            "ID":"角色ID",
                            "Name":"角色名称",
                            "ParentRoleId":"上级角色ID",
                        },
                        {...}
                    ]
                }

    */
    public static String createSapRoleInputArgs(){
        List<UserRole> roles = [SELECT Id,Name,ParentRoleId FROM UserRole];
        List<Map<String,String>> lstRole = new List<Map<String,String>>();
        for(UserRole pf : roles){
            Map<String,String> row = new Map<String,String>();
            row.put('ID',pf.Id);
            row.put('Name',pf.Name);
            row.put('ParentRoleId',pf.ParentRoleId);
            lstRole.add(row);
        }
        Map<String,Object> pro = new Map<String,Object>();
        pro.put('roles',lstRole);
        pro.put('approval','role');
        String strArgs = JSON.serialize(pro);
        System.debug(strArgs);
        return strArgs;
    }
    //创建传送给SAP Web Service的客户主数据参数
    public static String createSapCustomerInputArgs(String customerId){
        String sql = Utils.getApprovalSQL(SapApprovalEnum.CUSTOMER,true);
        sql = sql + ' WHERE Id = \'' + customerId + '\'';
        List<Custom_Approval_Managed__c> lstItems = Database.query(sql);
        if(lstItems.size() > 0){
            return createSapCustomerInputArgs(lstItems.get(0));
        }else{
            return '';
        }
    } 
    //创建传送给SAP Web Service的客户主数据参数
    public static String createSapCustomerInputArgs(Custom_Approval_Managed__c customer){
        List<Custom_Approval_Managed_Item__c> banks = 
            [SELECT Id,SAPID__c,Customer_Bank__c,Country__c,Country_Code__c,Country_Name__c,Bank_of_Code__c,
                    Account_Name__c,Name_of_Bank__c,IBANValue__c,SWIFT_Code__c,Account_of_Bank__c,Validate_Date__c 
            FROM Custom_Approval_Managed_Item__c 
            WHERE Customer_Bank__c = :customer.Id];
        List<Custom_Approval_Managed_Item__c> taxes = 
            [SELECT Id,SAPID__c,Customer_Tax__c,Country__c,Country_Code__c,Country_Name__c,Category_of_Tax__c,Type_of_Tax__c 
            FROM Custom_Approval_Managed_Item__c  
            WHERE Customer_Tax__c = :customer.Id];
        List<Contact> contacts = 
            [SELECT Id,SAPID__c,Customer_Contact__c,LastName,Phone,Extension_Number__c,Department,Department__c,
                    MobilePhone,Fax,Extension_Number_Fax__c,Email 
            FROM Contact 
            WHERE Customer_Contact__c = :customer.Id];
        List<Contact> partners = 
            [SELECT Id,SAPID__c,Customer_Partner__c,PF__c,Number_Partner__c,LastName,Description_of_Partner__c 
            FROM Contact 
            WHERE Customer_Partner__c = :customer.Id];

        return createSapCustomerInputArgs(customer,banks,partners,contacts,taxes);
    }
    /*
        目  的：创建传送给SAP Web Service的客户主数据参数
        参  数：customer - 客户主数据
        参  数：banks - 客户银行细目
        参  数：partners - 客户合伙人功能
        参  数：contacts - 客户联系人
        参  数：taxes - 客户税收类别
        返回值：SapWebServiceInputArgs类实例序列化后的Json字符串：
                {
                    "operate":"INSERT", //UPDATE
                    "approval":"Customer", 
                    "content":
                    {
                        "main":
                        {
                            "Id":"SFID",
                            "SAPID__c":"SAP主键值(Key)",
                            "Name":"审批流程编号",
                            "Dept_Name__c":"申请人部门",
                            "Approval_Name__c":"流程名称",
                            "Status__c":"单据状态",
                            "Applicant__c":"申请人",
                            "Applicant_Code__c":"申请人工号",
                            "Applicant_Name__c":"申请人姓名",
                            "Bill_Date__c":"单据日期",
                            "Corporation__c":"公司",
                            "Purchase_Org__c":"销售组织",
                            "Distribution_Channel__c":"分销管道",
                            "Product_Group__c":"产品组",
                            "Subject_Group__c":"科目组",
                            "Account_Name__c":"客户名称",
                            "Account_Number__c":"客户代码",
                            "Name_Additional__c":"名称补充",
                            "Title__c":"标题",
                            "Retrieve_Item1__c":"检索项",
                            "Retrieve_Item2__c":"检索项2",
                            "Province__c":"公司地址(省)",
                            "Province__c":"公司地址(省代码)",
                            "Province__c":"公司地址(省名称)",
                            "City__c":"公司地址(市)",
                            "City_Code__c":"公司地址(市代码)",
                            "City_Name__c":"公司地址(市名称)",
                            "Corp_Address__c":"公司地址",
                            "Province_of_Shopping__c":"送货地址1(省)",
                            "Province_Code_of_Shopping__c":"送货地址1(省代码)",
                            "Province_Name_of_Shopping__c":"送货地址1(省名称)",
                            "City_of_Shopping__c":"送货地址1(市)",
                            "City_Code_of_Shopping__c":"送货地址1(市代码)",
                            "City_Name_of_Shopping__c":"送货地址1(市名称)",
                            "Shopping_Address1__c":"  送货地址1",
                            "Shopping_Address2__c":"  送货地址2",
                            "Billing_Address1__c":"发票地址1",
                            "Billing_Address2__c":"发票地址2",
                            "Reserved_Street__c":"街道",
                            "House_Number__c":"门牌号",
                            "Postcode__c":"邮政编码",
                            "Area__c":"地区",
                            "Area_Code__c":"地区(代码)",
                            "Area_Name__c":"地区(名称)",
                            "Country__c":"国家",
                            "Country_Code__c":"国家(代码)",
                            "Country_Name__c":"国家(名称)",
                            "Language__c":"语言",
                            "Sales_Area__c":"销售地区",
                            "Sales_Dept__c":"销售部门",
                            "Sales_Group__c":"销售组",
                            "Customer_Group__c":"客户组",
                            "Currency__c":"币种",
                            "Price_Group__c":"价格组",
                            "Engrave_Type__c":"刻制方式",
                            "Shipping_Term__c":"装运条件",
                            "Delivery_Factory__c":"交货工厂",
                            "Term_of_Payment__c":"付款条件",
                            "Tax_Number__c":"税号",
                            "Control_Subject__c":"统驭科目",
                            "Delivery_Priority__c":"交货优先权",
                            "Is_Order_Portfolio__c":"是否订单组合",
                            "International_Trade_Term__c":"国际贸易条件",
                            "Account_Allot_Group__c":"账户分配组",
                            "Sorting_Code__c":"排序码",
                            "Industry__c":"行业",
                            "Mobile_Phone__c":"移动电话",
                            "Email__c":"Email",
                            "Phone__c":"电话",
                            "Phone_Extension_Number__c":"分机号",
                            "Fax__c":"传真",
                            "Fax_Extension_Number__c":"分机号",
                            "City_Additional__c":"城市",
                            "Remark__c":"注释",
                            "Invoice_Address1__c":"文本（发票地址）",
                            "Sales_Remark__c":"文本（销售注解）",
                            "Finance_Remark__c":"文本（财政注释）"
                        },
                        "details":
                        {
                            "banks": //银行子条目
                            [
                                {
                                    "Id":"SFID",
                                    "SAPID__c":"SAP主键值(Key)",
                                    "Customer_Bank__c":"申请单号",
                                    "Country__c":"国家",
                                    "Country_Code__c":"国家(代码)",
                                    "Country_Name__c":"国家(名称)",
                                    "Code_of_Bank__c":"银行代码",
                                    "Account_of_Bank__c":"银行账号",
                                    "Account_Name__c":"银行户主",
                                    "Name_of_Bank__c":"银行名称",
                                    "IBANValue__c":"IBANValue",
                                    "SWIFT_Code__c":"SWIFT码",
                                    "Validate_Date__c":"生效日期"
                                },
                                {...},
                                {...}
                            ],
                            "taxs": //税收子条目
                            [
                                {
                                    "Id":"SFID",
                                    "SAPID__c":"SAP主键值(Key)",
                                    "Customer_Tax__c":"申请单号",
                                    "Country__c":"国家",
                                    "Country_Code__c":"国家(代码)",
                                    "Country_Name__c":"国家(名称)",
                                    "Category_of_Tax__c":"税收类别",
                                    "Type_of_Tax__c":"税分类"
                                },
                                {...},
                                {...}
                            ],
                            "partners": //合作伙伴子条目
                            [
                                {
                                    "Id":"SFID",
                                    "SAPID__c":"SAP主键值(Key)",
                                    "Customer_Partner__c":"申请单号",
                                    "PF__c":"合伙人PF",
                                    "Functionally__c":"功能",
                                    "Number__c":"编号",
                                    "LastName":"名称",
                                    "Description_of_Partner__c":"合作伙伴描述"   
                                },
                                {...}
                            ],
                            "contacts": //联系人子条目
                            [
                                {
                                    "Id":"SFID",
                                    "SAPID__c":"SAP主键值(Key)",
                                    "Customer_Contact__c":"申请单号",
                                    "LastName":"名称",
                                    "Phone":"电话",
                                    "Extension_Number__c":"分机号",
                                    "Department__c":"部门描述",
                                    "Department":"部门",
                                    "Functionally__c":"功能",
                                    "MobilePhone":"移动电话",
                                    "Fax":"传真",
                                    "Extension_Number_Fax__c":"分机号",
                                    "Email":"Email"
                                },
                                {...}
                            ]
                        }
                    }
                }

    */
    public static String createSapCustomerInputArgs(Custom_Approval_Managed__c customer,List<Custom_Approval_Managed_Item__c> banks,List<Contact> partners, List<Contact> contacts,List<Custom_Approval_Managed_Item__c> taxes){
        String strArgs = '';
        try{
            //客户主数据
            Map<String,String> main = Utils.convertSObjectToMap(customer);
            System.debug('*** main' + main);
            //客户银行细目
            Map<String,List<Map<String,String>>> details = new Map<String,List<Map<String,String>>>();
            //银行
            if(banks != null){
                List<Map<String,String>> lstBanks = new List<Map<String,String>>();
                for(Custom_Approval_Managed_Item__c bank : banks){
                    lstBanks.add(Utils.convertSObjectToMap(bank));
                }
                details.put('banks', lstBanks);
            }
            //客户合伙人功能
            if(partners != null){
                List<Map<String,String>> lstPartners = new List<Map<String,String>>();
                for(Contact partner : partners){
                    lstPartners.add(Utils.convertSObjectToMap(partner));
                }
                details.put('partners', lstPartners);
            }
            //客户联系人
            if(contacts != null){
                List<Map<String,String>> lstContacts = new List<Map<String,String>>();
                for(Contact con : contacts){
                    lstContacts.add(Utils.convertSObjectToMap(con));
                }
                details.put('contacts', lstContacts);
            }
            //客户税收类别
            if(taxes != null ){
                List<Map<String,String>> lstTaxes = new List<Map<String,String>>();
                for(Custom_Approval_Managed_Item__c tax : taxes){
                    lstTaxes.add(Utils.convertSObjectToMap(tax));
                }
                details.put('taxes', lstTaxes);
            }

            String operate = (customer.Status__c == '新建' ? SapOperateEnum.INSERTED : SapOperateEnum.UPDATED);
            strArgs = Utils.serializeToJson(operate,SapApprovalEnum.CUSTOMER,main,details);
        }catch(Exception ex){
            System.debug('*** 生成客户主数据推送参数错误：' + ex.getMessage() + '\n' + ex.getStackTraceString());
        }
        return strArgs;
    }
    //创建传送给SAP Web Service的费用报销参数
    public static String createSapExpenseReimburseInputArgs(String expenseReimburseId){
        String sql = Utils.getApprovalSQL(SapApprovalEnum.EXPENSEREIMBURSE,true);
        sql = sql + ' WHERE Id = \'' + expenseReimburseId + '\'';
        List<Approval_Managed__c> lstItems = Database.query(sql);

        if(lstItems.size() > 0){
            return createSapExpenseReimburseInputArgs(lstItems.get(0));
        }else{
            return '';
        }
    }
    //创建传送给SAP Web Service的费用报销参数
    public static String createSapExpenseReimburseInputArgs(Approval_Managed__c expenseReimburse){
        List<Approval_Managed_Item__c> items = 
            [SELECT Id,SAPID__c,Purchase_Info_Inquiry__c,Row_Index__c,Ledger_Account__c,Type_of_Cost__c,
                    Quantity__c,Price__c,Amount__c,Dept_of_CostCenter__c,Remark__c,TaskID__c 
            FROM Approval_Managed_Item__c 
            WHERE Purchase_Info_Inquiry__c = :expenseReimburse.Id];
        List<Approval_Managed_Item__c> vouchers = 
            [SELECT Id,SAPID__c,Voucher_Info__c,Row_Index__c,Accounting_Code__c,Subject__c,Amount__c,
                    Dept_of_CostCenter__c,Allocation__c,Text__c,Reason_Code__c,SGL__c,Type_of_Affair__c 
            FROM Approval_Managed_Item__c  
            WHERE Voucher_Info__c = :expenseReimburse.Id];

        return createSapExpenseReimburseInputArgs(expenseReimburse,items,vouchers);
    }
    /*
        目  的：创建传送给SAP Web Service的费用报销参数
        参  数：expenseReimburse - 费用报销主数据
        参  数：items - 费用报销明细项
        参  数：vouchers - 费用报销凭证行信息
        返回值：SapWebServiceInputArgs类实例序列化后的Json字符串：
                {
                    "operate":"INSERT", //UPDATE
                    "approval":"ExpenseReimburse", 
                    "content":
                    {
                        "main":
                        {
                            "Id":"SFID",
                            "SAPID__c":"SAP主键值",
                            "Name":"审批流程编号",
                            "Dept_Name__c":"申请人部门",
                            "Approval_Name__c":"流程名称",
                            "Status__c":"单据状态",
                            "Applicant__c":"申请人",
                            "Applicant_Code__c":"申请人(工号)",
                            "Applicant_Name__c":"申请人(姓名)",
                            "Bill_Date__c":"单据日期",
                            "Expense_Type_Cost__c":"报销类型",
                            "Corporation__c":"公司",
                            "Employee__c":"员工",
                            "Employee_Code__c":"员工(工号)",
                            "Employee_Name__c":"员工(姓名)",
                            "Supplier__c":"厂商",
                            "Voucher_Code__c":"凭证编号",
                            "Voucher_Date__c":"凭证日期",
                            "Posting_Date__c":"过账日期",
                            "Same_Sample__c":"参照",
                            "Voucher_HeaderText__c":"凭证抬头文本",
                            "Clearing_Description__c":"清帐说明",
                            "Dept_of_CostCenter__c":"成本中心",
                            "Posting_of_Company__c":"过账单位",
                            "Amount_of_General__c":"冲账金额",
                            "Currency__c":"币种",
                            "Amount_of_Total__c":"金额汇总",
                            "Remark_of_Explain__c":"说明",
                            "Approval_Travel__c":"出差申请",
                            "Applicant_Travel__c":"出差申请人",
                            "Target_of_Travel__c":"出差对象",
                            "Type_of_Travel__c":"出差类型",
                            "Vehicle_of_Travel__c":"交通工具",
                            "Cost_Budget__c":"费用预算",
                            "Currency_of_Budget__c":"币种",
                            "Amount_of_Borrow__c":"借支金额",
                            "Currency_of_Borrow__c":"币种",
                            "Start_Travel_Datetime__c":"出发时间",
                            "End_Travel_Datetime__c":"返回时间",
                            "Approval_Entertained__c":"交际应酬费申请",
                            "Kind_of_Cost__c 费用类型",
                            "Estimate_Cost__c":"费用预估(RMB)",
                            "Occur_Datetime__c":"发生时间",
                            "Place__c":"地点",
                            "Description_of_Travel__c":"行程",
                            "Staff_of_Both__c":"双方人员"
                        },
                        "details":
                        {
                            "items": //费用报销明细
                            [
                                {
                                    "Id":"SFID",
                                    "SAPID__c":"SAP主键值",
                                    "Purchase_Info_Inquiry__c":"申请单号",
                                    "Row_Index__c":"行号",
                                    "Ledger_Account__c":"总账科目",
                                    "Type_of_Cost__c":"费用类型",
                                    "Quantity__c":"数量",
                                    "Price__c":"单价",
                                    "Amount__c":"金额",
                                    "Dept_of_CostCenter__c":"成本中心",
                                    "Remark__c":"备注",
                                    "TaskID__c":"活动任务ID"
                                },
                                {...},
                                {...}
                            ],
                            "vouchers": //费用报销凭证行信息
                            [
                                {
                                    "Id":"SFID",
                                    "SAPID__c":"SAP主键值",
                                    "Voucher_Info__c":"申请单号",
                                    "Row_Index__c":"行号",
                                    "Accounting_Code__c":"记账码",
                                    "Subject__c":"科目",
                                    "Amount__c":"金额",
                                    "Dept_of_CostCenter__c":"成本中心",
                                    "Allocation__c":"分配",
                                    "Text__c":"文本",
                                    "Reason_Code__c":"原因代码",
                                    "SGL__c":"SGL标识",
                                    "Type_of_Affair__c":"事务类型"
                                },
                                {...},
                                {...}
                            ]
                        }
                    }
                }
    */
    public static String createSapExpenseReimburseInputArgs(Approval_Managed__c expenseReimburse,List<Approval_Managed_Item__c> items,List<Approval_Managed_Item__c> vouchers){
        String strArgs = '';
        try{
            //费用报销主数据
            Map<String,String> main = Utils.convertSObjectToMap(expenseReimburse);
            System.debug('*** main' + main);
            //明细
            Map<String,List<Map<String,String>>> details = new Map<String,List<Map<String,String>>>();
            //费用报销明细
            /*
            if(items != null){
                List<Map<String,String>> lstItems = new List<Map<String,String>>();
                for(Approval_Managed_Item__c item : items){
                    lstItems.add(Utils.convertSObjectToMap(item));
                }
                details.put('items', lstItems);
            }
            */
            //费用报销行信息明细
            if(vouchers != null){
                List<Map<String,String>> lstVouchers = new List<Map<String,String>>();
                for(Approval_Managed_Item__c voucher : vouchers){
                    lstVouchers.add(Utils.convertSObjectToMap(voucher));
                }
                details.put('vouchers', lstVouchers);
            }
            
            String operate = (expenseReimburse.Status__c == '新建' ? SapOperateEnum.INSERTED : SapOperateEnum.UPDATED);
            strArgs = Utils.serializeToJson(operate,SapApprovalEnum.EXPENSEREIMBURSE,main,details);
        }catch(Exception ex){
            System.debug('*** 生成费用报销推送参数错误：' + ex.getMessage() + '\n' + ex.getStackTraceString());
        }
        return strArgs;
    }
    //创建传送给SAP Web Service的预付款申请单参数
    public static String createSapAdvanceChargeInputArgs(String advanceChargeId){
        String sql = Utils.getApprovalSQL(SapApprovalEnum.ADVANCECHARGE,true);
        sql = sql + ' WHERE Id = \'' + advanceChargeId + '\'';
        List<Approval_Managed__c> lstItems = Database.query(sql);

        if(lstItems.size() > 0){
            return createSapAdvanceChargeInputArgs(lstItems.get(0));
        }else{
            return '';
        }
    }
    /*
        目  的：创建传送给SAP Web Service的预付款申请单参数
        参  数：advanceCharge  - 预付款申请单主数据
        返回值：SapWebServiceInputArgs类实例序列化后的Json字符串：
                {
                    "operate":"INSERT", //UPDATE
                    "approval":"AdvanceCharge", 
                    "content":
                    {
                        "main":
                        {
                            "Id":"SFID",
                            "SAPID__c":"SAP主键值",
                            "Name":"审批流程编号",
                            "Dept_Name__c":"申请人部门",
                            "Approval_Name__c":"流程名称",
                            "Status__c":"单据状态",
                            "Applicant__c":"申请人",
                            "Applicant_Code__c":"申请人(工号)",
                            "Applicant_Name__c":"申请人(姓名)",
                            "Bill_Date__c":"单据日期",
                            "Expense_Type_Prepay__c":"报销类型",
                            "Corporation__c":"公司",
                            "Applicant_Cost__c":"预付申请人",
                            "Applicant_Code_Cost__c":"预付申请人(工号)",
                            "Applicant_Name_Cost__c":"预付申请人(姓名)",
                            "Dept_PR_Approval__c":"PR申请部门",
                            "Supplier__c":"厂商",
                            "Term_of_Payment__c":"付款条件",
                            "Purchase__c":"预付订单号",
                            "Amount_of_Purchase__c":"采购订单金额",
                            "Percent_Pay__c":"付款比例",
                            "Currency__c":"请款货币",
                            "Amount_Prepay__c":"请款金额",
                            "Remark_Vendor_Prepay__c":"供应商预付清账情况",
                            "Num_Unfinished__c":"申请人预付单未完成笔数",
                            "Amount_Offset__c":"订单已销金额",
                            "Remark_of_Explain__c":"说明",
                            "Type_of_Payment__c":"付款类型",
                            "Amount_Confirm__c":"确认金额"
                        },
                        "details":
                        {
                            "items":[]
                        }
                    }
                }
    */
    public static String createSapAdvanceChargeInputArgs(Approval_Managed__c advanceCharge){
        String strArgs = '';
        try{
            //预付款主数据
            Map<String,String> main = Utils.convertSObjectToMap(advanceCharge);
            System.debug('*** main' + main);
            //明细
            Map<String,List<Map<String,String>>> details = new Map<String,List<Map<String,String>>>();
            details.put('items', new List<Map<String,String>>());
            String operate = (advanceCharge.Status__c == '新建' ? SapOperateEnum.INSERTED : SapOperateEnum.UPDATED);
            strArgs = Utils.serializeToJson(operate,SapApprovalEnum.ADVANCECHARGE,main,details);
        }catch(Exception ex){
            System.debug('*** 生成预付款推送参数错误：' + ex.getMessage() + '\n' + ex.getStackTraceString());
        }
        return strArgs;
    }
    //创建传送给SAP Web Service的员工异动管理参数
    public static String createSapStaffTransferInputArgs(String staffTransferId){
        String sql = Utils.getApprovalSQL(SapApprovalEnum.STAFFTRANSFER,true);
        sql = sql + ' WHERE Id = \'' + staffTransferId + '\'';
        List<Approval_Managed__c> lstItems = Database.query(sql);

        if(lstItems.size() > 0){
            return createSapStaffTransferInputArgs(lstItems.get(0));
        }else{
            return '';
        }
    }
    /*
        目  的：创建传送给SAP Web Service的员工异动管理参数
        参  数：staffTransfer  - 员工异动管理主数据
        返回值：SapWebServiceInputArgs类实例序列化后的Json字符串：
                {
                    "operate":"INSERT", //UPDATE
                    "approval":"StaffTransfer", 
                    "content":
                    {
                        "main":
                        {
                            "Id":"SFID",
                            "SAPID":"SAP主键值",
                            "Name":"审批流程编号",
                            "Dept_Name":"申请人部门",
                            "Approval_Name":"流程名称",
                            "Status":"单据状态",
                            "Applicant":"申请人",
                            "Applicant_Code":"申请人(工号)",
                            "Applicant_Name":"申请人(姓名)",
                            "Bill_Date":"单据日期",
                            "Employee":"员工",
                            "Employee_Code":"员工(工号)",
                            "Employee_Name":"员工(姓名)",
                            "Human_Range":"人事范围",
                            "Work_Company_Old":"原工作单位",
                            "Job_Title_Old":"原职务",
                            "Job_Title_Level_Old":"原职等职级",
                            "Staff_Group_Old":"员工组",
                            "Staff_Sub_Group":"员工子组",
                            "Work_Company_New":"异动工作单位",
                            "Job_Title_New":"异动职务",
                            "Job_Title_Level_New":"异动职等职级",
                            "Staff_Group_New":"员工组",
                            "Staff_Sub_Group_New":"员工子组",
                            "Validate_Date":"生效日期",
                            "Reason_of_Operate":"操作原因",
                            "Is_Salary_Adjust":"是否薪资调整",
                            "Remark_of_Explain":"说明",
                            "Is_Work_Transfered":"工作移交是否完成",
                            "Handover_Man1":"交接人",
                            "Handover_Man1_Code":"交接人(工号)",
                            "Supervisor1":"上级主管",
                            "Supervisor1_Code":"上级主管(工号)",
                            "Transfer_Date":"交接日期",
                            "Is_Key_Returned":"工作柜钥匙是否交还",
                            "Handover_Man2":"交接人",
                            "Handover_Man2_Code":"交接人(工号)",
                            "Supervisor2":"上级主管",
                            "Supervisor2_Code":"上级主管(工号)",
                            "Is_Good_Regurned":"所借物品是否交还",
                            "Handover_Man3":"交接人",
                            "Handover_Man3_Code":"交接人(工号)",
                            "Supervisor3":"上级主管",
                            "Supervisor3_Code":"上级主管(工号)",
                            "Is_Tools_Returned":"工具文件是否交还",
                            "Handover_Man4":"交接人",
                            "Handover_Man4_Code":"交接人(工号)",
                            "Supervisor4":"上级主管",
                            "Supervisor4_Code":"上级主管(工号)"
                        },
                        "details":
                        {
                            "items":[]
                        }
                    }
                }
    */
    public static String createSapStaffTransferInputArgs(Approval_Managed__c staffTransfer ){
        String strArgs = '';
        try{
            //预付款主数据
            Map<String,String> main = Utils.convertSObjectToMap(staffTransfer);
            System.debug('*** main' + main);
            //明细
            Map<String,List<Map<String,String>>> details = new Map<String,List<Map<String,String>>>();
            details.put('items', new List<Map<String,String>>());
            String operate = (staffTransfer.Status__c == '新建' ? SapOperateEnum.INSERTED : SapOperateEnum.UPDATED);
            strArgs = Utils.serializeToJson(operate,SapApprovalEnum.STAFFTRANSFER,main,details);
        }catch(Exception ex){
            System.debug('*** 生成员工异动推送参数错误：' + ex.getMessage() + '\n' + ex.getStackTraceString());
        }
        return strArgs;
    }
    //创建传送给SAP Web Service的资产购置申请单参数
    public static String createSapAssetPurchaseInputArgs(String assetPurchaseId){
        String sql = Utils.getApprovalSQL(SapApprovalEnum.ASSETPURCHASE,true);
        sql = sql + ' WHERE Id = \'' + assetPurchaseId + '\'';
        List<Approval_Managed__c> lstItems = Database.query(sql);
        if(lstItems.size() > 0){
            return createSapAssetPurchaseInputArgs(lstItems.get(0));
        }else{
            return '';
        }
    }
    /*
        目  的：创建传送给SAP Web Service的资产购置申请单参数
        参  数：assetPurchase  - 资产购置申请单主数据
        返回值：SapWebServiceInputArgs类实例序列化后的Json字符串：
                {
                    "operate":"INSERT", //UPDATE
                    "approval":"AssetPurchase", 
                    "content":
                    {
                        "main":
                        {
                            "Id":"SFID",
                            "SAPID__c":"SAP主键值",
                            "Name":"审批流程编号",
                            "Dept_Name__c":"申请人部门",
                            "Approval_Name__c":"流程名称",
                            "Status__c":"单据状态",
                            "Applicant__c":"申请人",
                            "Applicant_Code__c":"申请人(工号)",
                            "Applicant_Name__c":"申请人(姓名)",
                            "Bill_Date__c":"单据日期",
                            "Factory__c":"工厂",
                            "Dept_of_CostCenter__c":"成本中心",
                            "Required_date__c":"需求日期",
                            "Asset_Type__c":"资产类型",
                            "Asset_Name__c":"资产名称",
                            "Model_and_Spec__c":"型号规格 ",
                            "Asset_Code_Inner__c":"资产主编号(内文)",
                            "Asset_Code__c":"资产编号",
                            "Asset_Code_Official__c":"正式资产编号",
                            "Stock_Note__c":"库存注记",
                            "Responsible_CostCenter__c":"负责成本中心",
                            "Place__c":"地点",
                            "Amount_of_Budget__c":"预算金额",
                            "Currcency_Budget__c":"单位",
                            "Quantity__c":"数量",
                            "Amount_of_Paid__c":"预算外已支出金额",
                            "Amount_of_Forecast__c":"预计发生金额",
                            "Material_Number__c":"物料号",
                            "Work_Center__c":"工作中心",
                            "Keeper_Reserved__c":"预定保管人",
                            "Capital_Order__c":"资本投资订单",
                            "REQ_Code__c":"请购单号",
                            "Reason_of_Purchase__c":"购置原因",
                            "Result_Effect_Current_Period__c":"影响本期损益结果",
                            "Is_Budgeted__c":"是否非预算",
                            "Price_Purchase__c":"采购价格",
                            "Currency__c":"币种",
                            "Period_Delivery__c":"交货周期",
                            "Is_Ok_Factory_Burthen__c":"厂内产能是否可以负荷",
                            "Kind_of_Asset__c":"资产分类",
                            "Stock_Number__c":"存货号",
                            "License_Number__c":"执照牌号",
                            "Status_Asset__c":"资产状态",
                            "Purchase__c":"采购订单号",
                            "Vendor__c":"供应商",
                            "Model_of_Asset__c":"资产型号",
                            "Amount_Asset__c":"资产金额",
                            "Device_Number__c":"设备号"
                        },
                        "details":
                        {
                            "items":[]
                        }
                    }
                }
    */
    public static String createSapAssetPurchaseInputArgs(Approval_Managed__c assetPurchase ){
        String strArgs = '';
        try{
            //资产购置申请单主数据
            Map<String,String> main = Utils.convertSObjectToMap(assetPurchase);
            System.debug('*** main' + main);
            //明细
            Map<String,List<Map<String,String>>> details = new Map<String,List<Map<String,String>>>();
            details.put('items', new List<Map<String,String>>());
            String operate = (assetPurchase.Status__c == '新建' ? SapOperateEnum.INSERTED : SapOperateEnum.UPDATED);
            strArgs = Utils.serializeToJson(operate,SapApprovalEnum.ASSETPURCHASE,main,details);
        }catch(Exception ex){
            System.debug('*** 生成资产购置申请单推送参数错误：' + ex.getMessage() + '\n' + ex.getStackTraceString());
        }
        return strArgs;
    }
    //创建传送给SAP Web Service的品质异常单参数
    public static String createSapAbnormalQualityInputArgs(String abnormalQualityId){
        String sql = Utils.getApprovalSQL(SapApprovalEnum.ABNORMALQUALITY,true);
        sql = sql + ' WHERE Id = \'' + abnormalQualityId + '\'';
        List<Approval_Managed__c> lstItems = Database.query(sql);

        if(lstItems.size() > 0){
            return createSapAbnormalQualityInputArgs(lstItems.get(0));
        }else{
            return '';
        }
    }
    //创建传送给SAP Web Service的品质异常单参数
    public static String createSapAbnormalQualityInputArgs(Approval_Managed__c abnormalQuality){
        List<Approval_Managed_Item__c> problems = 
            [SELECT Id,SAPID__c,Abnormal_Problem__c,Row_Index__c,Project__c,Project_No__c,Code_Group__c,
                    Type_of_Bug__c,Type_Description_Bug__c,Text__c 
            FROM Approval_Managed_Item__c 
            WHERE Abnormal_Problem__c = :abnormalQuality.Id];
        List<Approval_Managed_Item__c> rectifies = new List<Approval_Managed_Item__c>();
        for (Approval_Managed_Item__c ap : problems) {
            List<Approval_Managed_Item__c> rectifieItem =[SELECT Id,SAPID__c,Abnormal_Rectify__c,Parent_Row_Index__c,Row_Index__c,Plan_Completed_Date__c,Header__c,Header_Code__c,Text_Long__c 
            FROM Approval_Managed_Item__c  
            WHERE Abnormal_Rectify__c = :ap.Id];
            rectifies.addAll(rectifieItem);
        }
        List<Approval_Managed_Item__c> containments = 
            [SELECT Id,SAPID__c,Abnormal_Containment__c,Row_Index__c,Header__c,Header_Code__c,Text_Long__c 
            FROM Approval_Managed_Item__c 
            WHERE Abnormal_Containment__c = :abnormalQuality.Id];

        return createSapAbnormalQualityInputArgs(abnormalQuality,problems,rectifies,containments);
    }
    /*
        目  的：创建传送给SAP Web Service的品质异常单参数
        参  数：abnormalQuality  - 品质异常单主数据
        参  数：problems  - 品质异常单问题列表
        参  数：rectifies  - 品质异常单纠正措施
        参  数：containments  - 品质异常单围堵措施
        返回值：SapWebServiceInputArgs类实例序列化后的Json字符串：
                {
                    "operate":"INSERT", //UPDATE
                    "approval":"AbnormalQuality", 
                    "content":
                    {
                        "main":
                        {
                            "Id":"SFID",
                            "SAPID__c":"SAP主键值",
                            "Name":"审批流程编号",
                            "Dept_Name__c":"申请人部门",
                            "Approval_Name__c":"流程名称",
                            "Status__c":"单据状态",
                            "Applicant__c":"申请人",
                            "Applicant_Code__c":"申请人(工号)",
                            "Applicant_Name__c":"申请人(姓名)",
                            "Bill_Date__c":"单据日期",
                            "Abnormal_Code__c":"异常单号",
                            "Abnormal_Type__c":"异常单类型",
                            "Account__c":"客户",
                            "Status_Abnormal__c":"异常单状态",
                            "Description__c":"描述",
                            "Dept_of_Discovery__c":"发现部门",
                            "Order__c":"订单号",
                            "Make_Man__c":"开单人",
                            "Num_Order__c":"工单总数量",
                            "Num_Unqualified__c":"不良数量",
                            "Rate_Unqualified__c":"不良率(%)",
                            "Material_Number__c":"物料号",
                            "Material_Name__c":"物料名",
                            "Material_Description__c":"物料描述",
                            "Description_of_Material__c":"物料描述",
                            "Dept_of_Duty__c":"责任部门",
                            "Manager_of_Duty__c":"责任部门主管",
                            "Person_Liable__c":"责任人",
                            "Operator_Abnormal__c":"指定作业人",
                            "Is_Withhold__c":"是否扣款",
                            "Cause_of_Analysis1__c":"根本原因分析1",
                            "Cause_of_Analysis2__c":"根本原因分析2",
                            "Cause_of_Analysis3__c":"根本原因分析3",
                            "Cause_of_Analysis4__c":"根本原因分析4",
                            "Cause_of_Analysis5__c":"根本原因分析5",
                            "Description_of_Effect__c":"确认描述",
                            "Confirmor_of_Effect__c":"确认人",
                            "Confirm_Date_of_Effect__c":"确认日期",
                            "Description_Avoid__c":"具体措施说明",
                            "Material_Dealwith__c":"需平行处理料号",
                            "Confirmor_of_Feedback__c":"确认人",
                            "Confirm_Date_of_Feedback__c":"确认日期",
                            "Rejector__c":"拒绝人",
                            "Reject_Date__c":"拒绝日期",
                            "Reject_Reason__c":"拒绝原因"
                        },
                        "details":
                        {
                            "problems":
                            [
                                {
                                    "Id":"SFID",
                                    "SAPID__c":"SAP主键值",
                                    "Abnormal_Problem__c":"异常单号",
                                    "Row_Index__c":"行号",
                                    "Project__c":"项目",
                                    "Project_No__c":"号",
                                    "Code_Group__c":"代码组",
                                    "Type_of_Bug__c":"缺陷类型",
                                    "Type_Description_Bug__c":"缺陷类型描述",
                                    "Text__c":"文本"
                                },
                                {...}
                                {...}
                            ],
                            "rectifies":
                            [
                                {
                                    "Id":"SFID",
                                    "SAPID__c":"SAP主键值",
                                    "Abnormal_Rectify__c":"异常单号",
                                    "Row_Index__c":"行号",
                                    "Plan_Completed_Date__c":"计划完成日期",
                                    "Header__c":"负责人",
                                    "Header_Code__c":"负责人(工号)",
                                    "Text__c":"文本"
                                },
                                {...}
                                {...}
                            ],
                            "containments":
                            [
                                {
                                    "Id":"SFID",
                                    "SAPID__c":"SAP主键值",
                                    "Abnormal_Containment__c":"异常单号",
                                    "Row_Index__c":"行号",
                                    "Header__c":"负责人",
                                    "Header_Code__c":"负责人(工号)",
                                    "Text__c":"文本"
                                },
                                {...}
                                {...}
                            ]
                        }
                    }
                }
    */
    public static String createSapAbnormalQualityInputArgs(Approval_Managed__c abnormalQuality,List<Approval_Managed_Item__c> problems,List<Approval_Managed_Item__c> rectifies,List<Approval_Managed_Item__c> containments){
        String strArgs = '';
        try{
            //品质异常单主数据
            Map<String,String> main = Utils.convertSObjectToMap(abnormalQuality);
            System.debug('*** main' + main);
            //明细
            Map<String,List<Map<String,String>>> details = new Map<String,List<Map<String,String>>>();
            //品质异常问题列表
            if(problems != null){
                List<Map<String,String>> lstproblems = new List<Map<String,String>>();
                for(Approval_Managed_Item__c item : problems){
                    lstproblems.add(Utils.convertSObjectToMap(item));
                }
                details.put('problems', lstproblems);
            }
            //品质异常纠正措施
            if(rectifies != null){
                List<Map<String,String>> lstrectifies = new List<Map<String,String>>();
                for(Approval_Managed_Item__c item : rectifies){
                    lstrectifies.add(Utils.convertSObjectToMap(item));
                }
                details.put('rectifies', lstrectifies);
            }
            //品质异常围堵措施
            if(containments != null){
                List<Map<String,String>> lstcontainments = new List<Map<String,String>>();
                for(Approval_Managed_Item__c item : containments){
                    lstcontainments.add(Utils.convertSObjectToMap(item));
                }
                details.put('containments', lstcontainments);
            }
            String operate = (abnormalQuality.Status__c == '新建' ? SapOperateEnum.INSERTED : SapOperateEnum.UPDATED);
            strArgs = Utils.serializeToJson(operate,SapApprovalEnum.ABNORMALQUALITY,main,details);
        }catch(Exception ex){
            System.debug('*** 生成品质异常单推送参数错误：' + ex.getMessage() + '\n' + ex.getStackTraceString());
        }
        return strArgs;
    }
    //创建传送给SAP Web Service的员工主动离职申请单参数
    public static String createSapStaffLeaveOfficeInputArgs(String staffLeaveOfficeId){
        String sql = Utils.getApprovalSQL(SapApprovalEnum.STAFFLEAVEOFFICE,true);
        sql = sql + ' WHERE Id = \'' + staffLeaveOfficeId + '\'';
        List<Approval_Managed__c> lstItems = Database.query(sql);

        if(lstItems.size() > 0){
            return createSapStaffLeaveOfficeInputArgs(lstItems.get(0));
        }else{
            return '';
        }
    }
    /*
        目  的：创建传送给SAP Web Service的员工主动离职申请单参数
        参  数：staffLeaveOffice  - 员工主动离职申请单主数据
        返回值：SapWebServiceInputArgs类实例序列化后的Json字符串：
                {
                    "operate":"INSERT", //UPDATE
                    "approval":"StaffLeaveOffice", 
                    "content":
                    {
                        "main":
                        {
                            "Id":"SFID",
                            "SAPID__c":"SAP主键值",
                            "Name":"审批流程编号",
                            "Dept_Name__c":"申请人部门",
                            "Approval_Name__c":"流程名称",
                            "Status__c":"单据状态",
                            "Applicant__c":"申请人",
                            "Applicant_Code__c":"申请人(工号)",
                            "Applicant_Name__c":"申请人(姓名)",
                            "Bill_Date__c":"单据日期",
                            "Employee__c":"员工",
                            "Employee_Code__c":"员工(工号)",
                            "Employee_Name__c":"员工(姓名)",
                            "Human_Range__c":"人事范围",
                            "Department__c":"部门",
                            "Job_Title__c":"职务",
                            "Job_Title_Level__c":"职等职级",
                            "Birthday__c":"出生日期",
                            "Sex__c":"性别",
                            "Native_Place__c":"籍贯",
                            "Phone__c":"电话",
                            "Salary_Manager__c":"工资管理员",
                            "Post_Category__c":"职务分类",
                            "Take_Office_Date__c":"到职日期",
                            "Leave_Office_Date__c":"实际离职日",
                            "Kind_of_Work__c":"工种",
                            "Reason_of_Leave__c":"离职原因",
                            "Reason_of_Description__c":"具体原因",
                            "Remark_of_Explain__c":"说明",
                            "Reason_of_Leave_Human__c":"离职原因(人事)",
                            "Validate_Date__c":"生效日期",
                            "Reason_of_Operate__c":"操作原因"
                        },
                        "details":
                        {
                            "items":[]
                        }
                    }
                }
    */
    public static String createSapStaffLeaveOfficeInputArgs(Approval_Managed__c staffLeaveOffice ){
        String strArgs = '';
        try{
            //员工主动离职申请单主数据
            Map<String,String> main = Utils.convertSObjectToMap(staffLeaveOffice);
            System.debug('*** main' + main);
            //明细
            Map<String,List<Map<String,String>>> details = new Map<String,List<Map<String,String>>>();
            details.put('items', new List<Map<String,String>>());
            String operate = (staffLeaveOffice.Status__c == '新建' ? SapOperateEnum.INSERTED : SapOperateEnum.UPDATED);
            strArgs = Utils.serializeToJson(operate,SapApprovalEnum.STAFFLEAVEOFFICE,main,details);
        }catch(Exception ex){
            System.debug('*** 生成员工主动离职申请单推送参数错误：' + ex.getMessage() + '\n' + ex.getStackTraceString());
        }
        return strArgs;
    }
    //创建传送给SAP Web Service的员工出差申请单参数
    public static String createSapBusinessTravelInputArgs(String businessTravelId){
        String sql = Utils.getApprovalSQL(SapApprovalEnum.BUSINESSTRAVEL,true);
        sql = sql + ' WHERE Id = \'' + businessTravelId + '\'';
        List<Custom_Approval_Managed__c> lstItems = Database.query(sql);

        if(lstItems.size() > 0){
            return createSapBusinessTravelInputArgs(lstItems.get(0));
        }else{
            return '';
        }
    }
    //创建传送给SAP Web Service的员工出差申请单参数
    public static String createSapBusinessTravelInputArgs(Custom_Approval_Managed__c businessTravel){
        List<Custom_Approval_Managed_Item__c> items = 
            [SELECT Id,SAPID__c,Travel_Approval__c,Visit_Date__c,Corportion_Name__c,Address__c,Reason__c,
                    Interviewee__c,Phone_of_Interviewee__c,Campaign__c 
            FROM Custom_Approval_Managed_Item__c 
            WHERE Travel_Approval__c = :businessTravel.Id];

        return createSapBusinessTravelInputArgs(businessTravel,items);
    }
    /*
        目  的：创建传送给SAP Web Service的员工出差申请单参数
        参  数：businessTravel  - 员工出差申请单主数据
        参  数：items  - 员工出差申请单明细
        返回值：SapWebServiceInputArgs类实例序列化后的Json字符串：
                {
                    "operate":"INSERT", //UPDATE
                    "approval":"BusinessTravel", 
                    "content":
                    {
                        "main":
                        {
                            "Id":"SFID",
                            "SAPID__c":"SAP主键值",
                            "Name":"审批流程编号",
                            "Dept_Name__c":"申请人部门",
                            "Approval_Name__c":"流程名称",
                            "Status__c":"单据状态",
                            "Applicant__c":"申请人",
                            "Applicant_Code__c":"申请人(工号)",
                            "Applicant_Name__c":"申请人(姓名)",
                            "Bill_Date__c":"单据日期",
                            "Bill_No__c":"单号",
                            "Target_of_Travel__c":"出差对象",
                            "Type_of_Travel__c":"出差类型",
                            "Department_of_Approval__c":"申请部门",
                            "Area_of_Travel__c":"地域",
                            "Vehicle_of_Travel__c":"交通工具",
                            "Cost_Budget__c":"费用预算",
                            "Currency_of_Budget__c":"币种(预算)",
                            "Is_Borrow__c":"是否借支",
                            "Is_Salesperson__c":"是否销售人员",
                            "Is_Training__c":"是否培训",
                            "Is_Send_a_Car__c":"是否派车",
                            "Is_Before_Day__c":"前一天",
                            "Amount_of_Borrow__c":"借支金额",
                            "Currency_of_Borrow__c":"币种(借支)",
                            "Start_Travel_Datetime__c":"开始日期",
                            "End_Travel_Datetime__c":"结束日期",
                            "Description_of_Travel__c":"行程",
                            "Driver__c":"司机名",
                            "Plate_Number__c":"车牌号"
                        },
                        "details":
                        {
                            "items":
                            [
                                {
                                    "Id":"SFID",
                                    "SAPID__c":"SAP主键值",
                                    "Travel_Approval__c":"出差申请单号",
                                    "Visit_Date__c":"访问日期",
                                    "Corportion_Name__c":"公司名称",
                                    "Address__c":"地点",
                                    "Reason__c":"原因",
                                    "Interviewee__c":"受访者",
                                    "Phone_of_Interviewee__c":"受访者电话",
                                    "Campaign__c":"活动-预约ID"
                                },
                                {...}
                                {...}
                            ]
                        }
                    }
                }
    */
    public static String createSapBusinessTravelInputArgs(Custom_Approval_Managed__c businessTravel,List<Custom_Approval_Managed_Item__c> items){
        String strArgs = '';
        try{
            //员工出差申请单主数据
            Map<String,String> main = Utils.convertSObjectToMap(businessTravel);
            System.debug('*** main' + main);
            //明细
            Map<String,List<Map<String,String>>> details = new Map<String,List<Map<String,String>>>();
            //员工出差申请单明细
            if(items != null){
                List<Map<String,String>> lstitems = new List<Map<String,String>>();
                for(Custom_Approval_Managed_Item__c item : items){
                    lstitems.add(Utils.convertSObjectToMap(item));
                }
                details.put('items', lstitems);
            }
            String operate = (businessTravel.Status__c == '新建' ? SapOperateEnum.INSERTED : SapOperateEnum.UPDATED);
            strArgs = Utils.serializeToJson(operate,SapApprovalEnum.BUSINESSTRAVEL,main,details);
        }catch(Exception ex){
            System.debug('*** 生成员工出差申请单推送参数错误：' + ex.getMessage() + '\n' + ex.getStackTraceString());
        }
        return strArgs;
    }
    //创建传送给SAP Web Service的成本中心发料作业参数
    public static String createSapCostCenterSendInputArgs(String costCenterSendId){
        String sql = Utils.getApprovalSQL(SapApprovalEnum.COSTCENTERSEND,true);
        sql = sql + ' WHERE Id = \'' + costCenterSendId + '\'';
        List<Custom_Approval_Managed__c> lstItems = Database.query(sql);

        if(lstItems.size() > 0){
            return createSapCostCenterSendInputArgs(lstItems.get(0));
        }else{
            return '';
        }
    }
    //创建传送给SAP Web Service的成本中心发料作业参数
    public static String createSapCostCenterSendInputArgs(Custom_Approval_Managed__c costCenterSend){
        List<Custom_Approval_Managed_Item__c> items = 
            [SELECT Id,SAPID__c,CostCenter_Approval__c,Material_Number__c,Material_Name__c,Material_Description__c,
                Qty__c,Location_of_Storage__c,Batch__c,Qty_Stock__c,Qty_Send__c,Factory__c 
            FROM Custom_Approval_Managed_Item__c 
            WHERE CostCenter_Approval__c = :costCenterSend.Id];

        return createSapCostCenterSendInputArgs(costCenterSend,items);
    }
    /*
        目  的：创建传送给SAP Web Service的成本中心发料作业参数
        参  数：costCenterSend  - 成本中心发料作业主数据
        参  数：items  - 成本中心发料作业明细
        返回值：SapWebServiceInputArgs类实例序列化后的Json字符串：
                {
                    "operate":"INSERT", //UPDATE
                    "approval":"CostCenterSend", 
                    "content":
                    {
                        "main":
                        {
                            "Id":"SFID",
                            "SAPID__c":"SAP主键值",
                            "Name":"审批流程编号",
                            "Dept_Name__c":"申请人部门",
                            "Approval_Name__c":"流程名称",
                            "Status__c":"单据状态",
                            "Applicant__c":"申请人",
                            "Applicant_Code__c":"申请人(工号)",
                            "Applicant_Name__c":"申请人(姓名)",
                            "Bill_Date__c":"单据日期",
                            "Bill_No__c":"单号",
                            "Option_of_Operate__c":"操作选项",
                            "Is_Exist_Scrap__c":"存在报废",
                            "Material_Voucherno__c":"物料凭证号",
                            "Voucher_HeaderText__c":"凭证抬头文本",
                            "Voucher_Date__c":"凭证日期",
                            "Factory__c":"工厂",
                            "Address_of_Stock__c":"库存地点",
                            "Dept_of_CostCenter__c":"成本中心",
                            "Order_of_Production__c":"生产工单",
                            "Reason_of_Required__c":"需求原因"
                        },
                        "details":
                        {
                            "items":
                            [
                                {
                                    "Id":"SFID",
                                    "SAPID__c":"SAP主键值",
                                    "CostCenter_Approval__c":"申请单号",
                                    "Material_Number__c":"物料编号",
                                    "Material_Name__c":"物料名称",
                                    "Material_Description__c":"物料描述",
                                    "Qty__c":"需求数量",
                                    "Location_of_Storage__c":"库位",
                                    "Batch__c":"批次",
                                    "Qty_Stock__c":"当前库存",
                                    "Qty_Send__c":"发料数量",
                                    "Factory__c":"工厂"
                                },
                                {...}
                                {...}
                            ]
                        }
                    }
                }
    */
    public static String createSapCostCenterSendInputArgs(Custom_Approval_Managed__c costCenterSend,List<Custom_Approval_Managed_Item__c> items){
        String strArgs = '';
        try{
            //成本中心发料作业主数据
            Map<String,String> main = Utils.convertSObjectToMap(costCenterSend);
            System.debug('*** main' + main);
            //明细
            Map<String,List<Map<String,String>>> details = new Map<String,List<Map<String,String>>>();
            //成本中心发料作业明细
            if(items != null){
                List<Map<String,String>> lstitems = new List<Map<String,String>>();
                for(Custom_Approval_Managed_Item__c item : items){
                    lstitems.add(Utils.convertSObjectToMap(item));
                }
                details.put('items', lstitems);
            }
            String operate = (costCenterSend.Status__c == '新建' ? SapOperateEnum.INSERTED : SapOperateEnum.UPDATED);
            strArgs = Utils.serializeToJson(operate,SapApprovalEnum.COSTCENTERSEND,main,details);
        }catch(Exception ex){
            System.debug('*** 生成成本中心发料作业推送参数错误：' + ex.getMessage() + '\n' + ex.getStackTraceString());
        }
        return strArgs;
    }
    //创建传送给SAP Web Service的销售订单参数
    public static String createSapSaleOrderInputArgs(String saleOrderId){
        String sql = Utils.getApprovalSQL(SapApprovalEnum.SALEORDER,true);
        sql = sql + ' WHERE Id = \'' + saleOrderId + '\'';
        List<Custom_Approval_Managed__c> lstItems = Database.query(sql);

        if(lstItems.size() > 0){
            return createSapSaleOrderInputArgs(lstItems.get(0));
        }else{
            return '';
        }
    }
    //创建传送给SAP Web Service的销售订单参数
    public static String createSapSaleOrderInputArgs(Custom_Approval_Managed__c saleOrder){
        List<Custom_Approval_Managed_Item__c> items = new List<Custom_Approval_Managed_Item__c>();
        List<Custom_Approval_Managed_Item__c> headers = new List<Custom_Approval_Managed_Item__c>();
        List<Custom_Approval_Managed_Item__c> rows = new List<Custom_Approval_Managed_Item__c>();
        List<Contact> partners = new List<Contact>();

        /*
        List<Custom_Approval_Managed_Item__c> items = 
            [SELECT Id,SAPID__c,Sales_Order__c,Index_Item__c,Material_Number__c,Material_Name__c,
                    Material_Description__c,Quantity__c,Unit__c,Status_Overview__c,Material_of_Customer__c,
                    Schedule_Date__c,Price_Net__c,Currency__c,Reason__c, Your_Reference__c,Material_Cost__c 
            FROM Custom_Approval_Managed_Item__c 
            WHERE Sales_Order__c = :saleOrder.Id];
        List<Custom_Approval_Managed_Item__c> headers = 
            [SELECT Id,SAPID__c,Sales_Order_Header__c,Type_of_Price__c,Name_of_Price__c,Amount__c,Currency__c,
                    Quantity__c,Uom__c,Value_of_Price__c 
            FROM Custom_Approval_Managed_Item__c 
            WHERE Sales_Order_Header__c = :saleOrder.Id];
        List<Custom_Approval_Managed_Item__c> rows = 
            [SELECT Id,SAPID__c,Sales_Order_Detail__c,Type_of_Price__c,Name_of_Price__c,
                    Amount__c,Currency__c,Quantity__c,Uom__c,Value_of_Price__c 
            FROM Custom_Approval_Managed_Item__c 
            WHERE Sales_Order_Detail__c = :saleOrder.Id];
        List<Contact> partners = 
            [SELECT Id,SAPID__c,Sales_Order_Partner__c,PF__c,Number_Partner__c,LastName,Description_of_Partner__c 
            FROM Contact 
            WHERE Sales_Order_Partner__c = :saleOrder.Id];
        */
        return createSapSaleOrderInputArgs(saleOrder,items,headers,rows,partners);
    }
    /*
        目  的：创建传送给SAP Web Service的销售订单参数
        参  数：saleOrder  - 销售订单主数据
        参  数：items  - 销售订单明细
        参  数：headers  - 销售订单头条件明细
        参  数：rows  - 销售订单行条件明细
        返回值：SapWebServiceInputArgs类实例序列化后的Json字符串：
                {
                    "operate":"INSERT", //UPDATE
                    "approval":"SaleOrder", 
                    "content":
                    {
                        "main":
                        {
                            "Id":"SFID",
                            "SAPID__c":"SAP主键值",
                            "Name":"审批流程编号",
                            "Dept_Name__c":"申请人部门",
                            "Approval_Name__c":"流程名称",
                            "Status__c":"单据状态",
                            "Applicant__c":"申请人",
                            "Applicant_Code__c":"申请人(工号)",
                            "Applicant_Name__c":"申请人(姓名)",
                            "Bill_Date__c":"单据日期",
                            "Kind_of_Order__c":"订单类型",
                            "Bill_No__c":"正式订单号",
                            "Is_Agree_Refund__c":"供应商是否同意退款",
                            "Type_of_Approval__c":"流程类型",
                            "Customer__c":"售达方",
                            "Delivery_Party__c":"送达方",
                            "Reason_of_Order__c":"订单原因",
                            "Purchase__c":"采购订单号",
                            "Purchase_Order_Date__c":"采购订单日期",
                            "Purchase_Required_Date__c":"请求交货日期",
                            "Currency_Purchase__c":"币种",
                            "Term_of_Purchase_Payment__c":"付款条件",
                            "Term_of_Purchase_Trade__c":"国际贸易条件",
                            "Weight_Total__c":"总重量(KG)",
                            "Opportunity_Code__c":"商机编号",
                            "Sales_Org__c":"销售组织",
                            "Distribution_Channel__c":"分销渠道",
                            "Product_Group__c":"产品组",
                            "Price_Group__c":"价格组",
                            "Customer_Group__c":"客户组",
                            "Sales_Area__c":"销售地区",
                            "Sales_Office_Area__c":"销售办公区",
                            "Sales_Group__c":"销售小组",
                            "Is_Based_Quotation__c":"来源于报价单",
                            "Code_Reference__c":"参考号",
                            "Currency_Reference__c":"参考币种",
                            "Amount_Reference__c":"参考金额",
                            "Info_of_Discount__c":"折让信息",
                            "Text1_Additional__c":"补充文本1",
                            "Term_of_Contract__c":"合同附文",
                            "Remark__c":"备注信息",
                            "NotStandard_Price_Flag__c":"非标件价格判定标记",
                            "Prepare_Feed_Protocol__c":"备料单协议"
                        },
                        "details":
                        {
                            "items":
                            [
                                {
                                    "Id":"SFID",
                                    "SAPID__c":"SAP主键值",
                                    "Sales_Order__c":"销售订单",
                                    "Index_Item__c":"项次",
                                    "Material_Number__c":"物料号",
                                    "Material_Name__c":"物料名称",
                                    "Material_Description__c":"物料描述",
                                    "Quantity__c":"订单数量",
                                    "Unit__c":"单位",
                                    "Status_Overview__c":"总揽状态",
                                    "Material_of_Customer__c":"客户物料编号",
                                    "Schedule_Date__c":"预交日期",
                                    "Price_Net__c":"净价值",
                                    "Currency__c":"币种",
                                    "Reason__c":"拒绝原因",
                                    "Your_Reference__c":"你的参考",
                                    "Material_Cost__c":"物料成本"
                                }
                            ],
                            "headers":
                            [
                                {
                                    "Id":"SFID",
                                    "SAPID__c":"SAP主键值",
                                    "Sales_Order_Header__c":"销售订单",
                                    "Type_of_Price__c":"价格类型",
                                    "Name_of_Price__c":"价格名称",
                                    "Amount__c":"金额",
                                    "Currency__c":"币种",
                                    "Quantity__c":"数量",
                                    "Uom__c":"Uom",
                                    "Value_of_Price__c":"定价值"
                                }
                            ],
                            "rows":
                            [
                                {
                                    "Id":"SFID",
                                    "SAPID__c":"SAP主键值",
                                    "Sales_Order_Detail__c":"销售订单",
                                    "Type_of_Price__c":"类型",
                                    "Name_of_Price__c":"名称",
                                    "Amount__c":"金额",
                                    "Currency__c":"币种",
                                    "Quantity__c":"数量",
                                    "Uom__c":"Uom",
                                    "Value_of_Price__c":"定价值"
                                }
                            ],
                            "partners": //合作伙伴子条目
                            [
                                {
                                    "Id":"SFID",
                                    "SAPID__c":"SAPID__c",
                                    "Customer_Partner__c":"申请单号",
                                    "PF__c":"合伙人PF",
                                    "Number_Partner__c":"员工编号(合伙人)",
                                    "LastName":"名称",
                                    "Description_of_Partner__c":"合作伙伴描述"   
                                }
                            ]

                        }
                    }
                }
    */
    public static String createSapSaleOrderInputArgs(Custom_Approval_Managed__c saleOrder,List<Custom_Approval_Managed_Item__c> items,List<Custom_Approval_Managed_Item__c> headers,List<Custom_Approval_Managed_Item__c> rows,List<Contact> partners){
        String strArgs = '';
        try{
            //销售订单主数据
            Map<String,String> main = Utils.convertSObjectToMap(saleOrder);
            System.debug('*** main' + main);
            //明细
            Map<String,List<Map<String,String>>> details = new Map<String,List<Map<String,String>>>();
            //销售订单明细
            if(items != null){
                List<Map<String,String>> lstitems = new List<Map<String,String>>();
                for(Custom_Approval_Managed_Item__c item : items){
                    lstitems.add(Utils.convertSObjectToMap(item));
                }
                details.put('items', lstitems);
            }
            //销售订单头条件明细
            if(headers != null){
                List<Map<String,String>> lstheaders = new List<Map<String,String>>();
                for(Custom_Approval_Managed_Item__c item : headers){
                    lstheaders.add(Utils.convertSObjectToMap(item));
                }
                details.put('headers', lstheaders);
            }
            //销售订单行条件明细
            if(rows != null){
                List<Map<String,String>> lstrows= new List<Map<String,String>>();
                for(Custom_Approval_Managed_Item__c item : rows){
                    lstrows.add(Utils.convertSObjectToMap(item));
                }
                details.put('zrows', lstrows);
            }
            //销售订单合伙人功能
            if(partners != null){
                List<Map<String,String>>  lstpartners = new List<Map<String,String>>();
                for(Contact item : partners){
                    lstpartners.add(Utils.convertSObjectToMap(item));
                }
                details.put('partners', lstpartners);
            }
            String operate = (saleOrder.Status__c == '新建' ? SapOperateEnum.INSERTED : SapOperateEnum.UPDATED);
            strArgs = Utils.serializeToJson(operate,SapApprovalEnum.SALEORDER,main,details);
        }catch(Exception ex){
            System.debug('*** 生成销售订单推送参数错误：' + ex.getMessage() + '\n' + ex.getStackTraceString());
        }
        return strArgs;
    }
    //创建传送给SAP Web Service的费料处理参数
    public static String createSapWasteDisposeInputArgs(String wasteDisposeId){
        String sql = Utils.getApprovalSQL(SapApprovalEnum.WASTEDISPOSE,true);
        sql = sql + ' WHERE Id = \'' + wasteDisposeId + '\'';
        List<Custom_Approval_Managed__c> lstItems = Database.query(sql);

        if(lstItems.size() > 0){
            return createSapWasteDisposeInputArgs(lstItems.get(0));
        }else{
            return '';
        }
    }
    //创建传送给SAP Web Service的费料处理参数
    public static String createSapWasteDisposeInputArgs(Custom_Approval_Managed__c wasteDispose){
        List<Custom_Approval_Managed_Item__c> items = 
            [SELECT Id,SAPID__c,Waste_Approval__c,Material_Name__c,Weight_Actual__c,Qty__c,Price__c,Amount__c 
            FROM Custom_Approval_Managed_Item__c 
            WHERE Waste_Approval__c = :wasteDispose.Id];

        return createSapWasteDisposeInputArgs(wasteDispose,items);
    }
    /*
        目  的：创建传送给SAP Web Service的费料处理参数
        参  数：wasteDispose  - 费料处理主数据
        参  数：items  - 费料处理明细
        返回值：SapWebServiceInputArgs类实例序列化后的Json字符串：
                {
                    "operate":"INSERT", //UPDATE
                    "approval":"WasteDispose", 
                    "content":
                    {
                        "main":
                        {
                            "Id":"SFID",
                            "SAPID__c":"SAP主键值",
                            "Name":"审批流程编号",
                            "Dept_Name__c":"申请人部门",
                            "Approval_Name__c":"流程名称",
                            "Status__c":"单据状态",
                            "Applicant__c":"申请人",
                            "Applicant_Code__c":"申请人(工号)",
                            "Applicant_Name__c":"申请人(姓名)",
                            "Bill_Date__c":"单据日期",
                            "Type_of_Scrap__c":"废料类型",
                            "Factory__c":"工厂",
                            "Vendor__c":"供应商名称",
                            "Scrap_Date__c":"日期",
                            "Amount_Receipts__c":"收款金额",
                            "Order_of_Sales__c":"销售订单号",
                            "Invoice_and_Remark__c":"发票号及备注"
                        },
                        "details":
                        {
                            "items":
                            [
                                {
                                    "Id":"SFID",
                                    "SAPID__c":"SAP主键值",
                                    "Waste_Approval__c":"废料申请单",
                                    "Material_Name__c":"物料名称",
                                    "Weight_Actual__c":"实际称重(KG)",
                                    "Qty__c":"数量",
                                    "Price__c":"单价(RMB)",
                                    "Amount__c":"总价(RMB)"
                                },
                                {...}
                                {...}
                            ]
                        }
                    }
                }
    */
    public static String createSapWasteDisposeInputArgs(Custom_Approval_Managed__c wasteDispose,List<Custom_Approval_Managed_Item__c> items){
        String strArgs = '';
        try{
            //费料处理主数据
            Map<String,String> main = Utils.convertSObjectToMap(wasteDispose);
            System.debug('*** main' + main);
            //明细
            Map<String,List<Map<String,String>>> details = new Map<String,List<Map<String,String>>>();
            //费料处理明细
            if(items != null){
                List<Map<String,String>> lstitems = new List<Map<String,String>>();
                for(Custom_Approval_Managed_Item__c item : items){
                    lstitems.add(Utils.convertSObjectToMap(item));
                }
                details.put('items', lstitems);
            }
            String operate = (wasteDispose.Status__c == '新建' ? SapOperateEnum.INSERTED : SapOperateEnum.UPDATED);
            strArgs = Utils.serializeToJson(operate,SapApprovalEnum.WASTEDISPOSE,main,details);
        }catch(Exception ex){
            System.debug('*** 生成费料处理推送参数错误：' + ex.getMessage() + '\n' + ex.getStackTraceString());
        }
        return strArgs;
    }
    //创建传送给SAP Web Service的采购信息记录维护参数
    public static String createSapPurchaseInformationInputArgs(String purchaseInformationId){
        String sql = Utils.getApprovalSQL(SapApprovalEnum.PURCHASEINFORMATION,true);
        sql = sql + ' WHERE Id = \'' + purchaseInformationId + '\'';
        List<Custom_Approval_Managed__c> lstItems = Database.query(sql);

        if(lstItems.size() > 0){
            return createSapPurchaseInformationInputArgs(lstItems.get(0));
        }else{
            return '';
        }
    }
    //创建传送给SAP Web Service的采购信息记录维护参数
    public static String createSapPurchaseInformationInputArgs(Custom_Approval_Managed__c purchaseInformation){
        List<Custom_Approval_Managed_Item__c> items = 
            [SELECT Id,SAPID__c,Purchase_Info_Inquiry__c,Row_Index__c,Selected__c,Quote__c,Quote_Item__c,
                    Number_of_Purchase__c,Number_of_Item__c,Remark__c,Vendor__c,Material_Number__c,
                    Material_Name__c,Material_Description__c,Material_Number_of_Vendor__c 
            FROM Custom_Approval_Managed_Item__c 
            WHERE Purchase_Info_Inquiry__c = :purchaseInformation.Id];

        return createSapPurchaseInformationInputArgs(purchaseInformation,items);
    }
    /*
        目  的：创建传送给SAP Web Service的采购信息记录维护参数
        参  数：purchaseInformation  - 采购信息记录维护主数据
        参  数：items  - 采购信息记录维护明细
        返回值：SapWebServiceInputArgs类实例序列化后的Json字符串：
                {
                    "operate":"INSERT", //UPDATE
                    "approval":"PurchaseInformation", 
                    "content":
                    {
                        "main":
                        {
                            "Id":"SFID",
                            "SAPID__c":"SAP主键值",
                            "Name":"审批流程编号",
                            "Dept_Name__c":"申请人部门",
                            "Approval_Name__c":"流程名称",
                            "Status__c":"单据状态",
                            "Applicant__c":"申请人",
                            "Applicant_Code__c":"申请人(工号)",
                            "Applicant_Name__c":"申请人(姓名)",
                            "Bill_Date__c":"单据日期",
                            "Number_of_Purchase_Info__c":"锁定单号",
                            "Status_of_Purchase_Info__c":"状态",
                            "Kind_of_Material__c":"物料类型"
                        },
                        "details":
                        {
                            "items":
                            [
                                {
                                    "Id":"SFID",
                                    "SAPID__c":"SAP主键值",
                                    "Purchase_Info_Inquiry__c":"申请单号",
                                    "Row_Index__c":"行号",
                                    "Selected__c":"选择",
                                    "Quote__c":"报价请求",
                                    "Quote_Item__c":"请求项次",
                                    "Number_of_Purchase__c":"采购申请编号",
                                    "Number_of_Item__c":"项目编号",
                                    "Remark__c":"备注",
                                    "Vendor__c":"供应商",
                                    "Material_Number__c":"物料号",
                                    "Material_Name__c":"物料名称",
                                    "Material_Description__c":"物料描述",
                                    "Material_Number_of_Vendor__c":"供应商物料号"
                                },
                                {...}
                                {...}
                            ]
                        }
                    }
                }
    */
    public static String createSapPurchaseInformationInputArgs(Custom_Approval_Managed__c purchaseInformation,List<Custom_Approval_Managed_Item__c> items){
        String strArgs = '';
        try{
            //采购信息记录维护主数据
            Map<String,String> main = Utils.convertSObjectToMap(purchaseInformation);
            System.debug('*** main' + main);
            //明细
            Map<String,List<Map<String,String>>> details = new Map<String,List<Map<String,String>>>();
            //采购信息记录维护明细
            if(items != null){
                List<Map<String,String>> lstitems = new List<Map<String,String>>();
                for(Custom_Approval_Managed_Item__c item : items){
                    lstitems.add(Utils.convertSObjectToMap(item));
                }
                details.put('items', lstitems);
            }
            String operate = (purchaseInformation.Status__c == '新建' ? SapOperateEnum.INSERTED : SapOperateEnum.UPDATED);
            strArgs = Utils.serializeToJson(operate,SapApprovalEnum.PURCHASEINFORMATION,main,details);
        }catch(Exception ex){
            System.debug('*** 生成采购信息记录维护推送参数错误：' + ex.getMessage() + '\n' + ex.getStackTraceString());
        }
        return strArgs;
    }
    //创建传送给SAP Web Service的供应商主数据参数
    public static String createSapVendorInputArgs(String vendorId){
        String sql = Utils.getApprovalSQL(SapApprovalEnum.VENDOR,true);
        sql = sql + ' WHERE Id = \'' + vendorId + '\'';
        List<Custom_Approval_Managed__c> lstItems = Database.query(sql);

        if(lstItems.size() > 0){
            return createSapVendorInputArgs(lstItems.get(0));
        }else{
            return '';
        }
    }
    //创建传送给SAP Web Service的供应商主数据参数
    public static String createSapVendorInputArgs(Custom_Approval_Managed__c vendor){
        List<Custom_Approval_Managed_Item__c> banks = 
            [SELECT Id,SAPID__c,Vendor_Bank__c,Country__c,Country_Code__c,Country_Name__c,Bank_of_Code__c,
                    Account_of_Bank__c,Account_Name__c,Name_of_Bank__c,IBANValue__c,SWIFT_Code__c,Validate_Date__c 
            FROM Custom_Approval_Managed_Item__c 
            WHERE Vendor_Bank__c = :vendor.Id];
        List<Contact> contacts = 
            [SELECT Id,SAPID__c,Vendor_Contact__c,LastName,Phone,Extension_Number__c,Department__c,Functionally__c,
                    MobilePhone,Fax,Extension_Number_Fax__c,Email 
            FROM Contact 
            WHERE Vendor_Contact__c = :vendor.Id];
        List<Contact> partners = 
            [SELECT Id,SAPID__c,Vendor_Partner__c,PF__c,Functionally__c,Number_Partner__c,LastName,Description_of_Partner__c 
            FROM Contact 
            WHERE Vendor_Partner__c = :vendor.Id];

        return createSapVendorInputArgs(vendor,banks,partners,contacts);
    }
    /*
        目  的：创建传送给SAP Web Service的供应商主数据参数
        参  数：vendor - 供应商主数据
        参  数：banks - 供应商银行细目
        参  数：partners - 供应商合伙人功能
        参  数：contacts - 供应商联系人
        返回值：SapWebServiceInputArgs类实例序列化后的Json字符串：
                {
                    "operate":"INSERT", //UPDATE
                    "approval":"Vendor", 
                    "content":
                    {
                        "main":
                        {
                            "Id":"SFID",
                            "SAPID__c":"SAP主键值",
                            "Name":"审批流程编号",
                            "Dept_Name__c":"所属部门",
                            "Approval_Name__c":"流程名称",
                            "Status__c":"单据状态",
                            "Applicant__c":"申请人",
                            "Applicant_Code__c":"申请人(工号)",
                            "Applicant_Name__c":"申请人(姓名)",
                            "Bill_Date__c":"单据日期",
                            "Corporation__c":"公司",
                            "Purchase_Org__c":"采购组织",
                            "Account_Group__c":"账户组",
                            "Vendor_Number__c":"供应商代码",
                            "Title__c":"标题",
                            "Retrieve_Item1__c":"检索项",
                            "Retrieve_Item2__c":"检索项2",
                            "Vendor_Name__c":"名称",
                            "Name_Additional__c":"名称补充",
                            "Reserved_Street__c":"街道",
                            "House_Number__c":"门牌号",
                            "Postcode__c":"邮政编码",
                            "Country__c":"国家",
                            "Province__c":"省",
                            "Province_Code__c":"省(代码)",
                            "Province_Name__c":"省(名称)",
                            "City__c":"市",
                            "City_Code__c":"市(代码)",
                            "City_Name__c":"市(名称)",
                            "Time_Zone__c":"时区",
                            "Corp_Postcode__c":"公司邮政编码",
                            "Area__c":"地区",
                            "Language__c":"语言",
                            "Standard_Contac_Method__c":"标准通信方法",
                            "Mobile_Phone__c":"移动电话",
                            "Phone__c":"电话",
                            "Phone_Extension_Number__c":"分机号",
                            "Fax__c":"传真",
                            "Fax_Extension_Number__c":"分机号",
                            "Email__c":"Email",
                            "Tax_Number__c":"税号",
                            "Tax_Number_Additional__c":"加值税登记号码",
                            "Business_Type__c":"业务类型",
                            "Industry_Type__c":"工业类型",
                            "Is_Based_Invoice__c":"基于收货的发票验证",
                            "Purchase_Group__c":"采购组",
                            "Plan_Delivery_Days__c":"计划交货时间(天)",
                            "Control_Subject__c":"统驭科目",
                            "Sorting_Code__c":"排序码",
                            "Cash_Manage_Group__c":"现金管理群组",
                            "Term_of_Payment__c":"付款条件",
                            "Payment_Methods__c":"付款方式",
                            "Currency__c":"币种",
                            "Num_Min_Order__c":"最小订单量",
                            "Corp_Registed_Date__c":"公司注册日期",
                            "Num_Equipment1__c":"设备数量1",
                            "Num_Equipment2__c":"设备数量2",
                            "Num_Equipment3__c":"设备数量3",
                            "Num_Equipment4__c":"设备数量4",
                            "Num_Equipment5__c":"设备数量5",
                            "International_Trade_Term__c":"国际贸易条件",
                            "Subdivision__c":"小类",
                            "Project_of_Main__c":"主营项目",
                            "Production_Area__c":"产房面积",
                            "Annual_Capacity__c":"年产能",
                            "Registered_Capital__c":"注册资金",
                            "Termo_of_Payment1__c":"付款条件",
                            "Term_of_Explain__c":"条件说明 ",
                            "Name_Equipment1__c":"设备名称1",
                            "Name_Equipment2__c":"设备名称2",
                            "Name_Equipment3__c":"设备名称3",
                            "Name_Equipment4__c":"设备名称4",
                            "Name_Equipment5__c":"设备名称5",
                            "Num_Employee__c":"员工数",
                            "Spec_Equipment1__c":"设备规格1",
                            "Spec_Equipment2__c":"设备规格2",
                            "Spec_Equipment3__c":"设备规格3",
                            "Spec_Equipment4__c":"设备规格4",
                            "Spec_Equipment5__c":"设备规格5",
                            "Remark__c":"注释"
                        },
                        "details":
                        {
                            "banks": //银行子条目
                            [
                                {
                                    "Id":"SFID",
                                    "SAPID__c":"SAP主键值",
                                    "Approval_Managed__c":"申请单号",
                                    "Country__c":"国家",
                                    "Country_Code__c":"国家(代码)",
                                    "Country_Name__c":"国家(名称)",
                                    "Bank_of_Code__c":"银行代码",
                                    "Account_of_Bank__c":"银行账号",
                                    "Account_Name__c":"银行户主",
                                    "Name_of_Bank__c":"银行名称",
                                    "IBANValue__c":"IBANValue",
                                    "SWIFT_Code__c":"SWIFT码",
                                    "Validate_Date__c":"生效日期"
                                },
                                {...}
                            ],
                            "partners": //合作伙伴子条目
                            [
                                {
                                    "Id":"SFID",
                                    "SAPID__c":"SAP主键值",
                                    "Vendor_Partner__c":"申请单号",
                                    "PF__c":"PF",
                                    "Functionally__c":"功能",
                                    "Number__c":"编号",
                                    "LastName":"名称",
                                    "Description_of_Partner__c":"合作伙伴描述" 
                                },
                                {...}
                            ],
                            "contacts": //联系人子条目
                            [
                                {
                                    "Id":"SFID",
                                    "SAPID__c":"SAP主键值",
                                    "Vendor_Contact__c":"申请单号",
                                    "LastName":"名称",
                                    "Phone":"电话",
                                    "Extension_Number__c":"分机号",
                                    "Department":"部门描述",
                                    "Functionally__c":"功能",
                                    "MobilePhone":"移动电话",
                                    "Fax":"传真",
                                    "Extension_Number_Fax__c":"分机号",
                                    "Email":"Email"
                                },
                                {...}
                            ]
                        }
                    }
                }
    */
    public static String createSapVendorInputArgs(Custom_Approval_Managed__c vendor,List<Custom_Approval_Managed_Item__c> banks,List<Contact> partners, List<Contact> contacts){
        String strArgs = '';
        try{
            //供应商主数据
            Map<String,String> main = Utils.convertSObjectToMap(vendor);
            System.debug('*** main' + main);
            //供应商银行细目
            Map<String,List<Map<String,String>>> details = new Map<String,List<Map<String,String>>>();
            //银行
            if(banks != null){
                List<Map<String,String>> lstBanks = new List<Map<String,String>>();
                for(Custom_Approval_Managed_Item__c bank : banks){
                    lstBanks.add(Utils.convertSObjectToMap(bank));
                }
                details.put('banks', lstBanks);
            }
            //供应商合伙人功能
            if(partners != null){
                List<Map<String,String>> lstPartners = new List<Map<String,String>>();
                for(Contact partner : partners){
                    lstPartners.add(Utils.convertSObjectToMap(partner));
                }
                details.put('partners', lstPartners);
            }
            //供应商联系人
            if(contacts != null){
                List<Map<String,String>> lstContacts = new List<Map<String,String>>();
                for(Contact con : contacts){
                    lstContacts.add(Utils.convertSObjectToMap(con));
                }
                details.put('contacts', lstContacts);
            }

            String operate = (vendor.Status__c == '新建' ? SapOperateEnum.INSERTED : SapOperateEnum.UPDATED);
            strArgs = Utils.serializeToJson(operate,SapApprovalEnum.VENDOR,main,details);
        }catch(Exception ex){
            System.debug('*** 生成供应商主数据推送参数错误：' + ex.getMessage() + '\n' + ex.getStackTraceString());
        }
        return strArgs;
    }
    //创建传送给SAP Web Service的采购订单参数
    public static String createSapPurchaseOrderInputArgs(String purchaseOrderId){
        String sql = Utils.getApprovalSQL(SapApprovalEnum.PURCHASEORDER,true);
        sql = sql + ' WHERE Id = \'' + purchaseOrderId + '\'';
        List<Approval_Managed__c> lstItems = Database.query(sql);

        if(lstItems.size() > 0){
            return createSapPurchaseOrderInputArgs(lstItems.get(0));
        }else{
            return '';
        }
    }
    //创建传送给SAP Web Service的采购订单参数
    public static String createSapPurchaseOrderInputArgs(Approval_Managed__c purchaseOrder){
        List<Approval_Managed_Item__c> items = 
       [SELECT Id,SAPID__c,Row_Index__c,Purchase_Item_Type__c,Index_Item__c,Purchase_Order__c,
            Material_Number__c,Material_Name__c,Material_Description__c,Quantity__c,Unit__c,
            Delivery_Date__c,Price_Net__c,Currency__c,Price_Tax__c,Currency_Tax__c,
            Vendor_Response__c,Remark__c,Last_Pick_Date__c,Last_Pick_Price__c,
            Last_Pick_Currency__c,Per__c,Unit3__c,Factory__c,Applicant__c,Back_Project__c,
            Is_Free__c,Purchase_Order_Number__c,Applicant_Row__c,Amount_Price__c,
            Last_Pick_Number__c,Dept_of_CostCenter__c,Order2_Number__c,Order_Of_SalesOrder__c,
            Item__c,Sales_Amount_Total__c,Ledger_Account__c,Device_Number__c,Asset_Code__c,
            Asset_Value__c,Asset_Purchase_Date__c,Drawing_Number__c,Drawing_Version__c,
            Text_Project__c
        FROM Approval_Managed_Item__c 
             WHERE Purchase_Order__c = :purchaseOrder.Id];
        List<Approval_Managed_Item__c> prices = 
       [SELECT Id,SAPID__c,Purchase_Order_Price__c,Type_of_Price__c,Name_of_Price__c,Value_of_Price__c,Currency__c 
        FROM Approval_Managed_Item__c 
        WHERE Purchase_Order_Price__c = :purchaseOrder.Id];

        return createSapPurchaseOrderInputArgs(purchaseOrder,items,prices);
    }
    /*
        目  的：创建传送给SAP Web Service的采购订单参数
        参  数：purchaseOrder - 采购订单
        参  数：items - 采购订单明细
        参  数：prices - 采购订单定价元素
        返回值：SapWebServiceInputArgs类实例序列化后的Json字符串：
                {
                    "operate":"INSERT", //UPDATE
                    "approval":"PurchaseOrder", 
                    "content":
                    {
                        "main":
                        {
                            "Id":"SFID",
                            "SAPID__c":"SAP主键值",
                            "Name":"审批流程编号",
                            "Dept_Name__c":"申请人部门",
                            "Approval_Name__c":"流程名称",
                            "Status__c":"单据状态",
                            "Applicant__c":"申请人",
                            "Applicant_Code__c":"申请人(工号)",
                            "Applicant_Name__c":"申请人(姓名)",
                            "Bill_Date__c":"单据日期",
                            "Kind_of_Order__c":"订单类型",
                            "Bill_No__c":"单号",
                            "Purchase_Date__c":"凭证日期",
                            "Vendor__c":"供应商",
                            "Purchase_Org__c":"采购组织",
                            "Purchase_Group__c":"采购组",
                            "Corporation__c":"公司代码",
                            "Currency__c":"币种",
                            "Days_of_Payment__c":"付款(天)",
                            "Percent_of_Payment__c":"付款比例(%)",
                            "Exchange_Rate__c":"汇率",
                            "Term_of_Payment__c":"付款条件",
                            "Days_of_Payment_Term__c":"付款(天)",
                            "Percent_of_Payment_Term__c":"付款比例(%)",
                            "Amount_Net_Days__c":"天内净额",
                            "International_Trade_Term__c":"国际贸易条件",
                            "Text_of_Head__c":"头文本",
                            "Required_date__c":"需求日期",
                            "Is_Receipt_Info__c":"收货信息"
                        },
                        "details":
                        {
                            "items": //采购订单明细
                            [
                                {
                                    "Id":"SFID",
                                    "SAPID__c":"SAP主键值",
                                    "Purchase_Order__c":"采购订单号",
                                    "Material_Number__c":"物料号",
                                    "Material_Name__c":"物料名称",
                                    "Material_Description__c":"物料描述",
                                    "Quantity__c":"订单数量",
                                    "Unit__c":"单位",
                                    "Delivery_Date__c":"交货日期",
                                    "Price_Net__c":"净价",
                                    "Currency__c":"币种",
                                    "Price_Tax__c":"含税价格",
                                    "Currency_Tax__c":"含税价币种",
                                },
                                {...}
                            ],
                            "prices": //采购订单定价元素
                            [
                                {
                                    "Id":"SFID",
                                    "SAPID__c":"SAP主键值",
                                    "Purchase_Order_Price__c":"采购订单号",
                                    "Type_of_Price__c":"类型",
                                    "Name_of_Price__c":"名称",
                                    "Value_of_Price__c":"定价值",
                                    "Currency__c":"币种"
                                },
                                {...}
                            ]
                        }
                    }
                }
    */
    public static String createSapPurchaseOrderInputArgs(Approval_Managed__c purchaseOrder,List<Approval_Managed_Item__c> items,List<Approval_Managed_Item__c> prices){
        String strArgs = '';
        try{
            //采购订单
            Map<String,String> main = Utils.convertSObjectToMap(purchaseOrder);
            System.debug('*** main' + main);
            //供应商银行细目
            Map<String,List<Map<String,String>>> details = new Map<String,List<Map<String,String>>>();
            //采购订单明细
            if(items != null){
                List<Map<String,String>> lstItems = new List<Map<String,String>>();
                for(Approval_Managed_Item__c item : items){
                    lstItems.add(Utils.convertSObjectToMap(item));
                }
                details.put('items', lstItems);
            }
            //采购订单定价元素
            if(prices != null){
                List<Map<String,String>> lstPrices = new List<Map<String,String>>();
                for(Approval_Managed_Item__c price : prices){
                    lstPrices.add(Utils.convertSObjectToMap(price));
                }
                details.put('prices', lstPrices);
            }

            String operate = (purchaseOrder.Status__c == '新建' ? SapOperateEnum.INSERTED : SapOperateEnum.UPDATED);
            strArgs = Utils.serializeToJson(operate,SapApprovalEnum.PURCHASEORDER,main,details);
        }catch(Exception ex){
            System.debug('*** 生成采购订单推送参数错误：' + ex.getMessage() + '\n' + ex.getStackTraceString());
        }
        return strArgs;
    }

    //创建传送给SAP Web Service的采购申请参数
    public static String createSapPurchaseRequestInputArgs(String purchaseRequestId){
        String sql = Utils.getApprovalSQL(SapApprovalEnum.PURCHASEAPPLICATION,true);
        sql = sql + ' WHERE Id = \'' + purchaseRequestId + '\'';
        List<Approval_Managed__c> lstItems = Database.query(sql);
        
        if(lstItems.size() > 0){
            return createSapPurchaseRequestInputArgs(lstItems.get(0));
        }else{
            return '';
        }
    }
    //创建传送给SAP Web Service的采购申请参数
    public static String createSapPurchaseRequestInputArgs(Approval_Managed__c purchaseRequest){
        List<Approval_Managed_Item__c> items = 
       [SELECT Id,SAPID__c,Row_Index__c,P_Inclusive_of_Tax__c,Out_Delivery__c,Ratio__c,Cost_of_Tax__c
        FROM Approval_Managed_Item__c 
             WHERE Purchasing_Request__c = :purchaseRequest.Id];
        
            System.debug('*** xxxxxxxxxxx：' + purchaseRequest.Id);
        return createSapPurchaseRequestInputArgs(purchaseRequest,items);
    }

    public static String createSapPurchaseRequestInputArgs(Approval_Managed__c purchaseRequest,List<Approval_Managed_Item__c> items){
        String strArgs = '';
        try{
            Map<String,String> main = Utils.convertSObjectToMap(purchaseRequest);
            System.debug('*** main' + main);
            Map<String,List<Map<String,String>>> details = new Map<String,List<Map<String,String>>>();
            if(items != null){
                List<Map<String,String>> lstItems = new List<Map<String,String>>();
                for(Approval_Managed_Item__c item : items){
                    lstItems.add(Utils.convertSObjectToMap(item));
                }
                details.put('items', lstItems);
            }


            String operate = (purchaseRequest.Status__c == '新建' ? SapOperateEnum.INSERTED : SapOperateEnum.UPDATED);
            strArgs = Utils.serializeToJson(operate,SapApprovalEnum.PURCHASEAPPLICATION,main,details);
        }catch(Exception ex){
            System.debug('*** 生成采购申请推送参数错误：' + ex.getMessage() + '\n' + ex.getStackTraceString());
        }

        return strArgs;
    }

//员工请假
    //创建传送给SAP Web Service的请假参数STEP1
    public static String createSapAmleaveInputArgs(String amleaveId){
        String sql = Utils.getApprovalSQL(SapApprovalEnum.LEAVE,true);
        sql = sql + ' WHERE Id = \'' + amleaveId + '\'';
        List<Approval_Managed__c> lstItems = Database.query(sql);
        
        if(lstItems.size() > 0){
            return createSapAmleaveInputArgs(lstItems.get(0));
        }else{
            return '';
        }
    }
    //创建传送给SAP Web Service的请假参数STEP2
    public static String createSapAmleaveInputArgs(Approval_Managed__c amleave){
        List<Approval_Managed_Item__c> items = 
       [SELECT Id,SAPID__c,Leave_type__c,Leave_reason__c,Start_date__c,Start_Time__c,End_date__c,End_Time__c
        FROM Approval_Managed_Item__c 
             WHERE LeaveManage__c = :amleave.Id];
        
            System.debug('*** xxxxxxxxxxx：' + amleave.Id);
            System.debug(LoggingLevel.INFO, '*** items: ' + items);
        return createSapAmleaveInputArgs(amleave,items);
    }
    //创建传送给SAP Web Service的请假参数STEP3
    public static String createSapAmleaveInputArgs(Approval_Managed__c amleave,List<Approval_Managed_Item__c> items){
        String strArgs = '';
        try{
            Map<String,String> main = Utils.convertSObjectToMap(amleave);
            System.debug('*** main' + main);
            Map<String,List<Map<String,String>>> details = new Map<String,List<Map<String,String>>>();

            if(items != null){
                List<Map<String,String>> lstItems = new List<Map<String,String>>();
                for(Approval_Managed_Item__c item : items){
                    lstItems.add(Utils.convertSObjectToMap(item));
                }
                details.put('items', lstItems);
            }

            System.debug(LoggingLevel.INFO, '*** step3: ');
            String operate = 'INSERT';
            strArgs = Utils.serializeToJson(operate,SapApprovalEnum.LEAVE,main,details);
        }catch(Exception ex){
            System.debug('*** 生成员工请假推送参数错误：' + ex.getMessage() + '\n' + ex.getStackTraceString());
        }

        return strArgs;
    }



//PM通知单 
        //创建传送给SAP Web Service的请PM通知单参数STEP1
    public static String createSapPMTicketInputArgs(String PMTicketid){
        String sql = Utils.getApprovalSQL(SapApprovalEnum.PMTICKET,true);
        sql = sql + ' WHERE Id = \'' + PMTicketid + '\'';
        List<Approval_Managed__c> lstItems = Database.query(sql);
        
        if(lstItems.size() > 0){
            return createSapPMTicketInputArgs(lstItems.get(0));
        }else{
            return '';
        }
    }
    //创建传送给SAP Web Service的请假参数STEP2
    public static String createSapPMTicketInputArgs(Approval_Managed__c ampmticket){
        List<Approval_Managed_Item__c> items = new List<Approval_Managed_Item__c>();
        
            System.debug('*** xxxxxxxxxxx：' + ampmticket.Id);
            System.debug(LoggingLevel.INFO, '*** items: ' + items);
        return createSapPMTicketInputArgs(ampmticket,items);
    }
    //创建传送给SAP Web Service的请假参数STEP3
    public static String createSapPMTicketInputArgs(Approval_Managed__c ampmticket,List<Approval_Managed_Item__c> items){
        String strArgs = '';
        try{
            Map<String,String> main = Utils.convertSObjectToMap(ampmticket);
            System.debug('*** main' + main);
            Map<String,List<Map<String,String>>> details = new Map<String,List<Map<String,String>>>();

            if(items != null){
                List<Map<String,String>> lstItems = new List<Map<String,String>>();
                for(Approval_Managed_Item__c item : items){
                    lstItems.add(Utils.convertSObjectToMap(item));
                }
                details.put('items', lstItems);
            }

            System.debug(LoggingLevel.INFO, '*** step3: ');
            String operate = 'INSERT';
            strArgs = Utils.serializeToJson(operate,SapApprovalEnum.PMTICKET,main,details);
        }catch(Exception ex){
            System.debug('*** PM通知单回写参数错误：' + ex.getMessage() + '\n' + ex.getStackTraceString());
        }

        return strArgs;
    }


//销售定价业务流程
    //创建传送给SAP Web Service的销售定价业务流程参数--STEP1
     public static String createSapSalesPriceInputArgs(String SalesPrices){
        String sql = Utils.getApprovalSQL(SapApprovalEnum.SALESPRICE,true);
        sql = sql + ' WHERE Id = \'' + SalesPrices + '\'';
        List<Approval_Managed__c> lstItems = Database.query(sql);
        
        if(lstItems.size() > 0){
            return createSapSalesPriceInputArgs(lstItems.get(0));
        }else{
            return '';
        }
    }
    //创建传送给SAP Web Service的销售定价业务流程参数--STEP2
    public static String createSapSalesPriceInputArgs(Approval_Managed__c amSalesPrice){
        List<Approval_Managed_Item__c> items =  [SELECT Id,SAPID__c,Material_Number__c,Material_Description__c,Amount__c,Currency__c,Quantity__c,UOM__c,NumerationType__c,StartTime__c,EndTime__c,Standard_parts__c
        FROM Approval_Managed_Item__c 
        WHERE SalesPricing_son_table__c = :amSalesPrice.Id];

        System.debug('*** xxxxxxxxxxx：' + amSalesPrice.Id);
        System.debug(LoggingLevel.INFO, '*** items: ' + items);

        List<Approval_Managed_Item__c> amic = [SELECT Id,SAPID__c,Row_Index__c,LevelNumber__c,UOM__c,Amount__c,Currency__c,Quantity__c
        FROM Approval_Managed_Item__c
        WHERE SalesPricing_son2__c = :amSalesPrice.Id];

        return createSapSalesPriceInputArgs(amSalesPrice,items,amic);
    }
    //创建传送给SAP Web Service的销售定价业务流程参数--STEP3
    public static String createSapSalesPriceInputArgs(Approval_Managed__c amSalesPrice,List<Approval_Managed_Item__c> items,List<Approval_Managed_Item__c> amit){
        String strArgs = '';
        try{
            Map<String,String> main = Utils.convertSObjectToMap(amSalesPrice);
            System.debug('*** main' + main);
            Map<String,List<Map<String,String>>> details = new Map<String,List<Map<String,String>>>();

            if(items != null){
                List<Map<String,String>> lstItems = new List<Map<String,String>>();
                for(Approval_Managed_Item__c item : items){
                    lstItems.add(Utils.convertSObjectToMap(item));
                }
                details.put('items', lstItems);
            }

            if (amit != null) {
                List<Map<String,String>> lstamit = new List<Map<String,String>>();
                for(Approval_Managed_Item__c listson2 : amit){
                    lstamit.add(Utils.convertSObjectToMap(listson2));
                }
                details.put('amit', lstamit);
            }

            System.debug(LoggingLevel.INFO, '*** step3: ');
            String operate = 'INSERT';
            strArgs = Utils.serializeToJson(operate,SapApprovalEnum.SALESPRICE,main,details);
        }catch(Exception ex){
            System.debug('*** 销售定价业务流程回写参数错误：' + ex.getMessage() + '\n' + ex.getStackTraceString());
        }

        return strArgs; 
    }


}