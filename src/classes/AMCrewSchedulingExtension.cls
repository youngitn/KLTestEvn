public with sharing class AMCrewSchedulingExtension {   
	public Approval_Managed1__c am{get;set;} 
  public Id amId {get; set;}
    public AMCrewSchedulingExtension(ApexPages.StandardController con) {
    	  am = new Approval_Managed1__c();
        amId = con.getId();
        Id recType = HarryUtils.getRecordTypeIdByDevNameAndObjName('CrewScheduling','Approval_Managed1__c');
        if(amId != null){
		    //查询相应记录
           String sql = Utils.getApprovalSQL(SapApprovalEnum.CREWSCHEDULING,true);
           sql = sql + ' WHERE Id = \'' + amId + '\'';
           am = Database.query(sql);  
		}else{
            am = new Approval_Managed1__c(RecordTypeId = recType);
          return;
        }
    } 
 
    public PageReference save(){ 
      am.Remark__c = '员工排班申请由部门主管完成，具体排班内容需要以附件形式上传';
    	Upsert am;
        return new PageReference('/'+am.Id); 	
    }

    public PageReference cancel() {
        return new PageReference('/apex/ApprovalHome?sfdc.tabName=01rO0000000Dz6T');
    }


    

}