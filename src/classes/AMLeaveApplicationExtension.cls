global with sharing class AMLeaveApplicationExtension extends VFShowInApprovalExtension
{

    public   Approval_Managed__c am {get; set;}

    public   List<Approval_Managed_Item__c> list1 {get; set;}

    public  Transient Integer list1Row {get; set;}
    public Transient Integer hasError {get; set;}
    public Transient Date take_Office_Date {get; set;}
    public Transient String approvalNode {get; set;}
    //給測試數據用的變數
    public Transient String sapInsertArgs {get; set;}
    public AMLeaveApplicationExtension(ApexPages.StandardController con)
    {
        super('Approval_Managed__c', '請假申請流程', con, 'Approval_Managed_Item__c', '请假明细表', 'LeaveManage__c');

        System.debug('目前使用的語系:' + UserInfo.getLanguage());
        
        sapInsertArgs = null;
        list1Row = 0;
        list1 = (List<Approval_Managed_Item__c>)this.detailSObjList;
        am = (Approval_Managed__c)this.sobj;

        if (con.getId() == null)
        {
            am = (Approval_Managed__c)SObjectUtils.init(am);

        }
        else
        {
            //取得單據目前的審批關卡
            List<ProcessInstanceNode> pins = [SELECT Id, ProcessNodeId, ProcessNode.DeveloperName, ProcessInstance.ProcessDefinition.DeveloperName
                                              FROM ProcessInstanceNode
                                              WHERE ProcessInstance.TargetObjectId = :con.getId()  ORDER BY CreatedDate DESC
                                                      LIMIT 1];
            approvalNode = 'none';
            if (pins.size() > 0)
            {
                //取得關卡API NAME
                //如此可在前端做判斷條件使用
                approvalNode  = pins.get(0).ProcessNode.DeveloperName;
            }
        }

    }



    public override PageReference saveAction()
    {

        /***********************************************************************************/
        hasError = 0;

        //取得請假人的聯絡人物件
        Contact c = Peoples.getInstance().KlAllContactMapGetById.get(am.Employee__c);
        take_Office_Date = c.Take_Office_Date__c;

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
        validateDetailList(list1);

        if (hasError == 0)
        {
            // LeaveData ld = new LeaveData();
            // ld.empNumber = am.Employee_Code__c;
            // ld.amiList = list1;

            //儲存表頭(master)
            upsert am;
            //設置每一筆明細(detail)的 fk=表頭(master) Id
            //儲存明細(detail)
            list1 = setRelationOfDetailWithMaster(list1, am.Id);
            System.debug(list1);
            upsert list1;

            return this.goPage(am.Id);
        }
        else
        {

            return null;
        }
        /***********************************************************************************/
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
    public void validateDetailList(List<Approval_Managed_Item__c> list1)
    {
        //休假時數總和預設給0
        am.Sum_Vacation__c = 0;
        //特休可用時數
        Decimal sum1 = 0;
        //補休可用時數
        Decimal sum2 = 0;
        //下年度特休重置時數
        Decimal sum3 = 0;

        Integer i = 0;

        //am.Annual_leave__c = am.Annual_leave__c.replace(' ', '');
        //am.Adjustable_vacation__c = am.Adjustable_vacation__c.replace(' ', '');
        //特休可用時數
        sum1 = validateLeaveHour(am.Annual_leave__c, '特休可用時數');

        //補休可用時數
        sum2 = validateLeaveHour(am.Adjustable_vacation__c, '補休可用時數');

        //下年度特休重置時數
        sum3 = validateLeaveHour(am.Warehouse_confirmation__c, '下年度特休重置時數');
        System.debug('1list1--->' + list1.size());

        //將資料送至SAP執行卡控邏輯(班別&計算時數等..)
        String SAPQueryResult = null;
        if(sapInsertArgs != null)
        {
            SAPQueryResult = sapInsertArgs;
        }
        else
        {
            SapJsonStringBuilder sjb = new SapJsonStringBuilder();
            sjb.setMaster(am);
            sjb.setDetails(list1);
            SAPQueryResult = Utils.postToSAP( sjb.getJson('LEAVE_TW', 'leaveItem', null));
        }

        System.debug('2list1--->' + SAPQueryResult);
        Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(SAPQueryResult);
        List<Object> detailList = (List<Object>)m.get('leave_data');
        System.debug(m.get('check'));


        //更新详细记录
        if (list1.size() > 0)
        {

            for (Approval_Managed_Item__c ami : list1)
            {

                ami.time_number__c = ((String)((Map<String, Object>)detailList.get(i)).get('time_number__c')).trim();

                //判斷每筆請假時數 SAP計算回傳後是否為0
                if(Decimal.valueOf(ami.time_number__c) < 1)
                {
                    ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.WARNING, '第' + (i + 1) + '筆請假明細 時數不可為零'));
                    hasError ++;
                }


                //新特休生效日
                //假設 起單日 2010/5/1 到職日7/1 所以新年度特休生效日為2010/7/1(日期皆為2010年)
                Date dd = getResetDateOfNextYearAnnualLeaveHour(Date.today());

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

                i++;
            }
        }
        //判斷休假時數總和是否大於可休時數
        validateLeaveSum(sum1, '剩餘特休可休時數不足');
        validateLeaveSum(sum2, '剩餘補休可休時數不足');
        validateLeaveSum(sum3, '下年度特休可休時數不足');
        //檢查休假時數合計是否=0
        validateLeaveSumAll(am.Sum_Vacation__c);
        //單筆請假時數總和超過24小時,等於連續三天,存檔時會顯示錯誤訊息.
        isLeaveHourSumOver24(am.Sum_Vacation__c, am.Is_Been_Evaluated__c, (String)m.get('check'));
        //勾選連續休三天項目
        if((String)m.get('check') == 'X')
        {
            am.Is_Been_Evaluated__c = true;
        }
        if((String)m.get('status') == '0')
        {
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.WARNING, '注意:如請的是特休或補休需提前三天申請.'));
            // hasError ++;
        }

        //return list1;
    }

    /**
     * [取得下年度特休重置日期(根據起單日期)]
     * @param  today            [description]
     * @param  Take_Office_Date [description]
     * @return                  [description]
     */
    public Date getResetDateOfNextYearAnnualLeaveHour(Date today)
    {
        String day = '-' + take_Office_Date.month() + '-' + take_Office_Date.day();
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
    public void isLeaveHourSumOver24(Decimal sum, Boolean over24HCheckBox, String check)
    {

        if (check == 'X' && over24HCheckBox == false)
        {
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.WARNING, '請假天數大於三天(含假日),系統已自動勾選"連續休假天數是否三天以上(含例假/國定假日)"選項!'));
            //hasError ++;
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
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.WARNING, '刪除請假明細後請執行儲存動作,變更才會生效.'));
            Delete list1[list1Row];
            list1.remove(list1Row);
            take_Office_Date = Peoples.getInstance().KlAllContactMapGetById.get(am.Employee__c).Take_Office_Date__c;
            //表頭和請假明細相關的欄位需一併更新
            //如請假總時數
            //saveAction();

            return null;
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
    global static String queryVacation(String cid)
    {
        return RemoteActionsOfLeave.queryVacationTW(cid, 'VacationQuery');
    }

    //查詢SAP請假紀錄列表
    @RemoteAction
    global static String queryVacationTW(String cid)
    {
        return RemoteActionsOfLeave.queryVacationTW(cid, 'VacationQueryTW');
    }

    //推送請假紀錄到SAP
    @RemoteAction
    global static String leaveAppSyncToSAP(String id)
    {
        String argJson = '';

        Map<String, object> fromSapJson = new Map<String, object>();

        SapJsonStringBuilder sjb = new SapJsonStringBuilder();
        sjb.setMaster(id, 'Approval_Managed__c');
        sjb.setDetails(id, 'Approval_Managed_item__c', 'LeaveManage__c');
        argJson = sjb.getJson('LEAVE', 'Items', SapOperateEnum.INSERTED).replace('TypesOfLeave__c', 'Leave_type__c');
        System.debug('請假單同步SAP推送JSON-->==>' + argJson);
        String result = '{"test":"test"}';
        if(!Test.isRunningTest())
        {
            result = Utils.postToSAP(argJson);
        }

        //argJson = SapInputArgCreateForLeaveApplication.createSapAmleaveInputArgs(id);


        fromSapJson =  (Map<String, object>)JSON.deserializeUntyped(result);


        Approval_Managed__c am = (Approval_Managed__c)sjb.master;
        am.Interface_Info__c = 'SAP info:' + fromSapJson.get('message') + '';

        System.debug(am.Interface_Info__c);

        upsert am;
        return '' + fromSapJson.get('message');

    }
    // public class LeaveData{
    //     String empNumber;
    //     List<Approval_Managed_Item__c> amiList;
    //     public JSON jsonBuilder(){
    //         SapQueryArgCreate.createQueryArg('代定',lstCon);
    //         return JSON.serialize();
    //     }
    // }

}