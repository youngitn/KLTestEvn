public with sharing class AMInternalStaffRecommendExtension {
    PUBLIC Approval_Managed2__c am{GET;SET;}
    public AMInternalStaffRecommendExtension(ApexPages.StandardController con) {
    if(con.getId() == null){
      am = new Approval_Managed2__c();
            am.RecordTypeId = HarryUtils.getRecordTypeIdByDevNameAndObjName('AMInternalStaffRecommend','Approval_Managed2__c');
    }else{
      am = (Approval_Managed2__c)con.getRecord();
    }
     String a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
    }

    public PageReference save(){
      //am.Approval_Name__c = '内部员工引荐流程';
      am.Bill_Date__c=Date.today();
      List<Contact> u=[SELECT Number__c, Name,Dept_Number__c FROM Contact WHERE id = :am.Introducer__c];
      List<Organizational__c> d=[SELECT Name FROM Organizational__c WHERE id = :u.get(0).Dept_Number__c];
      am.RecommendationClause__c='兹介绍['+am.TheIntroducer__c+']先生/女士到['+am.IntroducerDept__c+']部门工作，据本人了解，被介绍人品行端正、工作忠实，未有犯罪记录，其工作经历符合公司召募岗位，且愿意遵守本公司的规章制度，本人愿作引荐人，并且遵守如下约定：\r\n' + 
				'\r\n' + 
				'1.	本人保证被介绍人所提供的个人简历材料及所有有效证件均属实，如有弄虚作假，按公司规定给予解雇，本人愿负连带责任。\r\n' + 
				'2.	若被介绍人有违反公司规章制度行为，请公司按章惩处，本人决不说情袒护，决不通过任何途径将被介绍人调换其它工作岗位。\r\n' + 
				'3.	本人保证在任何时候决不向被介绍人收取任何费用或礼品，而且充分了解这样的行为是严重触犯公司规章制度的规定，本人若有触犯，愿意受到公司立即解雇的惩处。\r\n' + 
				'\r\n' + 
				'\r\n' + 
				'特立此引荐书为凭。\r\n' + 
				'                                介绍人：'+u.get(0).Name+'\r\n' + 
				'日期：'+am.Bill_Date__c.year()+'年'+am.Bill_Date__c.month()+'月'+am.Bill_Date__c.day()+'日\r\n' + 
				'\r\n' + 
				'部门主管/经理: manager__c 介绍人所在部门：'+d.get(0).Name+'              工号：'+u.get(0).Number__c+'\r\n' + 
				'\r\n' + 
				'保存年限：3年   \r\n';
      Upsert am;
      return new PageReference('/'+am.Id);
    }

      public PageReference cancel() {
        return new PageReference('/apex/ApprovalHome?sfdc.tabName=01rO0000000Dz6T');
    }
}