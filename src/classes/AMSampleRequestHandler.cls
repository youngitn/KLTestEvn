/**********************************************************************
 名    称：样品申请流程
 目    的：设置样品申请流程各节点审批人
 作    者：王思佳
 创建日期：2018/03/07
 
 
 **********************************************************************/
public without sharing class AMSampleRequestHandler implements Triggers.Handler {
    public void handle() {
        Map<Decimal,Organizational__c>  mapSpecify = null;
        Id rtId = HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.SAMPLEREQUEST,'Approval_Managed1__c');
        if (Trigger.isBefore && Trigger.isInsert) {
            for (Approval_Managed1__c cam : (List<Approval_Managed1__c>)Trigger.new) {
                if (cam.RecordTypeId == rtId) {
                    if(mapSpecify == null){
                        mapSpecify = Utils.getApprovalStepByAPIName(SapApprovalEnum.SAMPLEREQUEST);
                    }
                    setApprovalUser(mapSpecify,cam);
                }
            }
        }

        if (Trigger.isBefore && Trigger.isUpdate) {
            for (Approval_Managed1__c cam : (List<Approval_Managed1__c>)Trigger.new) {
                if (cam.RecordTypeId == rtId && cam.Is_Reset_Approvaler__c) {
                    if(mapSpecify == null){
                        mapSpecify = Utils.getApprovalStepByAPIName(SapApprovalEnum.SAMPLEREQUEST);
                    }
                    setApprovalUser(mapSpecify,cam);
                    cam.Is_Reset_Approvaler__c = false;
                    //cam.head_description__c  = cam.Material_Number__c + '-' + cam.Modify_description__c + '-' + cam.die_use_bu__c;
                }
                
            }
        }
    }

            public void setApprovalUser(Map<Decimal,Organizational__c> mapSpecify,Approval_Managed1__c cam){

            	//节点一：部门主管审批
            	cam.Approval_User1__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(1),cam.Applicant__c),0);
            	//节点三：内勤主管审批
            	if(cam.SalesGroup__c=='20')
            	{
            		cam.Approval_User2__c  = utils.getUserByEmployeeCode('10210154');//程 汪林
            	}
            	else
            	{
            		cam.Approval_User2__c  = utils.getUserByEmployeeCode('10210452');//陈 丹华 
            	}
                
            }
          
    
}