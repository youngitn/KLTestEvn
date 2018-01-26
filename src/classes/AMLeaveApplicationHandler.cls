public with sharing class AMLeaveApplicationHandler  implements Triggers.Handler
{


    public void handle()
    {


        Map<Decimal, Organizational__c>  mapSpecify = null;
        Id rtId = HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.LEAVEAPPLICATION, 'Approval_Managed__c');

        if (Trigger.isBefore && Trigger.isInsert)
        {
            Set<String> userIds = new Set<String>();
            for (Approval_Managed__c cam : (List<Approval_Managed__c>)Trigger.new)
            {
                if (cam.RecordTypeId == rtId)
                {
                     if (cam.Employee__c == null){
                        cam.addError('Employee__c is empty');
                     }
                    if (mapSpecify == null)
                    {
                        //這裡的step來源是[流程配置] 不是Approval Processes
                        mapSpecify = Utils.getApprovalStepByAPIName(SapApprovalEnum.LEAVEAPPLICATION);
                    }
                    setApprovalUser(mapSpecify, cam);
                    //申請人讀取權限
                    //userIds.add( Peoples.getInstance().KlAllUserMapGetByNum.get(Peoples.getInstance().KlAllContactMapGetById.get(cam.Applicant__c).Number__c).Id);
                    
                    userIds.add( Peoples.getInstance().KlAllUserMapGetByNum.get(Peoples.getInstance().KlAllContactMapGetById.get(cam.Employee__c).Number__c).Id);

                    if(userIds.size() > 0)
                    {
                        Utils.ManualShareRecordToUsers(userIds, 'Approval_Managed__c', String.valueOf(cam.get('Id')));
                    }
                }

                
            }
        }
        if (Trigger.isBefore && Trigger.isUpdate)
        {
            System.debug('##################');

            for (Approval_Managed__c cam : (List<Approval_Managed__c>)Trigger.new)
            {

                if (cam.RecordTypeId == rtId )
                {
                    if (cam.Is_Reset_Approvaler__c){
                        if (mapSpecify == null)
                        {
                            mapSpecify = Utils.getApprovalStepByAPIName(SapApprovalEnum.LEAVEAPPLICATION);
                        }
                        setApprovalUser(mapSpecify, cam);
                        cam.Is_Reset_Approvaler__c = false;
                    }                    
                }

            }

        }
    }
    public void setApprovalUser(Map<Decimal, Organizational__c> mapSpecify, Approval_Managed__c cam)
    {

        // 主管簽核
        cam.Approval_User1__c       = Utils.getByIndex(ApproverUtils.approvalSearchApprrovalerByRuleWithOutSOQL(mapSpecify.get(1), cam.Employee__c), 0);

        //大於三天總經理簽核
        cam.Approval_User2__c       = Utils.getByIndex(ApproverUtils.approvalSearchApprrovalerByRuleWithOutSOQL(mapSpecify.get(2), null), 0);

        //HR經辦
        cam.Approval_User3__c       = Utils.getByIndex(ApproverUtils.approvalSearchApprrovalerByRuleWithOutSOQL(mapSpecify.get(3), null), 0);

        //HR主管
        cam.Approval_User4__c       = Utils.getByIndex(ApproverUtils.approvalSearchApprrovalerByRuleWithOutSOQL(mapSpecify.get(4), null), 0);
        
    }

}