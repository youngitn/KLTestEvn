global with sharing class SampleExtension extends VFShowInApprovalExtension
{
	//*必要 主表物件*
	public Approval_Managed__c am{ set; get;}
	
	//*非必要 明細表物件 有關聯明細才需要*
	public List<Approval_Managed_Item__c> list1 {get; set;}

	//*非必要 有關聯明細才需要 用來做為紀錄明細序號的變數*
    public  Transient Integer list1Row {get; set;}

	//參數 com =  因VF中已有定義StandardController 所以做為extension須將StandardController丟到建構式
	//可理解為目前所開啟的主表,記錄其狀態的物件. 
	//流程-- 網址/ID 進StandardController查詢 將查詢結果丟回StandardController.
	public SampleExtension(ApexPages.StandardController con) {
		//*前個參數必要,其餘給null即可 後三個參數有關聯明細才需要 *
		//super('主表物件API名稱', '紀錄類型API名稱', con, 'Approval_Managed_Item__c','AMClockInAndOutDetail', 'MasterId__c');
		super('Approval_Managed__c', 'SampleMaster', con, 'Approval_Managed_Item__c','Containment_Action', 'MasterId__c');
        //super('Approval_Managed__c', 'AMClockInAndOutApplication', con, null,null, null);

		//*必要 還原主表實體*
		am = (Approval_Managed__c)this.sobj;
		
		//*非必要 有關聯明細才需要*
		list1Row = 0;
		
		//*非必要 有關聯明細才需要 還原明細表實體*
        list1 = (List<Approval_Managed_Item__c>)this.detailSObjList;
        
        //*必要 ture=創建狀態 else=審批或存檔狀態*
        if (con.getId() == null)
        {
            am = (Approval_Managed__c)SObjectUtils.init(am);

        }
        
	}

	//儲存邏輯
	public override PageReference saveAction()
    {
    	//新增或更新主表
    	upsert am;
        
        //將主表和明細表進行關聯 預計統一使用MasterId__c欄位   
        list1 = setRelationOfDetailWithMaster(list1, am.Id,'MasterId__c');
        System.debug(list1);
        
        //新增或更新明細表
        upsert list1;

        //導向該筆已儲存的紀錄頁面
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
     * [增加一列明細]
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
       
        data.put('Number__c',  c.Number__c);
        System.debug(JSON.serialize(data));
        return (String)JSON.serialize(data);
    }
}