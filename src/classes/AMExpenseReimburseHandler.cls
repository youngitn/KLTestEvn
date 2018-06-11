/**********************************************************************
 名    称：费用报销审批流程
 目    的：设置费用报销审批流程各节点审批人
 作    者：刘文俊(liuwenjun@bluelinksys.com)
 创建日期：2017-04-25
 修 改 人：
 修改日期：
 修改原因：
 备    注：
 			    节点1 稽核单位审批              相关用户：*审批用户1
                节点2 部门主管审批              相关用户：*审批用户2
                节点3 售后部门主管审批            相关用户：*审批用户3
                节点4 一阶主管审批-供应商      相关用户：*审批用户4
                节点5 一阶主管审批-个人报销     相关用户：*审批用户5
                节点6 业务审批-个人报销           相关用户：*审批用户6
                节点7 财务经理审批              相关用户：*审批用户7
                节点8 费用审批人员-1000         相关用户：*审批用户8
                节点9 费用报销人员-非1000        相关用户：*审批用户9
 **********************************************************************/
public without sharing class AMExpenseReimburseHandler implements Triggers.Handler {

    public List<Approval_Managed_Item__c> list1 {get; set;}
    public List<Approval_Managed_Item__c> list2 {get; set;}


    public void handle() {
        //获取费用报销流程各节点配置
        Map<Decimal,Organizational__c>  mapSpecify = null;
        Id rtId = HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.EXPENSEREIMBURSE,'Approval_Managed__c');
        if (Trigger.isBefore && Trigger.isInsert) {
            for (Approval_Managed__c cam : (List<Approval_Managed__c>)Trigger.new) {
                if (cam.RecordTypeId == rtId) {
                    //如果不是从汇联易过来的单据，检查权限
                    if(!cam.Is_HLY_ExpenseReimburse__c){
                        //检测是否可以创建费用报销单
                        System_Setting__c ssc = System_Setting__c.getValues('Setting');
                        String corpCode = ssc.Can_Create_ExpenseReimburse__c;
                        String pernr = ssc.Pernr__c;
                        String uId = UserInfo.getUserId();
                        User u = [SELECT Id,Number__c,CompanyName FROM User WHERE Id =: uId];
                        String type = cam.Expense_Type_Cost__c;
                        /*
                        if(String.isBlank(corpCode)){
                            cam.addError('未设置创建个人费用报销单公司，请联系管理员设置！');
                            return;
                        }
                        */
                        //个人报销      01
                        //供应商报销    02
                        if(type == '01'){
                            if(String.isBlank(u.CompanyName) || !corpCode.contains(u.CompanyName) ){
                                if(!pernr.contains(u.Number__c) && !pernr.contains(cam.Employee_Code__c) ){
                                    cam.addError('非'+corpCode+'工厂员工或特定员工，不能创建个人报销！');
                                    return ;
                                }
                            }
                        }else if (type == '02') {
                            if (String.isNotBlank(cam.Employee__c) || String.isBlank(cam.Supplier__c)) {
                                cam.addError('供应商报销应该输入供应商号！');
                                return ;
                            }

                        }
                    }
                    if(mapSpecify == null){
                        mapSpecify = Utils.getApprovalStepByAPIName(SapApprovalEnum.EXPENSEREIMBURSE);
                    }

                    setApprovalUser(mapSpecify,cam);
                }
            }
        }
        if (Trigger.isBefore && Trigger.isUpdate) {
            for (Approval_Managed__c cam : (List<Approval_Managed__c>)Trigger.new) {
                //如果是汇联易同步过来已拒绝的单据，标记不能再提交
                if(cam.RecordTypeId == rtId  && !String.isBlank(cam.SAPID__c) && cam.Is_HLY_ExpenseReimburse__c && cam.Approval_Status__c == 'R'){
                    cam.Is_Reject_Submit__c = true;
                }

                if (cam.RecordTypeId == rtId && cam.Is_Reset_Approvaler__c) {
                    if(mapSpecify == null){
                        mapSpecify = Utils.getApprovalStepByAPIName(SapApprovalEnum.EXPENSEREIMBURSE);
                    }
                    setApprovalUser(mapSpecify,cam);
                    cam.Is_Reset_Approvaler__c = false;
                    cam.head_description__c  = cam.Remark_of_Explain__c;
                }

                //如果最后审批完成，将金额回写至CRM modify by 王思佳 at 2018/02/23
                /*if (cam.RecordTypeId == rtId && cam.Approval_Status__c == 'A')
                {
                    boolean flag=false;
                    String taId;
                    list1 = new List<Approval_Managed_Item__c>();
                    list2 = new List<Approval_Managed_Item__c>();
                    list1 = [SELECT RecordTypeId,Purchase_Info_Inquiry__c,Ledger_Account__c,Type_of_Cost__c,Quantity__c,Price__c,Amount__c,Dept_of_CostCenter__c,Remark__c,TaskID__c,Row_Index__c,Expense_Type__c
                 FROM Approval_Managed_Item__c 
                 WHERE Purchase_Info_Inquiry__c = :cam.Id AND RecordType.DeveloperName = 'Payment_Detail'];
                    list2 = [SELECT RecordTypeId,Voucher_Info__c,Accounting_Code__c,Subject__c,Amount__c,Dept_of_CostCenter__c,Allocation__c,Text__c,Reason_Code__c,SGL__c,Type_of_Affair__c,Row_Index__c
                 FROM Approval_Managed_Item__c Where Voucher_Info__c = :cam.Id AND RecordType.DeveloperName = 'Payment_Certificate'];
                    for (Approval_Managed_Item__c ami : list1)
                    {
                        if(ami.TaskID__c !=null && ami.TaskID__c != '')
                        {
                            flag=true;
                            taId=ami.TaskID__c;
                            break;
                        }
                    }
                    if(flag)
                    {
                        Decimal amount=0;
                        for (Approval_Managed_Item__c ami : list2)
                        {
                            amount = amount + ami.Amount__c;
                        }

                    }
                    Http http = new Http();
                    HttpRequest request = new HttpRequest();
                    request.setEndpoint('https://th-apex-http-callout.herokuapp.com/animals');
                    request.setMethod('GET');
                    HttpResponse response = http.send(request);
                    // If the request is successful, parse the JSON response.
                    if (response.getStatusCode() == 200) 
                    {
                    // Deserialize the JSON string into collections of primitive data types.
                        Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                        // Cast the values in the 'animals' key as a list
                        List<Object> animals = (List<Object>) results.get('animals');
                        System.debug('Received the following animals:');
                        for (Object animal: animals)
                        {
                            System.debug(animal);
                        }

                    }
                
                }*/
            }
        }
    }


    public void setApprovalUser(Map<Decimal,Organizational__c> mapSpecify,Approval_Managed__c cam){

        cam.Approval_User1__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(1),null),0);

        cam.Approval_User2__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(2),cam.Applicant__c),0);

        cam.Approval_User3__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(3),null),0);

        cam.Approval_User4__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(4),cam.Applicant__c),0);
      
        cam.Approval_User5__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(5),cam.Applicant__c),0);
       
        cam.Approval_User6__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(6),null),0);

        cam.Approval_User7__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(7),null),0);

        cam.Approval_User8__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(8),null),0);

        cam.Approval_User9__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(9),null),0);

        cam.Approval_User10__c  = specialCall(cam);

        cam.Approval_User11__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(11),cam.Applicant__c),0);
    }


     public Id specialCall(Approval_Managed__c cam){
        //公司代码不为6000 和2000
        if (cam.Corporation__c !='6000' && cam.Corporation__c !='3000' && cam.Corporation__c !='2000') {
            return utils.getUserByEmployeeCode('10210971');  //殷正宇
        }
        //生产及辅助设备
        else if (cam.Corporation__c =='6000' || cam.Corporation__c =='2000') {
            return utils.getUserByEmployeeCode('10212299');  //秦冬琴
        }
        else{
            return null;
        }
    }


}