public with sharing class JsonFormatSapToSf {
    public static String FormatSapToSf(String strSap){
    	String str = strSap;
    	//处理SAP返回的NULL值
		str = str.replace('"00000000"', '""').replace('"9999-12-31"','"2099-12-31"').replace('"0000-00-00"','""');
		//处理JSON字符串太长的问题
		String jsonResult = '';
		Boolean bl = true;
		Integer maxLen = 50000;
		while(bl){
		    if(str.length() > maxLen){
		        String tmp = str.substring(0,maxLen);
		        str = str.substring(maxLen);
		        Integer ind = tmp.lastIndexOf('},');
		        str = tmp.substring(ind + 1) + str;
		        tmp = tmp.substring(0,ind + 1);
		        tmp = tmp.replaceAll('"*(\\w+)"*:\\s*(["\\[{])', '"$1":$2');
		        tmp = tmp.replaceAll('"\\w+": {0,1}"",', '');
		        tmp = tmp.replaceAll(', {0,1}"\\w+": {0,1}"" {0,1}}','}');
		        jsonResult = jsonResult + tmp;
		    }else{
		        str = str.replaceAll('"*(\\w+)"*:\\s*(["\\[{])', '"$1":$2');
		        str = str.replaceAll('"\\w+": {0,1}"",', '');
		        str = str.replaceAll(', {0,1}"\\w+": {0,1}"" {0,1}}','}');
		        jsonResult = jsonResult + str;
		        bl = false;
		    }
		}   
	    return jsonResult;
    }
}