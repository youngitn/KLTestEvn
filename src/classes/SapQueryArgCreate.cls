/*
    目    的：主动从SAP查询数据时，生成SAP接收参数
    作    者：刘文俊(liuwenjun@bluelinksys.com)
    创建日期：2017-05-03
    修 改 人：
    修改日期：
    修改原因：
    备    注：
*/
public with sharing class SapQueryArgCreate {
	/*
        目  的：创建传送给SAP的查询(组织架构)接口参数
        返回值：SapWebServiceQueryArgs类实例序列化后的Json字符串：
                {
                    "approval":"OrganizationalQuery", 
                    "assemble":"",
                    "conditions":[]
                }

    */
    public static String createSapOrganizationalQueryArgs(){
        return JSON.serialize(createQueryArg('OrganizationalQuery',new List<Map<String,String>>()));
    }
    /*
        目  的：创建传送给SAP的查询(岗位)接口参数
        返回值：SapWebServiceQueryArgs类实例序列化后的Json字符串：
                {
                    "approval":"RoleQuery", 
                    "assemble":"",
                    "conditions":[]
                }

    */
    public static String createSapRoleQueryArgs(){
        return JSON.serialize(createQueryArg('RoleQuery',new List<Map<String,String>>()));
    }
    /*
        目  的：创建传送给SAP的查询(员工)接口参数
        返回值：SapWebServiceQueryArgs类实例序列化后的Json字符串：
                {
                    "approval":"StaffQuery", 
                    "assemble":"",
                    "conditions":[]
                }

    */
    public static String createSapStaffQueryArgs(){
    	return JSON.serialize(createQueryArg('StaffQuery',new List<Map<String,String>>()));
    }
    public static String createSapMaterialQueryArgs(String corpNumber,String locationOfStorage,String materialNumber){
        return createSapMaterialQueryArgs(corpNumber,locationOfStorage,materialNumber,'');
    }
    /*
        目  的：创建传送给SAP的查询(物料)接口参数
        参数 1：corpNumber - 公司编号
        参数 2：locationOfStorage - 库位编号
        参数 3：materialNumber - 物料编号
        参数 4：materialDesc - 物料描述
        返回值：SapWebServiceQueryArgs类实例序列化后的Json字符串：
                {
                    "approval":"MaterialQuery", 
                    "assemble":"",
                    "conditions":
                    [
                        {
                            "NO":"1",
                            "FieldName":"Material_Number__c",
                            "DataType":"String",
                            "Operate":"=",
                            "Value":"传入的参数值"
                        },
                        {
                            "NO":"2",
                            "FieldName":"Corp_Number__c",
                            "DataType":"String",
                            "Operate":"=",
                            "Value":"传入的参数值"
                        },
                        {
                            "NO":"3",
                            "FieldName":"Location_of_Storage__c",
                            "DataType":"String",
                            "Operate":"=",
                            "Value":"传入的参数值"
                        },
                        {
                            "NO":"4",
                            "FieldName":"Material_Description__c",
                            "DataType":"String",
                            "Operate":"LIKE",
                            "Value":"传入的参数值"
                        }
                    ]
                }
    */
    public static String createSapMaterialQueryArgs(String corpNumber,String locationOfStorage,String materialNumber,String materialDesc){
        List<Map<String,String>> lstCon = new List<Map<String,String>>();
    	Integer index = 1;

        Map<String,String> con1 = new Map<String,String>();
    	//公司编号
        lstCon.add(createCondition(index,'Corp_Number__c','String','=',corpNumber));
        index = index + 1;
        //库位编号
        lstCon.add(createCondition(index,'Location_of_Storage__c','String','=',locationOfStorage));
        index = index + 1;
        //物料号
    	lstCon.add(createCondition(index,'Material_Number__c','String','=',materialNumber));
        index = index + 1;
        //物料描述
        if(!String.isBlank(materialDesc)){
            lstCon.add(createCondition(index,'Material_Description__c','String','LIKE',materialDesc));
            index = index + 1;
        }
    	return JSON.serialize(createQueryArg('MaterialQuery',lstCon));
    }
    /*
        目  的：创建传送给SAP的查询(客户订单)接口参数
        参数 1：customerCode - 客户编号
        参数 2：orderStatus - 订单状态(待发货/已发货)
        参数 3：orderCode - 订单号
        参数 4：createdDate - 订单创建日期
        参数 5：deliveryDate - 订单应交付日期
        返回值：SapWebServiceQueryArgs类实例序列化后的Json字符串：
                {
                    "approval":"CustomerOrderQuery", 
                    "assemble":"",
                    "conditions":
                    [
                    	{
							"NO":"1",
							"FieldName":"Customer_Code__c",//客户编号
                            "DataType", "String",
                            "DataType":"string",
							"Operate":"=",
							"Value":"传入的参数值"
                    	},
                    	{
							"NO":"2",
							"FieldName":"Order_Status__c",//订单状态(待发货/已发货)
                            "DataType", "String",
							"Operate":"=",
							"Value":"传入的参数值"
                    	},
                    	{
							"NO":"3",
							"FieldName":"Create_Date__c",//订单创建日期
                            "DataType", "Date",
							"Operate":"=",
							"Value":"20170102"
                    	},
                    	{
							"NO":"4",
							"FieldName":"Delivery_Date__c",//订单应交付日期
                            "DataType", "Date",
							"Operate":"=",
							"Value":"传入的参数值"
                    	}
                    ]
                }

    */
    public static String createSapCustomerOrderQueryArgs(String customerCode,String orderStatus,String orderCode,Date createdDate,Date deliveryDate){
    	List<Map<String,String>> lstCon = new List<Map<String,String>>();
        Integer index = 1;
    	if(!String.isBlank(customerCode)){
            //客户编号
    		lstCon.add(createCondition(index,'Customer_Code__c','String','=',customerCode));
            index = index + 1;
    	}
    	
    	if(!String.isBlank(orderStatus)){
            //订单状态(待发货/已发货)
	    	lstCon.add(createCondition(index,'Order_Status__c','String','=',orderStatus));
            index = index + 1;
		}
        if(!String.isBlank(orderCode)){
            //订单号
            lstCon.add(createCondition(index,'Order_Code__c','String','=',orderCode));
            index = index + 1;
        }
		if(createdDate != null){
            //订单创建日期
	    	lstCon.add(createCondition(index,'Create_Date__c','Date','=',formatSAPDate(createdDate)));
            index = index + 1;
		}
		if(deliveryDate != null){
            //订单应交付日期
	    	lstCon.add(createCondition(index,'Delivery_Date__c','Date','=',formatSAPDate(deliveryDate)));
            index = index + 1;
		}

    	return JSON.serialize(createQueryArg('CustomerOrderQuery',lstCon));
    }



 //盘盈盘亏
    public static String createSapInventoryQueryDesc(String Factory,String Material_Number){
        return createSapInventoryQueryDesc(Factory,Material_Number,'','');
    }
    /*
        目  的：创建传送给SAP的查询(物料)接口参数
        参数 1：Factory - 工厂
        参数 2：Material_Number - 物料编号
        参数 3: Material_Description - 物料描述
        参数 4：Storage  - 库位
        返回值：createSapMaterialQueryDesc类实例序列化后的Json字符串：
                {
                    "approval":"INVENTORY", 
                    "assemble":"",
                    "conditions":
                    [
                         {
                            "NO":"1",
                            "FieldName":"Factory__c",
                            "DataType":"String",
                            "Operate":"=",
                            "Value":"传入的参数值"
                        },
                         {
                            "NO":"1",
                            "FieldName":"Material_Number__c",
                            "DataType":"String",
                            "Operate":"=",
                            "Value":"传入的参数值"
                        },
                        {
                            "NO":"1",
                            "FieldName":"Material_Description__c",
                            "DataType":"String",
                            "Operate":"=",
                            "Value":"传入的参数值"
                        },
                        {
                            "NO":"2",
                            "FieldName":"Storage__c",
                            "DataType":"String",
                            "Operate":"=",
                            "Value":"传入的参数值"
                        }
                    ]
                }
    */
    public static String createSapInventoryQueryDesc(String Factory,String Material_Number,String Material_Description,String Storage){
        List<Map<String,String>> lstCon = new List<Map<String,String>>();
        Integer index = 1;
        Map<String,String> con1 = new Map<String,String>();
        //工厂
        if (!String.isBlank(Factory)) {
            lstCon.add(createCondition(index,'Factory__c','String','=',Factory));
        index = index + 1;
        }
        //物料号
        if (!String.isBlank(Material_Number)) {
            lstCon.add(createCondition(index,'Material_Number__c','String','=',Material_Number));
        index = index + 1;
        }
        //物料描述
        if(!String.isBlank(Material_Description)){
            lstCon.add(createCondition(index,'Material_Description__c','String','LIKE',Material_Description));
            index = index + 1;
        }
        //库位
        if (!String.isBlank(Storage)) {
            lstCon.add(createCondition(index,'Storage__c','String','LIKE',Storage));
            index = index + 1;
        }
        return JSON.serialize(createQueryArg('INVENTORY',lstCon));    
    }
    


        public static String createSapClientQueryArgs(String salesName){
        return createSapClientQueryArgs(salesName,'','','','','','','','','','','','','');
    }
     /*
        目  的：创建传送给SAP的查询(客户信貸单筆核發申請)接口参数
        参  数：salesName - 銷售憑證
        返回值：SapWebServiceQueryArgs类实例序列化后的Json字符串：
                {
                    "approval":"CustomerContractMaterialQuery", 
                    "assemble":"",
                    "conditions":
                    [
                        {
                            "NO":"1",
                            "FieldName":"Sales_name",//銷售憑證
                            "DataType", "String",
                            "DataType":"string",
                            "Operate":"=",
                            "Value":"传入的参数值"
                        }
                    ]
                }

    */
     public static String createSapClientQueryArgs(
         String salesName,String customerCode
        ,String customerName,String riskCategory
        ,String totalamountReceivable,String overdueAmount
        ,String estimatedAmount,String overdueProportion,String letterLimit
        ,String openAmount,String prepaymentConditions
        ,String orderAmount,String purchaseorderNumber
        ,String prepaidAccounts){
    	List<Map<String,String>> lstCon = new List<Map<String,String>>();
        Integer index = 1;
    	if(!String.isBlank(salesName)){
            //銷售憑證
    		lstCon.add(createCondition(index,'Sales_name__c','String','=',salesName));
            index = index + 1;
    	}
    	
    	if(!String.isBlank(customerCode)){
            //客戶編號
	    	lstCon.add(createCondition(index,'Customer_code__c','String','=',customerCode));
            index = index + 1;
		}
        if(!String.isBlank(customerName)){
            //客戶名稱
            lstCon.add(createCondition(index,'Customer_name__c','String','=',customerName));
            index = index + 1;
        }
        if(!String.isBlank(riskCategory)){
            //風險類別
            lstCon.add(createCondition(index,'Risk_category__c','String','=',riskCategory));
            index = index + 1;
        }
        if(!String.isBlank(totalamountReceivable)){
            //應收總額
            lstCon.add(createCondition(index,'Total_amount_receivable__c','String','=',totalamountReceivable));
            index = index + 1;
        }
        if(!String.isBlank(overdueAmount)){
            //逾期合計金額
            lstCon.add(createCondition(index,'Overdue_amount__c','String','=',overdueAmount));
            index = index + 1;
        }
        if(!String.isBlank(estimatedAmount)){
            //暫估金額
            lstCon.add(createCondition(index,'Estimated_amount__c','String','=',estimatedAmount));
            index = index + 1;
        }
        if(!String.isBlank(overdueProportion)){
            //逾期占比%
            lstCon.add(createCondition(index,'Overdue_proportion__c','String','=',overdueProportion));
            index = index + 1;
        }
        if(!String.isBlank(letterLimit)){
            //信貨限額
            lstCon.add(createCondition(index,'Letter_limit__c','String','=',letterLimit));
            index = index + 1;
        }
        if(!String.isBlank(openAmount)){
            //未清金額
            lstCon.add(createCondition(index,'Open_amount__c','String','=',openAmount));
            index = index + 1;
        }
        if(!String.isBlank(prepaymentConditions)){
            //付款條件
            lstCon.add(createCondition(index,'Prepayment_conditions__c','String','=',prepaymentConditions));
            index = index + 1;
        }        
       if(!String.isBlank(orderAmount)){
            //訂單金額
            lstCon.add(createCondition(index,'order_amount__c','String','=',orderAmount));
            index = index + 1;
        }        
        if(!String.isBlank(purchaseorderNumber)){
            //採購訂單編號
            lstCon.add(createCondition(index,'Purchase_Order_Number__c','String','=',purchaseorderNumber));
            index = index + 1;
        }        
        if(!String.isBlank(prepaidAccounts)){
            //預收帳款
            lstCon.add(createCondition(index,'Prepaid_accounts__c','String','=',prepaidAccounts));
            index = index + 1;
        }
    	return JSON.serialize(createQueryArg('ClientQuery',lstCon));
    }
    /*
        目  的：创建传送给SAP的查询(客户协议合同及协议合同物料清单)接口参数
        参  数：customerCode - 客户编号
        返回值：SapWebServiceQueryArgs类实例序列化后的Json字符串：
                {
                    "approval":"CustomerContractMaterialQuery", 
                    "assemble":"",
                    "conditions":
                    [
                        {
                            "NO":"1",
                            "FieldName":"Customer_Code",//客户编号
                            "DataType", "String",
                            "DataType":"string",
                            "Operate":"=",
                            "Value":"传入的参数值"
                        }
                    ]
                }

    */
    public static String createSapCustomerContractMaterialArgs(String customerCode){
        List<Map<String,String>> lstCon = new List<Map<String,String>>();
        Integer index = 1;
        if(!String.isBlank(customerCode)){
            //客户编号
            lstCon.add(createCondition(index,'Customer_Code','String','=',customerCode));
            index = index + 1;
        }else{
            System.debug('*** 输入参数不能为空(createSapCustomerContractMaterialArgs)！');
            return '';
        }
        return JSON.serialize(createQueryArg('CustomerContractMaterialQuery',lstCon));
    }
    /*
        目  的：创建传送给SAP的查询(客户账单)接口参数
        参  数：customerCode - 客户编号
        返回值：SapWebServiceQueryArgs类实例序列化后的Json字符串：
                {
                    "approval":"CustomerBillingQuery", 
                    "assemble":"",
                    "conditions":
                    [
                        {
                            "NO":"1",
                            "FieldName":"Customer_Code__c",//客户编号
                            "DataType", "String",
                            "Operate":"=",
                            "Value":"传入的参数值"
                        }
                    ]
                }
    */
    public static String createSapCustomerBillingQueryArgs(String customerCode,Boolean hasBeenInvoiced, Boolean notInvoiced, Boolean prepayment){
        List<Map<String,String>> lstCon = new List<Map<String,String>>();
        Integer index = 1;
        if(!String.isBlank(customerCode)){
            //客户编号
            lstCon.add(createCondition(index,'Customer_Code__c','String','=',customerCode));
            
            index = index + 1;
        }
        lstCon.add(createCondition(index,'hasBeenInvoiced','String','=',String.valueOf(hasBeenInvoiced)));index++;
        lstCon.add(createCondition(index,'notInvoiced','String','=',String.valueOf(notInvoiced)));index++;
        lstCon.add(createCondition(index,'prepayment','String','=',String.valueOf(prepayment)));index++;

        return JSON.serialize(createQueryArg('CustomerBillingQuery',lstCon));
    }
    /*
        目  的：创建传送给SAP的查询(客户订单明细)接口参数
        参  数：orderCode - 客户编号
        返回值：SapWebServiceQueryArgs类实例序列化后的Json字符串：
                {
                    "approval":"CustomerBillingQuery", 
                    "assemble":"",
                    "conditions":
                    [
                    	{
							"NO":"1",
							"FieldName":"Customer_Code__c",//客户编号
                            "DataType", "String",
							"Operate":"=",
							"Value":"传入的参数值"
                    	}
                    ]
                }

    */
    public static String createSapOrderDetailQueryArgs(String orderCode){
    	List<Map<String,String>> lstCon = new List<Map<String,String>>();
        Integer index = 1;
    	if(!String.isBlank(orderCode)){
            //订单编号
    		lstCon.add(createCondition(index,'Order_Code__c','String','=',orderCode));
            index = index + 1;
    	}
    	return JSON.serialize(createQueryArg('CustomerOrderDetailQuery',lstCon));
    }
    /*
        目  的：创建传送给SAP的查询(出差申请单)接口参数
        参  数：travelCode - 出差申请单号
        返回值：SapWebServiceQueryArgs类实例序列化后的Json字符串：
                {
                    "approval":"StaffTravelQuery", 
                    "assemble":"",
                    "conditions":
                    [
                    	{
							"NO":"1",
							"FieldName":"Travel_Code__c",//出差申请单号
                            "DataType", "String",
							"Operate":"=",
							"Value":"传入的参数值"
                    	}
                    ]
                }

    */
    public static String createSapStaffTravelQueryArgs(String travelCode){
    	List<Map<String,String>> lstCon = new List<Map<String,String>>();
        Integer index = 1;
    	if(!String.isBlank(travelCode)){
            //出差申请单号
    		lstCon.add(createCondition(index,'Travel_Code__c','String','=',travelCode));
            index = index + 1;
    	}
        return JSON.serialize(createQueryArg('StaffTravelQuery',lstCon));
    }
    public static String createSapCustomerArgs(String customerCode){
        return createSapCustomerArgs(customerCode,'','','','','','');
    }

    /*
        目  的：创建传送给SAP的查询(客户主数据)接口参数
        参  数：customerCode - 客户代码
        参  数：customerName - 客户名称
        参  数：corpCode - 公司代码
        参  数：purchaseOrg - 销售组织代码
        参  数：distributionChannel - 分销渠道代码
        参  数：productGroup - 产品组代码
        参  数：subjectGroup - 科目组代码
        返回值：SapWebServiceQueryArgs类实例序列化后的Json字符串：
                {
                    "approval":"CustomerQuery",
                    "assemble":"",
                    "conditions":
                    [
                        {
                            "NO":"1",
                            "FieldName":"Customer_Code__c",//客户代码
                            "DataType":"String",
                            "Operate":"=",
                            "Value:"MT5487512"
                        },
                        {
                            "NO":"2",
                            "FieldName":"Corporation__c",//公司代码
                            "DataType":"String",
                            "Operate":"=",
                            "Value:"MT5487512"
                        },
                        {
                            "NO":"3",
                            "FieldName":"Purchase_Org__c",//销售组织代码
                            "DataType":"String",
                            "Operate":"=",
                            "Value:"MT5487512"
                        },
                        {
                            "NO":"4",
                            "FieldName":"Distribution_Channel__c",//分销渠道代码
                            "DataType":"String",
                            "Operate":"=",
                            "Value:"MT5487512"
                        },
                        {
                            "NO":"5",
                            "FieldName":"Product_Group__c",//产品组代码
                            "DataType":"String",
                            "Operate":"=",
                            "Value:"MT5487512"
                        },
                        {
                            "NO":"6",
                            "FieldName":"Subject_Group__c",//科目组
                            "DataType":"String",
                            "Operate":"=",
                            "Value:"MT5487512"
                        }
                    ]
                }
    */
    public static String createSapCustomerArgs(
        String customerCode,
        String customerName,
        String corpCode,
        String purchaseOrg,
        String distributionChannel,
        String productGroup,
        String subjectGroup){
        List<Map<String,String>> lstCon = new List<Map<String,String>>();
        Integer index = 1;
        if(!String.isBlank(customerCode)){
            //客户代码
            lstCon.add(createCondition(index,'Customer_Code__c','String','LIKE',customerCode));
            index = index + 1;
        }   

        if(!String.isBlank(customerName)){
            //客户名称
            lstCon.add(createCondition(index,'Account_Name__c','String','LIKE',customerName));
            index = index + 1;
        }
        if(!String.isBlank(corpCode)){
            //公司代码
            lstCon.add(createCondition(index,'Corporation__c','String','=',corpCode));
            index = index + 1;
        }
        if(!String.isBlank(purchaseOrg)){
            //销售组织代码
            lstCon.add(createCondition(index,'Purchase_Org__c','String','=',purchaseOrg));
            index = index + 1;
        }
        if(!String.isBlank(distributionChannel)){
            //分销渠道代码
            lstCon.add(createCondition(index,'Distribution_Channel__c','String','=',distributionChannel));
            index = index + 1;
        }
        if(!String.isBlank(productGroup)){
            //产品组代码
            lstCon.add(createCondition(index,'Product_Group__c','String','=',productGroup));
            index = index + 1;
        }
        if(!String.isBlank(subjectGroup)){
            //科目组
            lstCon.add(createCondition(index,'Subject_Group__c','String','=',subjectGroup));
            index = index + 1;
        }
        
        return JSON.serialize(createQueryArg('CustomerQuery',lstCon));
    }

    public static String createCustomerTestcateArgs(){
        return createCustomerTestcateArgs('test');
    }

    public static String createCustomerTestcateArgs(String customerCode){
        List<Map<String,String>> lstCon = new List<Map<String,String>>();
        Integer index = 1;
        if(!String.isBlank(customerCode)){
            //客户代码
            lstCon.add(createCondition(index,'Customer_Code__c','String','LIKE',customerCode));
            index = index + 1;
        }   

        
        return JSON.serialize(createQueryArg('CustomerQuery',lstCon));
    }

    public static String createSapVendorArgs(String vendorCode){
        return createSapVendorArgs(vendorCode,'','','','');
    }

    public static String createSapVendorArgs(
        String vendorCode,
        String vendorName,
        String corpCode,
        String purchaseOrg,
        String AccountGroup)
    {
        List<Map<String,String>> lstCon = new List<Map<String,String>>();
        Integer index = 1;
        if(!String.isBlank(vendorCode)){
            //供应商代码
            lstCon.add(createCondition(index,'Vendor_Number__c','String','LIKE',vendorCode));
            index = index + 1;
        }   

        if(!String.isBlank(vendorName)){
            //供应商名称
            lstCon.add(createCondition(index,'Vendor_Name__c','String','LIKE',vendorName));
            index = index + 1;
        }
        if(!String.isBlank(corpCode)){
            //公司代码
            lstCon.add(createCondition(index,'Corporation__c','String','=',corpCode));
            index = index + 1;
        }
        if(!String.isBlank(purchaseOrg)){
            //采购组织
            lstCon.add(createCondition(index,'Purchase_Org__c','String','=',purchaseOrg));
            index = index + 1;
        }
        if(!String.isBlank(AccountGroup)){
            //账户组
            lstCon.add(createCondition(index,'Account_Group__c','String','=',AccountGroup));
            index = index + 1;
        }
      
        
        return JSON.serialize(createQueryArg('VendorQuery',lstCon));
    }
    public static String createMaterialCertificateArgs(String materialCertificateCode){
        return createMaterialCertificateArgs(materialCertificateCode,'','','','');
    }
    /*
        目  的：创建传送给SAP的查询(材证资料)接口参数
        参  数：materialCertificateCode - 材证编号
        参  数：materialNumber - 物料号
        参  数：stockingNO - 备货单号
        参  数：contractNO - 合同号
        参  数：batchNO - 批次
        返回值：SapWebServiceQueryArgs类实例序列化后的Json字符串：
                {
                    "approval":"MaterialCertificate",
                    "assemble":"",
                    "conditions":
                    [
                        {
                            "NO":"1",
                            "FieldName":"Material_Certificate_Code",//材证编号
                            "DataType":"String",
                            "Operate":"=",
                            "Value:"MT5487512"
                        },
                        {
                            "NO":"2",
                            "FieldName":"Material_Number",//物料号
                            "DataType":"String",
                            "Operate":"=",
                            "Value:"MT5487512"
                        },
                        {
                            "NO":"3",
                            "FieldName":"Stocking_NO",//备货单号
                            "DataType":"String",
                            "Operate":"=",
                            "Value:"MT5487512"
                        },
                        {
                            "NO":"4",
                            "FieldName":"Contract_NO",//合同号
                            "DataType":"String",
                            "Operate":"=",
                            "Value:"MT5487512"
                        },
                        {
                            "NO":"5",
                            "FieldName":"Batch_NO",//批次
                            "DataType":"String",
                            "Operate":"=",
                            "Value:"MT5487512"
                        }
                    ]
                }
    */
    public static String createMaterialCertificateArgs(
        String materialCertificateCode,
        String materialNumber,
        String stockingNO,
        String contractNO,
        String batchNO){
        List<Map<String,String>> lstCon = new List<Map<String,String>>();
        Integer index = 1;
        if(!String.isBlank(materialCertificateCode)){
            //材证编号
            lstCon.add(createCondition(index,'Material_Certificate_Code','String','=',materialCertificateCode));
            index = index + 1;
        }
        if(!String.isBlank(materialNumber)){
            //物料号
            lstCon.add(createCondition(index,'Material_Number','String','=',materialNumber));
            index = index + 1;
        }
        if(!String.isBlank(stockingNO)){
            //备货单号
            lstCon.add(createCondition(index,'Stocking_NO','String','=',stockingNO));
            index = index + 1;
        }
        if(!String.isBlank(contractNO)){
            //合同号
            lstCon.add(createCondition(index,'Contract_NO','String','=',contractNO));
            index = index + 1;
        }
        if(!String.isBlank(batchNO)){
            //批次
            lstCon.add(createCondition(index,'Batch_NO','String','=',batchNO));
            index = index + 1;
        }
        return JSON.serialize(createQueryArg('MaterialCertificate',lstCon));
    }
    
    //盤盈虧   //QUERY物料編號
    public static String createSapMaterialQueryDesc(String materialNumber){
        return createSapMaterialQueryDesc(materialNumber,'');
    }
    /*
        目  的：创建传送给SAP的查询(物料)接口参数
        参数 1：materialNumber - 物料编号
        参数 4：materialDesc - 物料描述
        返回值：createSapMaterialQueryDesc类实例序列化后的Json字符串：
                {
                    "approval":"MaterialQuery", 
                    "assemble":"",
                    "conditions":
                    [
                        {
                            "NO":"1",
                            "FieldName":"Material_Number__c",
                            "DataType":"String",
                            "Operate":"=",
                            "Value":"传入的参数值"
                        },
                        {
                            "NO":"2",
                            "FieldName":"Material_Description__c",
                            "DataType":"String",
                            "Operate":"LIKE",
                            "Value":"传入的参数值"
                        }
                    ]
                }
    */
    public static String createSapMaterialQueryDesc(String materialNumber,String materialDesc){
        List<Map<String,String>> lstCon = new List<Map<String,String>>();
        Integer index = 1;
        Map<String,String> con1 = new Map<String,String>();
        //物料号
        lstCon.add(createCondition(index,'Material_Number__c','String','=',materialNumber));
        index = index + 1;
        //物料描述
        if(!String.isBlank(materialDesc)){
            lstCon.add(createCondition(index,'Material_Description__c','String','LIKE',materialDesc));
            index = index + 1;
        }
        return JSON.serialize(createQueryArg('MaterialDesc',lstCon));
    }
    
    
    /*
        格式为SAP日期格式
    */
    public static String formatSAPDate(Date dDate)
    {
        return Datetime.newInstance(dDate,Time.newInstance(0, 0, 0, 0)).format('yyyyMMdd');
    }
    /*
        目  的：创建条件
        参数 1：index - 顺序
        参数 2：fieldName - 字段名
        参数 3：dataType - 字段数据类型
        参数 4：operate - 条件
        参数 5：val - 值
        返回值：

    */
    public static Map<String,String> createCondition(Integer index,String fieldName,String dataType,String operate,String val){
        Map<String,String> con = new Map<String,String>();
        con.put('Value', val);
        con.put('Operate', operate);
        con.put('DataType', dataType);
        con.put('FieldName', fieldName);
        con.put('NO',  String.valueOf(index));
        return con;
    }
    public static SapWebServiceQueryArgs createQueryArg(String approval,List<Map<String,String>> conditions){
        return createQueryArg(approval,conditions,'');
    }
    /*
        目  的：创建查询参数
        参数 1：approval - 查询标识
        参数 2：conditions - 查询条件
        参数 3：assemble - 查询组合表达式
        返回值：

    */
    public static SapWebServiceQueryArgs createQueryArg(String approval,List<Map<String,String>> conditions,String assemble){
        SapWebServiceQueryArgs arg = new SapWebServiceQueryArgs();
        arg.conditions = conditions;
        arg.assemble = assemble;
        arg.approval = approval;
        return arg;
    } 

    public static String createVacationQuery(String pernr){
        List<Map<String,String>> lstCon = new List<Map<String,String>>();
        Integer index = 1;
        if(!String.isBlank(pernr)){
            lstCon.add(createCondition(index,'Employee_Code__c','String','=',pernr));
            index = index + 1;
        }
        System.debug(LoggingLevel.INFO, '*** lstCon[0]: ' + lstCon[0]);
        return JSON.serialize(createQueryArg('VacationQuery',lstCon));
    }

//客户信用贷款主数据申请
     public static String createSapCreditLoanQueryDesc(String Account,String CreditArea){
        return createSapCreditLoanQueryDesc(Account,CreditArea,'','','','','','','','','','','');
    }

    public static String createSapCreditLoanQueryDesc(String Account,String CreditArea,String Currency2,
    String credit_line,String Amount_receivable, String Special_current_debt,
    String Credit_account_numbe,String Used_Credit_amount,String Sales_value,
    String Credit_validity,String Total_credit_risk,String Guarantee_amount_receivable,
    String Risk_kind){
        List<Map<String,String>> lstCon = new List<Map<String,String>>();
        Integer index = 1;
        Map<String,String> con1 = new Map<String,String>();
        //客户
        if (!String.isBlank(Account)) {
            lstCon.add(createCondition(index,'Account__c','String','=',Account));
        index = index + 1;
        }
        // 信用控制范围
        if (!String.isBlank(CreditArea)) {
            lstCon.add(createCondition(index,'CreditArea__c','String','=',CreditArea));
        index = index + 1;
        }
        // 信用额度
        if(!String.isBlank(credit_line)){
            lstCon.add(createCondition(index,'credit_line__c','String','LIKE',credit_line));
            index = index + 1;
        }
        //币种
        if (!String.isBlank(Currency2)) {
            lstCon.add(createCondition(index,'Currency__c','String','LIKE',Currency2));
            index = index + 1;
        }
         //应收金额
        if (!String.isBlank(Amount_receivable)) {
            lstCon.add(createCondition(index,'Amount_receivable__c','String','LIKE',Amount_receivable));
            index = index + 1;
        }
         //特别往来债务
        if (!String.isBlank(Special_current_debt)) {
            lstCon.add(createCondition(index,'Special_current_debt__c','String','LIKE',Special_current_debt));
            index = index + 1;
        }
         //信贷帐户号码--
        if (!String.isBlank(Credit_account_numbe)) {
            lstCon.add(createCondition(index,'Credit_account_numbe__c','String','LIKE',Credit_account_numbe));
            index = index + 1;
        }
         //已使用信贷金额
        if (!String.isBlank(Used_Credit_amount)) {
            lstCon.add(createCondition(index,'Used_Credit_amount__c','String','LIKE',Used_Credit_amount));
            index = index + 1;
        }
         //销售值
        if (!String.isBlank(Sales_value)) {
            lstCon.add(createCondition(index,'Sales_value__c','String','LIKE',Sales_value));
            index = index + 1;
        }
         //信用有效期
        if (!String.isBlank(Credit_validity)) {
            lstCon.add(createCondition(index,'Credit_validity__c','String','LIKE',Credit_validity));
            index = index + 1;
        }
         //信用贷款风险总额
        if (!String.isBlank(Total_credit_risk)) {
            lstCon.add(createCondition(index,'Total_credit_risk__c','String','LIKE',Total_credit_risk));
            index = index + 1;
        }
         //担保应收金额
        if (!String.isBlank(Guarantee_amount_receivable)) {
            lstCon.add(createCondition(index,'Guarantee_amount_receivable__c','String','LIKE',Guarantee_amount_receivable));
            index = index + 1;
        }
         //风险类别
        if (!String.isBlank(Risk_kind)) {
            lstCon.add(createCondition(index,'Risk_kind__c','String','LIKE',Risk_kind));
            index = index + 1;
        }
        return JSON.serialize(createQueryArg('CustomerCreditLoan',lstCon));    
    }
    

    
    

}