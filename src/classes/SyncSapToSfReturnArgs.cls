/**********************************************************************
 名    称：SAP Web Service 调用返回参数
 目    的：在Salesforce主动从SAP取数据同步到时，接收从SAP返回的调用结果
 数据方向：SAP--->Salesforce
 作    者：刘文俊(liuwenjun@bluelinksys.com)
 创建日期：2017-05-15
 修 改 人：
 修改日期：
 修改原因：
 备    注：

Web Service: Public String ZwbSalesforce(String jsonArgs)

返回的Json格式样例：
{
	"status":"1",
	"message":"调用成功",
	"approval":"Customer",
	"keyno":"100001000",
	"content":
	{
		"main":
		{
			"SAPNO__c":"N4571023474",
			"SAPID__c":"1254789",
			"SFID__c":"02342a6b28d9200a"
			//如果有其它字段信息，请放在这里
		},
		"details":
		{
			//每一个返回信息的明细项可能不一样，详细定义参考"返回参数明细项定义"
			"partners":
			[
				{
					"Material_Name__c":"不锈钢水泵",
					"SAPID":"0123456789",
					"SFID":"02342a6b28d9200a"
					//如果有其它字段信息，请放在这里
				},
				{
					"Material_Name__c":"不锈钢水泵",
					"SAPID__c":"0123456789",
					"SFID__c":"02342a6b28d9200a"
					//如果有其它字段信息，请放在这里
				}
			],
			"banks":
			[
				{
					"Name_of_Bank__c":"中国工商银行",
					"SAPID__c":"0123456789",
					"SFID__c":"02342a6b28d9200a"
					//如果有其它字段信息，请放在这里
				}
			],
			"taxs":
			[
				{
					"Country__c":"CN",
					"SAPID__c":"0123456789",
					"SFID__c":"02342a6b28d9200a"
					//如果有其它字段信息，请放在这里
				}
			],
			"contacts":
			[
				{
					"LastName":"张学友",
					"SAPID__c":"0123456789",
					"SFID__c":"02342a6b28d9200a"
					//如果有其它字段信息，请放在这里
				}
			]
		}
	}
}
*************************************************************************/
public with sharing class SyncSapToSfReturnArgs {
    //调用成功标记：1 - 表示成功，0 - 表示失败
    public String status {GET;SET;}
    //调用描述：成功为空或相关信息，失败时为失败原因信息
    public String message {GET;SET;}
    //content为何种类型数据：参考SapApprovalEnum类
    public String approval {GET;SET;}
    //同步时SAP的主键值
    public String keyno {GET;SET;}
    //调用返回结果
    public SapContentOfReturnArgs content{GET;SET;}
}