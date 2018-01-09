public with sharing class AMQccExtension {
		PUBLIC Approval_Managed1__c am{GET;SET;}
    public AMQccExtension(ApexPages.StandardController con) {
		if(con.getId() == null){
			am = new Approval_Managed1__c();
            am.RecordTypeId = HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.QCC,'Approval_Managed1__c');
		}else{
			am = (Approval_Managed1__c)con.getRecord();
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