/**********************************************************************
 名    称：Salesforce主动推送数据到Sap时数据操作方式
 目    的：通知Sap接收到数据时应以何种方式操作数据
 作    者：刘文俊(liuwenjun@bluelinksys.com)
 创建日期：2017-04-17
 修 改 人：
 修改日期：
 修改原因：
 备    注：
 **********************************************************************/
public without sharing class SapOperateEnum {
    //更新
	public static final String UPDATED = 'UPDATE';
	//新增
	public static final String INSERTED = 'INSERT';
	//冻结
	public static final String FROZEN = 'FROZEN';
}