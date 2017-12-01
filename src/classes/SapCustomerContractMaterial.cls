/*
    目    的：主动从SAP查询客户协议合同及相关物料信息时，生成SAP接收参数
    作    者：刘文俊(liuwenjun@bluelinksys.com)
    创建日期：2017-06-06
    修 改 人：
    修改日期：
    修改原因：
    备    注：主动从SAP查询客户协议合同及相关物料信息时，查询结果转化类
*/
public without sharing class SapCustomerContractMaterial {
    //调用成功标记：1 - 表示成功，0 - 表示失败
    public String status {GET;SET;}
    //调用描述：成功为空或相关信息，失败时为失败原因信息
    public String message {GET;SET;}
    //调用返回结果
    public List<CustomerContract> content{GET;SET;}

    public class CustomerContract{
        public ProtocolContract main{GET;SET;}
        public ProtocolContractMaterial details{GET;SET;}
    }
    public class ProtocolContract{
    	public String Customer_Code{GET;SET;}//客户编号
        public String Customer_Name{GET;SET;}//客户名称
        public String Contract_Name{GET;SET;}//合同名称
        public String Start_Date{GET;SET;}//合同起始日期
        public String End_Date{GET;SET;}//合同结束日期
    }
    public class ProtocolContractMaterial{
        public List<MaterialList> materials{GET;SET;}//物料列表
    }
    //协议合同物料列表
    public class MaterialList{
        public Boolean checked{GET;SET;}
    	public String Material_Code{GET;SET;}//物料号
        public String Material_Name{GET;SET;}//物料名称
        public String Customer_Material_Code{GET;SET;}//客户物料
        public String Stock_Quantity{GET;SET;}//当前库存量
        public String Protocol_Price{GET;SET;}//协议价
        public String Order_Quantity{GET;SET;}//订单数量
        public String Remark{GET;SET;}//备注
    }
}