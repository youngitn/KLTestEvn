/**********************************************************************
 名    称：SAP Web Service 调用返回参数
 目    的：在Salesforce主动推送数据到SAP后，接收从SAP返回的调用结果
 数据方向：SAP--->Salesforce
 作    者：刘文俊(liuwenjun@bluelinksys.com)
 创建日期：2017-04-17
 修 改 人：
 修改日期：
 修改原因：
 备    注：

Web Service: Public String syncDataFromSfToSap(String jsonArgs)

传送给SAP的jsonArgs格式样例：
{
	"operate":"INSERT", //新增记录
	"approval":"Customer",//要新增的是客户主数据
	"content": //每一个流程对应的数据不一样，详细定义参考"SAP入参定义"
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
			"items":
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
public without sharing class SapWebServiceInputArgs {
	/*
		操作标记(SapOperateEnum)
	*/
    public String operate {GET;SET;}
    /*
		审批流程名(SapApprovalEnum)
    */
    public String approval {GET;SET;}
    /*
		调用时传送给SAP的参数明细数据
    */
    public SapContentOfArgs content{GET;SET;}
}