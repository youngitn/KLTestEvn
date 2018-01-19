global with sharing class AMLeaveApplicationExtension extends VFShowInApprovalExtension
{

    public  Approval_Managed__c am {get; set;}
    public  String Start_date {get; set;}

    public  List<Approval_Managed_Item__c> list1 {get; set;}

    public  Integer list1Row {get; set;}

    public AMLeaveApplicationExtension(ApexPages.StandardController con)
    {
        super('Approval_Managed__c','請假申請流程',con,'Approval_Managed_Item__c','请假明细表','LeaveManage__c');

       
        list1Row = 0; 
        list1 = (List<Approval_Managed_Item__c>)this.detailSObjList;
        am = (Approval_Managed__c)this.sobj;
        if (con.getId() == null){
            am = (Approval_Managed__c)SObjectUtils.init(am);
            newlist1();

        }
        
        
    }

    public override PageReference saveAction()
    {   System.debug(Start_date);
        if (String.isNotBlank(am.Employee__c) )
        {
            List<Contact> lstCon    = [SELECT Name, Number__c FROM Contact WHERE Id = :am.Employee__c AND RecordType.DeveloperName = 'Staff'];
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
            am.Employee__c      = null;
        }
        try
        {

            upsert am;
            //DELETE preDeletelist1;
            am.Sum_Vacation__c = 0;

            Decimal sum1 = 0;
            Decimal sum2 = 0;
            
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
                        ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.WARNING, '開始日期不能大於结束日期'));
                        return null;
                    }
                    //明細關聯於此
                    ami.RecordTypeId    = this.detailRecTypeId;
                    ami.LeaveManage__c  = am.Id;
                    am.Sum_Vacation__c += Decimal.valueOf(ami.time_number__c);

                    //计算年休和
                    if (ami.Leave_type__c == '1006' && Decimal.valueOf(ami.time_number__c) != null)
                    {
                        sum1 -= Decimal.valueOf(ami.time_number__c);
                    }

                    //補休加總
                    if (ami.Leave_type__c == '1015' && Decimal.valueOf(ami.time_number__c) != null)
                    {
                        sum2 -= Decimal.valueOf(ami.time_number__c);
                    }
                }
            }

            //年休和>剩余年休||调休和>剩余调休 ->报错
            if (am.Sum_Vacation__c == 0)
            {
                ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.WARNING, '請假時數為0'));
                return null;
            }

            //判斷休假時數總和是否大於可休時數
            if (sum1 < 0  || sum2 < 0)
            {
                ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.WARNING, '剩餘可休時數不足'));
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
        return this.goPage(am.Id);

    }

    public PageReference newlist1()
    {

        Approval_Managed_Item__c ami    = new Approval_Managed_Item__c();
        ami.RecordTypeId                = this.detailRecTypeId;
        
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
    
    /**
     * AJAX 查詢個人資料
     * @param  contactId 聯絡人ID
     * @return String    json格式的字串
     */
    @RemoteAction
    global static String queryEmpId(String contactId)
    {

        Contact c = Peoples.getInstance().KlAllContactMapGetById.get(contactId);
        Map<String, String> data = new Map<String, String>();
        //Take_Office_Date Job_Title_Level Applicant_position
        data.put('Take_Office_Date',    String.valueOf(c.Take_Office_Date__c));
        data.put('Job_Title_Level',     c.Job_Title_Level__c);
        data.put('Applicant_position',  c.Post_Number__r.Post_Description__c);
        return (String)JSON.serialize(data);
    }

    //RemoteActionsOfLeave.queryVacation 靜態方法
    //用來查詢SAP的特休&補休資料<-此方法只回傳這兩個假別資訊
    @RemoteAction
    global static String queryVacation(String empId)
    {
       return RemoteActionsOfLeave.queryVacation(empId);
    }

}