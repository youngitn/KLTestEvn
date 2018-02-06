//HR pt 60 异常信息
public without sharing  class AbnormalityHrPt60 {
    public String pernr {get;set;}   //员工号
	public String ename {get;set;}   //姓名
	public String kurzt {get;set;}   //星期
	public String ldate {get;set;}   //刷卡日期
	public String ltime {get;set;}   //第一次刷卡时间
	public String ltime2 {get;set;}  //最后一次刷卡时间
	public String error {get;set;}   //原因标识
	public String etext {get;set;}   //描述
	public String schkz {get;set;}   //班别
	public String ttext {get;set;}   //班别描述
	public String sobeg {get;set;}   //系统标准工作开始
	public String soend {get;set;}   //系统标准工作结束
}