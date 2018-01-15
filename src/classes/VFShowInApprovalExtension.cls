/**
 * 繼承本類別後於流程查詢和審批時都可正常顯示VF表單,
 * 不必再用標準layout做編輯審批的檢視
 */
public virtual class VFShowInApprovalExtension extends BaseExtension
{

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
                                     String DetailSobjName , String DetailApprovalName, String MasterKey)
    {
        super(sobjName, ApprovalName, stdController);
        isOld = false;
        nowStatus = 'INSERT';
        //有子項 則進行子項紀錄類型查詢
        if (DetailApprovalName != null)
        {
            detailRecTypeId = this.getReCTypeId(DetailSobjName, DetailApprovalName);
            //建立子項實體
            String listType = 'List<' + DetailSobjName + '>';
            detailSObjList = (List<SObject>)Type.forName(listType).newInstance();
        }

        //不是進入流程創建頁,則執行已存在紀錄查詢
        //如有子項也一併處理
        if (stdController.getId() != null)
        {
            nowStatus = 'PROCESS';
            isOld = true;
            String sql = '';
        
            sql += 'Select ' + SObjectUtils.getAllFields(sobjName).get(sobjName) + ' from ' + sobjName;
            sql += ' WHERE Id = \'' + stdController.getId() + '\'';
            this.sobj = Database.query(sql);
            System.debug('master record SQL = ' + sql);

            //如果有子項則進入處理
            if (DetailApprovalName != null)
            {
                
                String dSql = '';
         
                dSql += 'Select ' + SObjectUtils.getAllFields(DetailSobjName).get(DetailSobjName) + ' from ' + DetailSobjName;
                dSql += ' WHERE ' + MasterKey + '= \'' + stdController.getId() + '\'';
                System.debug('detail Sql =' + dSql);
                this.detailSObjList = Database.query(dSql);

            }
            return;
        }

    }

    //如果是開啟既有紀錄,則按下儲存時導向目前頁
    //否則會出現iframe當中又再出現iframe
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