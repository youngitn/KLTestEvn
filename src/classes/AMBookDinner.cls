public with sharing class AMBookDinner {
 public Approval_Managed1__c am{get;set;}
    public Boolean isDeletedStatus{GET;SET;}
    public AMBookDinner(ApexPages.StandardController con) {
    	am = new Approval_Managed1__c();
        am.RecordTypeId = HarryUtils.getRecordTypeIdByDevNameAndObjName('BookDinner','Approval_Managed1__c');
    	if(con.getId() == null){
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