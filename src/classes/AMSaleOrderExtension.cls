// 销售订单审批流程

public with sharing class AMSaleOrderExtension {

    public Custom_Approval_Managed__c am {get; set;}

    public Id amId {get; set;}

    public List<Custom_Approval_Managed_Item__c> list1 {get; set;}
    public List<Custom_Approval_Managed_Item__c> list2 {get; set;}
    public List<Custom_Approval_Managed_Item__c> list3 {get; set;}

    public List<Custom_Approval_Managed_Item__c> preDeletelist1 {get; set;}
    public List<Custom_Approval_Managed_Item__c> preDeletelist2 {get; set;}
    public List<Custom_Approval_Managed_Item__c> preDeletelist3 {get; set;}

    public Integer list1Row {get; set;}
    public Integer list2Row {get; set;}
    public Integer list3Row {get; set;}
    //销售订单明细记录类型ID
    private Id recTypeDetailTd = null;
    //销售订单头条件明细记录类型ID
    private Id recTypeHeaderId = null;
    //销售订单行条件明细记录类型ID
    private Id recTypeRowId = null;


    public AMSaleOrderExtension(ApexPages.StandardController con) {
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

        String sql = Utils.getApprovalSQL(SapApprovalEnum.SALEORDER, true);
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
                update am;
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

    public PageReference deletelist1() {
        if (list1[list1Row].Id != null) {
            preDeletelist1.add(list1[list1Row]);
        }
        list1.remove(list1Row);
        return null;
    }
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

    public PageReference newlist1() {
        list1.add(new Custom_Approval_Managed_Item__c(Sales_Order__c = am.Id));
        return null;
    }
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
}