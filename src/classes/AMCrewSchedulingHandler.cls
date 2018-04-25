/**********************************************************************
 名    称：排班管理流程
 作    者：刘忠林
 创建日期：2018/4/10 
 
 **********************************************************************/

public without sharing class AMCrewSchedulingHandler implements Triggers.Handler {
   public void handle() {
        Map<Decimal,Organizational__c>  mapSpecify = null;
        Id rtId = HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.CREWSCHEDULING,'Approval_Managed1__c');
        if (Trigger.isBefore && Trigger.isInsert) {
            for (Approval_Managed1__c cam : (List<Approval_Managed1__c>)Trigger.new) {
                if (cam.RecordTypeId == rtId) {
                    if(mapSpecify == null){
                        mapSpecify = Utils.getApprovalStepByAPIName(SapApprovalEnum.CREWSCHEDULING);
                    }
                    setApprovalUser(mapSpecify,cam);
                }
            }
        }

        if (Trigger.isBefore && Trigger.isUpdate) {
            for (Approval_Managed1__c cam : (List<Approval_Managed1__c>)Trigger.new) {
                if (cam.RecordTypeId == rtId && cam.Is_Reset_Approvaler__c) {
                    if(mapSpecify == null){
                        mapSpecify = Utils.getApprovalStepByAPIName(SapApprovalEnum.CREWSCHEDULING);
                    }
                    setApprovalUser(mapSpecify,cam);
                    cam.Is_Reset_Approvaler__c = false;
                    //cam.head_description__c  = cam.Material_Number__c + '-' + cam.Modify_description__c + '-' + cam.die_use_bu__c;
                }
                
            }
        }
    }

            public void setApprovalUser(Map<Decimal,Organizational__c> mapSpecify,Approval_Managed1__c cam){

            	//节点一：一阶主管审批
            	cam.Approval_User1__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(1),cam.Applicant__c),0);
            	//节点三：HR考勤专员
            	if(cam.Applicant_Corp_Code__c  !='3000' || cam.Applicant_Corp_Code__c  !='2000'){
            		cam.Approval_User2__c  = utils.getUserByEmployeeCode('10210156');//李燕
            	}else if (cam.Applicant_Corp_Code__c =='2000') {
                    cam.Approval_User2__c  = utils.getUserByEmployeeCode('20210234');//刘倩
                }


            }

}