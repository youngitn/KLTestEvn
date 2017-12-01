public without sharing class GetTaskInfoFromCRMHandler2 implements Triggers.Handler {
    public void handle() {
    	if(Trigger.isAfter){
	    	for (SObject am : Trigger.new) {
	    		String sobjectName = String.valueOf(am.getSObjectType());
	    		String taskId = null;
	    		if(sobjectName == 'Custom_Approval_Managed2_Item__c'){
	    			taskId = String.valueOf(am.get('Campaign__c'));
	    			if(!String.isBlank(taskId)){
	    				Utils.getTaskFromCRM(String.valueOf(am.get('Id')),taskId,'Travel_Manage');
	    			}
	    		}else if(sobjectName == 'Approval_Managed2_Item__c'){
	    			//taskId = String.valueOf(am.get('TaskID__c'));
	    			//if(!String.isBlank(taskId)){
	    			//	Utils.getTaskFromCRM(String.valueOf(am.get('Id')),taskId,'Payment_Detail');
	    			//}
	    		}
	    	}
    	}
    }
}