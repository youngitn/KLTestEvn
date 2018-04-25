public with sharing class MeetingMinutesMainPageController extends VFShowInApprovalExtension
{

    public String Participant　 { set; get;}
    public List<ParticipantRow> participantList { set; get;}

    public KL_Systems__c kls {set; get;}
    public List<SelectOption> meetingRoomOptions {set; get;}
    public String selectedMeetingRoom {set; get;}
    public MeetingMinutesMainPageController(ApexPages.StandardController con)
    {

        super('KL_Systems__c', 'Meeting_Minutes', con, null, null, null);
        participantList = new List<ParticipantRow>();
        kls = (KL_Systems__c)this.sobj;
        meetingRoomOptions = getCountries();
        if(con.getId() != null)
        {
            //因為沒有狀態欄位
            //禁止編輯的判斷要在這邊做
            this.isEditable = false;//無可編輯欄位設置
            this.nowStatus = 'PROCESS';//審批中狀態
        }
    }

    public PageReference addParticipant()
    {

        //contactList.add(New Contact());
        ParticipantRow p = new ParticipantRow();
        participantList.add(p);
        return null;
    }
    public PageReference deleteRow()
    {
        //get rowId
        Integer rowId = integer.valueof(Apexpages.currentPage().getParameters().get('rowId')) - 1;

        //contactList.remove(rowId);
        participantList.remove(rowId);
        return null;
    }

    public  PageReference putValue()
    {

        String inputType = Apexpages.currentPage().getParameters().get('inputType');
        String inputValue  = Apexpages.currentPage().getParameters().get('inputValue');
        Integer rowId = integer.valueof(Apexpages.currentPage().getParameters().get('rowId')) - 1;
        ParticipantRow pr = participantList.get(rowId);
        pr.name = getValue('name', inputType, inputValue, pr.name);

        pr.subject =  getValue('subject', inputType, inputValue, pr.subject);

        pr.duedate =  getValue('duedate', inputType, inputValue, pr.duedate);

        return null;
    }

    public String getValue( String myKey, String nowKey, String inputValue , String oldValue)
    {

        if (!String.isBlank(inputValue) && !inputValue.equals(oldValue) && myKey.equals(nowKey))
        {
            return  inputValue;
        }
        else
        {
            return oldValue;
        }
        return null;
    }


    public class ParticipantRow
    {
        public String name {get; set;}
        // public String empid {get; set;}
        public String subject {get; set;}
        public String duedate {get; set;}
    }

    public override PageReference saveAction()
    {

        if(selectedMeetingRoom != 'else'){
            kls.Meeting_Place__c = selectedMeetingRoom;
        }
        if (kls.Meeting_Place__c == null || kls.Meeting_Place__c.trim() == ''){
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.WARNING, '請輸入會議地點'));
            return null;
        }
        upsert kls;

        String persons = '';
        integer count = participantList.size();
        List<String> emails = new List<String>();
        //決議事項
        //正常用新建TASK方式,則指派對象會自動收到mail
        //但是用Apex新增TASK則要寫程式來做email寄送
        if (count > 0)
        {
            for (ParticipantRow row : participantList)
            {
                insertTask( kls.Id, row);
                emails.add('young_cheng@kinglai-hm.com');
            }

        }

        /**
         * 這裡還需送信件給決議事項的指派對象
         * 另一個類似 sendMailToParticipants(emails, kls) 的方法;
         */
        //主席&紀錄加到參與者 取得email emails list需清空
        //先定義決議事項指派對象不等於會議參與者.
        kls.Participant__c = kls.Participant__c + ',' + kls.Toastmaster__c + ',' + kls.Note_Taker__c;
        if (kls.Participant__c != null)
        {
            List<String> pList = kls.Participant__c.split(',');
            for(String p : pList)
            {
                User u = getUser(p);
                emails.add('young_cheng@kinglai-hm.com');
            }
        }

        sendMailToParticipants(emails, kls);
        return this.goPage(kls.Id);
    }

    public void insertTask(Id billId, ParticipantRow row)
    {
        User u = getUser(row.name);
        Task task = new Task();
        task.WhatId = billId;
        task.OwnerId = u.Id;
        task.Subject = row.subject;
        // task.priority = 'Normal';
        // task.status = 'Not Started';
        /****下面有給紀錄類型,表示工作是能區分類型的****/
        task.recordTypeId = '012O0000000Aa6v';
        task.ActivityDate = Date.valueOf(row.duedate);
        //task.description = 'New  Work';
        insert task;
    }

    public User getUser(String nameAndNumber)
    {
        String empid = nameAndNumber.substringAfter('-');
        User u = Peoples.getInstance().KlAllUserMapGetByNum.get(empid);
        return u;
    }
    public void sendMailToParticipants(List<String> commAddresses, KL_Systems__c kls)
    {

        Messaging.reserveSingleEmailCapacity(2);


        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        // Strings to hold the email addresses to which you are sending the email.
        String[] toAddresses = commAddresses;
        System.debug(toAddresses);

        mail.setCharset('UTF-8');

        // Specify the address used when the recipients reply to the email.
        mail.setReplyTo('support@acme.com');

        // Specify the name used as the display name.
        mail.setSenderDisplayName('Salesforce');

        // Optionally append the salesforce.com email signature to the email.
        // The email address of the user executing the Apex Code will be used.
        mail.setUseSignature(false);

        mail.setSubject('Salesforce 會議記錄創建完成');

        mail.setHtmlBody('您所參與的會議記錄已創建完成. <br> 會議日期:' + ('' + kls.Meeting_Date__c).left(10) + '<br> 會議時間:' + kls.BegingTime__c + '~' + kls.EndTime__c + '<br>會議地點:' + kls.Meeting_Place__c + '<br>會議主題:' + kls.Meeting_Subject__c + '<br> 會議主席:' + kls.Toastmaster__c + '<br>會議紀錄:' + kls.Note_Taker__c + '<br><br>表單詳情請至連結檢視:<a href="https://kinglai.my.salesforce.com/' + kls.id + '">開啟連結</a>');
        mail.setToAddresses(commAddresses);
        mail.setWhatId(kls.Id);
        System.debug(commAddresses);
        if (!Test.isRunningTest())
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

    }

    public List<SelectOption> getCountries()
    {
        List<SelectOption> options = new List<SelectOption>();

        Schema.DescribeFieldResult fieldResult =
            Approval_Managed1__c.MeetingRooms__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

        for( Schema.PicklistEntry f : ple)
        {
            options.add(new SelectOption(f.getLabel(),f.getLabel()));
        }
        options.add(new SelectOption('else','其他'));
        return options;
    }
}