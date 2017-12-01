public with sharing class AMMeasuringInstRequestExtension {
    PUBLIC Approval_Managed__c am{GET;SET;}
    public AMMeasuringInstRequestExtension(ApexPages.StandardController con) {
    if(con.getId() == null){
      am = new Approval_Managed__c();
            am.RecordTypeId = HarryUtils.getRecordTypeIdByDevNameAndObjName('MeasuringInstRequest','Approval_Managed__c');
    }else{
      am = (Approval_Managed__c)con.getRecord();
    }
    }
    public PageReference save(){
      Upsert am;
      return new PageReference('/'+am.Id);
    }

      public PageReference cancel() {
        return new PageReference('/apex/ApprovalHome?sfdc.tabName=01rO0000000Dz6T');
    }
}