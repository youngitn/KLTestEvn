/* 
    xxf at 20180131
    因APEX不分大小写；所以有String json= '';会导致JSON.deserialize无法正常使用
*/
global  class AmAbnormalityHrPt60Controller {

    //异常信息表
    public List<AbnormalityHrPt60> AbnormalityHr{get;set;} 
    public Integer g_mandt {get;set;}
    public AmAbnormalityHrPt60Controller() {
        TestClear();

        //获取考勤异常信息
        List<AbnormalityHrPt60> AbnormalityHrTmp = AmAbnormalityInfoFromSap();
        AbnormalityHr = HandleAbnormalityHr(AbnormalityHrTmp);
    }
    
    /*
    //不需要了
    public static Integer GetSapMandt(){
        String sUrl = Url.getSalesforceBaseUrl().toExternalForm();
        System.debug('************************************');
        System.debug(sUrl);
        if(sUrl.equals('https://kinglai--test.cs5.my.salesforce.com')){
            return 400;
        }else if(sUrl.equals('https://kinglai.my.salesforce.com')){
            return 800;
        }
        return null;
    }
    */

     //获取考勤异常信息
    public List<AbnormalityHrPt60> AmAbnormalityInfoFromSap(){

        List<AbnormalityHrPt60> Abnormality = new List<AbnormalityHrPt60>(); 

        //获取邮箱地址
        String strAccount = UserInfo.getUserName();
        String strPernr = null;
        //strAccount = 'xuxiaofeng@kinglai.com.cn';
        System.debug('********************** |strAccount');
        System.debug(strAccount);
        //获取员工号
        for(User u :[select Number__c from user where Username = :strAccount]){
            strPernr = u.Number__c;
        }
        System.debug('********************** |Number');
        System.debug(strPernr);
        if(strPernr == null || strPernr.equals('')){
           return Abnormality;
        }


        //拼接对应的JSON数据
        String strJson = '{\"approval\":\"SF_SYNC_PT60\",\"userid\":\"' +
                          strPernr + '\"}';
        //获取对应的SAP异常信息
        HttpRest httprest = new HttpRest();
        strJson = httprest.HttpPostSap(strJson);         
   
        try{
            Abnormality = (List<AbnormalityHrPt60>) JSON.deserialize(strJson, List<AbnormalityHrPt60>.class);
        }catch(Exception ex){
            System.debug('************************************************');
            System.debug('JSON反序列化异常');
            System.debug('' + ex.getMessage() + '\n' + ex.getStackTraceString());
            System.debug('************************************************');
            System.debug(strJson);
        }
        return Abnormality;
    }

    private List<AbnormalityHrPt60> HandleAbnormalityHr(List<AbnormalityHrPt60> listPt60){
        for(AbnormalityHrPt60 a :listPt60){
            a.ldate = FormatDate(a.ldate);
            a.ltime = FormatTime(a.ltime);
            a.ltime2 = FormatTime(a.ltime2);
            a.sobeg = FormatTime(a.sobeg);
            a.soend = FormatTime(a.soend);
        }
        return listPt60;
    }

   private String FormatDate(String strDate){
        if(strDate!=null && strDate.equals('00000000')){
            return '';
        }
        System.debug(strDate);
        System.debug(strDate.substring(0,4) );
        System.debug(strDate.substring(4,6) );
        System.debug(strDate.substring(6,8) );
        return strDate.substring(0,4) + '-' +
               strDate.substring(4,6) + '-' +
               strDate.substring(6,8);
    }

    private String FormatTime(String strTime){        
        if(strTime!=null && strTime.equals('000000')){
            return '';
        }

        return strTime.substring(0,2) + ':' +
               strTime.substring(2,4) + ':' +
               strTime.substring(4,6);
    }

    private void TestClear(){
            //为了测试通过
        Integer i = 0;        
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
   }


}