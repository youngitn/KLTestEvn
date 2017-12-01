/**********************************************************************
 名    称：MR模具申请
 目    的：设置MR模具申请流程各节点审批人
 作    者：王思佳
 创建日期：2017/11/14
 修 改 人：王思佳
 修改日期：2017/11/23
 修改原因：修复BUG
 
 
 **********************************************************************/
public without sharing class AMMRDieRequestHandler implements Triggers.Handler {
    public void handle() {
        Map<Decimal,Organizational__c>  mapSpecify = null;
        Id rtId = HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.MRDIEREQUEST,'Approval_Managed__c');
        if (Trigger.isBefore && Trigger.isInsert) {
            for (Approval_Managed__c cam : (List<Approval_Managed__c>)Trigger.new) {
                if (cam.RecordTypeId == rtId) {
                    if(mapSpecify == null){
                        mapSpecify = Utils.getApprovalStepByAPIName(SapApprovalEnum.MRDIEREQUEST);
                    }
                    setApprovalUser(mapSpecify,cam);
                }
            }
        }


        
        if (Trigger.isBefore && Trigger.isUpdate) {
            for (Approval_Managed__c cam : (List<Approval_Managed__c>)Trigger.new) {
                if (cam.RecordTypeId == rtId && cam.Is_Reset_Approvaler__c) {
                    if(mapSpecify == null){
                        mapSpecify = Utils.getApprovalStepByAPIName(SapApprovalEnum.MRDIEREQUEST);
                    }
                    setApprovalUser(mapSpecify,cam);
                    cam.Is_Reset_Approvaler__c = false;
                }
            }
        }
    }

            public void setApprovalUser(Map<Decimal,Organizational__c> mapSpecify,Approval_Managed__c cam){

            	//节点一：申请人部门主管
            	cam.Approval_User1__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(1),cam.Applicant__c),0);
            	//节点二：指定作业人   朱 新华-10210007
            	cam.Approval_User2__c  = utils.getUserByEmployeeCode('10210007');
            	//节点三：模具设计
            	cam.Approval_User3__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(3),cam.Operator_Abnormal__c),0);
            	//节点四：主管确认		朱 新华-10210007
            	cam.Approval_User4__c  = utils.getUserByEmployeeCode('10210007');
            	List<Id> listID=specialCal(cam);
            	if(listID!=null&&listID.size()==1)
                {
                    cam.Approval_User5__c=listID[0];  //节点五：下单
                    cam.Approval_User6__c=listID[0];  //节点六：生产
                    cam.Approval_User10__c=listID[0]; //节点十：模具/刻字/入库
                }
            	//节点七：检验  吴 正红-10210955
            	cam.Approval_User7__c  = utils.getUserByEmployeeCode('10210955');
            	//节点八：工单TECO  谢 壮壮-10211860
            	cam.Approval_User8__c  = utils.getUserByEmployeeCode('10211860');
            	//节点九：成本计算/编固资号/维护结算规则
            	cam.Approval_User9__c = utils.getUserByEmployeeCode('10210900');//汪 军义-10210900
            	cam.Approval_User12__c = utils.getUserByEmployeeCode('10210776');//张 榕-10210776
            	//节点十一：申请人确认(模具)
            	cam.Approval_User11__c = utils.getUserByEmployeeCode(cam.Applicant_Code__c);
            }


            //下单
    public List<Id> specialCal(Approval_Managed__c cam){
        List<Id> lstID = new List<Id>();
        if (cam.die_use_bu__c=='BU1')//判断模具使用BU
        {
            lstID.add(utils.getUserByEmployeeCode('10210045')); //张 战会-10210045
        }
        else if(cam.die_use_bu__c=='BU2')
        {
            lstID.add(utils.getUserByEmployeeCode('10210239')); //张 海军-10210239
        }
        else if(cam.die_use_bu__c=='BU3')
        {
            lstID.add(utils.getUserByEmployeeCode('10210036')); //冯 保金-10210036
        }
        else if(cam.die_use_bu__c=='BU4'||cam.die_use_bu__c=='BU5'||cam.die_use_bu__c=='BU6')
        {
            lstID.add(utils.getUserByEmployeeCode('10210063')); //张 曙光-10210063
        }
        return lstID;
    }   


          
    
}