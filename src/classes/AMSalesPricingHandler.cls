/**********************************************************************
 名    称：销售定价业务流程
 目    的：设置流程各节点审批人
 作    者：刘忠林
 创建日期：2017/11/07 
 
 **********************************************************************/

public without sharing class AMSalesPricingHandler implements Triggers.Handler {
    public void handle() {
        Map<Decimal,Organizational__c>  mapSpecify = null;
        Id rtId = HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.SALESPRICE,'Approval_Managed__c');
        if (Trigger.isBefore && Trigger.isInsert) {
            for (Approval_Managed__c cam : (List<Approval_Managed__c>)Trigger.new) {
                if (cam.RecordTypeId == rtId) {
                    if(mapSpecify == null){
                        mapSpecify = Utils.getApprovalStepByAPIName(SapApprovalEnum.SALESPRICE);
                    }
                    setApprovalUser(mapSpecify,cam);
                }
            }
        }
  
        if (Trigger.isBefore && Trigger.isUpdate) {
            for (Approval_Managed__c cam : (List<Approval_Managed__c>)Trigger.new) {
                if (cam.RecordTypeId == rtId && cam.Is_Reset_Approvaler__c) {
                    if(mapSpecify == null){
                        mapSpecify = Utils.getApprovalStepByAPIName(SapApprovalEnum.SALESPRICE);
                    }
                    setApprovalUser(mapSpecify,cam);
                    cam.Is_Reset_Approvaler__c = false;
                }
            }
        }
    }
 
    public void setApprovalUser(Map<Decimal,Organizational__c> mapSpecify,Approval_Managed__c cam){
        // cam.Approval_User2__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(2),cam.指定申请人字段),0);
        //节点一: 成本管理师1
        cam.Approval_User1__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(1),null),0);
        //节点二: 成本中心主管 （特殊计算）
        cam.Approval_User2__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(2),cam.Applicant__c),0);
         List<Id> lstID2 = specialCal2(cam);
            if (lstID2!=null && lstID2.size()==1) {
                cam.Approval_User2__c  = lstID2[0];
            }
    } 

        //成本中心主管
    public List<Id> specialCal2(Approval_Managed__c cam){
        List<Id> lstID = new List<Id>();
        if (cam.Sales_Org__c != '2000') {
            lstID.add(utils.getUserByEmployeeCode('10210841')); //邵玉波
            
        }else{

            lstID.add(utils.getUserByEmployeeCode('10211000')); //徐素东
        }
        return lstID;
    }    

}