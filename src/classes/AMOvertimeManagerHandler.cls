/**********************************************************************
 名    称：加班管理流程
 目    的：设置加班管理流程各节点审批人
 作    者：
 创建日期：
 修 改 人：王思佳
 修改日期：2017/10/23
 
 
 **********************************************************************/
public without sharing class AMOvertimeManagerHandler implements Triggers.Handler {
    public void handle() {
        Map<Decimal,Organizational__c>  mapSpecify = null;
        Id rtId = HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.OVERTIMEMANAGER,'Approval_Managed__c');
        if (Trigger.isBefore && Trigger.isInsert) {
            for (Approval_Managed__c cam : (List<Approval_Managed__c>)Trigger.new) {
                if (cam.RecordTypeId == rtId) {
                    if(mapSpecify == null){
                        mapSpecify = Utils.getApprovalStepByAPIName(SapApprovalEnum.OVERTIMEMANAGER);
                    }
                    setApprovalUser(mapSpecify,cam);
                }
            }
        }


        
        if (Trigger.isBefore && Trigger.isUpdate) {
            for (Approval_Managed__c cam : (List<Approval_Managed__c>)Trigger.new) {
                if (cam.RecordTypeId == rtId && cam.Is_Reset_Approvaler__c) {
                    if(mapSpecify == null){
                        mapSpecify = Utils.getApprovalStepByAPIName(SapApprovalEnum.OVERTIMEMANAGER);
                    }
                    setApprovalUser(mapSpecify,cam);
                    cam.Is_Reset_Approvaler__c = false;
                }
                cam.head_description__c  = cam.overtime_instructions__c;
            }
        }
    }

            public void setApprovalUser(Map<Decimal,Organizational__c> mapSpecify,Approval_Managed__c cam){

                //新增节点：上级主管审批   60210029 刘帅
                cam.Approval_User5__c=utils.getUserByEmployeeCode('60210029');
            	//节点一：申请人部门主管
                if(cam.Applicant_Code__c=='10210861')
                {
                    cam.Approval_User1__c=utils.getUserByEmployeeCode('10210533');//章 国庆
                }
                else if(cam.Applicant_Corp_Code__c!='3000'&&
                        cam.Dept_Name__c!='10001509'&&
                        cam.Dept_Name__c!='10001528'&&
                        cam.Dept_Name__c!='10001526'&&
                        cam.Dept_Name__c!='10000221'&&
                        cam.Dept_Name__c!='10000222'&&
                        cam.Dept_Name__c!='10000223'&&
                        cam.Dept_Name__c!='10001527')
                {
                    cam.Approval_User1__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(1),cam.Applicant__c),0);
                }
                else
                {
                    cam.Approval_User1__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(1),cam.Applicant__c),0);
                }
        		//节点二: 申请人一阶主管
        		cam.Approval_User2__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(2),cam.Applicant__c),0);
        		
                cam.Approval_User4__c=utils.getUserByEmployeeCode('10210156');
                List<Id> listID=specialCal(cam);
                if(listID!=null&&listID.size()==2)
                {
                    cam.Approval_User3__c=listID[0];  //节点三: 生管员
                    cam.Approval_User4__c=listID[1];  //节点四: 考勤专员
                }
                else if(listID!=null&&listID.size()==1)
                {
                    cam.Approval_User4__c=listID[0];  //节点四: 考勤专员
                }

                cam.Approval_User20__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(20),null),0);
            }

            //招聘专员
    public List<Id> specialCal(Approval_Managed__c cam){
        List<Id> lstID = new List<Id>();
        if (cam.Factory__c=='1000'&&(cam.apply_dept__c == '02'|| cam.apply_dept__c == '03'))//判断生管员
        {
            lstID.add(utils.getUserByEmployeeCode('10210194')); //苟 建忠10210194 涉及生产:1000 BU2/BU3
        }
        else if(/*cam.Involving_production__c==true&&*/(cam.Factory__c=='1000'||cam.Factory__c=='2000')&&cam.apply_dept__c == '01')
        {
            lstID.add(utils.getUserByEmployeeCode('20210012')); //康 翠丽 涉及生产:1000 BU1/2000 
        }
        else if(cam.Factory__c=='1000'&&(cam.apply_dept__c == '04'|| cam.apply_dept__c == '05'))
        {
            lstID.add(utils.getUserByEmployeeCode('10211123')); //陈 小平 涉及生产:1000 BU4/BU5
        }
        else if(cam.Factory__c=='1000'&&cam.apply_dept__c == '07')
        {
            lstID.add(utils.getUserByEmployeeCode('10211567')); //陈 艳萍 涉及生产:1000 BU6
        }

        if(cam.Factory__c=='3000')//判断考勤专员
        {
            lstID.add(utils.getUserByEmployeeCode('30210206'));//陳 亞琳-30210206
        }
        else
        {
            lstID.add(utils.getUserByEmployeeCode('10210156'));//李 燕-10210156
        }
        return lstID;
    }   


          
    
}