global with sharing class AMClockInAndOutApplicationExtension extends VFShowInApprovalExtension
{
	public Approval_Managed__c am{ set; get;}
	public List<Approval_Managed_Item__c> list1 {get; set;}

    public  Transient Integer list1Row {get; set;}
	public AMClockInAndOutApplicationExtension(ApexPages.StandardController con) {
		super('Approval_Managed__c', 'AMClockInAndOutApplication', con, 'Approval_Managed_Item__c','AMClockInAndOutDetail', 'MasterId__c');
		am = (Approval_Managed__c)this.sobj;
		list1Row = 0;
        list1 = (List<Approval_Managed_Item__c>)this.detailSObjList;
        if (con.getId() == null)
        {
            am = (Approval_Managed__c)SObjectUtils.init(am);

        }
        
        
	}

	public override PageReference saveAction()
    {
    	 upsert am;
            //設置每一筆明細(detail)的 fk=表頭(master) Id
            //儲存明細(detail)
            list1 = setRelationOfDetailWithMaster(list1, am.Id,'MasterId__c');
            System.debug(list1);
            upsert list1;

            return this.goPage(am.Id);
    }
    
    /**
     * [將表頭Id塞入表身關聯欄位]
     * @param  detaillist [description]
     * @param  masterId   [description]
     * @return            [description]
     */
    public List<SObject> setRelationOfDetailWithMaster(List<Approval_Managed_Item__c> detaillist, Id masterId,String fkeyFieldName)
    {
        for (Approval_Managed_Item__c ami : detaillist)
        {
            ami.put(fkeyFieldName,am.Id);
        }

        return detaillist;
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
            Delete list1[list1Row];
            list1.remove(list1Row);
            
            return null;
        }
        list1.remove(list1Row);
        return null;
    }

    //很常用到 可考慮拉出來
    @RemoteAction
    global static String queryEmpId(String contactId)
    {
    	System.debug(contactId);
        Contact c = Peoples.getInstance().KlAllContactMapGetById.get(contactId);
        Map<String, String> data = new Map<String, String>();
        //Take_Office_Date Job_Title_Level Applicant_position
       /**
        * 增加本月補考勤次數查詢邏輯
        */
        
        data.put('Number__c',  c.Number__c);
        System.debug(JSON.serialize(data));
        return (String)JSON.serialize(data);
    }
}