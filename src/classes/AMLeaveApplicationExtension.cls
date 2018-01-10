global with sharing class AMLeaveApplicationExtension extends VFShowInApprovalExtension
{

    public Approval_Managed__c am {get; set;}

    public Id amId {get; set;}
    public List<Approval_Managed_Item__c> list1 {get; set;}

    //public List<Approval_Managed_Item__c> preDeletelist1 {get; set;}

    public Map<String, Approval_Managed_Item__c> mapVoucher {get; set;}

    public Integer list1Row {get; set;}
    public Boolean isDeletedStatus {GET; SET;}
    //明细记录类型ID
    private Id recTypeDetailId = null;
    public String ActionOfStatus {GET; SET;}

    public AMLeaveApplicationExtension(ApexPages.StandardController con)
    {
        super('Approval_Managed__c','請假申請流程',con,'Approval_Managed_Item__c','请假明细表','LeaveManage__c');

        System.debug(LoggingLevel.INFO, '*** detailRecTypeId: ' + this.detailRecTypeId);
        list1Row = 0;
        amId = con.getId();
        System.debug(LoggingLevel.INFO, '*** con.getId: ' + con.getId());
        System.debug(LoggingLevel.INFO, '*** amId: ' + amId);
        mapVoucher = new Map<String, Approval_Managed_Item__c>();


        // if (con.getId() != null)
        // {
        //     ActionOfStatus = 'j$("input[type=submit]").hide()';
        //     //從metadata物件中的SQL查詢,根據專屬的紀錄類型找到匹配的SOQL字串
        //     String sql = Utils.getApprovalSQL(SapApprovalEnum.LEAVEAPPLICATION, true);
        //     //加上已存在的單號
        //     sql = sql + ' WHERE Id = \'' + amId + '\'';
        //     //將查詢到的物件結果丟到參數中給VF去讀取
        //     am = Database.query(sql);
        //     //子項也要一併查詢
        //     list1 = [SELECT RecordTypeId, LeaveManage__c, TypesOfLeave__c, Leave_reason__c, Start_date__c, End_date__c, Start_time__c, End_time__c, Time_number__c FROM Approval_Managed_Item__c
        //              WHERE LeaveManage__c = :amid AND RecordType.DeveloperName = 'LeaveDetails'];

        //     return ;
        // }

        //ActionOfStatus = 'alert("it\'s OK");';
        am = (Approval_Managed__c)this.sobj;
        list1 = new List<Approval_Managed_Item__c>();
        newlist1();

        //preDeletelist1 = new List<Approval_Managed_Item__c>();
        am.Applicant_Name__c = UserInfo.getName();
        User u = Peoples.getInstance().KlAllUserMapGetById.get(UserInfo.getUserId());
        System.debug(u);
        System.debug('$$' + u.Number__c);
        if (u.Number__c != null && !String.isBlank(u.Number__c))
        {
            Contact c = Peoples.getInstance().KlAllContactMapGetByNum.get(u.Number__c);
            am.company_number__c = c.Corp_Code__c;
            am.Dept_Name__c = c.Dept_Number__r.Name;

        }
        am.Approval_Name__c = '請假申請流程';
        //am.Approval_Status__c = '草稿';
        am.Bill_Date__c =   Date.today();
    }

    public PageReference save()
    {
        if (String.isNotBlank(am.Employee__c) )
        {
            List<Contact> lstCon = [SELECT Name, Number__c FROM Contact WHERE Id = :am.Employee__c AND RecordType.DeveloperName = 'Staff'];
            if (lstCon.size() > 0)
            {
                am.Employee_Code__c = lstCon[0].Number__c;
                am.Employee_Name__c = lstCon[0].Name;
            }
        }
        else
        {
            am.Employee_Code__c = null;
            am.Employee_Name__c = null;
            am.Employee__c = null;
        }
        try
        {


            upsert am;
            //DELETE preDeletelist1;
            am.Sum_Vacation__c = 0;

            Decimal sum1;
            Decimal sum2;
            sum1 = 0;
            sum2 = 0;
            //am.Annual_leave__c = am.Annual_leave__c.replace(' ', '');
            //am.Adjustable_vacation__c = am.Adjustable_vacation__c.replace(' ', '');

            if (am.Annual_leave__c != null)
            {
                sum1 = Decimal.valueOf(am.Annual_leave__c.replace(' ', ''));
            }

            if (am.Adjustable_vacation__c != null)
            {
                sum2 = Decimal.valueOf(am.Adjustable_vacation__c.replace(' ', ''));
            }

            System.debug('*** listRowInfo: ' + list1 + '');
            //更新详细记录
            if (list1.size() > 0)
            {

                for (Approval_Managed_Item__c ami : list1)
                {

                    if (ami.Start_date__c > ami.End_date__c)
                    {
                        ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.WARNING, '开始日期不能大于结束日期'));
                        return null;
                    }
                    //明細關聯於此
                    ami.RecordTypeId = this.detailRecTypeId;
                    ami.LeaveManage__c = am.Id;
                    am.Sum_Vacation__c += Decimal.valueOf(ami.time_number__c);

                    //计算年休和
                    if (ami.Leave_type__c == '0100' && Decimal.valueOf(ami.time_number__c) != null)
                    {
                        sum1 -= Decimal.valueOf(ami.time_number__c);
                    }

                    //计算调休和
                    if (ami.Leave_type__c == '1100' && Decimal.valueOf(ami.time_number__c) != null)
                    {
                        sum2 -= Decimal.valueOf(ami.time_number__c);
                    }
                }
            }

            //年休和>剩余年休||调休和>剩余调休 ->报错
            if (am.Sum_Vacation__c == 0)
            {
                ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.WARNING, '请假时数为0'));
                return null;
            }

            //年休和>剩余年休||调休和>剩余调休 ->报错
            if (sum1 < 0  || sum2 < 0)
            {
                ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.WARNING, '年/调休假总和大于剩余年/调休假时数'));
                return null;
            }

            upsert list1;
            upsert am;
        }
        catch (Exception e)
        {
            System.debug('The following exception has occurred: ' + e.getMessage());
            ApexPages.addMessages(e);
            return null;
        }
        return new PageReference('/' +  am.Id);

    }


    public PageReference cancel()
    {
        return new PageReference('/apex/ApprovalHome?sfdc.tabName=01rO0000000Dz6T');
    }

    public PageReference newlist1()
    {
        Approval_Managed_Item__c ami = new Approval_Managed_Item__c();
        ami.RecordTypeId = this.detailRecTypeId;
        list1.add(ami);
        return null;
    }

    public PageReference deletelist1()
    {
        if (list1[list1Row].Id != null)
        {
            //preDeletelist1.add(list1[list1Row]);
        }
        list1.remove(list1Row);
        return null;
    }


    public Boolean isInsert()
    {
        return amId == null;
    }

    @RemoteAction
    global static String queryEmpId(String contactId)
    {

        Contact c = Peoples.getInstance().KlAllContactMapGetById.get(contactId);
        Map<String, String> data = new Map<String, String>();
        //Take_Office_Date Job_Title_Level Applicant_position
        data.put('Take_Office_Date', String.valueOf(c.Take_Office_Date__c));
        data.put('Job_Title_Level', c.Job_Title_Level__c);
        data.put('Applicant_position', c.Post_Number__r.Post_Description__c);
        return (String)JSON.serialize(data);
    }


    @RemoteAction
    global static String queryVacation(String empId)
    {
        System.debug(LoggingLevel.INFO, '*** 进入查询: ' + empId);
        if (String.isBlank(empId))
        {
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.WARNING, '请输入员工名称'));
            return null;
        }
        System.debug('empId=' + empId);

        //use Peoples
        Contact con = [SELECT Name, Number__c FROM Contact WHERE Id = :empId AND RecordType.DeveloperName = 'Staff' LIMIT 1];
        System.debug('con=' + con);
        String ret;
        try
        {
            String str1 = SapQueryArgCreate.createVacationQuery(con.Number__c);
            System.debug(str1);
            String str2 = Utils.postToSAP(str1);
            SapWebServiceReturnArgs args = (SapWebServiceReturnArgs)JSON.deserialize(str2, SapWebServiceReturnArgs.class);
            System.debug(LoggingLevel.INFO, '*** args: ' + args);
            Approval_Managed__c amget = (Approval_Managed__c)JSON.deserialize(JSON.serialize(args.content[0].main), Approval_Managed__c.class);
            // am.Employee_Code__c = amget.Employee_Code__c;
            // am.Annual_leave__c  = amget.Annual_leave__c;
            // am.Adjustable_vacation__c  = amget.Adjustable_vacation__c;
            ret = JSON.serialize(args.content[0].main);
        }
        catch(Exception ex)
        {
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage() + '\n' + ex.getStackTraceString()));
        }
        return ret;
    }

}