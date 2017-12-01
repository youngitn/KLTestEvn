/**********************************************************************
 名    称：HLYSyncBilling
 目    的：同步开票信息到汇联易
 作    者：刘文俊(liuwenjun@bluelinksys.com)
 创建日期：2017-06-20
 修 改 人：
 修改日期：
 修改原因：
 备    注：

 脚本执行步骤：

 @Url: /services/apexrest/HLY/syncBilling
 接收的Json数据格式:
{
    "action": "EXECUTE", 
    "data_type": "INVOICE",
    "parameter": 
    {
		"hly_number":"ER098766787",
		"status":"N" Y/N
    }
}

 返回的Json数据格式：
{
    "success":"true OR false",
    "err_msg":"成功或失败信息",
    "source_code":"Salesforce",
    "data_type":"INVOICE"
}
*************************************************************************/
@RestResource(urlMapping = '/HLY/syncBilling')
global without sharing class HLYSyncBilling {
    @HttpPost
    global static HLYRestReturnArgs doPost(String action, String data_type, BParameter parameter) {
        System.debug('***  开票状态接口接收参数为: action:' + action);
        System.debug('***  开票状态接口接收参数为: data_type:' + data_type);
        System.debug('***  开票状态接口接收参数为: parameter:' + JSON.serializePretty(parameter));
        //返回参数
        HLYRestReturnArgs reArg = new HLYRestReturnArgs();
        reArg.data_type = data_type;
        reArg.success = 'true';
        List<Approval_Managed__c> amlist = [
        		SELECT Id,Is_Invoice_Success__c  
        		FROM Approval_Managed__c 
        		WHERE RecordType.DeveloperName
                LIKE '%ExpenseReimburse%' 
        		AND SAPID__c =: parameter.hly_number];
        if(amlist.size() > 0){
        	try{
	        	Approval_Managed__c am = amlist[0];
                Boolean bl = Approval.Islocked(am);
                if(bl){
                    Approval.Unlock(am);
                }
	        	am.Is_Invoice_Success__c = (parameter.status =='Y'?true:false);
	        	UPDATE am;

                if(bl){
                    Approval.Lock(am);
                }
	        }catch(Exception ex){
	        	reArg.success = 'false';
        		reArg.err_msg = '开票状态接口执行错误：' + ex.getMessage() + '; ' + ex.getStackTraceString();
	        }
        }else{
        	reArg.success = 'false';
        	reArg.err_msg = '汇联易单号【' + parameter.hly_number + '】不存在！';
        }
        return reArg;
    }
    /*
        主记录对应参数类
    */
    global class BParameter {
        public String status {GET; SET;}
        //员工编号
        public String hly_number {GET; SET;}
    }
}