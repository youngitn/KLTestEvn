public with sharing class GetBoss {

	public String empid{set;get;}

	public GetBoss() {
		
	}

	public PageReference GetMyBoss() {

		Organizational__c o = new Organizational__c();
        o.Approval_Rule__c  = '指定人部门主管';
        Contact c = Peoples.getInstance().KlAllContactMapGetByNum.get(empid);
        User u = Peoples.getInstance().KlAllUserMapGetById.get(ApproverUtils.approvalSearchApprrovalerByRuleWithOutSOQL(o,c.Id).get(0));


		ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.WARNING, 'boss->'+u.name+' '+u.Number__c));
		return null;
	}


}