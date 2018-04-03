global with sharing class AMLeaveApplicationExtension extends VFShowInApprovalExtension
{

    public   Approval_Managed__c am {get; set;}

    public   List<Approval_Managed_Item__c> list1 {get; set;}

    public  Transient Integer list1Row {get; set;}
    public Transient Integer hasError {get; set;}
    public AMLeaveApplicationExtension(ApexPages.StandardController con)
    {
        super('Approval_Managed__c', '請假申請流程', con, 'Approval_Managed_Item__c', '请假明细表', 'LeaveManage__c');


        list1Row = 0;
        list1 = (List<Approval_Managed_Item__c>)this.detailSObjList;
        am = (Approval_Managed__c)this.sobj;
        if (con.getId() == null)
        {
            am = (Approval_Managed__c)SObjectUtils.init(am);
            newlist1();

        }


    }

    public override PageReference saveAction()
    {
        hasError = 0;
        //取得請假人的聯絡人物件
        Contact c = Peoples.getInstance().KlAllContactMapGetById.get(am.Employee__c);
        if (c != null)
        {
            am.Employee_Code__c = c.Number__c;
            am.Employee_Name__c = c.Name;
        }
        else
        {
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.WARNING, '請假人不存在聯絡人列表中'));
            hasError++;
        }

        //檢查輸入日期是否合法&假別時數是否可休&超過三天是否有勾選checkBox
        validateDetailList(list1, c.Take_Office_Date__c);
        if (hasError == 0)
        {
            //儲存表頭(master)
            upsert am;
            //設置每一筆明細(detail)的 fk=表頭(master) Id           
            setRelationOfDetailWithMaster(list1, am.Id);
            //儲存明細(detail)
            upsert list1;
            System.debug('&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&');
            return this.goPage(am.Id); 
        }else{
            System.debug('&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&>>>>>>>>>>'+hasError);          
            return null;
        }
        
    }

    /**
     * [將表頭Id塞入表身關聯欄位]
     * @param  detaillist [description]
     * @param  masterId   [description]
     * @return            [description]
     */
    public List<SObject> setRelationOfDetailWithMaster(List<Approval_Managed_Item__c> detaillist, Id masterId)
    {
        for (Approval_Managed_Item__c ami : detaillist)
        {
            ami.LeaveManage__c  = am.Id;
        }

        return detaillist;
    }

    /**
     * [檢查detail資料]
     * @param  list1            [明細Llist]
     * @param  Take_Office_Date [到職日]
     * @return                  [description]
     */
    public List<Approval_Managed_Item__c> validateDetailList(List<Approval_Managed_Item__c> list1, Date Take_Office_Date)
    {
        //休假時數總和預設給0
        am.Sum_Vacation__c = 0;
        //特休可用時數
        Decimal sum1 = 0;
        //補休可用時數
        Decimal sum2 = 0;
        //下年度特休重置時數
        Decimal sum3 = 0;

        //am.Annual_leave__c = am.Annual_leave__c.replace(' ', '');
        //am.Adjustable_vacation__c = am.Adjustable_vacation__c.replace(' ', '');
        //特休可用時數
        sum1 = validateLeaveHour(am.Annual_leave__c, '特休可用時數');

        //補休可用時數
        sum2 = validateLeaveHour(am.Adjustable_vacation__c, '補休可用時數');

        //下年度特休重置時數
        sum3 = validateLeaveHour(am.Warehouse_confirmation__c, '下年度特休重置時數');
        //更新详细记录
        if (list1.size() > 0)
        {

            for (Approval_Managed_Item__c ami : list1)
            {

                //新特休生效日
                //假設 起單日 2010/5/1 到職日7/1 所以新年度特休生效日為2010/7/1(日期皆為2010年)
                Date dd = getResetDateOfNextYearAnnualLeaveHour(Date.today(), Take_Office_Date);

                if(Date.valueOf(ami.Start_date__c) > dd && Date.valueOf(ami.Start_date__c).year() > dd.year())
                {
                    ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.WARNING, '預請年度錯誤'));
                    hasError ++;
                }

                if (ami.Start_date__c > ami.End_date__c)
                {
                    ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.WARNING, '開始日期不能大於结束日期'));
                    hasError ++;
                }
                //設置detaill的紀錄類型
                ami.RecordTypeId    = this.detailRecTypeId;

                am.Sum_Vacation__c += Decimal.valueOf(ami.time_number__c);


                //計算預先請休特休和
                if (ami.TypesOfLeave__c == '1006' && Decimal.valueOf(ami.time_number__c) != null && Date.today() < dd && ami.Start_date__c >= dd)
                {
                    System.debug('預先請下年度特休-->' + ami.Start_date__c);
                    sum3 -= Decimal.valueOf(ami.time_number__c);
                }
                //计算特休和
                else if (ami.TypesOfLeave__c == '1006' && Decimal.valueOf(ami.time_number__c) != null )
                {
                    System.debug('請本年度特休日-->' + ami.Start_date__c);
                    sum1 -= Decimal.valueOf(ami.time_number__c);
                }
                //補休加總
                if (ami.TypesOfLeave__c == '1015' && Decimal.valueOf(ami.time_number__c) != null)
                {
                    sum2 -= Decimal.valueOf(ami.time_number__c);
                }
            }
        }
        //判斷休假時數總和是否大於可休時數
        validateLeaveSum(sum1, '剩餘特休可休時數不足');
        validateLeaveSum(sum2, '剩餘補休可休時數不足');
        validateLeaveSum(sum3, '下年度特休可休時數不足');
        //檢查休假時數合計是否=0
        validateLeaveSumAll(am.Sum_Vacation__c);
        //單筆請假時數總和超過24小時,等於連續三天,存檔時會顯示錯誤訊息.
        isLeaveHourSumOver24(am.Sum_Vacation__c, am.Is_Been_Evaluated__c);
        return list1;
    }

    /**
     * [取得下年度特休重置日期(根據起單日期)]
     * @param  today            [description]
     * @param  Take_Office_Date [description]
     * @return                  [description]
     */
    public Date getResetDateOfNextYearAnnualLeaveHour(Date today, Date Take_Office_Date)
    {
        String day = '-' + Take_Office_Date.month() + '-' + Take_Office_Date.day();
        Date dd = Date.valueOf(String.valueOf(today.year()) + day);
        System.debug('下次重置日期----------------->' + dd);
        //如起單日期 >= 生效日: 2010/7/2起單 2010的特休已正式生效
        //這個情況下要預請休 動用到的將會是 2011/7/1生效的特休(生效日為2011年)
        if (Date.today() >= dd)
        {
            dd = Date.valueOf(String.valueOf(today.year() + 1) + day);

        }
        return dd;
    }


    /**
     * [單筆請假時數總和超過24小時,等於連續三天,存檔時會顯示錯誤訊息]
     * @param  sum             [description]
     * @param  over24HCheckBox [description]
     * @return                 [description]
     */
    public void isLeaveHourSumOver24(Decimal sum, Boolean over24HCheckBox)
    {

        if (sum >= 24 && over24HCheckBox == false)
        {
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.WARNING, '請假天數大於三天,請勾選"連續休假天數是否三天以上(含例假/國定假日)"欄位!'));
            hasError ++;
        }

    }

    /**
     * [檢查請假必要資料(可休時數)是否為'空']
     * @param  value     [description]
     * @param  fieldName [description]
     * @return           [description]
     */
    public Decimal validateLeaveHour(String value, String fieldName)
    {
        if (value != null)
        {
            return Decimal.valueOf(value.trim());
        }
        else
        {
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.WARNING, fieldName + '為空資料,請聯絡HR.'));
            hasError ++;
            return null;
        }
    }


    /**
     * [檢查可休時數是否不足]
     * @param  sum         [description]
     * @param  errorString [description]
     * @return             [description]
     */
    public void validateLeaveSum(Decimal sum, String errorString)
    {
        //判斷休假時數總和是否大於可休時數
        if (sum < 0 )
        {
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.WARNING, errorString));
            hasError ++;
        }
    }


    /**
    * [檢查休假時數合計是否=0]
    * @param  sum         [description]
    * @param  errorString [description]
    * @return             [description]
    */
    public void validateLeaveSumAll(Decimal sum)
    {
        //判斷休假時數總和是否大於可休時數
        if (sum == 0 )
        {
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.WARNING, '請假總時數不可為零'));
            hasError ++;
        }
    }

    /**
     * [增加一列請假明細]
     * @return [description]
     */
    public PageReference newlist1()
    {

        Approval_Managed_Item__c ami    = new Approval_Managed_Item__c();
        ami.RecordTypeId                = this.detailRecTypeId;

        list1.add(ami);

        return null;
    }

    /**
     * [移除一列請假明細]
     * @return [description]
     */
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
        data.put('Number__c',  c.Number__c);
        data.put('Phone',  c.Phone);
        return (String)JSON.serialize(data);
    }

    //RemoteActionsOfLeave.queryVacation 靜態方法
    //用來查詢SAP的特休&補休資料<-此方法只回傳這兩個假別資訊
    @RemoteAction
    global static String queryVacation(String empId)
    {
        return RemoteActionsOfLeave.queryVacation(empId);
    }

    @RemoteAction
    global static String queryVacationTW(String empId)
    {
        return RemoteActionsOfLeave.queryVacationTW(empId);
    }

}