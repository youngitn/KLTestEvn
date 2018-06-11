global with sharing class AMSalesOrderDatatableExtension extends VFShowInApprovalExtension
{

    public   Custom_Approval_Managed__c am {get; set;}

    public   List<Custom_Approval_Managed_Item__c> list1 {get; set;}

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

        if (isInsert()) {
            am = new Custom_Approval_Managed__c(
                RecordTypeId = HarryUtils.getRecordTypeIdByDevNameAndObjName('销售订单', 'Custom_Approval_Managed__c'));
            list1 = new List<Custom_Approval_Managed_Item__c>();
            list2 = new List<Custom_Approval_Managed_Item__c>();
            list3 = new List<Custom_Approval_Managed_Item__c>();

            preDeletelist1 = new List<Custom_Approval_Managed_Item__c>();
            preDeletelist2 = new List<Custom_Approval_Managed_Item__c>();
            preDeletelist3 = new List<Custom_Approval_Managed_Item__c>();
            return;
        }

        String sql = Utils.getApprovalSQL(SapApprovalEnum.SALEORDERDATATABLE, true);
        sql = sql + ' WHERE Id = \'' + amId + '\'';
        am = Database.query(sql);

        
        list1 = [SELECT RecordTypeId,Sales_Order__c, Index_Item__c, Material_Number__c, Material_Name__c,
                 Material_Description__c, Quantity__c, Unit__c, Status_Overview__c,
                 Material_of_Customer__c, Schedule_Date__c, Price_Net__c, Currency__c
                 FROM Custom_Approval_Managed_Item__c WHERE Sales_Order__c = :amId ];

        list2 = [SELECT RecordTypeId,Sales_Order_Header__c, Type_of_Price__c, Name_of_Price__c, Amount__c,
                 Currency__c, Quantity__c, Uom__c, Value_of_Price__c
                 FROM Custom_Approval_Managed_Item__c WHERE Sales_Order_Header__c = :amId ];

        list3 = [SELECT RecordTypeId,Sales_Order_Detail__c, Type_of_Price__c, Name_of_Price__c, Amount__c,
                 Currency__c, Quantity__c, Uom__c, Value_of_Price__c
                 FROM Custom_Approval_Managed_Item__c WHERE Sales_Order_Detail__c = :amId ];


        preDeletelist1 = new List<Custom_Approval_Managed_Item__c>();
        preDeletelist2 = new List<Custom_Approval_Managed_Item__c>();
        preDeletelist3 = new List<Custom_Approval_Managed_Item__c>();

        

    }



    public override PageReference saveAction()
    {
        
        /***********************************************************************************/
        hasError = 0;

        //取得請假人的聯絡人物件
        Contact c = Peoples.getInstance().KlAllContactMapGetById.get(am.Employee__c);
        

        if (c != null)
        {
         // 员工（工号）
            am.Employee_Code__c = c.Number__c;
         //  员工（姓名）          名称（文字/文本）
            am.Employee_Name__c = c.FirstName;
        }
        else
        {
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.WARNING, '该工单号不在工单列表中'));
            hasError++;
        }

         return new PageReference('/'+am.Id);
    }

    /**
     * [將表頭Id塞入表身關聯欄位]
     * @param  detaillist [description]
     * @param  masterId   [description]
     * @return            [description]
     */
    public List<SObject> setRelationOfDetailWithMaster(List<Custom_Approval_Managed_Item__c> detaillist, Id masterId)
    {
        for (Custom_Approval_Managed_Item__c ami : detaillist)
        {
            ami.Sales_Order__c  = am.Id;
        }

        return detaillist;
    }

    


    /**
     * [增加一列請假明細]
     * @return [description]
     */
    public PageReference newlist1()
    {

        Custom_Approval_Managed_Item__c ami    = new Custom_Approval_Managed_Item__c();
        ami.RecordTypeId                = this.detailRecTypeId;

        list1.add(ami);

        return null;
    }




    /**
     * [移除一列請假明細]
     * @return [description]
     */
    public PageReference deletelist1()
    {

        if (list1[list1Row].Id != null)
        {
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.WARNING, '刪除請假明細後請執行儲存動作,變更才會生效.'));
            Delete list1[list1Row];
            list1.remove(list1Row);
           
            return null;
        }
        list1.remove(list1Row);
        return null;
    }

   public Id amId {get; set;}

    public List<Custom_Approval_Managed_Item__c> list2 {get; set;}
    public List<Custom_Approval_Managed_Item__c> list3 {get; set;}

    public List<Custom_Approval_Managed_Item__c> preDeletelist1 {get; set;}
    public List<Custom_Approval_Managed_Item__c> preDeletelist2 {get; set;}
    public List<Custom_Approval_Managed_Item__c> preDeletelist3 {get; set;}

    public Integer list2Row {get; set;}
    public Integer list3Row {get; set;}
    //销售订单明细记录类型ID
    private Id recTypeDetailTd = null;
    //销售订单头条件明细记录类型ID
    private Id recTypeHeaderId = null;
    //销售订单行条件明细记录类型ID
    private Id recTypeRowId = null;


   
    public PageReference save() {
        System.Savepoint savepoint = Database.setSavepoint();
        try {
            if (isInsert()) {
                insert am;
                for (Custom_Approval_Managed_Item__c ami : list1) {
                    ami.Sales_Order__c = am.Id;
                    //增加销售订单明细记录类型ID
                    ami.RecordTypeId = recTypeDetailTd;
                }
                for (Custom_Approval_Managed_Item__c ami : list2) { 
                    ami.Sales_Order_Header__c = am.Id;
                    //增加销售订单头条件明细记录类型ID
                    ami.RecordTypeId = recTypeHeaderId;
                }
                for ( Custom_Approval_Managed_Item__c ami : list3) {
                    ami.Sales_Order_Detail__c = am.Id;
                    //增加销售订单行条件明细记录类型ID
                    ami.RecordTypeId = recTypeRowId;
                }
            } else {
                if (am.Approval_User1__c == null) {
                    am.Approval_User1__c = am.Applicant__c;
                }
                update am;
                System.debug(LoggingLevel.INFO, '*** am: ' + am);
            }

            upsert list1;
            upsert list2;
            upsert list3;

            delete preDeletelist1;
            delete preDeletelist2;
            delete preDeletelist3;

        } catch (Exception e) {
            Database.rollback(savepoint);
            System.debug('The following exception has occurred: ' + e.getMessage());
            ApexPages.addMessages(e);
            return null;
        }
        return new PageReference('/' + am.Id);
    }

    public PageReference cancel() {
        return new PageReference('/a01/o');
    }

 /*   public PageReference deletelist1() {
        if (list1[list1Row].Id != null) {
            preDeletelist1.add(list1[list1Row]);
        }
        list1.remove(list1Row);
        return null;
    }*/

    public PageReference deletelist2() {
        if (list2[list2Row].Id != null) {
            preDeletelist2.add(list2[list2Row]);
        }
        list2.remove(list2Row);
        return null;
    }
    public PageReference deletelist3() {
        if (list3[list3Row].Id != null) {
            preDeletelist3.add(list3[list3Row]);
        }
        list3.remove(list3Row);
        return null;
    }

 /*   public PageReference newlist1() {
        list1.add(new Custom_Approval_Managed_Item__c(Sales_Order__c = am.Id));
        return null;
    }*/
    public PageReference newlist2() {
        list2.add(new Custom_Approval_Managed_Item__c(Sales_Order_Header__c = am.Id));
        return null;
    }
    public PageReference newlist3() {
        list3.add(new Custom_Approval_Managed_Item__c(Sales_Order_Detail__c = am.Id));//TODO
        return null;
    }
    public Boolean isInsert() {
        return amId == null;
    }


     @RemoteAction
    global static String dataTabledata(String empId )
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