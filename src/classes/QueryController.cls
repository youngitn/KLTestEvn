global with sharing class QueryController
{



    //master-detail
    public SObject sobj {set; get;}
    public String objList {get; set;}
    public List<AllApprovalData> allApproval {GET; SET;}
    public String selectedDeptName {GET; SET;}  //部門
    public String selectedContactCodeValue {GET; SET;} //輸入查詢工號
    public String selectedContactNameValue {GET; SET;} //輸入查詢員工姓名
    public String selectedfactoryValue {GET; SET;}  //工廠
    public String profileImageUrl {GET; SET;}  //頭像
    //与前台进行交互参数类
    public Contact meta {GET; SET;}
    public QueryController()
    {
        //sobj = (SObject)Type.forName(sobjName).newInstance();
        meta = new Contact();
        meta.Human_Range__c = '3000';
        query();
        objList = JSON.serialize(allApproval);
    }

    //queryApplicantNum 應該是查詢請假人而非申請人
    @RemoteAction
    global static String doQuery(String queryString)
    {
        Map<String, String> mapx = new Map<String, String>();

        mapx = (Map<String, String>)JSON.deserialize(queryString, Map<String, String>.class);
        String sobjName = mapx.get('sobjName');
        Id recType = mapx.get('recordTypeId');

        String soql = mapx.get('SOQL');

        //      Map<String,String> inputMap = new Map<String,String>();
        //inputMap.put('Start_date__c',sQueryDate);
        //inputMap.put('End_date__c',eQueryDate);
        //inputMap.put('End_date__c',eQueryDate);

        //inputMap.put('LeaveManage__r.RecordTypeId',recType);

        //      System.debug(inputMap);
        //      sql += ' '+Utils.checkStringToBuildSOQLString(inputMap,true) ;
        //      System.debug(sql);
        String listType = 'List<' + sobjName + '>';
        List<SObject> SObjList = (List<SObject>)Type.forName(listType).newInstance();
        SObjList = Database.query(soql);

        //      System.debug(JSON.serialize(amis));
        return JSON.serialize(SObjList).unescapeHtml4();
    }

    @RemoteAction
    global static String getEmpId(String cId )
    {

        return Peoples.getInstance().KlAllContactMapGetById.get(cId).Number__c;
    }


    //内部类
    //員工lookup名單資料結構
    public class AllApprovalData
    {
        public String id {GET; SET;}
        //工廠
        public String factory {GET; SET;}
        //單位部門 //欄位:公司部門
        public String Department {GET; SET;}
        //聯絡人姓名
        public String Contact_Name {GET; SET;}
        //聯絡人工號
        public String Contact_Code {GET; SET;}
        //聯絡人分機
        public String Extension_Number {GET; SET;}
        //聯絡人手機簡碼
        public String Phone {GET; SET;}
        // 頭像
        public String profileImageUrl {GET; SET;}
        //  Email
        public String Email {GET; SET;}
        public String Klphone {GET; SET;}
    }

    //員工lookup名單資料來源
    public PageReference query()
    {
        allApproval = new List<AllApprovalData>();

        String sqlSelect = 'SELECT Id,SF_user__c, Human_Range__c, Dept_Number__r.Name, Name, Number__c, Phone, MobilePhone, Email';
        String sqlFrom = ' FROM Contact ';
        String sqlWhere = ' WHERE Id != null AND Human_Range__c != null AND Dept_Number__r.Name != null ';
        System.debug(LoggingLevel.INFO, '*** selectedContactCodeValue: ' + selectedContactCodeValue);


        //工廠
        if ( meta.Human_Range__c != null)
        {
            String fac = meta.Human_Range__c ;
            sqlWhere += ' AND Human_Range__c =  \'' + fac + '\' ';
        }
        //部門
        if ( meta.Department != null)
        {
            String dep =  meta.Department;
            sqlWhere += ' AND  Dept_Number__r.Name LIKE \'' + '%' + dep + '%' + '\' ';
        }
        //工號
        if ( meta.Number__c != null)
        {
            String num = meta.Number__c ;
            sqlWhere += ' AND Number__c LIKE  \'' + num + '%' + '\' ';
        }
        //姓名
        if ( meta.SAPID__c != null)
        {
            String nam = meta.SAPID__c;
            sqlWhere += ' AND NAME LIKE  \'' + '%' + nam + '%' + '\' ';
        }
        //Email
        if ( meta.Native_Place__c != null)
        {
            String eml = meta.Native_Place__c;
            sqlWhere += ' AND Email LIKE \'' + eml + '%' + '\' ';
        }

        String sqlWhere1 = ' ORDER BY Dept_Number__r.Name, Number__c  LIMIT 100';
        List<Contact> con = Database.query(sqlSelect + sqlFrom + sqlWhere + sqlWhere1);

        List<KL_Systems__c> klsys = [ SELECT MeetingRoom_Text__c FROM  KL_Systems__c WHERE  MeetingRoom_Name__c = 'TWKL' ];

        for(KL_Systems__c abc : klsys)
        {
            AllApprovalData  data1 = new AllApprovalData();
            data1.Klphone = abc.MeetingRoom_Text__c;
            allApproval.add(data1);

        }
        for (Contact cn : con)
        {
            AllApprovalData  data = new AllApprovalData();
            data.factory = cn.Human_Range__c;
            data.Department = cn.Dept_Number__r.Name;
            data.Contact_Code = cn.Number__c;

            //聯絡人id=使用者id ，抓出user頭像
            if( cn.SF_user__c != null)
            {
                String theId = cn.SF_user__c;
                data.profileImageUrl = [select SmallPhotoUrl from User where Id = :theId ].SmallPhotoUrl;

            }
            data.Id = cn.Id;
            data.Contact_Name = cn.Name ;
            data.Extension_Number = cn.Phone;
            data.Phone = cn.MobilePhone;
            data.Email = cn.Email;
            allApproval.add(data);
        }

        return null;
    }
}