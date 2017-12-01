public without sharing class SiteUpdatePasswordExtension {
    public String pwdList {Get; Set;}
    public String pwd {Get; Set;}
    public String newPwd {Get; Set;}
    public String newPwd2 {Get; Set;}
    public String userName {Get; Set;}
    public String language {Get; Set;}
    public String url_Customer {Get; Set;}
    public SiteUpdatePasswordExtension() {
        System_Setting__c ssc = System_Setting__c.getValues('Setting');
        url_Customer = ssc.URL_Customer__c;
        //获取登录的语言参数信息
        language = Apexpages.currentPage().getParameters().get('language');
        if (language == '') {
            language = 'zh-CN';
        }
    }

    public PageReference updatePwd() {
        try {
            //将页面输入的密码数据传到Class,用于后台验证
            List<String> plist = (List<String>)JSON.deserialize(pwdList,List<String>.class);
            System.debug(LoggingLevel.INFO, '*** plist.size(): ' + plist.size());
            pwd = plist[0];
            newPwd = plist[1];
            newPwd2 = plist[2];
            //存在没有填写的密码，提示填写完整信息
            if (pwd == '' || newpwd == '' || newpwd2 == '') {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Not_Complete));
                return null;
            }
            //确认密码输入不一致，提示重新输入。
            else if (newPwd != newPwd2) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.pwd_IsDifferent));
                return null;
            } else {
                //获取Cookie中用户名信息，查询对应用户名密码，
                Cookie un = ApexPages.currentPage().getCookies().get('un');
          /*      Blob data = EncodingUtil.base64Decode(un.getValue());
                userName = data.toString();*/
                userName = un.getValue();
                Account acc = [SELECT Id, customer_password__c
                               FROM Account
                               WHERE SAPID__c = :userName OR Customer_Number__c =:userName];
                if (acc.customer_password__c != pwd) {
                    //与数据库中密码不一致，提示原始密码错误
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.old_Pwd_Error));
                    return null;
                } else {
                    //将NewPwd赋值，update用户信息
                    acc.customer_password__c = newPwd;
                    update acc;
                    //跳转客户信息界面，confirm=1表示密码修改成功,在客户信息界面提示密码修改成功.
                    Cookie pw = new Cookie('apex__pw', EncodingUtil.base64Encode(Blob.valueOf(newPwd)), null, 7200, false);
                    ApexPages.currentPage().setCookies(new Cookie[] {pw});
                    ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.INFO, '您的密码已成功更新！'));
                    return null;
                }
            }
            // 查询该用户名对应的客户密码信息
        } catch (Exception e) {
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            return null;
        }
    }

    public PageReference Cancel() {
        PageReference page = new PageReference(url_Customer + '/SiteUserInfo');
        page.getParameters().put('language', language);
        return page;
    }
}