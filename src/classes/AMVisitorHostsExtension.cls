public with sharing class AMVisitorHostsExtension {
	PUBLIC Approval_Managed1__c am{GET;SET;}
	public AMVisitorHostsExtension(ApexPages.StandardController con) {
		if(con.getId() == null){
			am = new Approval_Managed1__c();
		}else{
			am = (Approval_Managed1__c)con.getRecord();
		}
    }
    public PageReference save(){ 


        am.Head_description__c ='来访事由：'+am.visit_reason__c;

    	am.RecordTypeId = HarryUtils.getRecordTypeIdByDevNameAndObjName('VisitorHosts','Approval_Managed1__c');


    	Upsert am;
    	ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.INFO,'数据保存成功！'));
    	return new PageReference('/'+am.Id);
    }
}