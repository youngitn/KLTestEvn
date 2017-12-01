/**********************************************************************
 名    称：SAP Web Service 调用返回参数
 目    的：在Salesforce主动推送数据到SAP后，接收从SAP返回的调用结果
 数据方向：SAP--->Salesforce
 作    者：刘文俊(liuwenjun@bluelinksys.com)
 创建日期：2017-05-10
 修 改 人：
 修改日期：
 修改原因：
 备    注：

返回的Json格式样例：
{
	"status":"1",
	"message":"调用成功",
	"SAPID__c":"0123456789", //SAP主键值
    "SFID__c":"02342a6b28d9200a" //SF传送过去的ID
}
*************************************************************************/
public with sharing class SapWebServiceReturnResult {
    //调用成功标记：1 - 表示成功，0 - 表示失败
    public String status {GET;SET;}
    //调用描述：成功为空或相关信息，失败时为失败原因信息
    public String message {GET;SET;}
    //SAP主键值
    public String SAPID {GET;SET;}
    //SF传送过去的ID
    public String SFID {GET;SET;}
}