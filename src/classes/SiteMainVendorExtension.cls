public without sharing class SiteMainVendorExtension{
	public String username {get; set;}
    public String language {get; set;}
    public String URL_Customer{GET;SET;}
    public static String URLCustomer{GET;SET;}
    public SiteMainVendorExtension() {
        System_Setting__c ssc = System_Setting__c.getValues('Setting');
        URL_Customer = ssc.URL_Customer__c;
        URLCustomer  = ssc.URL_Customer__c;
         language = Apexpages.currentPage().getParameters().get('language');
        if (language == '') {
            language = 'zh-CN';
        }
    }
     public static PageReference isUserExist() {
        Cookie un = ApexPages.currentPage().getCookies().get('un');
        System.debug(LoggingLevel.INFO, '*** un: ' + un);
        //如果Cookie为空重新登录
        // if (un == null) {
            // System.debug(LoggingLevel.INFO, '*** 1: ' + 1);
            // return new PageReference('/apex/SiteSignIn');
        // } else {
            //延时Cookie
            // un = new Cookie('un', un.getValue(), null, 7200, false);
            // ApexPages.currentPage().setCookies(new Cookie[] {un});
            return null;
        // }
    }
    public PageReference exit() {
        System_Setting__c ssc = System_Setting__c.getValues('Setting');
        URLCustomer  = ssc.URL_Customer__c;
        //注销Cookie
        try{
            Cookie un = new Cookie('apex__un', '', null, 1, false);
            ApexPages.currentPage().setCookies(new Cookie[] {un});
            PageReference page = new PageReference(URLCustomer + '/SiteSignIn?language=' + language);
            page.setRedirect(true);
            return page;
        }catch(Exception ex){
            System.debug('*** 注销Cookie出错：'+ ex.getMessage() + '; ' + ex.getStackTraceString());
            return null;
        }
    }
    public static PageReference check(){
        System.debug('*** 进入检查函数（check）');
        System_Setting__c ssc = System_Setting__c.getValues('Setting');
        URLCustomer  = ssc.URL_Customer__c;
        if(!SiteSecurityService.userValidation(ApexPages.currentPage(),'Vendor')){
            return new PageReference(URLCustomer + '/SiteSignIn');
        }else{
            return null;
        }
    }
}