global with sharing class MyCangExtension {
    public MyCangExtension() {
        
    }

    @RemoteAction
    global static Object queryCustomer(String customerCod){
    	//SapQueryArgCreate.createCustomerTestcateArgs 对数据处理 返回Json
        String str1 = SapQueryArgCreate.createCustomerTestcateArgs(customerCod);
        //utils.posttosap 执行sap交互
        String str2 = Utils.postToSAP(str1);
        return JSON.deserializeUntyped(str2);
    }


}