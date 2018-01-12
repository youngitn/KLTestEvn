/**********************************************************************
 名    称：员工异动管理审批流程
 目    的：设置员工异动管理审批流程各节点审批人
 作    者：刘文俊(liuwenjun@bluelinksys.com)
 创建日期：2017-04-25
 修 改 人：
 修改日期：
 修改原因：
 备    注：
 			节点1   调出部门一阶主管审批            Related User: *审批用户1    
            节点2   调入部门二阶主管审批          Related User: *审批用户2    
            节点3   调入一阶主管审批            Related User: *审批用户3    
            节点4   HR经理-非3000      Related User: *审批用户4    
            节点5   HR经理-3000           Related User: *审批用户5    
            节点6   副总经理-非3000      Related User: *审批用户6    
            节点7   副总经理-3000           Related User: *审批用户7    
            节点8   HR人事-非3000      Related User: *审批用户8    
            节点9   HR人事-3000           Related User: *审批用户9    
 **********************************************************************/
public without sharing class AMStaffTransferHandler implements Triggers.Handler {
    public void handle() {
        //获取员工异动管理流程各节点配置
        Map<Decimal,Organizational__c>  mapSpecify = null;
        Id rtId = HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.STAFFTRANSFER,'Approval_Managed__c');
        if (Trigger.isBefore && Trigger.isInsert) {
            for (Approval_Managed__c cam : (List<Approval_Managed__c>)Trigger.new) {
                if (cam.RecordTypeId == rtId) {
                    if(mapSpecify == null){
                        mapSpecify = Utils.getApprovalStepByAPIName(SapApprovalEnum.STAFFTRANSFER);
                    }
                    setApprovalUser(mapSpecify,cam);
                }
            }
        }
        if (Trigger.isBefore && Trigger.isUpdate) {
            for (Approval_Managed__c cam : (List<Approval_Managed__c>)Trigger.new) {
                if (cam.RecordTypeId == rtId && cam.Is_Reset_Approvaler__c) {
                    if(mapSpecify == null){
                        mapSpecify = Utils.getApprovalStepByAPIName(SapApprovalEnum.STAFFTRANSFER);
                    }
                    setApprovalUser(mapSpecify,cam);
                    cam.Is_Reset_Approvaler__c = false;
                    cam.head_description__c  = cam.Remark_of_Explain__c;
                }
                
            }
        }
    }
    public void setApprovalUser(Map<Decimal,Organizational__c> mapSpecify,Approval_Managed__c cam){
        //节点一 
         cam.Approval_User1__c     = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(1),cam.Employee__c),0);
        //节点二 无审批规则，从字段‘异动工作单位’获取部门二阶阶主管
        cam.Approval_User2__c     = Utils.approvalSearchUserByDept(cam.Work_Company_New__c, 4);
        //节点三 无审批规则，从字段‘异动工作单位’获取一阶主管
        cam.Approval_User3__c     = Utils.approvalSearchUserByDept(cam.Work_Company_New__c, 3);
        //节点四 
        cam.Approval_User4__c     = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(4),null),0);
        //节点五 
        cam.Approval_User5__c     = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(5),null),0);
        //节点六 
        cam.Approval_User6__c    = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(6),null),0);
        //节点七
        cam.Approval_User7__c    = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(7),null),0);
        //节点八
        cam.Approval_User8__c    = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(8),null),0);
        //节点九
        cam.Approval_User9__c    = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(9),null),0);

        cam.Approval_User10__c    = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(10),null),0);

        cam.Approval_User20__c    = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(20),null),0);
    }
}