public with sharing class AMLeaveApplicationHandler  implements Triggers.Handler
{


    public void handle()
    {


        Map<Decimal, Organizational__c>  mapSpecify = null;
        Id rtId = HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.LEAVEAPPLICATION, 'Approval_Managed__c');
        Boolean haveSfID = true;
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
                    System.debug('cam.Employee_code__c-->'+cam.Employee_code__c);
                    //申請人讀取權限
                    //userIds.add( Peoples.getInstance().KlAllUserMapGetByNum.get(Peoples.getInstance().KlAllContactMapGetById.get(cam.Applicant__c).Number__c).Id);
                    if (Peoples.getInstance().KlAllContactMapGetById.get(cam.Employee__c).SF_user__r.Id != null){
                        //userIds.add( Peoples.getInstance().KlAllContactMapGetById.get(cam.Employee__c).SF_user__r.Id);
                        userIds.add(Peoples.getInstance().KlAllContactMapGetById.get(cam.Employee__c).SF_user__r.Id);
                    }else if(Peoples.getInstance().KlAllUserMapGetByNum.get(cam.Employee_code__c) != null){
                        userIds.add(Peoples.getInstance().KlAllUserMapGetByNum.get(cam.Employee_code__c).Id);
                    }     

                    if(userIds.size() > 0)
                    {
                        Utils.ManualShareRecordToUsers(userIds, 'Approval_Managed__c', String.valueOf(cam.get('Id')));
                    }
                    setApprovalUser(mapSpecify, cam );
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
                        setApprovalUser(mapSpecify, cam );
                        cam.Is_Reset_Approvaler__c = false;
                    }                    
                }

            }

        }
    }
    public void setApprovalUser(Map<Decimal, Organizational__c> mapSpecify, Approval_Managed__c cam )
    {

        // 主管簽核(請假人主管)
        cam.Approval_User1__c = Utils.getByIndex(ApproverUtils.approvalSearchApprrovalerByRuleWithOutSOQL(mapSpecify.get(1), cam.Employee__c), 0);
        //大於三天總經理簽核
        cam.Approval_User2__c = Utils.getByIndex(ApproverUtils.approvalSearchApprrovalerByRuleWithOutSOQL(mapSpecify.get(2), null), 0);

        //HR經辦
        cam.Approval_User3__c = Utils.getByIndex(ApproverUtils.approvalSearchApprrovalerByRuleWithOutSOQL(mapSpecify.get(3), null), 0);

        //-----以下為抓通知人用-----------
        
        //HR主管
        cam.Approval_User4__c = Utils.getByIndex(ApproverUtils.approvalSearchApprrovalerByRuleWithOutSOQL(mapSpecify.get(4), null), 0);
        cam.Approval_User5__c = mustNeedUserToNatify(cam.Employee__c,cam);
        cam.Approval_User6__c = mustNeedUserToNatify(cam.Operator_Abnormal__c,cam);
    }
    public Id mustNeedUserToNatify(Id cId,Approval_Managed__c cam){
        //請假人 
        Contact c = Peoples.getInstance().KlAllContactMapGetById.get(cId);

        //情況一 可以從聯絡人關聯到User 間接人員
        if (c != null && c.SF_user__r.Id != null ){
            return c.SF_user__r.Id;

        }//情況二 無法從聯絡人關聯到User 須拿工號關聯才有資料 部分現場人員(chatter free user)
        else if(c != null && Peoples.getInstance().KlAllUserMapGetByNum.get(c.Number__c) !=null){
            return Peoples.getInstance().KlAllUserMapGetByNum.get(c.Number__c).Id;
            
        }//確定完全沒User帳號 將通知人設為主管
        else{
            return cam.Approval_User1__c;
        }
    }

}