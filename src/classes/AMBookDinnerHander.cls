/**********************************************************************
 名    称：订餐&派车申请流程
 目    的：设置订餐&派车申请流程各节点审批人
 作    者：
 创建日期：
 修 改 人：张旭
 修改日期：2017/07/20
 修改原因：
 备    注：
 
 
 **********************************************************************/
public without sharing class AMBookDinnerHander implements Triggers.Handler {

        public void handle() {
        Map<Decimal,Organizational__c>  mapSpecify = null;
        Id rtId = HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.BOOKDINNER,'Approval_Managed1__c');
        if (Trigger.isBefore && Trigger.isInsert) {
            for (Approval_Managed1__c cam : (List<Approval_Managed1__c>)Trigger.new) {
                if (cam.RecordTypeId == rtId) {
                    if(mapSpecify == null){
                        mapSpecify = Utils.getApprovalStepByAPIName(SapApprovalEnum.BOOKDINNER);
                    }
                    setApprovalUser(mapSpecify,cam);
                }
            }
        }
        if (Trigger.isBefore && Trigger.isUpdate) {
            for (Approval_Managed1__c cam : (List<Approval_Managed1__c>)Trigger.new) {
                if (cam.RecordTypeId == rtId && cam.Is_Reset_Approvaler__c) {
                    if(mapSpecify == null){
                        mapSpecify = Utils.getApprovalStepByAPIName(SapApprovalEnum.BOOKDINNER);
                    }
                    setApprovalUser(mapSpecify,cam);
                    cam.Is_Reset_Approvaler__c = false;
                }
            }
        }
    }
        //获取订餐&派车申请流程各节点配置
    public void setApprovalUser(Map<Decimal,Organizational__c> mapSpecify,Approval_Managed1__c cam){
        //节点一：一阶主管
        cam.Approval_User1__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(1),cam.Applicant__c),0);
        //节点二：前台审核
        cam.Approval_User2__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(2),null),0);  
        //节点三：一阶主管
        cam.Approval_User3__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(3),cam.Applicant__c),0);
        //节点四：总务主管
        cam.Approval_User4__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(4),null),0); 
        //节点五：李总审批
        cam.Approval_User4__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(5),null),0); 
        //节点六：物流部
        cam.Approval_User5__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(6),null),0);
        //节点七：采购
        cam.Approval_User6__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(7),null),0);
        //节点八：新莱派车人员
        cam.Approval_User7__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(8),null),0);
        //节点九：宝莱派车人员
        cam.Approval_User8__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(9),null),0);
        //节点五：派车人员（特殊计算）
    //      List<Id> lstID = specialCal1(cam);
    //     if (lstID!=null  ) {
    //         cam.Approval_User5__c  = lstID[0];
   
    //     }
    // }

    // public List<Id> specialCal1(Approval_Managed1__c cam){
    //   List<Id> lstID = new List<Id>();
    //  if (cam.Factory__c != '3000' && cam.Factory__c != '2000') {
    //   lstID.add(utils.getUserByEmployeeCode('10210156')); //李燕    
    //  }else if (cam.Factory__c == '2000') {
    //   lstID.add(utils.getUserByEmployeeCode('20210063')); //张世超
    //  }

    //  return lstID;


    // }

}
}