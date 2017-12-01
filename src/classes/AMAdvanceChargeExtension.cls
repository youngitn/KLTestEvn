//预付款申请流程

public without sharing class AMAdvanceChargeExtension {
    public Approval_Managed__c am {GET; SET;}
    public Id amId {GET; SET;}

    //页面字段级控制变量
    public String szAbleEditFields{get;set;}
    public Boolean isClosed{get;set;}
    

    public AMAdvanceChargeExtension(ApexPages.StandardController con) {
        amId = con.getId();
        isClosed = true;
        Id recType = HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.ADVANCECHARGE, 'Approval_Managed__c');
        //用来计算页面字段级控制
        szAbleEditFields = Utils.getApprovalPageEditFields(amId,recType);
        if (!String.isBlank(szAbleEditFields)) {
            isClosed = false;
        }
        if (amId == null) {
            am = new Approval_Managed__c();
            am.RecordTypeId = recType;
            return;
        }
        String sql = Utils.getApprovalSQL(SapApprovalEnum.ADVANCECHARGE,true);
        sql = sql + ' WHERE Id = \'' + amId + '\'';
        am = Database.query(sql);
    }

    public PageReference save() {
        try {
            if (String.isNotBlank(am.Applicant_Cost__c)) {
                List<Contact> lstCon = [SELECT Name, Number__c FROM Contact WHERE Id = :am.Applicant_Cost__c];
                if (lstCon.size()>0) {
                    am.Applicant_Code_Cost__c = lstCon[0].Number__c;
                    am.Applicant_Name_Cost__c = lstCon[0].Name;
                }
            }
            if (String.isNotBlank(am.Vendor__c)) {
                List<Account> lstAcc = [SELECT Name, Vendor_Number__c FROM Account WHERE Id = :am.Vendor__c];
                if (lstAcc.size()>0) {
                    am.Supplier_Number__c = lstAcc[0].Vendor_Number__c;
                    am.Supplier_Name__c = lstAcc[0].Name;
                }
            }          
            upsert am;
        } catch (Exception e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
            ApexPages.addMessages(e);
            return null;
        }
        return new PageReference('/' + am.Id);
    }

    public PageReference cancel() {
        return new PageReference('/apex/ApprovalHome?sfdc.tabName=01rO0000000Dz6T');
    }
}