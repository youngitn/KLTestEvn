/**********************************************************************
 名    称：流程配置页控制器
 目    的：通过配置，设置每一个流程节点审批人规则
 作    者：刘文俊(liuwenjun@bluelinksys.com)
 创建日期：2017-04-25
 修 改 人：zhonghui
 修改日期：4-25
 修改原因：添加逻辑
 备    注：
 **********************************************************************/
public with sharing class ApprovalSettingController {
	//流程配置表
	public List<OrganizationalWrapper> lstApprovalSettingWarpper{GET;SET;}
	public Organizational__c orgApproval{GET;SET;}
	public Integer rowID {GET;SET;}   //页面子表行数
	public Boolean isRender{GET;SET;}
	public RecordType recTypeAprConfig;
    //流程名称
    public Metadata__c meta{GET;SET;}
	public List<Organizational__c> lstDelete;
    public ApprovalSettingController() {
        meta = new Metadata__c();
		lstApprovalSettingWarpper = new List<OrganizationalWrapper>();
		lstDelete = new List<Organizational__c>();
		isRender = true;
        recTypeAprConfig=[SELECT Id, DeveloperName FROM RecordType Where SObjectType = 'Organizational__c' AND DeveloperName ='Approval_Config'];
    	lstApprovalSettingWarpper.sort();
    }

    public PageReference actionAddItem(){
        System.debug('*** meta.Approval_Name__c: ' + meta.Approval_Name__c + '');
        if (string.isBlank(meta.Approval_Name__c)) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING, '请选择一个具体流程');
            ApexPages.addMessage(myMsg);
            return null;
        }
    	Organizational__c addItem = new Organizational__c();
    	addItem.Approval_Step__c = lstApprovalSettingWarpper.size()+1;
    	addItem.Approval_Name__c = meta.Approval_Name__c;
    	addItem.RecordTypeId = recTypeAprConfig.Id;
        lstApprovalSettingWarpper.add(new OrganizationalWrapper(addItem));
        return null;
    }
    public PageReference actionDeleteItem(){
         System.debug('*** rowID: ' + rowID + '');
         if (!String.isBlank(lstApprovalSettingWarpper[rowID-1].org.Id)) {
         	lstDelete.add(lstApprovalSettingWarpper[rowID-1].org);
         }
         if (rowID != lstApprovalSettingWarpper.size()) {

         	lstApprovalSettingWarpper.remove(rowID-1);
         	for (Integer i =rowID;i<=lstApprovalSettingWarpper.size();i++) {
         		lstApprovalSettingWarpper[i-1].org.Approval_Step__c = lstApprovalSettingWarpper[i-1].org.Approval_Step__c-1;
         	}
         }else{
         	lstApprovalSettingWarpper.remove(rowID-1);
         }
        return null;
    }
    public PageReference upAction(){
    	if (rowID <=1) {
    		isRender = false;
    		return null;
    	}
    	else{
    		isRender = true;
    		lstApprovalSettingWarpper[rowID-1].org.Approval_Step__c =rowID-1;
    		lstApprovalSettingWarpper[rowID-2].org.Approval_Step__c =rowID;
    		lstApprovalSettingWarpper.sort();
    	}
    	return null;
    }
    public PageReference downAction(){
    	if (rowID == lstApprovalSettingWarpper.size()) {
    		isRender =false;
    	}
    	else{
    		isRender =true;
    		lstApprovalSettingWarpper[rowID-1].org.Approval_Step__c =rowID+1;
    		lstApprovalSettingWarpper[rowID].org.Approval_Step__c =rowID;
    		lstApprovalSettingWarpper.sort();
    	}
    	return null;
    }
    public PageReference saveAction(){
    	System.debug('*** lstApprovalSettingWarpper: ' + lstApprovalSettingWarpper + '');
    	List<Organizational__c>  lstorg= new List<Organizational__c>();
    	for (OrganizationalWrapper apw:lstApprovalSettingWarpper) {
            apw.org.Name = apw.org.Approval_Step_Name__c;
    		lstorg.add(apw.org);
    	}
    	if (lstorg.size()>0) {
    		Upsert lstorg;
    	}
    	if (lstDelete.size()>0) {
    		Delete lstDelete;
    	}
  		
    	return Page.ApprovalSetting;
    }
    public PageReference selectChangeAction(){
        System.debug(LoggingLevel.INFO, '*** meta.Approval_Name__c: ' + meta.Approval_Name__c);
    	//显示相关流程步骤
    	lstApprovalSettingWarpper.clear();
    	lstDelete.clear();
        //查询相关流程配置记录
        List<Organizational__c> lstApprovalConfig  = [SELECT Id,Approval_Name__c,Approval_Step__c,Approval_Step_Name__c,Approval_Rule__c,
                                    Approval_Department__c,Approval_Post__c,Approval_Personnel__c,Approval_Special_Field__c 
                             FROM Organizational__c 
                             WHERE RecordType.DeveloperName = 'Approval_Config'  
                             AND Approval_Name__c = :meta.Approval_Name__c];
        if(lstApprovalConfig.size() > 0){
            for (Organizational__c org : lstApprovalConfig) {
                lstApprovalSettingWarpper.add(new OrganizationalWrapper(org));
            }
        }else{
            //如果没有配置则从标准流程配置结点(ProcessNode)中取出数据
            List<ProcessNode> nodes = [ SELECT Id, Name, DeveloperName, ProcessDefinitionId, Description 
                                    FROM ProcessNode 
                                    WHERE ProcessDefinition.DeveloperName = :meta.Approval_Name__c ORDER BY SystemModstamp];
            if(nodes.size() > 0){
                Integer index = 1;
                for (ProcessNode node : nodes) {
                    Organizational__c org = new Organizational__c();
                    org.Approval_Name__c = meta.Approval_Name__c;
                    org.RecordTypeId = recTypeAprConfig.Id;
                    org.Approval_Step__c = index;
                    org.Approval_Step_Name__c = node.Name;
                    lstApprovalSettingWarpper.add(new OrganizationalWrapper(org)); 
                    index = index + 1;
                }
            }
        }

    	lstApprovalSettingWarpper.sort();
    	return null;
    }

}