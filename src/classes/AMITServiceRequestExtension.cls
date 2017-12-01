public without sharing class AMITServiceRequestExtension {
    public Approval_Managed1__c am{get;set;}
    public Boolean isDeletedStatus{GET;SET;}
    public AMITServiceRequestExtension(ApexPages.StandardController con) {
    	am = new Approval_Managed1__c();
        am.RecordTypeId = HarryUtils.getRecordTypeIdByDevNameAndObjName('IRS_InformationService','Approval_Managed1__c');
    	if(con.getId() == null){
		}else{
			am = (Approval_Managed1__c)con.getRecord();
		}
    }
    public PageReference save(){
        
  if (am.Factory__c== '3000'&&(am.ServiceCategory__c == '120' || am.ServiceCategory__c == '130'|| am.ServiceCategory__c == '150'|| am.ServiceCategory__c == '190'|| 
      am.ServiceCategory__c == '200'|| am.ServiceCategory__c == '210')) {
  if(am.ModuleName__c==null){
  ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, '尚未選模組'));
     return null;
    }
 }
    	Upsert am;
    	return new PageReference('/'+am.Id);
    }
    public PageReference cancel() {
        return new PageReference('/apex/ApprovalHome?sfdc.tabName=01rO0000000Dz6T');
    }
}