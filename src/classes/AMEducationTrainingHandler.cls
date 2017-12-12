/**********************************************************************
 名    称：教育訓練申請流程
 目    的：指定流程關卡簽核人
 作    者：Young
 创建日期：2017-10-24
 修 改 人：王思佳
 修改日期：2017-11-28 8:25
 修改原因：增加6—13节点审批人
 备    注：

            节点1   申請人單位主管              Related User: *审批用户1：Approval_User1__c
            节点2   人力資源課承辦人（梁惠雯）  Related User: *审批用户2：Approval_User2__c
            节点3   人力資源課（高慧珠）        Related User: *审批用户3：Approval_User3__c
            节点4   管理部（高慧珠）            Related User: *审批用户4：Approval_User4__c
            节点5   總經理核示（李柏樺）        Related User: *审批用户5：Approval_User5__c
    新增节点:
            节点6   主管审批                Related User: *审批用户6： Approval_User6__c
            节点7   一阶主管审批            Related User: *审批用户7： Approval_User7__c
            节点8   管理部经理(陈瑞峰)      Related User: *审批用户8： Approval_User8__c
            节点9   总经理室(郭红飞)        Related User: *审批用户9： Approval_User9__c
            节点10  培训专员报名(颜斌)      Related User: *审批用户10：Approval_User10__c
            节点11  提交培训报告            Related User: *审批用户11：Approval_User11__c
            节点12  一阶主管确认报告        Related User: *审批用户12：Approval_User12__c
            节点13  培训专员确认(颜斌)      Related User: *审批用户13：Approval_User13__c
 **********************************************************************/
