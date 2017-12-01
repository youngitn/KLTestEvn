/**********************************************************************
 名    称：采购信息记录维护审批流程
 目    的：设置采购信息记录维护审批流程各节点审批人
 作    者：刘文俊(liuwenjun@bluelinksys.com)
 创建日期：2017-04-25
 修 改 人：
 修改日期：
 修改原因：
 备    注：
 			节点一　:采购课长-指定岗位1：相关用户：*审批用户1
 			节点二　:采购课长-指定岗位2: 相关用户：*审批用户2
 			节点三　:采购经理-指定岗位	:相关用户：*审批用户3
 			节点四　:采购经理-指定人员	:相关用户：*审批用户4
 			节点五　:成本中心稽核:相关用户：*审批用户5
 			节点六　:成本管理师	:相关用户：*审批用户6，
 **********************************************************************/
 public without sharing class AMPurchaseInformationHandler implements Triggers.Handler {
 	public void handle() {
        Map<Decimal,Organizational__c>  mapSpecify = null;
        Id rtId = HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.PURCHASEINFORMATION,'Custom_Approval_Managed__c');
        if (Trigger.isBefore && Trigger.isInsert) {
            for (Custom_Approval_Managed__c cam : (List<Custom_Approval_Managed__c>)Trigger.new) {
                if (cam.RecordTypeId == rtId) {
                    if(mapSpecify == null){
                        mapSpecify = Utils.getApprovalStepByAPIName(SapApprovalEnum.PURCHASEINFORMATION);
                    }
                    setApprovalUser(mapSpecify,cam);
                }
            }
        }
        if (Trigger.isBefore && Trigger.isUpdate) {
            for (Custom_Approval_Managed__c cam : (List<Custom_Approval_Managed__c>)Trigger.new) {
                if (cam.RecordTypeId == rtId && cam.Is_Reset_Approvaler__c) {
                    if(mapSpecify == null){
                        mapSpecify = Utils.getApprovalStepByAPIName(SapApprovalEnum.PURCHASEINFORMATION);
                    }
                    setApprovalUser(mapSpecify,cam);
                    cam.Is_Reset_Approvaler__c = false;
                }
            }
        }
    }
    public void setApprovalUser(Map<Decimal,Organizational__c> mapSpecify,Custom_Approval_Managed__c cam){
		//节点一：
			cam.Approval_User1__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(1),null),0);
		//节点二：
			cam.Approval_User2__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(2),null),0);
		//节点三：
			cam.Approval_User3__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(3),null),0);
		//节点四：
			cam.Approval_User4__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(4),null),0);
		//节点五： 特殊计算
			cam.Approval_User5__c = specialCal1(cam);
		//节点六：
			cam.Approval_User6__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(6),null),0);
    }

 	public Id specialCal1(Custom_Approval_Managed__c cam){
 		//	林 文昌-30210010
 		if (cam.Applicant_Corp_Code__c == '3000'  ) { 			
 			return utils.getUserByEmployeeCode('30210010');
 		}
 		// 	颛 孙慧-10210265
 		else if(cam.Applicant_Corp_Code__c != '3000'  && 
 			cam.Kind_of_Material__c == 'F'){
 			return utils.getUserByEmployeeCode('10210265');
 		// 谢 飞-10211037
 	    }else if(cam.Applicant_Corp_Code__c != '3000'  && 
	 		cam.Kind_of_Material__c != 'F'        &&
	 		cam.Applicant_Code__c == '10210940'){
	 		return utils.getUserByEmployeeCode('10211037');
	 	//张 伟-10210919
		 }else if(cam.Applicant_Corp_Code__c != '3000'  && 
	 		cam.Kind_of_Material__c == 'A'        &&
	 		cam.Applicant_Code__c == '10210940'){
	 		return utils.getUserByEmployeeCode('10210919');
	 	//王 丽珍-10210727
		 }else if(cam.Applicant_Corp_Code__c != '3000'  && 
	 		cam.Kind_of_Material__c != 'A'        &&
	 		cam.Kind_of_Material__c != 'F'        &&
	 		cam.Applicant_Code__c != '10210940'){
	 		return utils.getUserByEmployeeCode('10210727');
		 }else{
		 	return null;
		 }
	}
}