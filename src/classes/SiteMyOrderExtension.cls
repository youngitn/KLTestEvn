global without sharing class SiteMyOrderExtension {
    public String url_Customer {Get; Set;}
    public SiteMyOrderExtension() {
        Cookie un = ApexPages.currentPage().getCookies().get('un');

    }
    public PageReference check(){
        System_Setting__c ssc = System_Setting__c.getValues('Setting');
        url_Customer = ssc.URL_Customer__c;
        if(!SiteSecurityService.userValidation(ApexPages.currentPage(),'Customer')){
            return new PageReference(url_Customer + '/SiteSignIn');
        }else{
            return null;
        }
    }

    @RemoteAction
    global static Object queryCustomerOrder(String customerCode, String orderStatus, String orderCode, String createdDate, String deliveryDate) {
        String str1 = SapQueryArgCreate.createSapCustomerOrderQueryArgs(customerCode, orderStatus, orderCode, HarryUtils.str2Date(createdDate), HarryUtils.str2Date(deliveryDate));
        System.debug(str1);
        String str2 = '';
        str2 = Utils.postToSAP(str1);
        return JSON.deserializeUntyped(str2);
    }
    @RemoteAction
    global static Object queryOderDetail(String orderId) {
        String str1 = SapQueryArgCreate.createSapOrderDetailQueryArgs(orderId);
        System.debug(str1);
        String str2 = '';
        str2 = Utils.postToSAP(str1);
        return JSON.deserializeUntyped(str2);
    }
    @RemoteAction
    global static Object querySelfOrder(String username) {
        System.debug(LoggingLevel.INFO, '*** username: ' + username);
        String str1 = SapQueryArgCreate.createSapCustomerContractMaterialArgs(username);//'0001009030'
        String str2 = Utils.postToSAP(str1);
        return JSON.deserializeUntyped(str2);
    }
    @RemoteAction
    global static Object queryBill(String customercode, Boolean hasBeenInvoiced, Boolean notInvoiced, Boolean prepayment) {
        String str1 = SapQueryArgCreate.createSapCustomerBillingQueryArgs(customercode, hasBeenInvoiced, notInvoiced, prepayment);
        System.debug(LoggingLevel.INFO, '*** str1: ' + str1);
        String str2  = Utils.postToSAP(str1);
        return JSON.deserializeUntyped(str2);
    }
    @RemoteAction
    global static String submitOrder(String main, String detail) {
        SapCustomerContractMaterial.CustomerContract args = (SapCustomerContractMaterial.CustomerContract)JSON.deserialize(main, SapCustomerContractMaterial.CustomerContract.class);
        Map<String,String> main_arg = new Map<String,String>();
        main_arg.put('customer_code', args.main.Customer_Code);
        Map<String,List<Map<String,String>>> details = new Map<String,List<Map<String,String>>>();
        details.put('items', new List<Map<String,String>>());

        List<Map<String,String>> items = new List<Map<String,String>>();
        for(SapCustomerContractMaterial.MaterialList arg : args.details.materials){
            if(arg.checked){
                Map<String,String>  item = new Map<String,String>();
                item.put('Material_Code',arg.Material_Code);
                item.put('Customer_Material_Code',arg.Customer_Material_Code);
                item.put('Order_Quantity',arg.Order_Quantity);
                items.add(item);
            }
        }
        details.put('items', items);
        if(items.size() > 0){
            String str1  = Utils.serializeToJson('INSERT','PortalOrder',main_arg,details);
            String str2  = Utils.postToSAP(str1);
            SapWebServiceReturnResult result = (SapWebServiceReturnResult)JSON.deserialize(str2, SapWebServiceReturnResult.class);
            if(result.status == '1'){
                //发送邮件给销售内勤
                System_Setting__c ssc = System_Setting__c.getValues('Setting');
                String emailAddr = ssc.Inside_Sale_Email__c;
                Messaging.SingleEmailMessage el = new Messaging.SingleEmailMessage();
                //发送地址
                List<String> address = new List<String>();
                address.add(emailAddr);
                el.setToAddresses(address);
                el.setSubject('客户门户订单：' + result.message);
                el.setHtmlBody('您好：<br/>客户已在客户门户下单，订单号为：'+result.message + '；请跟进！');
                //发送邮件
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {el});

                return '您的订单下单成功！订单号为:' + result.message;
            }else{
                return '您的订单下单失败，请重试或联系我们的客服人员！失败原因：' + result.message;
            }
        }else{
            return '请选择订单项！';
        }
    }

    @RemoteAction
    global static Object queryAllContentDocuments(String username){
        List<ContentWorkspace> wslist = [SELECT Id,Name FROM ContentWorkspace WHERE Name = '客户门户'];
        
        List<ContentVersion> fileList = new List<ContentVersion>();
        if(wslist.size() > 0){
            Id pid = wslist[0].Id;
            fileList = [
            SELECT Id,ContentDocument.Title,ContentDocument.ContentSize,
                   ContentDocument.FileType,ContentDocument.FileExtension,ContentDocument.ArchivedDate 
            FROM ContentVersion WHERE ContentDocument.ParentId = :pid AND IsLatest = true];
        }
        System.debug(LoggingLevel.INFO, '*** fileList: ' + fileList);

        // String username = 'test';
        List<Account> accList = [SELECT Id FROM Account WHERE SAPID__c = : username OR Customer_Number__c=:username];
        Set<Id> cdIds = new Set<Id>();
        if(accList.size() > 0){
            Id uid = accList[0].Id;
            List<ContentDocumentLink> cdllist = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :uid];
            for(ContentDocumentLink cdlink : cdllist){
                cdIds.add(cdlink.ContentDocumentId);
            }
        }
        
        fileList.add([SELECT Id,ContentDocument.Title,ContentDocument.ContentSize,ContentDocument.FileType,
            ContentDocument.FileExtension,ContentDocument.ArchivedDate 
            FROM ContentVersion WHERE ContentVersion.ContentDocumentId in :cdIds AND IsLatest = true]);

        System.debug(LoggingLevel.INFO, '*** : ' + fileList);
        return fileList;
    }
}