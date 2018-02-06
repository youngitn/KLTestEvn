/**
 * 繼承本類別後於流程查詢和審批時都可正常顯示VF表單,
 * 不必再用標準layout做編輯審批的檢視
 */
public virtual class VFShowInApprovalExtension extends BaseExtension
{

    public boolean isOld {set; get;}
    public Id detailRecTypeId {set; get;}
    public Transient List<SObject> detailSObjList {set; get;}
    public String nowStatus {GET; SET;}
    public String nowNode  {GET; SET;}
    public Boolean isEditable {GET; SET;}

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
        isEditable = false;
        nowStatus = 'NEW';
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
             String sql = '';
            sql += 'Select ' + SObjectUtils.getAllFields(sobjName).get(sobjName) + ' from ' + sobjName;
            sql += ' WHERE Id = \'' + stdController.getId() + '\'';
            this.sobj = Database.query(sql);

            if ((String)this.sobj.get('Approval_Status__c') == 'S'){
                //送審後須判斷是否允許編輯
                isEditable = ProcessUtils.checkEditable(stdController.getId(),recordTypeId);

                nowStatus = 'PROCESS';
            }else if((String)this.sobj.get('Approval_Status__c') == 'R' || (String)this.sobj.get('Approval_Status__c') == 'A'){
                //通過和拒絕都不能編輯 isEditable 維持預設值false
                nowStatus = 'RejectedOrApproved';
            }else{
                //草稿不需判斷能否編輯 直接給true
                isEditable = true;
                nowStatus = 'SKETCH';
            }
            //這筆資料已存在紀錄 
            //給 goPage(Id recordId)判斷用
            isOld = true;
             
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
    //發生在流程查詢頁面 (同審批頁面)
    //否則會出現iframe當中又再出現iframe
    public PageReference goPage(Id recordId)
    {
        if (this.isOld)
        {
            //審批中 編輯存檔導向
            return ApexPages.currentPage();
        }
        //創建時 存檔導向
        return new PageReference('/' + recordId);
    }
    
    
}