/**********************************************************************
 名    称：電話簿
 目    的：電話簿 查詢員工
 作    者：劉昱杰，蔡育庭
 创建日期：2017-07
 修 改 人：鄭仰廷
 修改日期：2017-11-27
 修改原因：資料改為前端js控制 減少後端SOQL次數
 备    注：使用js套件 DataTable呈現資料

 **********************************************************************/
public without sharing class ApprovalContactExtension {
    public String selectedDeptName {GET; SET;}  //部門
    public String selectedContactCodeValue{GET; SET;}  //輸入查詢工號
    public String selectedContactNameValue{GET; SET;}  //輸入查詢員工姓名
    public String selectedfactoryValue {GET; SET;}  //工廠
    public String profileImageUrl {GET; SET;}  //頭像
    //与前台进行交互参数类
    public Contact meta {GET; SET;}
    public KL_Systems__c kl {GET; SET;}
    //内部类，保存全部数据
    public List<AllApprovalData> allApproval {GET; SET;}
    public String objList {get;set;}


    public ApprovalContactExtension() {
        meta = new Contact();
        kl =new KL_Systems__c();
        meta.Human_Range__c = '3000';
        query();
        objList = JSON.serialize(allApproval);
    }
    //内部类
    public class AllApprovalData {
    	//工廠
    	public String factory{GET;SET;}
        //單位部門 //欄位:公司部門
        public String Department{GET;SET;}
        //聯絡人姓名
        public String Contact_Name{GET;SET;}
        //聯絡人工號
        public String Contact_Code{GET;SET;}
        //聯絡人分機
        public String Extension_Number{GET;SET;}
        //聯絡人手機簡碼
        public String Phone{GET;SET;}
        // 頭像
        public String profileImageUrl{GET;SET;}
        //  Email
        public String Email{GET;SET;}
        public String Klphone{GET;SET;}
    }   
         // public class KLData {
         // public String Klphone{GET;SET;}


         // }


    public PageReference query() {
        allApproval = new List<AllApprovalData>();
         
        String sqlSelect = 'SELECT SF_user__c, Human_Range__c, Dept_Number__r.Name, Name, Number__c, Phone, MobilePhone, Email';
        String sqlFrom = ' FROM Contact ';
        String sqlWhere = ' WHERE Id != null AND Human_Range__c != null AND Dept_Number__r.Name != null ';
        System.debug(LoggingLevel.INFO, '*** selectedContactCodeValue: ' + selectedContactCodeValue);


        //工廠
        if ( meta.Human_Range__c != null) {
            String fac = meta.Human_Range__c ;
            sqlWhere += ' AND Human_Range__c =  \'' + fac+ '\' '; 
        }
        //部門
        if ( meta.Department != null) {
            String dep =  meta.Department;
            sqlWhere += ' AND  Dept_Number__r.Name LIKE \''+'%' + dep + '%' + '\' '; 
        }
        //工號
        if ( meta.Number__c != null) {
            String num = meta.Number__c ;
            sqlWhere += ' AND Number__c LIKE  \''+ num + '%' + '\' '; 
        }
        //姓名
        if ( meta.SAPID__c != null) {
            String nam = meta.SAPID__c;
            sqlWhere += ' AND NAME LIKE  \'' + '%' + nam + '%' + '\' ';
        }
        //Email
        if ( meta.Native_Place__c != null) {
            String eml = meta.Native_Place__c;
            sqlWhere += ' AND Email LIKE \'' + eml + '%' + '\' ';
        }
         
        String sqlWhere1 = ' ORDER BY Dept_Number__r.Name, Number__c  LIMIT 100';
        List<Contact> con = Database.query(sqlSelect + sqlFrom + sqlWhere + sqlWhere1);
        
       List<KL_Systems__c> klsys = [ SELECT MeetingRoom_Text__c FROM  KL_Systems__c WHERE  MeetingRoom_Name__c = 'TWKL' ];
       
        for(KL_Systems__c abc : klsys)
        {
        AllApprovalData  data1 = new AllApprovalData();       
        data1.Klphone= abc.MeetingRoom_Text__c;
        allApproval.add(data1);

        }       
        for (Contact cn : con) {
            AllApprovalData  data = new AllApprovalData();
            data.factory = cn.Human_Range__c;
            data.Department = cn.Dept_Number__r.Name;
            data.Contact_Code = cn.Number__c;
            
            //聯絡人id=使用者id ，抓出user頭像
            if( cn.SF_user__c != null) {
                String theId = cn.SF_user__c;
                data.profileImageUrl = [select SmallPhotoUrl from User where Id = :theId ].SmallPhotoUrl;
                
            }
            
            data.Contact_Name = cn.Name ;
            data.Extension_Number = cn.Phone;
            data.Phone = cn.MobilePhone;
            data.Email = cn.Email;
            allApproval.add(data);
        }

        return null;
    }
}