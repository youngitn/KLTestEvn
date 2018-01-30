/**********************************************************************
 名    称：内部联络申请流程
 目    的：设置内部联络申请流程各节点审批人
 作    者：
 创建日期：
 修 改 人：张旭
 修改日期：2017/07/12
 修改原因：添加昆山各节点审核人（节点三至节点七）
 备    注：昆山&台湾共同使用该流程
 
 
 **********************************************************************/
public without sharing class AMInternalmemoHandler implements Triggers.Handler {
    public void handle() {
        Map<Decimal,Organizational__c>  mapSpecify = null;
        Id rtId = HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.INTERNALMEMO,'Approval_Managed1__c');
        if (Trigger.isBefore && Trigger.isInsert) {
            for (Approval_Managed1__c cam : (List<Approval_Managed1__c>)Trigger.new) {
                if (cam.RecordTypeId == rtId) {
                    if(mapSpecify == null){
                        mapSpecify = Utils.getApprovalStepByAPIName(SapApprovalEnum.INTERNALMEMO);
                    }
                    setApprovalUser(mapSpecify,cam);
                }
            }
        }
        if (Trigger.isBefore && Trigger.isUpdate) {
            for (Approval_Managed1__c cam : (List<Approval_Managed1__c>)Trigger.new) {
                if (cam.RecordTypeId == rtId && cam.Is_Reset_Approvaler__c) {
                    if(mapSpecify == null){
                        mapSpecify = Utils.getApprovalStepByAPIName(SapApprovalEnum.INTERNALMEMO);
                    }
                    setApprovalUser(mapSpecify,cam);
                    if (cam.Service_Desc__c != null) {
                      cam.head_description__c  = cam.Service_Desc__c.substring(0,(cam.Service_Desc__c.length()>200?200:cam.Service_Desc__c.length()));
                    }
                    cam.Is_Reset_Approvaler__c = false;
                }
            }
        }
    }
            //获取內部連絡單流程各节点配置
    public void setApprovalUser(Map<Decimal,Organizational__c> mapSpecify,Approval_Managed1__c cam){
        //节点一：申请人部门主管
        cam.Approval_User1__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(1),cam.Applicant__c),0);
        //节点二：特殊计算
        cam.Approval_User2__c  = specialCal1(cam);    
        //节点三 一阶主管
        cam.Approval_User3__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(3),cam.Applicant__c),0);
        //节点四 部门主管
        cam.Approval_User4__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(4),cam.Applicant__c),0); 
        //节点五 财务部
        cam.Approval_User10__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(5),null),0);
        //节点六 总经理室
        cam.Approval_User11__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(6),null),0);
        //节点七 HR经理
        cam.Approval_User5__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(7),null),0);
        //节点八 莱恒总经理
        cam.Approval_User12__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(8),null),0);
        //节点九 收件人作业 特殊计算
        List<Id> lstID = specialCal2(cam);
        if (lstID!=null && lstID.size()>=2) {
            cam.Approval_User6__c  = lstID[0];
            cam.Approval_User8__c = lstID[1];
        }
        else if(lstID!=null && lstID.size()==1){
            cam.Approval_User6__c  = lstID[0];
            cam.Approval_User8__c = lstID[0];
        }
        //节点十 申请人确认
        cam.Approval_User9__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(9),cam.Applicant__c),0);
    }
    public Id specialCal1(Approval_Managed1__c cam){
        if (cam.Recipient_Unit__c == '管理' ) {
            //通过不同规则找SF用户
            return utils.getUserByEmployeeCode('30210035');
        }
        else if (cam.Recipient_Unit__c == '總經理室' ) {
            //通过不同规则找SF用户
            return utils.getUserByEmployeeCode('30210002');
        }
        else if (cam.Recipient_Unit__c == '資訊' ) {
            //通过不同规则找SF用户
            return utils.getUserByEmployeeCode('30210240');
        }
        else if (cam.Recipient_Unit__c == '財務' ) {
            //通过不同规则找SF用户
            return utils.getUserByEmployeeCode('30210035');
        }
        else if (cam.Recipient_Unit__c == '品保' ) {
            //通过不同规则找SF用户
            return utils.getUserByEmployeeCode('30210045');
        }
        else if (cam.Recipient_Unit__c == '研發' ) {
            //通过不同规则找SF用户
            return utils.getUserByEmployeeCode('30210010');
        }
        else if (cam.Recipient_Unit__c == '業務' ) {
            //通过不同规则找SF用户
            return utils.getUserByEmployeeCode('30210069');
        }
        else if (cam.Recipient_Unit__c == '生產製造' ) {
            //通过不同规则找SF用户
            return utils.getUserByEmployeeCode('30210242');
        }
        else{
            return null;
        }
    }

      public List<Id> specialCal2(Approval_Managed1__c cam){List<Id> lstID = new List<Id>();

    if (cam.Factory__c !='3000' && (cam.TYPE__c == '05' || cam.TYPE__c == '11')) {
        lstID.add(utils.getUserByEmployeeCode('10210533')); //章国庆
        
    }else if (cam.Factory__c != '3000' && cam.TYPE__c == '06'){
        lstID.add(utils.getUserByEmployeeCode('10210194')); //苟建忠

    }else if (cam.Factory__c != '3000' && cam.TYPE__c == '07'){
        lstID.add(utils.getUserByEmployeeCode('10219008')); //伍建辉

    }else if (cam.Factory__c != '3000' && (cam.TYPE__c == '08' || cam.TYPE__c == '10')) {
        lstID.add(utils.getUserByEmployeeCode('10210156')); //李燕
        
    }else if (cam.Factory__c != '3000' && cam.TYPE__c == '19') {
        lstID.add(utils.getUserByEmployeeCode('10210841')); //邵玉波
        
    }else if (cam.Factory__c != '3000' && cam.TYPE__c == '12') {
        lstID.add(utils.getUserByEmployeeCode('10210225')); //徐井西

    }else if (cam.Factory__c == '1000' && cam.TYPE__c == '13') {
        lstID.add(utils.getUserByEmployeeCode('10210018')); //崔雪莉

    }else if (cam.Factory__c == '6000' && cam.TYPE__c == '13') {
        lstID.add(utils.getUserByEmployeeCode('60210029')); //刘帅

    }else if (cam.Factory__c == '2000' && cam.TYPE__c == '13') {
        lstID.add(utils.getUserByEmployeeCode('10211072')); //康翠丽
        
    }else if (cam.Factory__c != '3000' && cam.TYPE__c == '20') {
        lstID.add(utils.getUserByEmployeeCode('10212239')); //由张大华变更为彦斌
        
    }else if (cam.Factory__c != '3000' && cam.TYPE__c == '14') {
        lstID.add(utils.getUserByEmployeeCode('10210018')); //崔雪莉
        
    }else if (cam.Factory__c != '3000' && cam.TYPE__c == '15') {
        lstID.add(utils.getUserByEmployeeCode('10211022')); //顾湘
        
    }else if (cam.Factory__c != '3000' && cam.TYPE__c == '17') {
        lstID.add(utils.getUserByEmployeeCode('10210288')); //孙菊芳
        
    }else if (cam.Factory__c != '3000' && (cam.TYPE__c == '18' || cam.TYPE__c == '21')) {
        lstID.add(utils.getUserByEmployeeCode('10210320')); //孙海平
        
    }else if (cam.Factory__c != '3000' && (cam.TYPE__c == '22')) {
        lstID.add(utils.getUserByEmployeeCode('10211573')); //魏哲
        
    }else if (cam.Factory__c != '3000' && (cam.TYPE__c == '22')) {
        lstID.add(utils.getUserByEmployeeCode('10210943')); //杨小龙
        
    }else if (cam.Factory__c !='3000' && (cam.TYPE__c == '15' || cam.TYPE__c == '16')) {
        List<Organizational__c> lstOrg = [SELECT Id FROM Organizational__c 
                                              WHERE RecordType.DeveloperName = 'Job_Title' AND Post_Number__c = '30000263'];
            if (lstOrg.size()>0) {
              lstID = utils.approvalSearchUserByJob(lstOrg[0].Id);   
    }
}
return lstID;
}
}