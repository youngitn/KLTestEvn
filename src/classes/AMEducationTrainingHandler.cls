/**********************************************************************
 名    称：教育訓練申請流程
 目    的：指定流程關卡簽核人
 作    者：Young
 创建日期：2017-10-24
 修 改 人：王思佳
 修改日期：2017-11-28 8:25
 修改原因：增加6—13节点审批人
 备    注：

            节点1     申請人單位主管              Related User: *审批用户1：Approval_User1__c
            节点2     人力資源課承辦人（梁惠雯）  Related User: *审批用户2：Approval_User2__c
            节点3     人力資源課（高慧珠）        Related User: *审批用户3：Approval_User3__c
            节点4     管理部（高慧珠）            Related User: *审批用户4：Approval_User4__c
            节点5     財務主管                    Related User: *审批用户13：Approval_User14__c
            节点6     財務人員                    Related User: *审批用户13：Approval_User15__c
            节点7     總經理核示（李柏樺）        Related User: *审批用户5：Approval_User5__c
    崑山节点:
            节点8     主管审批                    Related User: *审批用户6： Approval_User6__c
            节点9     一阶主管审批                Related User: *审批用户7： Approval_User7__c
            节点10    管理部经理(陈瑞峰)          Related User: *审批用户8： Approval_User8__c
            节点11    总经理室(郭红飞)            Related User: *审批用户9： Approval_User9__c
            节点12    培训专员报名(颜斌)          Related User: *审批用户10：Approval_User10__c
            节点13    提交培训报告                Related User: *审批用户11：Approval_User11__c
            节点14    一阶主管确认报告            Related User: *审批用户12：Approval_User12__c
            节点15    培训专员确认(颜斌)          Related User: *审批用户13：Approval_User13__c
 **********************************************************************/
