/**
 * 繼承本類別後於流程查詢和審批時都可正常顯示VF表單,
 * 不必再用標準layout做編輯審批的檢視
 */
public virtual class VFShowInApprovalExtension extends BaseExtension
{

    //
    public String developerName {set; get;}
    public String detaildeveloperName {set; get;}
    public boolean isOld {set; get;}
    public Id detailRecTypeId {set; get;}
    public List<SObject> detailSObjList {set; get;}
     public String nowStatus {GET; SET;}
    /////////////////////////////////////////////////////////////////////////////////////////////////
    // BaseExtension
    // 屬性 -->
    // public SObject sobj {set; get;} // master表單物件
    // public Id recordTypeId {set; get;} // master紀錄類型Id
    // public Map<Id, Contact> contactsById {get;private set;} //Peoples 聯絡人員查找物件by ContactId
    // public Map<String, Contact> contactsByNum {get;private set;} //Peoples 聯絡人員查找物件 by 員編
    // public Map<Id, User> usersById {get;private set;} //Peoples 聯絡人員查找物件 by UserId
    // public Map<String, User> usersByNum {get;private set;} //Peoples 聯絡人員查找物件 by 員編
    // method -->
    // public virtual PageReference saveAction() //
    // public Id getReCTypeId(String sobjName,String approvalName)
    // public virtual PageReference cancelAction()
    /////////////////////////////////////////////////////////////////////////////////////////////////
    
    public VFShowInApprovalExtension(String sobjName, String ApprovalName, ApexPages.StandardController stdController,
                                     String DetailSobjName , String DetailApprovalName,String MasterKey)
    {
        super(sobjName, ApprovalName, stdController);
        isOld = false;
        String listType = 'List<' + DetailSobjName + '>';
        detailSObjList = (List<SObject>)Type.forName(listType).newInstance();
        nowStatus = 'INSERT';
        if (DetailApprovalName != null)
        {
            detailRecTypeId = this.getReCTypeId(DetailSobjName,DetailApprovalName);
        }
        if (stdController.getId() != null)
        {
            nowStatus = 'PROCESS';
            isOld = true;
            developerName = [SELECT name, DeveloperName  from RecordType where Id = :this.recordTypeId Limit 1].get(0).DeveloperName;
            String sql = Utils.getApprovalSQL(developerName, true);

            sql = sql + ' WHERE Id = \'' + stdController.getId() + '\'';
            this.sobj = Database.query(sql);
            System.debug(sql);
            //cam = (Custom_Approval_Managed__c)con.getRecord();
            if (DetailApprovalName != null)
            {
                
                String dSql = Utils.getApprovalSQL(developerName, false);
                
                detaildeveloperName = [SELECT name, DeveloperName  from RecordType where Id = :detailRecTypeId Limit 1].get(0).DeveloperName;
                dSql = dSql + ' WHERE '+MasterKey +'= \'' + stdController.getId() + '\'' + ' AND RecordType.DeveloperName = '+'\''+detaildeveloperName+'\'';
                System.debug('dSql@@='+dSql);
                this.detailSObjList = Database.query(dSql);

            }
            return;
        }

    }
    public PageReference goPage(Id recordId)
    {
        if (this.isOld)
        {
            return ApexPages.currentPage();
        }
        return new PageReference('/' + recordId);
    }
    public String getRecordName()
    {
        return 'Hello ' + (String)this.sobj.get('name') + ' (' + (Id)this.sobj.get('Id') + ')';
    }
}