public without sharing class SiteUserInfoExtension {
    public Account acc {Get; Set;}
    public String userName {Get; Set;}
    public String language {Get; Set;}
    public String url_Customer {Get; Set;}
    public SiteUserInfoExtension() {
        System_Setting__c ssc = System_Setting__c.getValues('Setting');
        url_Customer = ssc.URL_Customer__c;
    }
   
    public PageReference getUserInfo() {
            
        PageReference page = CustomerController.isUserExist();
        if (page != null) {
            page.setRedirect(true);
            return page;
        }
        //获取登录用户选择的语言参数信息
        language = Apexpages.currentPage().getParameters().get('language');
        if (language == '') {
            language = 'zh-CN';
        }
        Cookie un = ApexPages.currentPage().getCookies().get('un');
        System.debug(LoggingLevel.INFO, '*** un: ' + un);
        //如果Cookie为空提示登录信息错误，重新登录
        if (un == null) {
            System.debug(LoggingLevel.INFO, '*** 1: ' + 1);
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, Label.UserErrorMessage));
            return null;
        } else {
            try {
                //解密用户名信息
                
                userName = un.getValue();
                //将用户名加密后存入Cookie
                un = new Cookie('un', userName, null, 300, false);
                //查询该用户名对应的客户信息
                acc = [SELECT Name, SAPID__c, Tax_Number__c, Corp_Address__c, Billing_Address1__c, Shopping_Address1__c
                       FROM Account
                       WHERE SAPID__c = :userName OR Customer_Number__c = :userName];
                return null;
            } catch (Exception e) {
                ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
                return null;
            }
        }
    }

}