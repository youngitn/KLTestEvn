public with sharing class AMCreditLoanExtension {
	public Approval_Managed1__c am{GET;SET;}
	public AMCreditLoanExtension(ApexPages.StandardController con) {
		if(con.getId() == null){
			am = new Approval_Managed1__c();
		}else{
			am = (Approval_Managed1__c)con.getRecord();
		}
    }
    public PageReference save(){
    	am.RecordTypeId = HarryUtils.getRecordTypeIdByDevNameAndObjName('CreditLoan','Approval_Managed1__c');
    	Upsert am;
    	ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.INFO,'數據保存成功！'));
    	return new PageReference('/'+am.Id);
    }
}