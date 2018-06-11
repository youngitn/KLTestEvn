/**********************************************************************
 名    称：成本中心发料作业审批流程
 目    的：设置成本中心发料作业审批流程各节点审批人
 作    者：刘文俊(liuwenjun@bluelinksys.com)
 创建日期：2017-04-25
 修 改 人：
 修改日期：
 修改原因：
 备    注：
 			节点一　:申请人部门主管审批	:相关用户：*审批用户1
 			节点二　:一阶主管审批  :相关用户：*审批用户2
 			节点三　:生管员审批	:相关用户：*审批用户3
 			节点四　:品管员审批	:相关用户：*审批用户4
 			节点五　:仓库帐管员审批	:相关用户：*审批用户5
 			节点六　:库管员审批	:相关用户：*审批用户6，相关用户：*审批用户7
 **********************************************************************/
public without sharing class AMCostCenterSendHandler implements Triggers.Handler {
    public void handle() {
        Map<Decimal,Organizational__c>  mapSpecify = null;
        Id rtId = HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.COSTCENTERSEND,'Custom_Approval_Managed__c');
        if (Trigger.isBefore && Trigger.isInsert) {
            for (Custom_Approval_Managed__c cam : (List<Custom_Approval_Managed__c>)Trigger.new) {
                if (cam.RecordTypeId == rtId) {

                    //201   成本中心领料
                    //Z61   计划外发料
                    if(cam.Option_of_Operate__c == '201'){
                        if(String.isBlank(cam.Dept_of_CostCenter__c)){
                            cam.addError('选成本中心领料时成本中心必输！');
                            return ;
                            }
                        }else if (cam.Option_of_Operate__c == 'Z61') {
                            if (String.isBlank(cam.Order_of_Production__c)) {
                                cam.addError('选计划外领料时工单号必输！');
                                return ;
                            }
                        }
                    if(mapSpecify == null){
                        mapSpecify = Utils.getApprovalStepByAPIName(SapApprovalEnum.COSTCENTERSEND);
                    }
                    setApprovalUser(mapSpecify,cam);
                }
            }
        }

        if (Trigger.isUpdate) {
            for (Custom_Approval_Managed__c cam : (List<Custom_Approval_Managed__c>)Trigger.new) {
                if (cam.RecordTypeId == rtId && cam.Approval_Status__c != 'R') {
                    System.debug(LoggingLevel.INFO, '*** cam.Approval_Status__c: ' + cam.Approval_Status__c);
                    if(cam.Option_of_Operate__c == '201'){
                        if(String.isBlank(cam.Dept_of_CostCenter__c)){
                            cam.addError('选成本中心领料时成本中心必输！');
                            return ;
                            }
                        }else if (cam.Option_of_Operate__c == 'Z61') {
                            if (String.isBlank(cam.Order_of_Production__c)) {
                                cam.addError('选计划外领料时工单号必输！');
                                return ;
                            }
                        }
                    if(mapSpecify == null){
                        mapSpecify = Utils.getApprovalStepByAPIName(SapApprovalEnum.COSTCENTERSEND);
                    }
                    setApprovalUser(mapSpecify,cam);
                }
            }
        }

        if (Trigger.isBefore && Trigger.isUpdate) {
            for (Custom_Approval_Managed__c cam : (List<Custom_Approval_Managed__c>)Trigger.new) {
                if (cam.RecordTypeId == rtId && cam.Is_Reset_Approvaler__c) {
                    if(mapSpecify == null){
                        mapSpecify = Utils.getApprovalStepByAPIName(SapApprovalEnum.COSTCENTERSEND);
                    }
                    setApprovalUser(mapSpecify,cam);
                    cam.Is_Reset_Approvaler__c = false;
                    cam.head_description__c  = cam.Reason_of_Required__c;
                }
                
            }
        }
    }
    public void setApprovalUser(Map<Decimal,Organizational__c> mapSpecify,Custom_Approval_Managed__c cam){
        //节点一：申请人部门主管
        cam.Approval_User1__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(1),cam.Applicant__c),0);
        //节点二：申请人一阶主管
        cam.Approval_User2__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(2),cam.Applicant__c),0);
        //节点三：
        cam.Approval_User3__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(3),null),0);
        //节点四：
        cam.Approval_User4__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(4),null),0);
        //节点五：特殊计算
        cam.Approval_User5__c = specialCal1(cam);
        //节点六：特殊计算
        
        List<Id> lstID = specialCal2(cam);
        if (lstID!=null && lstID.size()>=2) {
            cam.Approval_User6__c  = lstID[0];
            cam.Approval_User7__c = lstID[1];
        }
        else if(lstID!=null && lstID.size()==1){
            cam.Approval_User6__c  = lstID[0];
            cam.Approval_User7__c = lstID[0];
        }
        cam.Approval_User8__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(7),null),0);
    }
    public Id specialCal1(Custom_Approval_Managed__c cam){
        //成本中心发料  10210408
        if (cam.Option_of_Operate__c == '201' 
            && cam.Address_of_Stock__c !='D01'  
            && cam.Address_of_Stock__c !='D03' 
            && cam.Address_of_Stock__c !='D04'
            && cam.Address_of_Stock__c !='D05'
            && cam.Address_of_Stock__c !='D06'
            && cam.Address_of_Stock__c !='D07' ) {
            //通过不同规则找SF用户
            return utils.getUserByEmployeeCode('10210408');
        }
        //计划外发料  10211128
        else if(cam.Option_of_Operate__c == 'Z61' && cam.Address_of_Stock__c !='D01'  
            && cam.Address_of_Stock__c !='D03' 
            && cam.Address_of_Stock__c !='D04'
            && cam.Address_of_Stock__c !='D05'
            && cam.Address_of_Stock__c !='D06'
            && cam.Address_of_Stock__c !='D07'){

            return utils.getUserByEmployeeCode('10211128');
        }
        //资讯  10210225
        else if (cam.Address_of_Stock__c =='D04') {
            return utils.getUserByEmployeeCode('10210225');
        }
        else{
            return null;
        }
    }
    public List<Id> specialCal2(Custom_Approval_Managed__c cam){

        List<Id> lstID = new List<Id>();
        Set<String> set1 = new Set<String>{'A00','A02','A03','A04','PRO','H00','H01','H02','H03','C01','C02','C03','C04','E00','A08','A98'};
        Set<String> set2 = new Set<String>{'A01','D02','C07','C08','C11','C13'};
        Set<String>  set3= new Set<String>{'D05','D06','C10','D01','P06','P03','P01'};

        //计划外(成本中心)发料作业:1000   夏 勤芳-10211128
        if (cam.Factory__c == '1000' && set1.contains(cam.Address_of_Stock__c)) {
            lstID.add(utils.getUserByEmployeeCode('10211128'));
        }   
        //计划外(成本中心)发料作业:1000徐倩  10210408
        else if (cam.Factory__c == '1000' && set3.contains(cam.Address_of_Stock__c)) {
            lstID.add(utils.getUserByEmployeeCode('10210408'));
        }
        //计划外(成本中心)发料作业:D03王彩红 10210861转给徐倩10210408
        else if (cam.Applicant_Corp_Code__c != '3000' && cam.Applicant_Corp_Code__c != '6000' && cam.Address_of_Stock__c == 'D03') {
            lstID.add(utils.getUserByEmployeeCode('10210408'));
        }
        //计划外(成本中心)发料作业:D04资讯   岗位:30000010
        else if (cam.Applicant_Corp_Code__c != '3000'&& cam.Address_of_Stock__c == 'D04') {
            List<Organizational__c> lstOrg = [SELECT Id FROM Organizational__c 
                                              WHERE RecordType.DeveloperName = 'Job_Title' AND Post_Number__c = '30000010'];
            if (lstOrg.size()>0) {
              lstID = utils.approvalSearchUserByJob(lstOrg[0].Id);
            }
        }
        //计划外(成本中心)发料作业:E02 张 莉-10210237
        else if (cam.Applicant_Corp_Code__c != '3000'&& cam.Address_of_Stock__c == 'E02') {
            lstID.add(utils.getUserByEmployeeCode('10210237'));
        }
        //计划外(成本中心)发料作业:6000 张 伟-60210025
        else if (cam.Applicant_Corp_Code__c == '6000') {
            lstID.add(utils.getUserByEmployeeCode('60210025'));
        }
        //计划外(成本中心)发料作业:宝莱  郭 张凤-10211357
        else if ((cam.Factory__c == '2000' && cam.Address_of_Stock__c != 'D04')||(cam.Factory__c== '1000'&&set2.contains(cam.Address_of_Stock__c))) {
            lstID.add(utils.getUserByEmployeeCode('10211357'));
        }

        //计划外(成本中心)发料作业:1000 C14 贺 亮亮-10211221
        else if (cam.Factory__c == '1000' && cam.Address_of_Stock__c == 'C14') {
            lstID.add(utils.getUserByEmployeeCode('10211221'));
        }
        //计划外(成本中心)发料作业:P04  徐 东平-10211664
        else if (cam.Factory__c == '1000' && cam.Address_of_Stock__c == 'P04') {
            lstID.add(utils.getUserByEmployeeCode('10211664'));

        }
        //计划外(成本中心)发料作业:D00  张 伟-60210025
        else if (cam.Factory__c == '1000' && cam.Address_of_Stock__c == 'D00') {
            lstID.add(utils.getUserByEmployeeCode('60210025'));

        }
        else{
            return null;
        }
        return lstID;
    }

}