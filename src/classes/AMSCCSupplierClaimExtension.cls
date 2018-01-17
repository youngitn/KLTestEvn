public with sharing class AMSCCSupplierClaimExtension {

	public Custom_Approval_Managed__c am{get;set;} 
    public Id amId {get; set;}
    public AMSCCSupplierClaimExtension(ApexPages.StandardController con) {
         amId = con.getId();
        Id recType = HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.SCCSUPPLIERCLAIM, 'Custom_Approval_Managed__c');
        if (amId == null) {
            am = new Custom_Approval_Managed__c(RecordTypeId = recType);
            return;
        }
        String sql = Utils.getApprovalSQL(SapApprovalEnum.SCCSUPPLIERCLAIM,true);
        sql = sql + ' WHERE Id = \'' + amId + '\'';
        am = Database.query(sql); 
    }

     public PageReference save() {
        return new PageReference('/' + am.Id);
    }

    public PageReference cancel() {
        return new PageReference('/apex/ApprovalHome?sfdc.tabName=01rO0000000Dz6T');
    }


}