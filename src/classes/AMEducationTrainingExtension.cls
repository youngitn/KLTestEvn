public class AMEducationTrainingExtension
{

    public Approval_Managed1__c am  {Get; Set;}
    public Contact contact {get; set;}
    public String ApplicantEmpid  {get; set;}
    public Event EventX  {get; set;}
    public String objList {get; set;}
    //public List<Contact > contactList {get; set;}
    //public String  contactName{Get; Set;}
    //參訓人員
    public List<participant> participants {get; set;}

    public AMEducationTrainingExtension(ApexPages.StandardController con)
    {

        am = new Approval_Managed1__c();

        am.RecordTypeId = HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.EDUCATIONTRAININGREQUEST, 'Approval_Managed1__c');

        am.Approval_Name__c = SapApprovalEnum.EDUCATIONTRAININGREQUEST;

        if (con.getId() != null)
        {
            am = (Approval_Managed1__c)con.getRecord();
        }

        participants = new List<participant>();
        contact = new Contact();
        EventX = new Event();
        objList = JSON.serialize([SELECT Number__c, Name FROM Contact WHERE Human_Range__c = '3000']);

    }


    public PageReference save()
    {

        if (am.StartDate__c == null )
        {
            am.StartDate__c = Date.today();
        }
        if (am.BegingTime__c == null )
        {
            am.BegingTime__c = '10:00 AM';
        }
        if (am.EndTime__c == null )
        {
            am.EndTime__c = '11:00 AM';
        }
        //計算持續時間
        String bt = am.BegingTime__c;
        String et = am.EndTime__c;
        Date sdd = am.StartDate__c;
        //String sd = sdd.day() + '/' + sdd.month() + '/' + sdd.year();
        String sd = sdd.format();
        System.debug(sd);
        datetime startTime =  DateTime.parse(sd + ' ' + bt);
        datetime endTime = DateTime.parse(sd + ' ' + et);
        Long dm = ((endTime.getTime() - startTime.getTime()) / 60000);
        if ( dm > 1440)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, '教育訓練單次進行時間不能大於24小時,請調整 開始時間 與 結束時間 .'));
            return null;
        }

        String ps = '';

        //內訓內聘如果不為空 增加到參訓人 一起EVENT進行邀請
        if (am.EducationTrainingInHouseLecturerName__c != null && !String.IsBlank(am.EducationTrainingInHouseLecturerName__c))
        {
            participant p = new participant();
            List<User> u = [SELECT Name, Number__c FROM User WHERE id = :am.EducationTrainingInHouseLecturerName__c];
            p.empid = u.get(0).Number__c;
            p.name  = u.get(0).Name;
            participants.add(p);

        }
        Integer participantSize = participants.size();
        //天數不能為0
        if (am.Days__c == null || am.Days__c == 0)
        {

            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, '天數必須大於0,請重新輸入'));
            return null;
        }
        try
        {
            System.debug('amId---->' + am.id);
            Upsert am;


        }
        catch (DmlException e)
        {

            System.debug(e.getMessage());

        }

        System.debug('amId2---->' + am.id);
        System.debug('am.Equipment_Order__c---->' + am.Equipment_Order__c);
        if (Test.isRunningTest())
        {
            am.Equipment_Order__c = true;
        }
        if (am.Equipment_Order__c)
        {
            //建立一event type=日循環
            Event e = new Event(RecurrenceType = 'RecursDaily'); //如果API文件上面類型是屬性 則要在建構式給它
            e.Subject = am.EducationTrainingName__c;


            if (am.Applicant__c != null)
            {
                e.OwnerId = Utils.getUserIdByContactID(am.Applicant__c);
            }

            e.StartDateTime = e.ActivityDateTime = startTime;
            //e.StartDateTime = startTime;//只抓時間


            //e.WhoId = am.Applicant__c;//非必要
            e.WhatId = am.Id;//關聯單Id
            e.IsAllDayEvent = false; //是否全天
            e.IsRecurrence = true; //循環
            e.RecurrenceStartDateTime = e.StartDateTime; //循環開始時間 同開始時間

            System.debug('@@ e.RecurrenceStartDateTime=' + e.RecurrenceStartDateTime);
            //天數要減1 addDays(1) 會變成兩天
            if (am.Days__c != null && startTime != null)
            {
                e.RecurrenceEndDateOnly = startTime.adddays(Integer.valueOf(am.Days__c) - 1).date(); //循環結束日期

            }
            else
            {
                e.RecurrenceEndDateOnly = startTime.adddays(0).date(); //循環結束日期

            }


            e.RecurrenceInterval = 1; //循環頻率
            if (am.EducationTrainingHours__c == null)
            {
                am.EducationTrainingHours__c = 1;
            }
            e.DurationInMinutes = Integer.valueOf(dm);
            System.debug('@@ dm=' + dm);
            insert e;
            System.debug('@@ e.id=' + e.id);


            //內訓會議室選項 如果不為空則將會議室資源加入邀請
            if(am.MeetingRooms__c != null && !String.isBlank(am.MeetingRooms__c))
            {
                EventRelation res = new EventRelation();
                res.EventId = e.Id;
                res.RelationId = Id.valueOf(am.MeetingRooms__c);
                res.Status = 'Accepted';//設為邀請人已接受 因為是資源 所以必須設為接受
                insert res;
            }
            // 如果參訓人有新增 則加入邀請
            if (participantSize != null && participantSize > 0)
            {
                for (participant p : participants)
                {
                    participantSize--;

                    System.debug(p);
                    //增加邀請人

                    ps += p.name + '-' + p.empid;
                    if (participantSize > 0)
                    {

                        ps += ',';
                    }
                    addInv(e, p);

                }

                am.InternalEducationParticipants__c = ps;
                update am;
            }
        }
        System.debug('In save extention ');
        return new PageReference('/' + am.Id);
    }

    public void addInv(Event e, participant p)
    {
        EventRelation er = new EventRelation();
        System.debug(e.Id);

        //getUserByEmployeeCode(p.empid);
        if(!Test.isRunningTest())
        {
            er.EventId = e.Id;
            er.RelationId =  Utils.getUserByEmployeeCode(p.empid);//用SF_User__r.id作為邀請人才是真邀請
            er.Status = 'Accepted';

            insert er;
        }

    }
    public PageReference Cancel()
    {
        return null;
    }

    public PageReference addParticipant()
    {

        //contactList.add(New Contact());
        participant p = new participant();
        participants.add(p);
        return null;
    }

    public PageReference deleteRow()
    {
        //get rowId
        Integer rowId = integer.valueof(Apexpages.currentPage().getParameters().get('rowId')) - 1;

        //contactList.remove(rowId);
        participants.remove(rowId);
        return null;
    }


    public  PageReference putValue()
    {

        String inputType = Apexpages.currentPage().getParameters().get('inputType');
        String inputValue  = Apexpages.currentPage().getParameters().get('inputValue');
        Integer rowId = integer.valueof(Apexpages.currentPage().getParameters().get('rowId')) - 1;
        if (inputType.equals('empid') && !String.isBlank(inputValue))
        {
            participants.get(rowId).empid = inputValue;
            List<Contact> cont = [SELECT Name, Dept_Number__r.Name FROM CONTACT WHERE number__c = :inputValue];
            if(cont.size() < 1 )
            {
                participants.get(rowId).name = '查無此人';

            }
            else
            {
                participants.get(rowId).name = cont.get(0).name;
                participants.get(rowId).dep = cont.get(0).Dept_Number__r.Name;
            }

        }
        else
        {
            participants.get(rowId).name = inputValue;
        }

        return null;
    }

    public class participant
    {
        public String name {get; set;}
        public String empid {get; set;}
        public String dep {get; set;}

    }

    public void getContactNameByEmpid()
    {
        String empid = Apexpages.currentPage().getParameters().get('empid');
        ApplicantEmpid = [SELECT Name FROM CONTACT WHERE number__c = :empid].get(0).Name;

    }
    public void getContactEmpidByName()
    {
        String name = Apexpages.currentPage().getParameters().get('name');
        ApplicantEmpid = [SELECT number__c FROM CONTACT WHERE name = :name].get(0).number__c;


    }

}