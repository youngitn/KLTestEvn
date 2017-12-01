public with sharing class AMCancelTECOExtension {
        
    public Approval_Managed2__c am {get; set;}

    public Id amId {get; set;}

    public AMCancelTECOExtension(ApexPages.StandardController con) {
        amId = con.getId();

        if (amId == null) {
            am = new Approval_Managed2__c(RecordTypeId = HarryUtils.getRecordTypeIdByDevNameAndObjName('CancelTECO', 'Approval_Managed2__c'));
            return;
        }
        String sql = Utils.getApprovalSQL(SapApprovalEnum.STAFFLEAVEOFFICE,true);
        sql = sql + ' WHERE Id = \'' + amId + '\'';
        am = Database.query(sql);
    }
    
    public PageReference save() {
        if (String.isNotBlank(am.Applicant__c)) {
            Contact con = [SELECT  Number__c FROM Contact WHERE Id = :am.Applicant__c];
            am.Applicationcode__c = con.Number__c;
           // am.Applicant_Name__c = con.Applicant__c;
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