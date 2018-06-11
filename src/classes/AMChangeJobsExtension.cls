public  class AMChangeJobsExtension {   
  
	public Approval_Managed1__c am{get;set;} 
  public Id amId {get; set;} 
  public AMChangeJobsExtension(ApexPages.StandardController con) {
    if(con.getId() == null){
      am = new Approval_Managed1__c();
            am.RecordTypeId = HarryUtils.getRecordTypeIdByDevNameAndObjName('changejobs','Approval_Managed1__c');
    }else{
      am = (Approval_Managed1__c)con.getRecord();
      return;
    }

  } 
 
    public PageReference save(){ 
      am.Remark__c = '具体组织架构变更图，请以附件形式上传';
    	Upsert am;
        return new PageReference('/'+am.Id); 	
    }

    public PageReference cancel() {
        return new PageReference('/apex/ApprovalHome?sfdc.tabName=01rO0000000Dz6T');
    
    }

}