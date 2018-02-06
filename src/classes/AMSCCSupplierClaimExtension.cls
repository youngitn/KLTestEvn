public with sharing class AMSCCSupplierClaimExtension {  

	public Custom_Approval_Managed__c am{get;set;} 
    public Id amId {get; set;}
    Map<Decimal,Organizational__c> mapSpecify = Utils.getApprovalStepByAPIName(SapApprovalEnum.SCCSUPPLIERCLAIM);
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
    
            if (String.isBlank(am.Approval_User5__c)) {
                am.Approval_User5__c = am.Approval_User4__c;
            }
            if (String.isBlank(am.Approval_User6__c)) {
                am.Approval_User6__c = am.Approval_User4__c; 
            }
            System.debug(am.Approval_User6__c);

            if (String.isBlank(am.Approval_User8__c)) {
                am.Approval_User8__c = am.Approval_User7__c;
            }
            if (String.isBlank(am.Approval_User9__c)) {
                am.Approval_User9__c = am.Approval_User7__c;
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