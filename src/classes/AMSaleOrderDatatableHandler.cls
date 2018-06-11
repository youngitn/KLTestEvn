/**********************************************************************
 名    称：销售订单审批流程
 目    的：设置销售订单审批流程各节点审批人
 作    者：刘文俊(liuwenjun@bluelinksys.com)
 创建日期：2017-04-25
 修 改 人：
 修改日期：
 修改原因：
 备    注：
 			节点一　:销售主管审批:Superior_Manager__c
 			节点二　:成本中心主管审批:Specify_CostCenter_Manager__c
 **********************************************************************/
public without sharing class AMSaleOrderDatatableHandler implements Triggers.Handler {
    public void handle() {
        Map<Decimal,Organizational__c>  mapSpecify = null;
        Id rtId = HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.SALEORDER,'Custom_Approval_Managed__c');
        if (Trigger.isBefore && Trigger.isInsert) {
            for (Custom_Approval_Managed__c cam : (List<Custom_Approval_Managed__c>)Trigger.new) {
                if (cam.RecordTypeId == rtId) {
                    if(mapSpecify == null){
                        mapSpecify = Utils.getApprovalStepByAPIName(SapApprovalEnum.SALEORDER);
                    }
                    setApprovalUser(mapSpecify,cam);
                }
            }
        } 
        if (Trigger.isBefore && Trigger.isUpdate) {
            for (Custom_Approval_Managed__c cam : (List<Custom_Approval_Managed__c>)Trigger.new) {
                if (cam.RecordTypeId == rtId && cam.Is_Reset_Approvaler__c) {
                    if(mapSpecify == null){
                        mapSpecify = Utils.getApprovalStepByAPIName(SapApprovalEnum.SALEORDER);
                    }
                    setApprovalUser(mapSpecify,cam);
                    cam.Is_Reset_Approvaler__c = false;
                }
            }
        }
    } 
    public void setApprovalUser(Map<Decimal,Organizational__c> mapSpecify,Custom_Approval_Managed__c cam){
//节点一:
        cam.Approval_User1__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(1),cam.Applicant__c),0);
        // cam.Approval_User1__c = cam.Approval_User1__c;
//节点二：
        cam.Approval_User2__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(2),cam.Applicant__c),0);
//节点三：
        cam.Approval_User3__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(3),null),0);
//节点四：
        cam.Approval_User4__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(4),cam.Applicant__c),0);
//节点五：
        cam.Approval_User5__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(5),null),0);
//节点六：
        cam.Approval_User6__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(6),null),0);
//节点七：
        cam.Approval_User7__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(7),null),0);
//节点八：
        cam.Approval_User8__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(8),null),0);

        if(cam.Sales_Org__c == '6000'){
            cam.Approval_User9__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(18),null),0);
        }else{
            cam.Approval_User9__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(9),null),0);
        }

//节点十：
        cam.Approval_User10__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(10),null),0);
//节点十一：
        if(cam.Sales_Org__c == '6000'){
            cam.Approval_User11__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(19),null),0);
        }else{
            cam.Approval_User11__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(11),null),0);
        }
//节点十二：
        cam.Approval_User12__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(12),null),0);
        cam.Approval_User13__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(13),null),0);
//节点十三：
        cam.Approval_User14__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(14),null),0);
//节点十四：
        cam.Approval_User15__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(15),cam.Applicant__c),0);

        cam.Approval_User16__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(16),null),0);

//节点17 关联业务机会号
        cam.Approval_User17__c = specialCal7(cam);

        cam.Approval_User20__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(20),null),0);

        cam.Approval_User21__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(21),null),0);
    } 
    public Id specialCal7(Custom_Approval_Managed__c cam){
        if(cam.Applicant_Corp_Code__c == '3000'){
            return null;
        }

        if(cam.Type_of_Approval__c != '新增'){
            return null;
        }

        return utils.getUserByEmployeeCode(cam.Sales_Employee__c);       
        /*
        if(cam.Sales_Org__c == '6000'){
            return utils.getUserByEmployeeCode('60210013');
        }
        else{
            return utils.getUserByEmployeeCode(cam.Sales_Employee__c);            
        }
        */

    }

}