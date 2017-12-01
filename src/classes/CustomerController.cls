// **************************************************************************************************
//  * Name: CustomerController
//  * Object:
//  * Purpose: 客户门户界面的Extension
//  * Requirement:
//  * Author: luoxin
//  * Create Date: 2017-3-24
//  * Modify History:
// *****************************************************************************************************
public without sharing class CustomerController {
    public String username {get; set;}
    public String language {get; set;}
    public CustomerController() {
        language = Apexpages.currentPage().getParameters().get('language');
        if (language == '') {
            language = 'zh-CN';
        }
    }


    public static PageReference isUserExist() {
        Cookie un = ApexPages.currentPage().getCookies().get('un');
        System.debug(LoggingLevel.INFO, '*** un: ' + un);
        //如果Cookie为空重新登录
        if (un == null) {
            System.debug(LoggingLevel.INFO, '*** 1: ' + 1);
            return new PageReference('/apex/LoginPage');
        } else {
            //延时Cookie
            un = new Cookie('un', un.getValue(), null, 7200, false);
            ApexPages.currentPage().setCookies(new Cookie[] {un});
            return null;
        }
    }

    public PageReference exit() {
        //注销Cookie
        Cookie un = ApexPages.currentPage().getCookies().get('un');
        un = new Cookie('un', userName, null, 0, false);
        ApexPages.currentPage().setCookies(new Cookie[] {un});
        return new PageReference('/apex/LoginPage');
    }
    // @RemoteAction
    // public static Boolean checkCookie(String un) {
    //     // Cookie un = ApexPages.currentPage().getCookies().get('un');
    //     System.debug(LoggingLevel.INFO, '*** un: ' + un);
    //     //如果Cookie为空重新登录
    //     if (un == null) {
    //         System.debug(LoggingLevel.INFO, '*** 1: ' + 1);
    //         return true;
    //     } else {
    //         //延时Cookie
    //         un = new Cookie('un', un.getValue(), null, 300, false);
    //         ApexPages.currentPage().setCookies(new Cookie[] {un});
    //         return false;
            
    //     }
    // }
}