public with sharing class SiteSignInVendorExtension {
	public String userName{Get;Set;}
    public String passWord{Get;Set;}
    public String language{Get;Set;}
    public Integer lKey{Get;Set;}
    public String types {Get; Set;}
    public List<Account> accList{Get;Set;}

    public SiteSignInVendorExtension() {
        
    }

      //刷新页面更换语言
     public void refresh()
     {

     }
    //更换ApexPage的语言设置
    public void changeLan(){
    System.debug(LoggingLevel.INFO, '*** language: ' + language);
    }
    //登录方法
    public PageReference login(){
        try{
           
            //判断用户名和密码是否为空
            if(userName==''||passWord=='')
            {

                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.Alertmessage)	);
                return null;         
            }
            else
            {
                 System.debug(LoggingLevel.INFO, '*** type: ' + types );
                System.debug(LoggingLevel.INFO, '*** type: ' +userName );
                //查询客户中是否存在该用户名和密码的客户， AND RecordType.DeveloperName = 'Vendor'
                accList=[SELECT SAPID__c,customer_password__c 
                         FROM Account 
                         WHERE SAPID__c=:userName and customer_password__c=:passWord and RecordType.DeveloperName =:types];
                         System.debug(LoggingLevel.INFO, '*** accList: ' + accList );
                //不为空表示用户名和密码正确
                 PageReference page  = new PageReference('/apex/SiteMain');//默认客户
                if(!accList.isEmpty()){
                         if (types=='vendor')
                         {
                         page  =  new PageReference('/apex/SiteMainVendor');
                         }
                        
                        // 将用户名加密,存入Cookie
                         // Blob cipherText=Blob.valueOf(userName);

                         // String encodedCipherText = EncodingUtil.base64Encode(cipherText);
                   
                     Cookie un = new Cookie('un', userName, null, 7200, false);
                    System.debug(LoggingLevel.INFO, '*** un.getValue(): ' + un.getValue());
                    ApexPages.currentPage().setCookies(new Cookie[] {un});
                    page.setCookies(new Cookie[] {un});
                    page.getParameters().put('language', language);
                    page.setRedirect(true);
                    return page;

                }
                //为空提示错误信息，用户名或密码错误！
                else{
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.ErrorMessage1));
                        return null;
                }
            }
        }
        catch (Exception e) {
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR,

            e.getMessage()));
            return null;
        }
    }
}