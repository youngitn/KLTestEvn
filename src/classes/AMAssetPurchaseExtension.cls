//资产购置流程

public with sharing class AMAssetPurchaseExtension {

    public Approval_Managed__c am {get; set;}

    public Id amId {get; set;}
    //页面字段级控制变量
    public String szAbleEditFields{get;set;}
    public Boolean isClosed{get;set;}

    public AMAssetPurchaseExtension(ApexPages.StandardController con) {
        amId = con.getId();
        isClosed = true;
        Id recType = HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.ASSETPURCHASE, 'Approval_Managed__c');
        //用来计算页面字段级控制
        Id amId = con.getId();
        szAbleEditFields = Utils.getApprovalPageEditFields(amId,recType);
        if (!String.isBlank(szAbleEditFields)) {
            isClosed = false;
        }
        if (amId == null) {
            am = new Approval_Managed__c(RecordTypeId = recType);
            return;
        }
        String sql = Utils.getApprovalSQL(SapApprovalEnum.ASSETPURCHASE,true);
        sql = sql + ' WHERE Id = \'' + amId + '\'';
        am = Database.query(sql);
    }
    public PageReference save() {
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