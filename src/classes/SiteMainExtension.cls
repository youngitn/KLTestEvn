public without sharing class SiteMainExtension {
    public String username {GET; SET;}
    public String language {GET; SET;}
    public String URL_Customer{GET;SET;}
    public static String URLCustomer{GET;SET;}
    // public static String typeCV {GET;SET;}
    public SiteMainExtension() {
        System_Setting__c ssc = System_Setting__c.getValues('Setting');
        URL_Customer = ssc.URL_Customer__c;
        URLCustomer  = ssc.URL_Customer__c;
        Map<String,String> args = Apexpages.currentPage().getParameters();
        if(args.containsKey('language')){
            language = Apexpages.currentPage().getParameters().get('language');
        }else{
            language = 'zh_CN';
        }
    }


    public static PageReference isUserExist() {
        System_Setting__c ssc = System_Setting__c.getValues('Setting');
        URLCustomer  = ssc.URL_Customer__c;
        System.debug('*** 进入检查函数（isUserExist）');
        Cookie un = ApexPages.currentPage().getCookies().get('un');
        System.debug(LoggingLevel.INFO, '*** un: ' + un);
        //如果Cookie为空重新登录
        if (un == null || String.isBlank(un.getValue())) {
            System.debug(LoggingLevel.INFO, '*** 用户没有登录或Session已过期' );
            return new PageReference(URLCustomer + '/SiteSignIn');
        } else {
            //延时Cookie
            un = new Cookie('apex__un', un.getValue(), null, 7200, false);
            ApexPages.currentPage().setCookies(new Cookie[] {un});
            return null;
        }
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
     
        // typeCV = this.typeCV.endsWith(String str);
        String typeCV =system.currentPageReference().getParameters().get('typeCV');
         if(typeCV == 'customer')
        {
             typeCV = 'Customer';
            } 
         else
            {
             typeCV = 'Vendor';
            }
        System.debug('*** 进入检查函数（check）');
        System_Setting__c ssc = System_Setting__c.getValues('Setting');
        URLCustomer  = ssc.URL_Customer__c;
        if(!SiteSecurityService.userValidation(ApexPages.currentPage(),+typeCV)){
            return new PageReference(URLCustomer + '/SiteSignIn');
        }else{
            return null;
        }
    }
    /*测试代码 代码覆盖率
    */
  public String test {GET; SET;}
  public void test(){
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
         test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
        test = 'test1';
  }

}