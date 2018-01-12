/**********************************************************************
 名    称：出差管理审批流程
 目    的：设置出差管理审批流程各节点审批人
 作    者：刘文俊(liuwenjun@bluelinksys.com)
 创建日期：2017-04-25
 修 改 人：
 修改日期：
 修改原因：
 备    注：
 			1   稽核单位审批              Related User: *审批用户1    
            2   部门主管单位审批          Related User: *审批用户2    
            3   市场部审批                Related User: *审批用户3    
            4   一阶主管审批              Related User: *审批用户4    
            5   交通工具-飞机             Related User: *审批用户5, *审批用户6    
            6   总经理-3000               Related User: *审批用户7    
            7   总经理-非台湾             Related User: *审批用户8    
            8   培训专员-3000             Related User: *审批用户9    
            9   培训专员-非3000           Related User: *审批用户10   
            10  HR经理                    Related User: *审批用户11   
            11  借支审批                  Related User: *审批用户12   
            12  派车1-审批                Related User: *审批用户13   
            13  派车2-审批                Related User: *审批用户14   
            14  HR考勤专员3000            Related User: *审批用户15   
            15  HR考勤专员非3000          Related User: *审批用户16   
            16  自驾公里数填写            Related User: *审批用户17   
            17  自驾公里数2填写           Related User: *审批用户18   
            18  HR经理3000                Related User: *审批用户19   
 **********************************************************************/
public without sharing class AMBusinessTravelHandler implements Triggers.Handler {
    public void handle() {
        Map<Decimal,Organizational__c>  mapSpecify = null;
        Id rtId = HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.BUSINESSTRAVEL,'Custom_Approval_Managed__c');
        if (Trigger.isBefore && Trigger.isInsert) {
            for (Custom_Approval_Managed__c cam : (List<Custom_Approval_Managed__c>)Trigger.new) {
                if (cam.RecordTypeId == rtId) {
                    if(mapSpecify == null){
                        mapSpecify = Utils.getApprovalStepByAPIName(SapApprovalEnum.BUSINESSTRAVEL);
                    }
                    setApprovalUser(mapSpecify,cam);
                }
            }
        }
        if (Trigger.isBefore && Trigger.isUpdate) {
            for (Custom_Approval_Managed__c cam : (List<Custom_Approval_Managed__c>)Trigger.new) {
                if (cam.RecordTypeId == rtId && cam.Is_Reset_Approvaler__c) {
                    if(mapSpecify == null){
                        mapSpecify = Utils.getApprovalStepByAPIName(SapApprovalEnum.BUSINESSTRAVEL);
                    }
                    setApprovalUser(mapSpecify,cam);
                    cam.Is_Reset_Approvaler__c = false;
                    cam.head_description__c  = cam.Description_of_Travel__c;
                }
                
            }
        }
    }
    public void setApprovalUser(Map<Decimal,Organizational__c> mapSpecify,Custom_Approval_Managed__c cam){
        //节点一
        cam.Approval_User1__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(1),null),0);
        //节点二
        cam.Approval_User2__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(2),cam.Applicant__c),0);
        //节点三
        cam.Approval_User3__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(3),null),0);
        //节点四
        cam.Approval_User4__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(4),cam.Applicant__c),0);
        //节点五
        cam.Approval_User5__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(5),null),0);
        cam.Approval_User6__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(6),null),0);
        //节点六
        cam.Approval_User7__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(7),null),0);
        //节点七
        cam.Approval_User8__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(8),null),0);
        //节点八
        cam.Approval_User9__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(9),null),0);
        //节点九
        cam.Approval_User10__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(10),null),0);
        //节点十
        cam.Approval_User11__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(11),null),0);
        //节点十一
        cam.Approval_User12__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(12),null),0);
        //节点十二
        cam.Approval_User13__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(13),null),0);
        //节点十三
        cam.Approval_User14__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(14),null),0);
        //节点十四
        cam.Approval_User15__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(15),null),0);
        //节点十五
        cam.Approval_User16__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(16),null),0);
        //节点十六
        cam.Approval_User17__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(17),null),0);
        //节点十七
        cam.Approval_User18__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(18),null),0);
        //节点十八
        cam.Approval_User19__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(19),null),0);

        cam.Approval_User20__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(20),cam.Applicant__c),0);

        cam.Approval_User21__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(21),null),0);

        cam.Approval_User22__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(22),null),0);
    }
}