/**************************************************************************************************
 * Name: ItemBankDetailExtension
 * Object: Custom_Approval_Managed__c
 * Purpose: 当前用户是记录的审批人，就能够编辑银行细目子表，否则，只能查看。
 * Requirement:
 * Author: zhonghui
 * Create Date: 2017-4-16
 * Modify History: 
 * 
***************************************************************************************************/
public with sharing class ItemBankDetailExtension {
	public List<Custom_Approval_Managed_Item__c> listBankDetail{get;set;}
	public Boolean isRedered{get;set;}
    public ItemBankDetailExtension(ApexPages.StandardController con) {
    	listBankDetail = new List<Custom_Approval_Managed_Item__c>();
    	isRedered = false;
    	String recoredID = con.getId();
    	System.debug('*** recoredID: ' + recoredID + '');
    	//查询银行细目记录
    	RecordType recType=[SELECT Id FROM RecordType Where SObjectType = 'Custom_Approval_Managed_Item__c' AND DeveloperName ='Custmer_Bank_Detail'];
    	listBankDetail = [SELECT Is_Checked__c, Validate_Date__c, Country__c, Bank_of_Code__c, Account_of_Bank__c, Account_Name__c, Name_of_Bank__c, IBANValue__c, SWIFT_Code__c FROM Custom_Approval_Managed_Item__c Where Customer_Bank__c = :recoredID AND RecordTypeId = :recType.Id];
    	System.debug('*** listBankDetail: ' + listBankDetail + '');
    	//查询当前记录的审批人
    	List<ProcessInstance>  lstIstance= new List<ProcessInstance>();
    	lstIstance = [SELECT Id FROM ProcessInstance Where TargetObjectId = :recoredID];
    	System.debug('*** lstIstance: ' + lstIstance + '');
    	if (lstIstance.size()>0) {

    	    List<ProcessInstanceWorkitem> lstWorkItem = [SELECT ActorId FROM ProcessInstanceWorkitem Where ProcessInstanceId = :lstIstance[lstIstance.size()-1].Id];
			
            System.debug('*** lstWorkItem: ' + lstWorkItem + '');
			//判断当前用户是否是当前审批人
			if (lstWorkItem.size()>0) {
			    String userID = UserInfo.getUserId();
                String actorID = lstWorkItem[lstWorkItem.size()-1].ActorId;
                System.debug('*** 当前用户ID: ' + userID + '/n当前审批人：'+actorID);
    			if (userID.substring(0, 15)==actorID.substring(0, 15)) {
    	  		  //
    	   		 isRedered =true;
				}
    		
    		}
    	}
    	
    }
    public PageReference saveBankDetailRecord (){
    	try{
    		System.debug('*** listBankDetail: ' + listBankDetail + '');
    		update listBankDetail;
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO, '保存成功');
            ApexPages.addMessage(msg);
    	}
    	catch(Exception e){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, '更新出错:'+e.getMessage());
            ApexPages.addMessage(msg);
    		System.debug('*** 更新记录出错: ' + e.getMessage() + '');
    	}
    	return null;
    }
}