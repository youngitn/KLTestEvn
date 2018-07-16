global with sharing class AMSalesOrderDatatableExtension extends VFShowInApprovalExtension
{

    public   Custom_Approval_Managed__c am {get; set;}

    public List<Custom_Approval_Managed_Item__c> list1 {get; set;}
    public List<Custom_Approval_Managed_Item__c> list2 {get; set;}
    public List<Custom_Approval_Managed_Item__c> list3 {get; set;}

    public List<Custom_Approval_Managed_Item__c> preDeletelist1 {get; set;}
    public List<Custom_Approval_Managed_Item__c> preDeletelist2 {get; set;}
    public List<Custom_Approval_Managed_Item__c> preDeletelist3 {get; set;}

        public Id amId {get; set;}

    public Integer list2Row {get; set;}
    public Integer list3Row {get; set;}
    //销售订单明细记录类型ID
    private Id recTypeDetailTd = null;
    //销售订单头条件明细记录类型ID
    private Id recTypeHeaderId = null;
    //销售订单行条件明细记录类型ID
    private Id recTypeRowId = null;


    public Custom_Approval_Managed_Item__c sonlist{get;set;}

    public  Transient Integer list1Row {get; set;}
    public Transient Integer hasError {get; set;}
 
    public AMSalesOrderDatatableExtension(ApexPages.StandardController con)
    {
        super('Custom_Approval_Managed__c', '销售订单流程', con, 'Custom_Approval_Managed_Item__c', '销售订单明细', 'Sales_Order__c');


        list1Row = 0;
        list1 = (List<Custom_Approval_Managed_Item__c>)this.detailSObjList;
        am = (Custom_Approval_Managed__c)this.sobj;


        if (con.getId() == null)
        {
            am = (Custom_Approval_Managed__c)SObjectUtils.init(am);

        }
        recTypeDetailTd = HarryUtils.getRecordTypeIdByDevNameAndObjName('Sale_Order_Detail','Custom_Approval_Managed_Item__c');
        recTypeHeaderId = HarryUtils.getRecordTypeIdByDevNameAndObjName('Sale_Order_Detail_Header','Custom_Approval_Managed_Item__c');
        recTypeRowId = HarryUtils.getRecordTypeIdByDevNameAndObjName('Sale_Order_Detail_Row','Custom_Approval_Managed_Item__c');

        list1Row = 0;
        list2Row = 0;
        list3Row = 0;
        amId = con.getId();

    
        String sql ='SELECT Id,RecordTypeId,SAPID__c,Is_update_sjbh__c,Name,Dept_Code__c,Dept_Name__c,Approval_Name__c,Status__c,Applicant__c,Applicant_Code__c,Applicant_Name__c,Bill_Date__c,Kind_of_Order__c,Bill_No__c,Is_Agree_Refund__c,Type_of_Approval__c,Customer_Code__c,Customer_Name__c,Delivery_Party_Code__c,Delivery_Party_Name__c,Reason_of_Order__c,Purchase__c,Purchase_Order_Date__c,Purchase_Required_Date__c,Currency_Purchase__c,Term_of_Purchase_Payment__c,Term_of_Purchase_Trade__c,Weight_Total__c,Opportunity_Code__c,Sales_Org__c,Distribution_Channel__c,Product_Group__c,Price_Group__c,Customer_Group__c,Sales_Area__c,Sales_Office_Area__c,Sales_Group__c,Is_Based_Quotation__c,Code_Reference__c,Currency_Reference__c,Amount_Reference__c,NotStandard_Price_Flag__c,Prepare_Feed_Protocol__c,Sales_Employee__c,Approval_Status__c,Order_of_Sales__c FROM Custom_Approval_Managed__c';
        
        am = Database.query(sql);

        
        list1 = [SELECT RecordTypeId,Sales_Order__c, Index_Item__c, Material_Number__c, Material_Name__c,
                 Material_Description__c, Quantity__c, Unit__c, Status_Overview__c,
                 Material_of_Customer__c, Schedule_Date__c, Price_Net__c, Currency__c
                 FROM Custom_Approval_Managed_Item__c WHERE Sales_Order__c = :amId];

        list2 = [SELECT RecordTypeId,Sales_Order_Header__c, Type_of_Price__c, Name_of_Price__c, Amount__c,
                 Currency__c, Quantity__c, Uom__c, Value_of_Price__c
                 FROM Custom_Approval_Managed_Item__c WHERE Sales_Order_Header__c = :amId];

        list3 = [SELECT RecordTypeId,Sales_Order_Detail__c, Type_of_Price__c, Name_of_Price__c, Amount__c,
                 Currency__c, Quantity__c, Uom__c, Value_of_Price__c
                 FROM Custom_Approval_Managed_Item__c WHERE Sales_Order_Detail__c = :amId];


        preDeletelist1 = new List<Custom_Approval_Managed_Item__c>();
        preDeletelist2 = new List<Custom_Approval_Managed_Item__c>();
        preDeletelist3 = new List<Custom_Approval_Managed_Item__c>();

        

    }



    

     @RemoteAction
    global static String dataTabledata(String empId)
    {
         List<Custom_Approval_Managed_Item__c> lists = [SELECT Name,Row_Index__c, Index_Item__c, Operate_Type__c, Material_Number__c,
                 Material_Name__c, Quantity__c, Unit__c, Schedule_Date__c,
                 Price_Net__c, Reasons_for_refusal__c
                 FROM Custom_Approval_Managed_Item__c];
       
        Map<String, String> map1 = new Map<String, String>();
        //Take_Office_Date Job_Title_Level Applicant_position
        /*emp.put('Take_Office_Date',    String.valueOf(c.Take_Office_Date__c));
        emp.put('Job_Title_Level',     c.Job_Title_Level__c);
        emp.put('Applicant_position',  c.Post_Number__r.Post_Description__c);
        emp.put('Number__c',  c.Number__c);
        emp.put('Phone',  c.Phone);*/

       map1.put('Name','杨旺');
       System.debug(lists[0].Name);
       map1.put('Row_Index__c',String.valueOf(lists[0].Row_Index__c));
       map1.put('Operate_Type__c',lists[0].Operate_Type__c);
       map1.put('Material_Number__c',String.valueOf(lists[0].Material_Number__c));
       map1.put('Material_Name__c',lists[0].Material_Name__c);
       map1.put('Quantity__c',lists[0].Quantity__c+'');
       map1.put('Unit__c',lists[0].Unit__c);
       map1.put('Schedule_Date__c',lists[0].Schedule_Date__c+'');
       map1.put('Price_Net__c',lists[0].Price_Net__c+'');
       map1.put('Reasons_for_refusal__c',lists[0].Reasons_for_refusal__c);


        System.debug(map1);

        List<Map<String, String>> listx = new List<Map<String, String>>();
        listx.add(map1);
        return (String)JSON.serialize(listx);
    }


}