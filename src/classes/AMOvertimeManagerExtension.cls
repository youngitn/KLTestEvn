public with sharing class AMOvertimeManagerExtension {
    PUBLIC Approval_Managed__c am{GET;SET;}
    public AMOvertimeManagerExtension(ApexPages.StandardController con) {
    if(con.getId() == null){
      am = new Approval_Managed__c();
            am.RecordTypeId = HarryUtils.getRecordTypeIdByDevNameAndObjName('OvertimeWork','Approval_Managed__c');
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