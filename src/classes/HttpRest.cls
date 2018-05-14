/*
  许晓峰 AT 20180131
  功能：http GET POST 方法
  因APEX不分大小写；所以有String json= '';会导致JSON.deserialize无法正常使用
*/
public with sharing class HttpRest {    

    public HttpRest(){    

    }

    /******************************************************************************
     		GET 方法
    *******************************************************************************/
    
    /*    调用方式
          HttpRest hr = new HttpRest();
          hr.HttpGetSap('fun_name = demo' );
    */
    public String HttpGetSap(
    	//url ?后的地址；形式： xxx=yy&xxx=yy&...
    	//GET方式输入必须包含 ?fun_name = 'XXX'  ;'XXX'代表函数名称
    	                     String Parameter 
    	                     ){    	
    	//获取权限
    	String AuthorizationHeader = IniAuthorizationHeader();
    	//获取SAP url
    	String Sap_Url = IniSapUrl();
        if(Sap_Url == null || Sap_Url.equals('')){
            System.debug('*************************************');
            System.debug('error无效的URL');
            return 'error无效的URL';
        }
    	if(Sap_Url !=null && 
    	   !Sap_Url.equals('') && 
    	   Parameter != null && 
    	   !Parameter.equals('')){
    	   Sap_Url = Sap_Url + '&' + Parameter;
    	}    	
    	//POST到SAP
        System.debug('*************************************');
        System.debug(Sap_Url);

    	String Json = HttpGet(Sap_Url,AuthorizationHeader);
    	//因SAP转换的JSON是js对象形式，需要转换
	    Json = KlCommon.FormatSapJsonToSf(Json);
	   
        System.debug('*************************************');
	    System.debug(Json);
    	return Json;

    }

    public String HttpGet(String Url,
	                      String AuthorizationHeader){
    	if(Url == null || Url.equals('')){
    		return 'error无效的URL';
    	}
    	HttpRequest req = new HttpRequest();
    	req.setEndpoint(Url);
	    req.setMethod('GET');
	    req.setHeader('Authorization', AuthorizationHeader);
	    Http http = new Http();
	    HTTPResponse res = http.send(req);
	    return res.getBody();
    }

    /******************************************************************************
     		POST 方法
    *******************************************************************************/

    /* 调用方式
      HttpRest hr = new HttpRest();
      hr.HttpPostSap('{\"approval\":\"SF_SYNC_PT60\"}');
    */
    public String HttpPostSap(String Body   //POST BODY
    	                     ){
    	//获取权限
    	String AuthorizationHeader = IniAuthorizationHeader();
    	//获取SAP url
    	String Sap_Url = IniSapUrl();
    	//POST到SAP
    	System.debug('*************************************');
        System.debug(Sap_Url);
        System.debug(AuthorizationHeader);
        System.debug(Body);
    	String Json = HttpPost(Sap_Url,AuthorizationHeader,Body);
    	//因SAP转换的JSON是js对象形式，需要转换
	    Json = KlCommon.FormatSapJsonToSf(Json);
	    
        System.debug('*************************************');
	    System.debug(Json);
    	return Json;
    }

    public String HttpPost(String Url,
    	                   String AuthorizationHeader,
    	                   String Body){
    	if(Url == null || Url.equals('')){
    		return 'error无效的URL';
    	}
    	HttpRequest req = new HttpRequest();
    	req.setEndpoint(Url);
	    req.setMethod('POST');
	    req.setHeader('Authorization', AuthorizationHeader);
	    req.setBody(Body);
	    Http http = new Http();
	    HTTPResponse res = http.send(req);
	    return res.getBody();
    }

   

    /******************************************************************************
     		
    *******************************************************************************/

    //获取权限
    private String IniAuthorizationHeader(){
	    String username = '';
	    String password = '';
        
        SAP_Interface_Setting__c sis = 
            SAP_Interface_Setting__c.getValues('SapSetting');
        if (sis.UserName__c != null && sis.UserName__c != ''){
            username = sis.UserName__c;
        }

        if (sis.Password__c != null && sis.Password__c != ''){
            password = sis.Password__c;
        }

	    Blob headerValue = Blob.valueOf(username + ':' + password);
	    String authorizationHeader = 'BASIC ' +
	    EncodingUtil.base64Encode(headerValue);
        
        System.debug('*************************************');
        System.debug(authorizationHeader);
	    return authorizationHeader;
    }
    
    //初始化URL
    private String IniSapUrl(){    	
        SAP_Interface_Setting__c sis = 
            SAP_Interface_Setting__c.getValues('SapSetting');
        if (sis.HttpRestUrl__c != null && sis.HttpRestUrl__c != ''){
            return sis.HttpRestUrl__c;
        }

    	return null;
    }  


}