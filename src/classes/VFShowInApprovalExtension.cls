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
    public SObject detailSobj {set; get;}
    public VFShowInApprovalExtension(String sobjName, String ApprovalName, ApexPages.StandardController stdController,
                                     String DetailSobjName , String DetailApprovalName,String MasterKey)
    {
        super(sobjName, ApprovalName, stdController);
        isOld = false;
        if (stdController.getId() != null)
        {
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

                dSql = dSql + ' WHERE '+MasterKey +'= \'' + stdController.getId() + '\'' + 'AND RecordType.DeveloperName = '+'\''+detaildeveloperName+'\'';
                this.detailSobj = Database.query(dSql);

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