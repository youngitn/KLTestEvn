public with sharing class MeetingMinutesMainPageController extends VFShowInApprovalExtension
{

    public String Participant　 { set; get;}
    public List<ParticipantRow> participantList { set; get;}

    public KL_Systems__c kls {set; get;}
    public List<SelectOption> meetingRoomOptions {set; get;}
    public String selectedMeetingRoom {set; get;}
    public List<SelectOption> DeptOptions {set; get;}
    public String objList {get; set;}
    //Task 紀錄類型Id
    //final public String taskRcecordTypeId = '012O0000000Aa6v';

    public MeetingMinutesMainPageController(ApexPages.StandardController con)
    {

        super('KL_Systems__c', 'Meeting_Minutes', con, null, null, null);
        participantList = new List<ParticipantRow>();
        kls = (KL_Systems__c)this.sobj;
        meetingRoomOptions = getMeetingRoom();
        DeptOptions = getDept();
        objList = new QueryController().objList;
        if(con.getId() != null)
        {
            //因為不是審批流程,沒有狀態欄位
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
        if(getUser(kls.Note_Taker__c) == null ){
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.WARNING, '會議紀錄人:'+kls.Note_Taker__c + ' 非SF USER帳號用戶.'));
            return null;       
        }
        upsert kls;

        String persons = '';
        integer count = participantList.size();
        List<String> emails = new List<String>();
        //決議事項
        //正常用新建TASK方式,則指派對象會自動收到mail
        //但是用Apex新增TASK則要寫程式來做email寄送
        //會議紀錄人需跟隨所有決議事項
        //同時建立決議事項明細給信件內容使用
        
        if (count > 0)
        {
            System.debug('決議事項-->'+participantList);
            for (ParticipantRow row : participantList)
            {

                String taskId = insertTask( kls.Id, row).id;
                
                ConnectApi.ChatterUsers.follow(null, String.valueOf(getUser(kls.Note_Taker__c).Id), taskId);         
                
                //emails.add('young_cheng@kinglai-hm.com');    
                
                emails.add(getUser(row.name).email); 
                
                System.debug('ParticipantRow email part1-->'+emails);


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
               
                //emails.add('young_cheng@kinglai-hm.com');    
                System.debug('P-->'+p);
                if(getUser(p) != null){
                    emails.add(getUser(p).email);    
                }
                 
                           
               
            }
            
        }
        System.debug('ParticipantRow email part2-->'+emails);
        sendMailToParticipants(emails, kls ,participantList);
        return this.goPage(kls.Id);
    }

    public Task insertTask(Id billId, ParticipantRow row)
    {
        //name = 姓名-工號
        User u = getUser(row.name);
        Task task = new Task();
        task.WhatId = billId;
        task.OwnerId = u.Id;
        task.Subject = row.subject;
        // task.priority = 'Normal';
        // task.status = 'Not Started';
        /****下面有給紀錄類型,表示工作是能區分類型的****/
        //task.recordTypeId = this.taskRcecordTypeId;
        task.ActivityDate = Date.valueOf(row.duedate);
        //task.description = 'New  Work';
        insert task;
        return task;
    }

    public String taskDetailBodyBuilder(List<ParticipantRow> amiList){
        String body = '決議事項:<br>\r\n';
        body += '<table border="1">';
        body += '<tr>'+
                    '<th>主要負責人</th>'+
                    '<th>主題</th>'+  
                    '<th>預計完成日</th>'+
                '</tr>';

        for(ParticipantRow ami:amiList){
            body += '<tr>';
            body += '<td>' + ami.name + '</td>';
            body += '<td>' + ami.subject + '</td>';
            body += '<td>' + ami.duedate + '</td>';
            
            
            body += '</tr>'; 
        }
        body += '</table>';
        return body;
    }

    public User getUser(String nameAndNumber)
    {
        String empid = nameAndNumber.substringAfter('-');
        User u = Peoples.getInstance().KlAllUserMapGetByNum.get(empid);
        return u;
    }
    public void sendMailToParticipants(List<String> commAddresses, KL_Systems__c kls,List<ParticipantRow> participantList)
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

        mail.setHtmlBody('您所參與的會議記錄已創建完成. <br> 會議日期:' + ('' + kls.Meeting_Date__c).left(10) + '<br> 會議時間:' + kls.BegingTime__c + '~' + kls.EndTime__c + '<br>會議地點:' + kls.Meeting_Place__c + '<br>會議主題:' + kls.Meeting_Subject__c + '<br> 會議主席:' + kls.Toastmaster__c + '<br>會議紀錄:' + kls.Note_Taker__c + '<br>'+taskDetailBodyBuilder(participantList)+'<br><br>表單詳情請至連結檢視:<a href="https://kinglai.my.salesforce.com/' + kls.id + '">開啟連結</a>');
        mail.setToAddresses(commAddresses);
        mail.setWhatId(kls.Id);
        System.debug(commAddresses);
        if (!Test.isRunningTest())
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

    }

    public List<SelectOption> getMeetingRoom()
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


    public List<SelectOption> getDept()
    {
        List<SelectOption> options = new List<SelectOption>();

        List<Organizational__c> oList = [select Dept_Number__c,Description__c from Organizational__c where recordTypeId = '012O0000000DLwN' and Corp_Number__c='3000'];

        for( Organizational__c o : oList)
        {
            options.add(new SelectOption(o.Dept_Number__c,o.Description__c));
        }
        //options.add(new SelectOption('else','其他'));
        return options;
    }

   
}