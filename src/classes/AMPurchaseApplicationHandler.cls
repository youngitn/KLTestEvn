/**********************************************************************
 名    称：采购申请作业审批流程
 目    的：设置采购申请作业审批流程各节点审批人
 作    者：许晓峰
 创建日期：2017-07-12
 修 改 人：
 修改日期：
 修改原因：
 备    注：

 **********************************************************************/
public without sharing class AMPurchaseApplicationHandler implements Triggers.Handler {
	public void handle() {
        //获取采购申请流程各节点配置
        Map<Decimal,Organizational__c>  mapSpecify = null;
        Id rtId = HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.PURCHASEAPPLICATION,'Approval_Managed__c');
        if (Trigger.isBefore && Trigger.isInsert) {
            for (Approval_Managed__c cam : (List<Approval_Managed__c>)Trigger.new) {
                if (cam.RecordTypeId == rtId) {
                    if(mapSpecify == null){
                        mapSpecify = Utils.getApprovalStepByAPIName(SapApprovalEnum.PURCHASEAPPLICATION);
                    }
                    setApprovalUser(mapSpecify,cam);
                }
            }
        }
        if (Trigger.isBefore && Trigger.isUpdate) {
            for (Approval_Managed__c cam : (List<Approval_Managed__c>)Trigger.new) {
                if (cam.RecordTypeId == rtId && cam.Is_Reset_Approvaler__c) {
                    if(mapSpecify == null){
                        mapSpecify = Utils.getApprovalStepByAPIName(SapApprovalEnum.PURCHASEAPPLICATION);
                    }
                    setApprovalUser(mapSpecify,cam);
                    cam.Is_Reset_Approvaler__c = false;
                }
            }
        }
    }
    public void setApprovalUser(Map<Decimal,Organizational__c> mapSpecify,Approval_Managed__c cam){
		//节点一 部门主管 
		cam.Approval_User1__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(1),cam.Applicant__c),0);
		//节点二 
		cam.Approval_User2__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(2),null),0);
		//节点三 QC检具
		cam.Approval_User3__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(3),null),0);
		//节点四 一阶主管 KL
		cam.Approval_User4__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(4),cam.Applicant__c),0);
		//节点五 一阶主管 TW 特殊计算
		cam.Approval_User5__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(5),cam.Applicant__c),0);
		//specialCal5(cam);
		//节点六 环安课1
		cam.Approval_User6__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(6),null),0);
		//节点七 环安课2
		cam.Approval_User7__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(7),null),0);
		//节点八 设备类采购议价
		cam.Approval_User8__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(8),null),0);
		//节点九 成本类采购议价
		cam.Approval_User9__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(9),null),0);
		//节点十 维修/成本类型采购申请
		cam.Approval_User10__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(10),cam.Applicant__c),0);
		//节点11 委外评估-采购
		cam.Approval_User11__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(11),null),0);
		//节点12 委外评估-IE
		cam.Approval_User12__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(12),cam.Applicant__c),0);
		//节点13 设备/委外对应主管
		cam.Approval_User13__c = specialCal13(cam);
		//节点14 确认流程是否规范
		cam.Approval_User14__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(14),null),0);

		cam.Approval_User15__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(15),null),0);

		cam.Approval_User16__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(16),null),0);

		//USER23 添加可以查看单据的人员
		cam.Approval_User23__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(50),null),0);
    }

    public Id specialCal5(Approval_Managed__c cam){
		 	return null;
	}

    public Id specialCal13(Approval_Managed__c cam){

		if (cam.Applicant_Corp_Code__c != '3000' && cam.Confirm_Is_Stand__c == 'PB') { 			
			return utils.getUserByEmployeeCode('10210955');    //吴 正红
		}
		if (cam.Applicant_Corp_Code__c != '3000' && cam.Confirm_Is_Stand__c == 'BU1') { 			
			return utils.getUserByEmployeeCode('10210006');   //崇 加兴
		}
		if (cam.Applicant_Corp_Code__c != '3000' && cam.Confirm_Is_Stand__c == 'BU7') { 			
			return utils.getUserByEmployeeCode('60210001');   //陈 建安
		}
		if (cam.Applicant_Corp_Code__c != '3000' && cam.Confirm_Is_Stand__c == 'BU2') { 			
			return utils.getUserByEmployeeCode('10210010');   //郭 兴云
		}
		if (cam.Applicant_Corp_Code__c != '3000' && 
		     (cam.Confirm_Is_Stand__c == 'BU3' ||  
		      cam.Confirm_Is_Stand__c == 'BU4' || 
		      cam.Confirm_Is_Stand__c == 'BU5' ||
		      cam.Confirm_Is_Stand__c == 'BU6' ) ){ 			
			return utils.getUserByEmployeeCode('10210004');   //翁 鹏斌
		}
		if (cam.Applicant_Corp_Code__c != '3000' && cam.Confirm_Is_Stand__c == 'GYL') { 			
			return utils.getUserByEmployeeCode('30002526');
		}
	 	return null;
	}
}