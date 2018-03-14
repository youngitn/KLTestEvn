public with sharing class AMEXP_ApplicationFeeExtension {
     PUBLIC Approval_Managed2__c am{GET;SET;}
	public AMEXP_ApplicationFeeExtension(ApexPages.StandardController con) {
		if(con.getId() == null){
			am = new Approval_Managed2__c();
		}else{
			am = (Approval_Managed2__c)con.getRecord();
		}
    }
     public PageReference save(){
    	am.RecordTypeId = HarryUtils.getRecordTypeIdByDevNameAndObjName('EXP_ApplicationFee','Approval_Managed2__c');
        am.Head_description__c = am.Approval_Name__c;
        Upsert am;
    	ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.INFO,'数据保存成功！'));
    	return new PageReference('/'+am.Id);
    }
}