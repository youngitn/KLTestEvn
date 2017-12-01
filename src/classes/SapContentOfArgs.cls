/**********************************************************************
 名    称：SAP Web Service 调用时传送或接收参数中的明细
 目    的：用来传送SAP需要的参数明细或接收SAP返回的参数明细
 数据方向：SAP <---> Salesforce
 作    者：刘文俊(liuwenjun@bluelinksys.com)
 创建日期：2017-04-17
 修 改 人：
 修改日期：
 修改原因：
 备    注：
*************************************************************************/
public without sharing class SapContentOfArgs {
    //主记录信息
	public Map<String,String> main {GET;SET;}
	//各明细记录信息
	public Map<String,List<Map<String,String>>> details {GET;SET;}
}