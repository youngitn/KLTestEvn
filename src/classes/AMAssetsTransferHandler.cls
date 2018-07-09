/**********************************************************************
 名    称：资产转移报废停用申请流程
 作    者：刘忠林
 创建日期：2018/3/27

 **********************************************************************/

public without sharing class AMAssetsTransferHandler implements Triggers.Handler {
    public void handle() {
        Map<Decimal,Organizational__c>  mapSpecify = null;
        Id rtId = HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.ASSETSTRANSFER,'Approval_Managed__c');
        if (Trigger.isBefore && Trigger.isInsert) {
            for (Approval_Managed__c cam : (List<Approval_Managed__c>)Trigger.new) {
                if (cam.RecordTypeId == rtId) {
                    if(mapSpecify == null){
                        mapSpecify = Utils.getApprovalStepByAPIName(SapApprovalEnum.ASSETSTRANSFER);
                    }
                    setApprovalUser(mapSpecify,cam);
                }
            }
        }
       
        if (Trigger.isBefore && Trigger.isUpdate) {
            for (Approval_Managed__c cam : (List<Approval_Managed__c>)Trigger.new) {
                if (cam.RecordTypeId == rtId && cam.Is_Reset_Approvaler__c) {
                    if(mapSpecify == null){
                        mapSpecify = Utils.getApprovalStepByAPIName(SapApprovalEnum.ASSETSTRANSFER);
                    }
                    setApprovalUser(mapSpecify,cam);
                    cam.Is_Reset_Approvaler__c = false;
                    cam.head_description__c  = cam.Remark__c;
                }
                
            }
        }
    }

    public void setApprovalUser(Map<Decimal,Organizational__c> mapSpecify,Approval_Managed__c cam){
        // cam.Approval_User2__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(2),cam.指定申请人字段),0);
        //节点一：稽核单位审批         		
        cam.Approval_User1__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(1),null),0);
        //节点二: 一阶主管
        cam.Approval_User2__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(2),cam.Applicant__c),0);
        //节点三: 转入部门主管 
        cam.Approval_User3__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(3),cam.Applicant__c),0);
        //节点四: 设备管理部门主管（特殊计算）
        cam.Approval_User4__c  = specialCall(cam);
        //节点五：资产会计
        cam.Approval_User5__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(5),null),0);
        //节点六：总经理室
        cam.Approval_User6__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(6),null),0);
        //节点七：指定人员审批
        cam.Approval_User7__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(7),null),0);
        //节点八: 总经理
        cam.Approval_User8__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(8),null),0);
        //节点九: IE部门统计
        cam.Approval_User9__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(9),null),0);
        //节点十: 采购处理资产
        cam.Approval_User10__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(10),null),0);
        //节点十一: 资产会计 报废
        cam.Approval_User11__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(11),null),0);        		
    }


    public Id specialCall(Approval_Managed__c cam){
        //厂务工程和总务
        if (cam.Entity_asset_type__c =='a' || cam.Entity_asset_type__c =='b' || cam.Entity_asset_type__c =='e') {
            return utils.getUserByEmployeeCode('10210533');  //章 国庆
        }
        //生产及辅助设备
        else if (cam.Entity_asset_type__c =='c') {
            return utils.getUserByEmployeeCode('10210350');  //李 俊杰
        }
        //资讯办公设备
        else if (cam.Entity_asset_type__c =='d') {
            return utils.getUserByEmployeeCode('10210225');  //徐 井西
        }
        //检验设备
        else if(cam.Entity_asset_type__c == 'f'){
            return utils.getUserByEmployeeCode('10210542');  //张 然
        }
        //模具
        else if (cam.Entity_asset_type__c =='g') {
            return utils.getUserByEmployeeCode('10210216');   //李 鸿庆
        }
        //  其他
        else if (cam.Entity_asset_type__c =='h') {
            return utils.getUserByEmployeeCode('10210841');  //邵 玉波
        }
        else{
            return null;
        }
    }

}