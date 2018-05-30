global with sharing class AMSalesOrderDatatableExtention extends VFShowInApprovalExtension
{
     public Custom_Approval_Managed__c cam  {Get; Set;}
    public AMSalesOrderDatatableExtention(ApexPages.StandardController con)
    {
        //super('物件名稱', '紀錄類型名稱',ApexPages.StandardController,
        //      '子物件名稱 沒子項給null','子物件紀錄類型名稱 沒子項給null','子物件關聯欄位名稱 沒子項給null');
        super('Custom_Approval_Managed__c', '销售申请单', con, null, null, null);
        System.debug('OK');
        cam = (Custom_Approval_Managed__c)sobj;
        System.debug(cam);
        /***
            	此處可編輯一進入創建畫面要執行的邏輯
        ***/
        if (con.getId() != null)
        {
            cam = (Custom_Approval_Managed__c)SObjectUtils.init(cam);
            /***
            	此處可編輯一進入審批畫面要執行的邏輯
            ***/
        }

    }

    public override PageReference saveAction()
    {
        upsert cam;
        return new PageReference('/' + cam.Id);
    }

    /**
     * [dataTableDeom 
     * 	定義@RemoteAction標記,使其讓JS可呼叫此method.
     * 	主要邏輯為,將來源資料整理成MAP,放到LIST中,再轉換成JSON
     * ]
     * @param  empId [js 的input參數]
     * @return       [JSON]
     */
    @RemoteAction
    global static String dataTableDeom(String empId)
    {
    	
        Contact c = [SELECT Id, Phone,SF_User__r.Id,SF_User__r.isActive, Email, Number__c, Name, Is_Manager__c,SF_User__c ,SF_User__r.Is_First_Manager__c ,SF_User__r.Is_Manager__c,Dept_Number__c,Dept_Number__r.Parent_Number__c,Dept_Number__r.Name,Corp_Code__c,Take_Office_Date__c,Job_Title_Level__c,Title,Post_Number__r.Post_Description__c    
                            FROM Contact where Number__c =: empId].get(0);
        //可嘗試建立一個class取代Map<String, String>
        Map<String, String> emp = new Map<String, String>();
        //Take_Office_Date Job_Title_Level Applicant_position
        emp.put('Take_Office_Date',    String.valueOf(c.Take_Office_Date__c));
        emp.put('Job_Title_Level',     c.Job_Title_Level__c);
        emp.put('Applicant_position',  c.Post_Number__r.Post_Description__c);
        emp.put('Number__c',  c.Number__c);
        emp.put('Phone',  c.Phone);
        System.debug(emp);

        List<Map<String, String>> listx = new List<Map<String, String>>();
        listx.add(emp);
        return (String)JSON.serialize(listx);
    }
}