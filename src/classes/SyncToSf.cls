/**********************************************************************
 * 作者：许晓峰
 * 日期：2017-11-07 
 * 
 * @url: /services/apexrest/KL/SyncToSf
 
*************************************************************************/

//注解？用于指示对应的URL
@RestResource(urlMapping='/KL/SyncToSf')
global with sharing class SyncToSf {  
	/*Post方法
		doPost后的参数：因选择了json格式传参
			strJsonIn : 对应URL 提供json中匹配的值；如POST中BODY值为-
				        {"strJsonIn":"10210224"}，则 strJsonIn值为10210224；

						如有多个参数，对应json中需要提供多个类型:
							doPost(String strPernr,String strDate),则需要提供如下json
						    {"strPernr":"10210225","strDate":"2017-07"}
	*/
 	@HttpPost 	
    global static SfReturn doPost(String strSource, //json来源: SAP/CRM/...
    	                          String strJson    //json字符串
    	                         ) {
        String stemp = strJson ;
        //System.debug('******'+strJson);
    	strSource.toUpperCase(strSource);

        /*
         SAP需要将字符串转换，因SAP提供的json格式非标准
         SAP在调用此url时，post的参数 strSource / strJson 需要人为拼接上双引号
        */
	    if(strSource == 'SAP'){
	    	strJson = KlCommon.FormatSapJsonToSf(strJson);
	    }
        
        /*
        //测试用beg
        SfReturn temp = new SfReturn();
        temp = ReturnJson(strJson);
        temp.message = stemp;
        return temp;
        //测试用END
        */

        /*
    	 返回的类型；对应URL接收到的值为此类型的json格式
    	（当选择json格式后，会自动转换）
        */
        return ReturnJson(strJson);


    }



    public static SfReturn ReturnJson(String strJson){
        SfReturn myReturn = new SfReturn();          
        myReturn.type = '0';
        myReturn.sfid = '';
        try{   
            KlCommon.SyncToSfReturnArgs args = 
                (KlCommon.SyncToSfReturnArgs)JSON.deserialize(strJson,KlCommon.SyncToSfReturnArgs.class);
        	 
            String strFun = args.approval; //获取对应的函数名称
  

            if(strFun == 'FunDemo'){ 
               return FunDemo(args); //此函数建议用新类，以减少此文档的关联性
            }else if(strFun == 'XXXXXXX'){ 
                // return Funxxxxxx(args);
            }
        }
        catch(Exception ex)
        {    
            myReturn.message = strJson + 'error:' + ex.getMessage() + '-->' + ex.getStackTraceString();
            return myReturn;
        }
        
        myReturn.message = '未找到对应解析逻辑';
        return myReturn;
    }

    /*
        测试DEMO，实际操作建议产生新的CLASS，以防止此代码中函数过多，不便多人共用
    */
    private static SfReturn FunDemo(KlCommon.SyncToSfReturnArgs args){
        SfReturn myReturn = new SfReturn();   
        myReturn.type = '0';
        myReturn.sfid = '';
        //检查是否有相关的属性值
        if(args.content == null){ 
            myReturn.message = '未找到对应content属性';  
            return myReturn; 
        }

        /*
        if(!args.content.details.containsKey('items')){  
            myReturn.message = '未找到对应items属性';  
            return myReturn; 
        }
        */

        //对应处理逻辑

        myReturn.type = '1';
        myReturn.sfid = 'xxxx';
        myReturn.message = 'Demo pass';  
        return myReturn; 
    }
    
}