public without sharing class AMEducationTrainingHandler implements Triggers.Handler
{
    public void handle()
    {

        //获取教育訓練申請流程各节点配置
        Map<String, Contact> KlAllContactMap = new Map<String, Contact>();
        Map<String, Contact> KlAllContactMapByNum = new Map<String, Contact>();
        Map<String, User> KlAllUserMap = new Map<String, User>();
        for(Contact c : [SELECT Id, Email, Number__c, Name, SF_User__c FROM Contact])
        {
            KlallContactMap.put(c.Id, c);
            KlAllContactMapByNum.put(c.Number__c, c);
        }
        for(User u : [SELECT Id, Email, Number__c, Name FROM User])
        {
            KlAllUserMap.put(u.Number__c, u);
        }
        System.debug('!!!!!inAMEducationTrainingHandler');
        Map<Decimal, Organizational__c>  mapSpecify = null;
        Id rtId = HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.EDUCATIONTRAININGREQUEST, 'Approval_Managed1__c');
        System.debug('!!!!!get rtid =' + rtId);
        System.debug('Trigger.isBefore && Trigger.isInsert=' + Trigger.isBefore + '&&' + Trigger.isInsert);

        if (Trigger.isBefore && Trigger.isInsert)
        {
            Set<String> userIds = new Set<String>();
            for (Approval_Managed1__c cam : (List<Approval_Managed1__c>)Trigger.new)
            {
                if (cam.RecordTypeId == rtId)
                {
                    System.debug('!!!!!in cam.RecordTypeId == rtId');
                    if (mapSpecify == null)
                    {
                        //這裡的step來源是[流程配置] 不是Approval Processes
                        mapSpecify = Utils.getApprovalStepByAPIName(SapApprovalEnum.EDUCATIONTRAININGREQUEST);
                    }
                    setApprovalUser(mapSpecify, cam);
                }
                if (!String.isBlank(cam.InternalEducationParticipants__c))
                {

                    List<String> pList = cam.InternalEducationParticipants__c.split(',');
                    List<String> empidList = new List<String>();
                    for(String p : pList)
                    {
                        empidList.add(p.substringAfter('-'));

                    }
                    //for(User ps :[SELECT Id, Email, Name FROM User WHERE Number__c IN : empidList]){
                    //    userIds.add(ps.Id);
                    //}
                    for(String num : empidList)
                    {
                        userIds.add(KlAllUserMap.get(num).id);
                    }


                }
                //申請人讀取權限
                userIds.add( Utils.getUserIdByContactID(cam.Applicant__c));

                if(userIds.size() > 0)
                {
                    Utils.ManualShareRecordToUsers(userIds, 'Approval_Managed1__c', String.valueOf(cam.get('Id')));
                }
            }
        }
        if (Trigger.isBefore && Trigger.isUpdate)
        {
            System.debug('##################');

            for (Approval_Managed1__c cam : (List<Approval_Managed1__c>)Trigger.new)
            {

                // 如果是最後批准且已通过 寄出通知
                if (cam.Approval_Status__c == 'A' && cam.InternalEducationParticipants__c != null)
                {
                    List<String> pList = cam.InternalEducationParticipants__c.split(',');
                    List<String> empidList = new List<String>();
                    for(String p : pList)
                    {
                        empidList.add(p.substringAfter('-'));

                    }
                    //for(User ps :[SELECT Id, Email, Name FROM User WHERE Number__c IN : empidList]){
                    //    sendMailToParticipants(ps.Name, ps.email, cam);
                    //}
                    for(String num : empidList)
                    {

                        //取得主管email
                        Organizational__c o = new Organizational__c();
                        o.Approval_Rule__c  = '指定人部门主管';
                        Contact toCon = KlAllContactMapByNum.get(num);
                        Id bossId           = Utils.approvalSearchApprrovalerByRule(o, toCon.Id).get(0);
                        String bossEmail    = KlAllContactMap.get(bossId).email;
                        String toEmail      = toCon.email;
                        sendMailToParticipants(toCon.Name , toEmail , bossEmail , cam);
                    }



                }

                if (cam.RecordTypeId == rtId && cam.Is_Reset_Approvaler__c)
                {
                    if (mapSpecify == null)
                    {
                        mapSpecify = Utils.getApprovalStepByAPIName(SapApprovalEnum.EDUCATIONTRAININGREQUEST);
                    }
                    setApprovalUser(mapSpecify, cam);
                    cam.Is_Reset_Approvaler__c = false;
                }

            }

        }
    }
    public void setApprovalUser(Map<Decimal, Organizational__c> mapSpecify, Approval_Managed1__c cam)
    {
        //cam.Applicant__c 为与SALESFORCE帐号相关的申请人
        //cam.Employee__c  为界面上新增的员工字段，与SALESFORCE账号无关

        //申請人單位主管 mapSpecify.get(1)會抓[流程配置]第一關的資訊
        //丟到Utils.approvalSearchApprrovalerByRule(Organizational__c,contactID)後 會抓mapSpecify.get(1)的參數 ex.审批人规则=指定崗位 or 指定人員
        //指定崗位 or 指定人員 是用中文字判斷.
        //根據不同規則拿申請人(contactID)作條件查詢審批人.
        System.debug('申請人(contactID)~~~~~~~~~~~' + cam.Applicant__c);
        cam.Approval_User1__c     = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(1), cam.Applicant__c), 0);
        //Id myid = Id.valueOf('00528000006o8EJAAY');
        // cam.Approval_User1__c     = myid;
        //人力資源課承辦人
        cam.Approval_User2__c       = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(2), null), 0);

        //人力資源課
        cam.Approval_User3__c       = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(3), null), 0);

        //管理部
        cam.Approval_User4__c       = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(4), null), 0);

        //總經理核示
        cam.Approval_User5__c       = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(5), null), 0);


        //6-13节点审批人设置
        cam.Approval_User6__c       = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(6), cam.Applicant__c), 0);
        cam.Approval_User7__c       = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(7), cam.Applicant__c), 0);
        cam.Approval_User8__c       = utils.getUserByEmployeeCode('10210853');
        cam.Approval_User9__c       = utils.getUserByEmployeeCode('10210016');//郭 红飞-10210016
        cam.Approval_User10__c      = utils.getUserByEmployeeCode('10212239');//颜 斌-10212239
        cam.Approval_User11__c      = utils.getUserByEmployeeCode(cam.Applicant__c);
        cam.Approval_User12__c      = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(12), cam.Applicant__c), 0);
        cam.Approval_User13__c      = utils.getUserByEmployeeCode('10212239');//颜 斌-10212239
    }
    public void sendMailToParticipants(String name, String email , String bossEmail, Approval_Managed1__c am )
    {

        Messaging.reserveSingleEmailCapacity(2);


        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        // Strings to hold the email addresses to which you are sending the email.
        String[] toAddresses = new String[] {email};

        String[] ccAddresses = new String[] {bossEmail};
        System.debug('-------------------->' + ccAddresses);
        mail.setCcAddresses(ccAddresses);


        // Assign the addresses for the To and CC lists to the mail object.
        mail.setToAddresses(toAddresses);

        // Specify the address used when the recipients reply to the email.
        mail.setReplyTo('support@acme.com');

        // Specify the name used as the display name.
        mail.setSenderDisplayName('Salesforce');

        // Specify the subject line for your email address.
        mail.setSubject('Salesforce 教育訓練申請單 員工:' + name + ' 所參與之教育訓練已批准');

        // Set to True if you want to BCC yourself on the email.
        mail.setBccSender(false);

        // Optionally append the salesforce.com email signature to the email.
        // The email address of the user executing the Apex Code will be used.
        mail.setUseSignature(false);

        // Specify the text content of the email.
        

        mail.setHtmlBody('name + '+' 您所參與的教育訓練申請流程 已批准. <br> 單號:' + am.Name + '<br> 申請人:' + am.Applicant__c  +'<br>表單詳情請至連結檢視:' + URL.getSalesforceBaseUrl() + '/' + am.Id );

        // Send the email you have created.
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}