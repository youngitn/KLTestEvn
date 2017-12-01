public with sharing class AMStaffTransferExtension {
       
    public Approval_Managed__c am {get; set;}

    public Id amId {get; set;}
    //页面字段级控制变量
    public String szAbleEditFields{get;set;}
    public Boolean isClosed{get;set;}
    public AMStaffTransferExtension(ApexPages.StandardController con) {
        amId = con.getId();
        isClosed = true;
        Id recType = HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.STAFFTRANSFER, 'Approval_Managed__c');
        //用来计算页面字段级控制
        szAbleEditFields = Utils.getApprovalPageEditFields(amId,recType);
        if (!String.isBlank(szAbleEditFields)) {
            isClosed = false;
        }
        if (amId == null) {
            am = new Approval_Managed__c(RecordTypeId = recType);
            return;
        }
        String sql = Utils.getApprovalSQL(SapApprovalEnum.STAFFTRANSFER,true);
        sql = sql + ' WHERE Id = \'' + amId + '\'';
        am = Database.query(sql);
    }
    
    public PageReference save() {
        if (String.isNotBlank(am.Employee__c)) {
            Contact con = [SELECT Number__c, Name , toLabel(Staff_Group__c), toLabel(Staff_Sub_Group__c) FROM Contact WHERE Id = :am.Employee__c];
            am.Employee_Code__c = con.Number__c;
            am.Employee_Name__c = con.Name;
            am.Staff_Group_Name__c = con.Staff_Group__c;
            am.Staff_Sub_Group_Name__c = con.Staff_Sub_Group__c;
        }
        try {
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