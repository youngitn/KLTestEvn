/*
    目    的：主动从SAP查询数据时，生成SAP接收参数
    作    者：刘文俊(liuwenjun@bluelinksys.com)
    创建日期：2017-05-03
    修 改 人：
    修改日期：
    修改原因：
    备    注：在主动从SAP查询数据时，要生成的参数
*/
public with sharing class SapWebServiceQueryArgs {
	//查询名称
    public String approval{SET;GET;}
    //查询条件组合
    public String assemble{SET;GET;}
    /*
    	查询条件字段设置：
    	"NO":"1",
        "FieldName":"Material_Number__c",
        "DataType":"String/Date/Number",
        "Operate":"=",
        "Value:"MT5487512"
    */
    public List<Map<String,String>> conditions{SET;GET;}
}