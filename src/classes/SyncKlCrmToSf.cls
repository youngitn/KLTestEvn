/**********************************************************************
 * 
 *
 * @url: /services/apexrest/KL/SyncKlCrmToSf
 * @data:
 *  {
        CRM同步直接调用此函数
    }
*************************************************************************/

//注解？用于指示对应的URL
@RestResource(urlMapping='/KL/SyncKlCrmToSf')
global with sharing class SyncKlCrmToSf {    
	/*POOT方法
		doPost后的参数：
			strJsonIn : 对应URL 提供json中匹配的值；如POST中BODY值为-
				        {"strJsonIn":"10210224"}，则 strJsonIn值为10210224；

						如有多个参数，对应json中需要提供多个类型:
							doPost(String strPernr,String strDate),则需要提供如下json
						    {"strPernr":"10210225","strDate":"2017-07"}
	*/
 	@HttpPost 	
    global static KlCrmToSfReturn doPost(String strJsonIn) {
    	//返回的类型；对应URL接收到的值为此类型的json格式
    	//（当选择json格式后，会自动转换）
        KlCrmToSfReturn sReturn = new KlCrmToSfReturn();
        sReturn.sflag = strJsonIn;
       return sReturn;
    }
}