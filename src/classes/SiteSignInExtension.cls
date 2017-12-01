// **************************************************************************************************
//  * Name: LoginExtension
//  * Object:
//  * Purpose: 登录的后台Extension
//  * Requirement:
//  * Author: luoxin
//  * Create Date: 2017-3-24
//  * Modify History:
// *****************************************************************************************************
global without sharing class SiteSignInExtension {
    public static Boolean isRunTestMode = false;
    public String userName {Get; Set;}
    public String passWord {Get; Set;}

    public String language {Get; Set;}
    public String typeCV {Get; Set;}
    public String URL_Vendor {Get; Set;}
    public String URL_Customer {Get; Set;}

    public Integer lKey {Get; Set;}
    // public List<Account> accList {Get; Set;}
    public SiteSignInExtension() {
        Map<String,String> args = Apexpages.currentPage().getParameters();
        if(args.containsKey('language')){
            language = Apexpages.currentPage().getParameters().get('language');
        }else{
            language = 'zh_CN';
        }
        if(args.containsKey('typeCV')){
            typeCV = Apexpages.currentPage().getParameters().get('typeCV');
        }else{
            typeCV = 'customer';
        }
        System_Setting__c ssc = System_Setting__c.getValues('Setting');
        URL_Customer = ssc.URL_Customer__c;
        // URL_Customer = 'apex';
    }

    //更换ApexPage的语言设置
    public void changeLan() {
        System.debug(LoggingLevel.INFO, '*** language: ' + language);
    }

    //刷新页面更换语言
    public void refresh() {

    }

    @RemoteAction
    global static Boolean signin(String username, String password,String rtName) {
        System.debug('*** 用户名：' + username);
        System.debug('*** 密码：' + password);
        System.debug('*** 类型：' + rtName);
       
        //查询客户门户权限开通
        if (rtName == 'Customer') {
            String strjosn = '{"approval":"CUSTOMERPORTAL","account_id":"'+username+'"}';
            String str = '';
            if (!isRunTestMode) {
                 str =  Utils.postToSAP(strjosn);
            }
            if (str == 'false') {
                return false;
            }
        }
       
       
        List<Account> accList = [
                SELECT SAPID__c, customer_password__c 
                FROM Account 
                WHERE (SAPID__c = :userName OR Vendor_Number__c = :userName OR Customer_Number__c = :userName) 
                AND customer_password__c = :passWord
                AND RecordType.DeveloperName = :rtName];
        if(accList.size() > 0){
            return true;
        }else{
            return false;
        }
    }


}