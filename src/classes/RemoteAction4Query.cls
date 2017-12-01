global without sharing class RemoteAction4Query {
    public RemoteAction4Query() {}
    @RemoteAction
    global static String queryCustomerOrder(String customerCode,String orderStatus,String createdDate,String deliveryDate){
        // return SapQueryArgCreate.createSapCustomerOrderQueryArgs( customerCode, orderStatus, createdDate, deliveryDate);
        return '{"status":"1","message":"成功为空，失败时为失败原因信息","orders":[{"Customer_Contract_No__c":"客户合同号","Order_Code__c":"订单编号","Order_Date__c":"下单日期","Order_Time__c":"下单时间","Order_Status__c":"订单状态","Total_Amount__c":"总金额","Currency__c":"币种","Delivery_Address__c":"交货地址","Predelivery_Date__c":"预交日期","Predelivery_Time__c":"预交时间","Project_Name__c":"项目名称"}]}';
    }
    /*
		查询客户主数据
    */
    @RemoteAction
    global static SapWebServiceReturnArgs getCustomerInfo(String custCode){
        String str1 = SapQueryArgCreate.createSapCustomerArgs(custCode);
        System.debug(str1);
        String str2 = Utils.postToSAP(str1);
        SapWebServiceReturnArgs swsra = (SapWebServiceReturnArgs)JSON.deserialize(str2, SapWebServiceReturnArgs.class);
        return swsra;
    }
}