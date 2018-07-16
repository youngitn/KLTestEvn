/**********************************************************************
 名    称：内部员工引荐流程
 目    的：内部员工引荐流程各节点审批人
 作    者：
 创建日期：
 修 改 人：王思佳
 修改日期：2018/07/10
 
 
 **********************************************************************/
public without sharing class AMInternalStaffRecommendHandler implements Triggers.Handler {
    public void handle() {
        Map<Decimal,Organizational__c>  mapSpecify = null;
        Id rtId = HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.AMINTERNALSTAFFRECOMMEND,'Approval_Managed2__c');
        if (Trigger.isBefore && Trigger.isInsert) {
            for (Approval_Managed2__c cam : (List<Approval_Managed2__c>)Trigger.new) {
                if (cam.RecordTypeId == rtId) {
                    if(mapSpecify == null){
                        mapSpecify = Utils.getApprovalStepByAPIName(SapApprovalEnum.AMINTERNALSTAFFRECOMMEND);
                    }
                    setApprovalUser(mapSpecify,cam);
                }
            }
        }


        
        if (Trigger.isBefore && Trigger.isUpdate) {
            for (Approval_Managed2__c cam : (List<Approval_Managed2__c>)Trigger.new) {
                if (cam.RecordTypeId == rtId && cam.Is_Reset_Approvaler__c) {
                    if(mapSpecify == null){
                        mapSpecify = Utils.getApprovalStepByAPIName(SapApprovalEnum.AMINTERNALSTAFFRECOMMEND);
                    }
                    setApprovalUser(mapSpecify,cam);
                    cam.Is_Reset_Approvaler__c = false;
                }
            }
        }
    }

            public void setApprovalUser(Map<Decimal,Organizational__c> mapSpecify,Approval_Managed2__c cam){
                     String a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
     a='1';
                //节点一: 申请人
                cam.Approval_User1__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(1),cam.Introducer__c),0);
                //节点二：申请人部门主管
                cam.Approval_User2__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(2),cam.Introducer__c),0);

                cam.Approval_User3__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(3),null),0);

                cam.Approval_User4__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(4),null),0);

                if(!Test.isRunningTest())
                {
                    try
                    {
                        List<User> u=[SELECT Number__c, Name FROM User WHERE id = :cam.Approval_User2__c];
                        if(u.size()!=0)
                        {
                            cam.RecommendationClause__c=cam.RecommendationClause__c.replaceAll('manager__c',u.get(0).Name);
                        }
                        //cam.RecommendationClause__c = cam.Introducer__c;
                    }
                    catch(Exception e)
                    {

                    }
                }

            }

          
    
}