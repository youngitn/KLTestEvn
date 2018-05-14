public with sharing class AMLeaveApplicationHandler  implements Triggers.Handler
{


    public void handle()
    {


        Map<Decimal, Organizational__c>  mapSpecify = null;
        Id rtId = HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.LEAVEAPPLICATION, 'Approval_Managed__c');
        Boolean haveSfID = true;
        if (Trigger.isBefore && Trigger.isInsert)
        {
            Set<String> userIds = new Set<String>();
            for (Approval_Managed__c cam : (List<Approval_Managed__c>)Trigger.new)
            {
                if (cam.RecordTypeId == rtId)
                {
                    if (cam.Employee__c == null)
                    {
                        cam.addError('Employee__c is empty');
                    }
                    if (mapSpecify == null)
                    {
                        //這裡的step來源是[流程配置] 不是Approval Processes
                        mapSpecify = Utils.getApprovalStepByAPIName(SapApprovalEnum.LEAVEAPPLICATION);
                    }
                    System.debug('cam.Employee_code__c-->' + cam.Employee_code__c);
                    //申請人讀取權限
                    //userIds.add( Peoples.getInstance().KlAllUserMapGetByNum.get(Peoples.getInstance().KlAllContactMapGetById.get(cam.Applicant__c).Number__c).Id);
                    if (Peoples.getInstance().KlAllContactMapGetById.get(cam.Employee__c).SF_user__r.Id != null)
                    {
                        //userIds.add( Peoples.getInstance().KlAllContactMapGetById.get(cam.Employee__c).SF_user__r.Id);
                        userIds.add(Peoples.getInstance().KlAllContactMapGetById.get(cam.Employee__c).SF_user__r.Id);
                    }
                    else if(Peoples.getInstance().KlAllUserMapGetByNum.get(cam.Employee_code__c) != null)
                    {
                        userIds.add(Peoples.getInstance().KlAllUserMapGetByNum.get(cam.Employee_code__c).Id);
                    }

                    if(userIds.size() > 0)
                    {
                        Utils.ManualShareRecordToUsers(userIds, 'Approval_Managed__c', String.valueOf(cam.get('Id')));
                    }
                    setApprovalUser(mapSpecify, cam );
                }


            }
        }
        if (Trigger.isBefore && Trigger.isUpdate)
        {
            System.debug('##################');

            for (Approval_Managed__c cam : (List<Approval_Managed__c>)Trigger.new)
            {

                if (cam.RecordTypeId == rtId )
                {
                    if (cam.Is_Reset_Approvaler__c)
                    {
                        if (mapSpecify == null)
                        {
                            mapSpecify = Utils.getApprovalStepByAPIName(SapApprovalEnum.LEAVEAPPLICATION);
                        }
                        setApprovalUser(mapSpecify, cam );
                        cam.Is_Reset_Approvaler__c = false;
                    }

                    //**代理人通知**
                    //狀態如果"更新"為是審批中才寄出
                    //從草稿or拒絕->審批中才符合更新條件,所以只會在提交時執行一次
                    if (cam.Approval_Status__c == 'S')
                    {
                        Messaging.reserveSingleEmailCapacity(2);

                        List<Approval_Managed_item__c> amiList = 
                            [SELECT toLabel(TypesOfLeave__c),Leave_reason__c,Start_date__c,toLabel(Start_Time__c),End_date__c,toLabel(End_Time__c),time_number__c 
                                FROM Approval_Managed_item__c 
                                WHERE LeaveManage__c =:cam.id];
                        String detailBody = leaveDetailBodyBuilder(amiList);
                        //核准/拒絕頁面專用明細顯示欄位;資料建立
                        cam.Remark__c = leaveDetailBodyBuilderForRemark(amiList);          
                        List<String> toAddresses = new List<String>();
                        //收件人設為Approval_User6__c的email addr
                        
                        if (cam.Approval_User6__c != null)
                        {
                            toAddresses.add(Peoples.getInstance().KlAllUserMapGetById.get(cam.Approval_User6__c).email);
                        }else{
                            toAddresses.add('salesforce@kltest.com');
                        }
                        
                        List<String> ccAddresses = null;
                        String subject = 'Salesforce 請假單 代理人通知';
                        String applicantName = 'Admin';
                        if (Peoples.getInstance().KlAllContactMapGetById.get(cam.Applicant__c) != null){
                            applicantName = Peoples.getInstance().KlAllContactMapGetById.get(cam.Applicant__c).Name;
                        }
                        
                        String htmlBody = 
                            '單號:' + cam.Name + 
                            '<br>申請人:' + applicantName +' '+cam.Applicant_Code__c+
                            '<br>申請日期:' +cam.CreatedDate + 
                            '<br>請假人:'+ Peoples.getInstance().KlAllContactMapGetById.get(cam.Employee__c).Name + ' '+cam.Employee_Code__c+ 
                            '<br>' + detailBody +
                            '<br>表單詳情請至連結檢視:<a href="https://kinglai.my.salesforce.com/' + cam.id + '">https://kinglai.my.salesforce.com/' + cam.id + '</a>';
        
                        Messaging.sendEmail(new Messaging.SingleEmailMessage[]
                                            {
                                                //建立Messaging.SingleEmailMessage物件並設置相關資料
                                                buildMail(subject, htmlBody, toAddresses, ccAddresses)
                                            });

                    }
                    //核准後同步SAP
                    if (cam.Approval_Status__c == 'A' && cam.Interface_Info__c == null)
                    {
                        
                        /**回傳格式:
                        {"status":"0", "message":"因冲突不能插入",  "sapid":""}**/
                       myMethod(String.valueOf(cam.id));
                        // if(((String)fromSapJson.get('status')) == '0'){
                        //     cam.addError( '<script>document.getElementById("bodyCell").innerHTML="<cnter><H1 >'+fromSapJson.get('message')+'</H1></center>";</script>', false);
                        // }else{
                        //     cam.Interface_Info__c=(String)fromSapJson.get('message');
                        // }
                        
                    }     

                }

            }

        }
    }

    //在trigger中callout必須設置 標註（Annotation） 
    //回傳值必須void且是靜態方法
    //傳入參數必須是標準資料型態(應該吧)
    @future (callout=true)
    public static void myMethod(String id) {
        String argJson = SapInputArgCreate.createSapAmleaveInputArgs(id);
        argJson = argJson.replace('TypesOfLeave__c', 'Leave_type__c');
        System.debug('argJson==>'+argJson);
       Map<String, object> fromSapJson =  (Map<String, object>)JSON.deserializeUntyped(Utils.postToSAP(argJson));
       Approval_Managed__c am = [SELECT Interface_Info__c FROM Approval_Managed__c WHERE id =:id];
       
       am.Interface_Info__c = 'SAP info:'+fromSapJson.get('message')+'';
        
        System.debug(am.Interface_Info__c);
        upsert am;

    }
    public void setApprovalUser(Map<Decimal, Organizational__c> mapSpecify, Approval_Managed__c cam )
    {

        // 主管簽核(請假人主管)
        cam.Approval_User1__c = Utils.getByIndex(ApproverUtils.approvalSearchApprrovalerByRuleWithOutSOQL(mapSpecify.get(1), cam.Employee__c), 0);
        //大於三天總經理簽核
        cam.Approval_User2__c = Utils.getByIndex(ApproverUtils.approvalSearchApprrovalerByRuleWithOutSOQL(mapSpecify.get(2), null), 0);

        //HR經辦
        cam.Approval_User3__c = Utils.getByIndex(ApproverUtils.approvalSearchApprrovalerByRuleWithOutSOQL(mapSpecify.get(3), null), 0);

        //-----以下為抓通知人用-----------

        //HR主管
        cam.Approval_User4__c = Utils.getByIndex(ApproverUtils.approvalSearchApprrovalerByRuleWithOutSOQL(mapSpecify.get(4), null), 0);
        //請假人
        cam.Approval_User5__c = mustNeedUserToNatify(cam.Employee__c, cam.Approval_User1__c);
        //代理人
        cam.Approval_User6__c = mustNeedUserToNatify(cam.Operator_Abnormal__c, cam.Approval_User1__c);
    }

    /**
     * [取得通知人ID 判斷cid是否有userId 如果沒有則通知人userid設為userId]
     * @param  cId            [連絡人id]
     * @param  userId         [如果cid沒有userId 則userId取代]
     * @return                [Id]
     */
    public Id mustNeedUserToNatify(Id cId, Id replaceUserId)
    {
        //請假人
        Contact c = Peoples.getInstance().KlAllContactMapGetById.get(cId);

        //情況一 可以從聯絡人關聯到User 間接人員
        if (c != null && c.SF_user__r.Id != null )
        {
            return c.SF_user__r.Id;

        }//情況二 無法從聯絡人關聯到User 須拿工號關聯才有資料 部分現場人員(chatter free user)
        else if(c != null && Peoples.getInstance().KlAllUserMapGetByNum.get(c.Number__c) != null)
        {
            return Peoples.getInstance().KlAllUserMapGetByNum.get(c.Number__c).Id;

        }//確定完全沒User帳號 將通知人設為主管
        else
        {
            return replaceUserId;
        }
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

    public String leaveDetailBodyBuilder(List<Approval_Managed_item__c> amiList){
        String body = '請假明細:<br>\r\n';
        body += '<table border="1">';
        body += '<tr>'+
                    '<th>假別</th>'+
                    '<th>事由</th>'+
                    '<th>開始日期</th>'+
                    '<th>開始時間</th>'+
                    '<th>結束日期</th>'+
                    '<th>結束時間</th>'+
                    '<th>請假時數</th>'+
                '</tr>';

        for(Approval_Managed_item__c ami:amiList){
            body += '<tr>';
            body += '<td>' + ami.TypesOfLeave__c + '</td>';
            body += '<td>' + ami.Leave_reason__c + '</td>';
            body += '<td>' + String.valueOf(ami.Start_date__c).substring(0, 10) + '</td>';
            body += '<td>' + ami.Start_Time__c + '</td>';
            body += '<td>' + String.valueOf(ami.End_date__c).substring(0, 10) + '</td>';
            body += '<td>' + ami.End_Time__c + '</td>';
            body += '<td>' + ami.time_number__c + '</td>';
            body += '</tr>'; 
        }
        body += '</table>';
        return body;
    }

    //重複程式碼
    public String leaveDetailBodyBuilderForRemark(List<Approval_Managed_item__c> amiList){
        String body = '請假明細:\r\n';
        
        Integer i = 1;

        for(Approval_Managed_item__c ami:amiList){
            body += '('+i+')'+'{'+
                    ' '+ami.TypesOfLeave__c.substringAfter(' ')+
                    ' / 事由: '+ami.Leave_reason__c+
                    ' / 請假期間: '+String.valueOf(ami.Start_date__c).substring(0, 10)+' '+ami.Start_Time__c +
                    ' 至 '+String.valueOf(ami.End_date__c).substring(0, 10) + ' '+ami.End_Time__c +
                    ' / 時數: '+ami.time_number__c +
                ' }\r\n';  
            i++;         
        }

        return body;
    }

}