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
        Integer i ;
        if (am.meal_YN__c != 'Y' && am.souvenir_YN__c != 'Y' && am.pickup_car_YN__c != 'Y' && am.deliver_car_YN__c != 'Y' && 
            am.pickup_plane_YN__c != 'Y' && am.deliver_plane_YN__c != 'Y' && am.hotel_YN__c != 'Y') {
            i = 1;
            i = 1;
            i = 1;
            i = 1;
            i = 1;
            i = 1;
            i = 1;
            i = 1;
            ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.WARNING,'请至少选择订餐、礼品、派车、飞机、住宿中的一条！'));
            return null;
        }else{
            am.Head_description__c ='来访事由：'+am.visit_reason__c;

            am.RecordTypeId = HarryUtils.getRecordTypeIdByDevNameAndObjName('VisitorHosts','Approval_Managed1__c');

            Upsert am;
            System.debug('***am:' + am);
            ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.INFO,'数据保存成功！'));
            
        }
        return new PageReference('/'+am.Id);      
    }
}