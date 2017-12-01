public with sharing class AMSignetUseExtension { 

    public Approval_Managed__c am{get;set;} 
    public Id amId {get; set;}

    public AMSignetUseExtension(ApexPages.StandardController con) {
        amId = con.getId();
        Id recType = HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.SIGNETUSE, 'Approval_Managed__c');
        if (amId == null) {
            am = new Approval_Managed__c(RecordTypeId = recType);
            return;
        }
        String sql = Utils.getApprovalSQL(SapApprovalEnum.SIGNETUSE,true);
        sql = sql + ' WHERE Id = \'' + amId + '\'';
        am = Database.query(sql); 
    }


    public PageReference save() {
        // if (am.Acceptance_condition__c == true && am.Content_acceptance__c != null) {
            
        // }
      if (String.isNotBlank(am.Account__c)) {
            list<Account> con = [SELECT AccountNumber, Name FROM Account WHERE Id = :am.Account__c];
            if (con.size() > 0) {
              am.Account_Number__c = con[0].AccountNumber;
              am.Account_Name__c = con[0].Name;
            }
        }
        try {
            upsert am;
            System.debug(LoggingLevel.INFO, '*** am.Acceptance_condition__c: ' + am.Acceptance_condition__c); 
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