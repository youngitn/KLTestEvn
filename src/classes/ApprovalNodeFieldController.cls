public with sharing class ApprovalNodeFieldController {
	//记录类型Id
	public Id rtId = null;
    //流程名称
    public Metadata__c meta{GET;SET;}
    //结点集合
	public List<Organizational__c> lstNodes{GET;SET;}
    //要删除的旧数据
    public List<Organizational__c> lstDelOrg{GET;SET;}
    public ApprovalNodeFieldController() {
        meta = new Metadata__c();
        lstNodes = new List<Organizational__c>();
        lstDelOrg = new List<Organizational__c>();
        rtId = HarryUtils.getRecordTypeIdByDevNameAndObjName('Node_Edit_Field','Organizational__c');
    }
    public PageReference saveAction(){
    	if(lstNodes.size() > 0){
    		UPSERT lstNodes;
    	}
        if (lstDelOrg.size()>0) {
            DELETE lstDelOrg;
        }
    	return Page.ApprovalNodeField;
    }
    public PageReference selectChangeAction(){
        System.debug(LoggingLevel.INFO, '*** 流程名称: ' + meta.Approval_Name__c);
        //更新前清除所有节点数据
        lstNodes.clear();
        lstDelOrg.clear();
        //查询相关流程配置记录
        List<Organizational__c> configs  = [
        					SELECT Id,Approval_Name__c,ProcessNodeId__c,Approval_Step__c,Node_API__c,Node_Name__c,
                                   Is_SyncCheck__c,Node_Edit_Fields__c,Node_DetailEdit_Fields__c,
                                   Node_Require_Fields__c,Node_DetailRequire_Fields__c  
                            FROM Organizational__c 
                            WHERE RecordType.DeveloperName = 'Node_Edit_Field'  
                            AND Approval_Name__c = :meta.Approval_Name__c];
        System.debug(LoggingLevel.INFO, '*** configs: ' + configs);
        Map<String,Organizational__c> mapSetting = new Map<String,Organizational__c>();
        for(Organizational__c org : configs){
        	if(!mapSetting.containsKey(org.Node_API__c)){
        		mapSetting.put(org.Node_API__c, org);
        	}
        }
        //查询流程结点配置信息(ProcessNode)
        List<ProcessNode> nodes = [
        					SELECT Id, Name, DeveloperName, ProcessDefinitionId, Description 
                            FROM ProcessNode 
                            WHERE ProcessDefinition.DeveloperName = :meta.Approval_Name__c 
                            ORDER BY DeveloperName];
        System.debug(LoggingLevel.INFO, '*** nodes: ' + nodes);
        Set<String> setRealNodes = new Set<String>();
        if(nodes.size() > 0){
            Integer index = 1;
            for (ProcessNode node : nodes) {
                Organizational__c org = new Organizational__c();
                org.Approval_Name__c = meta.Approval_Name__c;
                org.RecordTypeId = rtId;
                org.Node_API__c = node.DeveloperName;
                org.Node_Name__c = node.Name;
                org.ProcessNodeId__c = node.Id;
                org.Approval_Step__c = index;
                if(mapSetting.containsKey(node.DeveloperName)){
                    Organizational__c old = mapSetting.get(node.DeveloperName);
                    org.Id = old.Id;
                	org.Node_Edit_Fields__c = old.Node_Edit_Fields__c;
                    org.Node_DetailEdit_Fields__c = old.Node_DetailEdit_Fields__c;
                    org.Node_Require_Fields__c = old.Node_Require_Fields__c;
                    org.Node_DetailRequire_Fields__c = old.Node_DetailRequire_Fields__c;
                    org.Is_SyncCheck__c = old.Is_SyncCheck__c;
                }else{
                	org.Node_Edit_Fields__c = '';
                    org.Node_DetailEdit_Fields__c = '';
                    org.Node_Require_Fields__c = '';
                    org.Node_DetailRequire_Fields__c = '';
                }
                setRealNodes.add(node.DeveloperName);
                lstNodes.add(org);
                index = index + 1;
            }
        }
        //删除旧的数据
        for ( String str : mapSetting.keySet() ) {
            if (!setRealNodes.contains(str)) {
                lstDelOrg.add(mapSetting.get(str));
            }
        }
        System.debug(LoggingLevel.INFO, '*** lstDelOrg: ' + lstDelOrg);

    	return null;
    }
}