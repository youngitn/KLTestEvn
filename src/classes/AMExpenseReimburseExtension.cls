//费用报销流程

public with sharing class AMExpenseReimburseExtension {
    public Approval_Managed__c am {get; set;}

    public Id amId {get; set;}
    public List<Approval_Managed_Item__c> list1 {get; set;}
    public List<Approval_Managed_Item__c> list2 {get; set;}

    public List<Approval_Managed_Item__c> preDeletelist1 {get; set;}
    public List<Approval_Managed_Item__c> preDeletelist2 {get; set;}
    public Map<String,Approval_Managed_Item__c> map2{get;set;}

    public Integer list1Row {get; set;}
    public Integer list2Row {get; set;}
    public Integer maxindex {get; set;}
    //费用报销明细记录类型ID
    private Id recTypeDetailId = null;
    //费用报销凭证行信息记录类型ID
    private Id recTypeCertificateId = null;

    public AMExpenseReimburseExtension(ApexPages.StandardController con) {
        recTypeDetailId = HarryUtils.getRecordTypeIdByDevNameAndObjName('Payment_Detail','Approval_Managed_Item__c');
        recTypeCertificateId = HarryUtils.getRecordTypeIdByDevNameAndObjName('Payment_Certificate','Approval_Managed_Item__c');
        list1Row = 0;
        list2Row = 0;
        amId = con.getId();
        map2 = new Map<String,Approval_Managed_Item__c>();

        //public Boolean isInsert() {
        //    return amId == null;
        //}
        if (isInsert()) {
            am = new Approval_Managed__c();
            am.Is_HLY_ExpenseReimburse__c = false;
            am.RecordTypeId = HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.EXPENSEREIMBURSE, 'Approval_Managed__c');
            System.debug(LoggingLevel.INFO, '*** : 测试是否到达');
            list1 = new List<Approval_Managed_Item__c>();
            list2 = new List<Approval_Managed_Item__c>();

            preDeletelist1 = new List<Approval_Managed_Item__c>();
            preDeletelist2 = new List<Approval_Managed_Item__c>();
            return;
        }

        String sql = Utils.getApprovalSQL(SapApprovalEnum.EXPENSEREIMBURSE, true);
        sql = sql + ' WHERE Id = \'' + amId + '\'';
        am = Database.query(sql);

        list1 = [SELECT RecordTypeId,Purchase_Info_Inquiry__c,Ledger_Account__c,Type_of_Cost__c,Quantity__c,Price__c,Amount__c,Dept_of_CostCenter__c,Remark__c,TaskID__c,Row_Index__c,Expense_Type__c
                 FROM Approval_Managed_Item__c 
                 WHERE Purchase_Info_Inquiry__c = :amId AND RecordType.DeveloperName = 'Payment_Detail'];

        list2 = [SELECT RecordTypeId,Voucher_Info__c,Accounting_Code__c,Subject__c,Amount__c,Dept_of_CostCenter__c,Allocation__c,Text__c,Reason_Code__c,SGL__c,Type_of_Affair__c,Row_Index__c
                 FROM Approval_Managed_Item__c Where Voucher_Info__c = :amId AND RecordType.DeveloperName = 'Payment_Certificate'];
        for (Approval_Managed_Item__c ami: list2) {
            map2.put(ami.Row_Index__c, ami);
        }

        preDeletelist1 = new List<Approval_Managed_Item__c>();
        preDeletelist2 = new List<Approval_Managed_Item__c>();
    }

    public PageReference save() {
        System.Savepoint savepoint = Database.setSavepoint();
        if (String.isNotBlank(am.Employee__c) && am.Expense_Type_Cost__c == '01') {
            List<Contact> lstCon = [SELECT Name, Number__c FROM Contact WHERE Id = :am.Employee__c];
            if (lstCon.size()>0) {
                am.Employee_Code__c = lstCon[0].Number__c;
                am.Employee_Name__c = lstCon[0].Name;
            }
        }else{
                am.Employee_Code__c = null;
                am.Employee_Name__c = null;
                am.Employee__c = null;
        }

        /*
        if (String.isNotBlank(am.Supplier__c) && am.Expense_Type_Cost__c == '02') {
        }else{
                am.Supplier__c = null;
                am.Supplier_Number__c = null;
                am.Supplier_Name__c = null;
        }
        */
        

        //费用申请单信息
        if (String.isNotBlank(am.Approval_Entertained__c) ) {
            List<Approval_Managed__c> lstAM = [SELECT Id,Estimate_Cost__c,Occur_Datetime__c,Staff_of_Both__c,Place__c,Description_of_Travel__c,Approval_Entertained_Code__c,Kind_of_Cost__c
                     FROM Approval_Managed__c 
                     WHERE RecordType.DeveloperName = 'EntertaineCost' AND Id = :am.Approval_Entertained__c];
            if (lstAM.size()>0) {
                am.Approval_Entertained_Code__c = lstAM[0].Approval_Entertained_Code__c;
                am.Estimate_Cost__c = lstAM[0].Estimate_Cost__c;
                am.Occur_Datetime__c = lstAM[0].Occur_Datetime__c;
                am.Staff_of_Both__c = lstAM[0].Staff_of_Both__c;
                am.Place__c = lstAM[0].Place__c;
                am.Kind_of_Cost__c = lstAM[0].Kind_of_Cost__c;
                am.Description_of_Travel__c = lstAM[0].Description_of_Travel__c;
             } 
        }

        //汇总金额
        Decimal decTotal = 0;
        Decimal decInvoice = 0;
        try {
            upsert am;
            Delete preDeletelist1;
            Delete preDeletelist2;

            List<Approval_Managed_Item__c> lstVoucher = new List<Approval_Managed_Item__c>();
            for (Approval_Managed_Item__c ami : list1) {
                ami.Purchase_Info_Inquiry__c = am.Id;
                //添加费用报销明细记录类型ID
                ami.RecordTypeId = recTypeDetailId;
                if (ami.Price__c != null && ami.Quantity__c != null) {
                    ami.Amount__c = ami.Price__c * ami.Quantity__c;
                    decTotal += ami.Amount__c;
                    if (ami.Expense_Type__c == 'N') {
                        decInvoice += ami.Amount__c;
                    }
                }

                if (am.Approval_Status__c == 'D' || am.Approval_Status__c == null) {
                    //费用报销行信息带出凭证行信息
                    if (!map2.containsKey(ami.Row_Index__c)) {
                        Approval_Managed_Item__c s_ami_i = new Approval_Managed_Item__c();
                        s_ami_i.Row_Index__c = ami.Row_Index__c;        //编号方式有问题
                        s_ami_i.Voucher_Info__c = am.Id;
                        s_ami_i.RecordTypeId = recTypeCertificateId;
                        s_ami_i.Subject__c = ami.Ledger_Account__c;
                        s_ami_i.Amount__c = ami.Amount__c;
                        s_ami_i.Dept_of_CostCenter__c = ami.Dept_of_CostCenter__c;
                        s_ami_i.Text__c = ami.Remark__c;
                        s_ami_i.Accounting_Code__c = '40';
                        list2.add(s_ami_i);
                    }else{
                        //更新list2已有匹配的数据
                        Approval_Managed_Item__c s_ami_i = map2.get(ami.Row_Index__c);
                        s_ami_i.Subject__c = ami.Ledger_Account__c;
                        s_ami_i.Amount__c = ami.Amount__c;
                        s_ami_i.Dept_of_CostCenter__c = ami.Dept_of_CostCenter__c;
                        s_ami_i.Text__c = ami.Remark__c;
                        s_ami_i.Accounting_Code__c = '40';
                        System.debug(LoggingLevel.INFO, '*** : s_ami_i.Amount__c' + s_ami_i.Amount__c);
                    }
                }
            }
            Upsert list1;

            for (Approval_Managed_Item__c ami : list2) {
                System.debug(LoggingLevel.INFO, '*** : ami.Amount__c' + ami.Amount__c);
                ami.Voucher_Info__c = am.Id;
                //添加费用报销凭证行信息记录类型ID
                ami.RecordTypeId = recTypeCertificateId;
            }

            Upsert list2;

            am.Amount_of_Total__c = decTotal;
            am.Invoice_Amount_Total__c = decInvoice;
            System.debug(LoggingLevel.INFO, '*** : am主记录' + am);
            Update am;

        } catch (Exception e) {
            Database.rollback(savepoint);
            System.debug('The following exception has occurred: ' + e.getMessage());
            ApexPages.addMessages(e);
            return null;
        }
        return new PageReference('/' + am.Id);
    }

    public PageReference cancel() {
        return new PageReference('/apex/ApprovalHome?sfdc.tabName=01rO0000000Dz6T');
    }

    public PageReference deletelist1() {
        if (list1[list1Row].Id != null) {
            preDeletelist1.add(list1[list1Row]);

            if (map2.containsKey(list1[list1Row].Row_Index__c)) {
                Approval_Managed_Item__c s_ami_d = map2.get(list1[list1Row].Row_Index__c);
                preDeletelist2.add(s_ami_d);
            }

            for (Integer i = 0;i < list2.size() ;i++ ) {
                System.debug(LoggingLevel.INFO, '*** list2.i1: ' + i);
                if (list2[i].Row_Index__c == list1[list1Row].Row_Index__c) {
                    list2.remove(i);
                    System.debug(LoggingLevel.INFO, '*** list2.i2: ' + i);
                    break;
                }
            }
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

    public PageReference newlist1() {
        Approval_Managed_Item__c ami = new Approval_Managed_Item__c();
        ami.Expense_Type__c = 'N';
        ami.Row_Index__c = String.valueOf(getmaxindex());
        list1.add(ami);
        return null;
    }
    public PageReference newlist2() {
        Approval_Managed_Item__c ami = new Approval_Managed_Item__c();
        ami.Row_Index__c = String.valueOf(getmaxindex());
        list2.add(ami);
        return null;
    }

    

    public Integer getmaxindex() {
        maxindex = 0;
        if (list1.size() > 0) {
            for (Approval_Managed_Item__c ami : list1) {
                if (maxindex <= Integer.valueOf(ami.Row_Index__c)) {
                    maxindex = Integer.valueOf(ami.Row_Index__c);
                }
            }  
        }

        if (list2.size() > 0) {
            for (Approval_Managed_Item__c ami : list2) {
                if (maxindex <= Integer.valueOf(ami.Row_Index__c)) {
                    maxindex = Integer.valueOf(ami.Row_Index__c);
                }
            }
        }
        maxindex = maxindex + 1;
        return maxindex;
    }
        
    
}