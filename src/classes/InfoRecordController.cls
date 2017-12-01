public with sharing class InfoRecordController {
	public Custom_Approval_Managed__c infoRecord{get;set;} //信息记录抬头
    public List<Custom_Approval_Managed_Item__c> listResult{get;set;}//信息记录结果
    public InfoRecordController(ApexPages.StandardController con) {
    	infoRecord = new Custom_Approval_Managed__c();        
        listResult = new List<Custom_Approval_Managed_Item__c>();
        
    }    
    public PageReference saveAction(){
    	return null;
    }

    
    public PageReference cancelAction(){
    	return null;
    }
}