public without sharing class AMEducationTrainingHandler implements Triggers.Handler
{


    public void handle()
    {

        System.debug('!!!!!inAMEducationTrainingHandler');
        Map<Decimal, Organizational__c>  mapSpecify = null;
        Id rtId = HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.EDUCATIONTRAININGREQUEST, 'Approval_Managed1__c');
        System.debug('!!!!!get rtid =' + rtId);

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
                        empidList.add(p.substring(0, 8));

                    }
                    System.debug(empidList);
                    //for(User ps :[SELECT Id, Email, Name FROM User WHERE Number__c IN : empidList]){
                    //    userIds.add(ps.Id);
                    //}
                    for(String num : empidList)
                    {
                        userIds.add(Peoples.getInstance().KlAllUserMapGetByNum.get(num).id);
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
        //***************isUpdate****************isUpdate*****************isUpdate*******************isUpdate*************************************************************************//
        if (Trigger.isBefore && Trigger.isUpdate)
        {
            System.debug('##################');

            for (Approval_Managed1__c cam : (List<Approval_Managed1__c>)Trigger.new)
            {

                // 如果是最後已批准 寄出通知
                // 審批狀態應該會更新進而觸發此程式
                if (cam.RecordTypeId == rtId && cam.Approval_Status__c == 'A' && cam.InternalEducationParticipants__c != null)
                {

                }
                /***********************************************************************************************************************************************/
                if (cam.RecordTypeId == rtId && cam.Is_Reset_Approvaler__c)
                {
                    if (mapSpecify == null)
                    {
                        mapSpecify = Utils.getApprovalStepByAPIName(SapApprovalEnum.EDUCATIONTRAININGREQUEST);
                    }
                    setApprovalUser(mapSpecify, cam);
                    cam.Is_Reset_Approvaler__c = false;
                    cam.head_description__c  = cam.EducationTrainingName__c;
                }
                //刪除事件
                if(cam.RecordTypeId == rtId && cam.Approval_Status__c == 'R' )
                {

                    List<Event> le = [select Id, Subject, whatId from Event where whatId = :cam.Id];
                    List<EventRelation> ler = [select id from EventRelation where EventId in :le];

                    Delete le;
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

        //財務主管
        cam.Approval_User14__c       = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(5), null), 0);

        //財務人員
        cam.Approval_User15__c       = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(6), null), 0);

        //總經理核示
        cam.Approval_User5__c       = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(7), null), 0);

        // //6-13节点审批人设置
        cam.Approval_User6__c       = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(8), cam.Applicant__c), 0);
        cam.Approval_User7__c       = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(9), cam.Applicant__c), 0);
        cam.Approval_User8__c       = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(10), null), 0);
        cam.Approval_User9__c       = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(11), null), 0);
        /*if(!Test.isRunningTest() || ![SELECT Id, IsSandbox FROM Organization].get(0).IsSandbox)
        {*/
        cam.Approval_User10__c      = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(12), null), 0);
        cam.Approval_User11__c      = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(13), cam.Applicant__c), 0);
        cam.Approval_User12__c      = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(14), cam.Applicant__c), 0);
        cam.Approval_User13__c      = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(15), null), 0);
        //}


    }
    public Id getBoosId(Contact toCon)
    {
        Organizational__c o = new Organizational__c();
        o.Approval_Rule__c  = '指定人部门主管';
        return ApproverUtils.approvalSearchApprrovalerByRuleWithOutSOQL(o, toCon.Id).get(0);

    }

    public void notification(Approval_Managed1__c cam)
    {
        List<String> pList = cam.InternalEducationParticipants__c.split(',');
        List<String> empidList = new List<String>();
        //一般間接員工 有SF帳號 email資訊
        List<String> commAddresses = new List<String>();
        //主管email
        List<String> bossAddresses = new List<String>();

        //找不到可通知的人,就會寄給申請人
        List<String> nonAddresses = new List<String>();
        nonAddresses.add(Peoples.getInstance().KlAllContactMapGetById.get(cam.Applicant__c).email);

        String nonEmp = '';
        for(String p : pList)
        {

            if(p.length() < 8)
            {
                empidList.add('10211222');
            }
            else
            {
                empidList.add(p.substring(0, 8));
            }

        }
        //如果有內聘內訓講師,則查詢其工號將工號加入mail通知list
        if (cam.EducationTrainingInHouseLecturerName__c != null && !String.IsBlank(cam.EducationTrainingInHouseLecturerName__c))
        {
            List<User> u = [SELECT Name, Number__c FROM User WHERE id = :cam.EducationTrainingInHouseLecturerName__c];
            //Peoples.getInstance().KlAllContactMapGetByNum.get(num)
            //u.get(0).Number__c;
            //u.get(0).Name;
            empidList.add(u.get(0).Number__c);
        }
        //for(User ps :[SELECT Id, Email, Name FROM User WHERE Number__c IN : empidList]){
        //    sendMailToParticipants(ps.Name, ps.email, cam);
        //}

        Contact toCon = new Contact();

        Set<String> ManualShareRecordToUsers = new Set<String>();

        //取得主管email並寄出通知
        for(String num : empidList)
        {
            //從VF過來的都是聯絡人
            toCon = Peoples.getInstance().KlAllContactMapGetByNum.get(num);

            String bossEmail  = 'SF@SF.com';

            //判斷此工號的聯絡人資料:
            //1.沒有帳號或沒有啟用帳號
            //2.沒有email
            if (toCon == null || toCon.email == null || toCon.email == '')
            {

                nonEmp += num + '-' + toCon.Name;
                //sendMailToParticipants(toCon.Name , toCon.Email , bossEmail , cam ,noBoss , noContactEmail);

            }
            //連絡人資料齊全
            else
            {
                //將該參訓人mail加入通知列表
                commAddresses.add(toCon.email);
                Id bossId = null;
                //取主管
                bossId = getBoosId(toCon);
                if (bossId != null)
                {
                    bossEmail    = Peoples.getInstance().KlAllUserMapGetById.get(bossId).email;
                    bossAddresses.add(bossEmail);
                    ManualShareRecordToUsers.add(bossId);
                }
                //如果找不到主管 則收件人設為申請人寄出通知
                else
                {
                    nonEmp += num + '-' + toCon.Name;
                }
            }


        }
        //主管也需要觀看權限
        if (ManualShareRecordToUsers.size() > 0)
            Utils.ManualShareRecordToUsers(ManualShareRecordToUsers, 'Approval_Managed1__c', cam.Id);

        sendMailToParticipants(commAddresses , bossAddresses , nonAddresses, nonEmp, cam );
    }


    /**
     * [審核通過後,通知參訓人&其主管]
     * @param commAddresses [參訓人mail addr]
     * @param bossAddresses [參訓人主管 mail addr]
     * @param nonAddresses  [申請人 mail addr]
     * @param nonEmp        [無法收到通知的名單]
     * @param am            [description]
     */
    public void sendMailToParticipants(List<String> commAddresses, List<String> bossAddresses, List<String> nonAddresses, String nonEmp, Approval_Managed1__c am)
    {

        Messaging.reserveSingleEmailCapacity(2);

        // Strings to hold the email addresses to which you are sending the email.
        String[] toAddresses = commAddresses;
        String[] ccAddresses = bossAddresses;
        String[] nnAddresses = nonAddresses;
        String ApplicantName = '';
        String ApplicantNum = '';
        if (!Test.isRunningTest())
        {
            Contact Applicant = Peoples.getInstance().KlAllContactMapGetById.get(am.Applicant__c);
            ApplicantName = Applicant.Name;
            ApplicantNum = Applicant.Number__c;
        }

        String htmlBody = '您所參與的教育訓練申請流程已批准. <br> 單號:' + am.Name + '<br> 申請人:' + ApplicantName + ' ' + ApplicantNum + '<br>參訓名單:<br>' + am.InternalEducationParticipants__c + ' <br>表單詳情請至連結檢視:<a href="https://kinglai.my.salesforce.com/' + am.id + '">https://kinglai.my.salesforce.com/' + am.id + '</a>';
        String subject = 'Salesforce 教育訓練申請單 已批准';
        //如果有無發接收mail通知的參訓人存在,
        //則將收件人List增加申請人email addr,
        //並在內容加上"**系統無法自動通知以下的人員與其主管,煩請手動通知..."的字樣
        if (!Test.isRunningTest() && nnAddresses.size() > 0 && (!nonEmp.equals('') || nonEmp != null) )
        {
            //內容增加有無法收信的參訓人字樣
            htmlBody = '**系統無法自動通知以下的人員與其主管,煩請手動通知:' + nonEmp + '<br>' + htmlBody;
            //收件人增加申請人
            toAddresses.addAll(nnAddresses);
        }

        //寄送通知
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]
                            {
                                //建立Messaging.SingleEmailMessage物件並設置相關資料
                                buildMail(subject, htmlBody, toAddresses, ccAddresses)
                            });
    }

    /**
     * [mail類別設置]
     * @param  mail    [Messaging.SingleEmailMessage 物件]
     * @param  subject [String 主旨]
     * @param  body    [String 內容]
     * @param  to      [List 收件者]
     * @param  cc      [List 副本]
     * @return         [Messaging.SingleEmailMessage 物件]
     */
    public Messaging.SingleEmailMessage buildMail( String subject, String body, List<String> to, List<String> cc)
    {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setCharset('UTF-8');

        mail.setReplyTo('support@acme.com');

        mail.setSenderDisplayName('Salesforce');
        mail.setBccSender(false);
        mail.setUseSignature(false);
        mail.setSubject(subject);
        mail.setHtmlBody(body);
        mail.setToAddresses(to);
        if (cc != null)
        {
            mail.setCcAddresses(cc);
        }
        return mail;
    }
}