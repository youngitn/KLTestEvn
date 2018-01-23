public with sharing class ProcessUtils {
	public static Boolean checkEditable(Id objId,Id rId){
       String nowNode = [SELECT Id, ProcessNodeId, ProcessNode.DeveloperName, ProcessInstance.ProcessDefinition.DeveloperName
                         FROM ProcessInstanceNode
                         WHERE ProcessInstance.TargetObjectId =:objId  ORDER BY CreatedDate DESC
                                 LIMIT 1].get(0).ProcessNode.DeveloperName;
        System.debug(nowNode);                        
        String RTDevName = [SELECT Id, Name, DeveloperName FROM RecordType WHERE id =: rId].get(0).DeveloperName;
        System.debug(RTDevName);
        List<Organizational__c> setlist = [SELECT Id, Node_API__c ,Node_Edit_Fields__c, Node_DetailEdit_Fields__c,
                                              Node_Require_Fields__c, Node_DetailRequire_Fields__c
                                              FROM Organizational__c
                                              WHERE RecordType.DeveloperName = 'Node_Edit_Field'
                                                      AND Node_API__c = :nowNode
                                                              AND Approval_Name__c = :RTDevName];
        System.debug(setlist);
        if (setlist.get(0).Node_Edit_Fields__c != null){
            return true;
        }
        return false;
    }
}