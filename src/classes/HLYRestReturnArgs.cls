/**********************************************************************
 名    称：HLYRestReturnArgs
 目    的：当汇联易调用Salesforce的Rest接口同步数据时的返回参数
 作    者：刘文俊(liuwenjun@bluelinksys.com)
 创建日期：2017-05-17
 修 改 人：
 修改日期：
 修改原因：
 备    注：

*************************************************************************/
global without sharing class HLYRestReturnArgs {
    public String success = 'true'; //true/false
	public String err_msg = ''; //成功或失败时的信息
	public String source_code = 'Salesforce';
	/*
		员工出差 - TRL_REQUISITION
		交际应酬 - JYC_REQUISITION
		费用报销 - REPORT
	*/
	public String data_type = '';
}