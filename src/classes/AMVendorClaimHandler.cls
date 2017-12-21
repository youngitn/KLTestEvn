public class AMVendorClaimHandler implements Triggers.Handler
{
    public void handle()
    {


        Map<Decimal, Organizational__c>  mapSpecify = null;
        Id rtId = HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.VENDORCLAIM, 'Custom_Approval_Managed__c');

        if (Trigger.isBefore && Trigger.isInsert)
        {
            Set<String> userIds = new Set<String>();
            for (Custom_Approval_Managed__c cam : (List<Custom_Approval_Managed__c>)Trigger.new)
            {
                if (cam.RecordTypeId == rtId)
                {

                    if (mapSpecify == null)
                    {
                        //這裡的step來源是[流程配置] 不是Approval Processes
                        mapSpecify = Utils.getApprovalStepByAPIName(SapApprovalEnum.VENDORCLAIM);
                    }
                    setApprovalUser(mapSpecify, cam);
                }

                //申請人讀取權限
                userIds.add( Utils.getUserIdByContactID(cam.Applicant__c));

                if(userIds.size() > 0)
                {
                    Utils.ManualShareRecordToUsers(userIds, 'Custom_Approval_Managed__c', String.valueOf(cam.get('Id')));
                }
            }
        }
        if (Trigger.isBefore && Trigger.isUpdate)
        {
            System.debug('##################');

            for (Custom_Approval_Managed__c cam : (List<Custom_Approval_Managed__c>)Trigger.new)
            {

                if (cam.RecordTypeId == rtId && cam.Is_Reset_Approvaler__c)
                {
                    if (mapSpecify == null)
                    {
                        mapSpecify = Utils.getApprovalStepByAPIName(SapApprovalEnum.VENDORCLAIM);
                    }
                    setApprovalUser(mapSpecify, cam);
                    cam.Is_Reset_Approvaler__c = false;
                }

            }

        }
    }
    public void setApprovalUser(Map<Decimal, Organizational__c> mapSpecify, Custom_Approval_Managed__c cam)
    {

        // 品管主管審核 由Adam指派
        cam.Approval_User1__c       = Utils.getByIndex(ApproverUtils.approvalSearchApprrovalerByRuleWithOutSOQL(mapSpecify.get(1), null), 0);

        //生管
        cam.Approval_User2__c       = Utils.getByIndex(ApproverUtils.approvalSearchApprrovalerByRuleWithOutSOQL(mapSpecify.get(2), null), 0);

        //財務
        cam.Approval_User3__c       = Utils.getByIndex(ApproverUtils.approvalSearchApprrovalerByRuleWithOutSOQL(mapSpecify.get(3), null), 0);

        //採購 申請人自己
        cam.Approval_User4__c       = Peoples.getInstance().KlAllUserMapGetByNum.get(Peoples.getInstance().KlAllContactMapGetById.get(cam.Applicant__c).Number__c).Id;

        //.採購主管
        cam.Approval_User5__c       = Utils.getByIndex(ApproverUtils.approvalSearchApprrovalerByRuleWithOutSOQL(mapSpecify.get(5), null), 0);

        //財務結案
        cam.Approval_User6__c       = Utils.getByIndex(ApproverUtils.approvalSearchApprrovalerByRuleWithOutSOQL(mapSpecify.get(6), null), 0);



    }

}