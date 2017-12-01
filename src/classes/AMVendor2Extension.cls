public with sharing class AMVendor2Extension {
    public Boolean displayQueryResult {get; set;}
	public Custom_Approval_Managed__c cusAP{get;set;}
    public List<Custom_Approval_Managed__c> camList {get; set;}
    public List<SapContentOfReturnArgs> contentList {get;set;}
    public List<Contact> listContactPF{get;set;}  //合伙人列表
    public List<Contact> delListContactPF{get;set;}
    public List<Custom_Approval_Managed_Item__c> listBankDetail{get;set;}//供应商银行细目列表
    public List<Custom_Approval_Managed_Item__c> delListBankDetail{get;set;}
    public String recTypeBankDetailID = '';

    public String recTypeContactID = '';
    public String recTypePartnerID = '';
    public Integer rowID {GET;SET;}   //页面子表行数
    public List<Contact> listContact{get;set;}//联系人列表
    public List<Contact> delListContact{get;set;} 
    public Boolean isDeletedStatus{GET;SET;}

	//构造方法
    public AMVendor2Extension(ApexPages.StandardController con) {
            cusAP = new Custom_Approval_Managed__c();
            listBankDetail = new List<Custom_Approval_Managed_Item__c>();
            delListBankDetail = new List<Custom_Approval_Managed_Item__c>();
            listContact = new List<Contact>();
            delListContact = new List<Contact>();
            listContactPF = new List<Contact>();
            delListContactPF = new List<Contact>();
            displayQueryResult = false;
            isDeletedStatus = false;
            //设置记录类型为供应商
            cusAP.RecordTypeId = HarryUtils.getRecordTypeIdByDevNameAndObjName('Vendor','Custom_Approval_Managed__c');
            //查询各子表的对应记录类型ID
            recTypeBankDetailID = HarryUtils.getRecordTypeIdByDevNameAndObjName('Vendor_Bank_Info','Custom_Approval_Managed_Item__c');
            recTypeContactID = HarryUtils.getRecordTypeIdByDevNameAndObjName('Vendor_Contact__c','Contact');
            recTypePartnerID = HarryUtils.getRecordTypeIdByDevNameAndObjName('Vendor_Partner','Contact');
            //判断是新建还是编辑
        if (con.getId() != null) {
            isDeletedStatus = true;
            //查询相应记录
            String sql = Utils.getApprovalSQL(SapApprovalEnum.CUSTOMER,true);
            sql = sql + ' WHERE Id = \'' + con.getId() + '\'';
            cusAP = Database.query(sql);
             System.debug('*** cusAP: ' + cusAP + '');

             //查询银行细目子表
            listBankDetail = [SELECT Id, RecordTypeId, Is_Checked__c, Bank_of_Code__c, Account_of_Bank__c, Account_Name__c, Name_of_Bank__c, IBANValue__c, SWIFT_Code__c, Validate_Date__c, Country__c FROM Custom_Approval_Managed_Item__c  
                                Where Customer_Bank__c = :con.getId() AND RecordTypeId = :recTypeBankDetailID];
           
            //联系人
            listContact = [SELECT Id, RecordTypeId, Is_Checked__c, LastName, Phone, Department__c, Functionally__c, MobilePhone, Fax, Extension_Number__c, Extension_Number_Fax__c, Email 
                            FROM Contact 
                            Where Customer_Contact__c = :con.getId() AND RecordTypeId = :recTypeContactID];
            //合作伙伴
            listContactPF = [SELECT Id, RecordTypeId, LastName,PF__c, Number_Partner__c, Description_of_Partner__c 
            FROM Contact Where Customer_Partner__c = :con.getId() AND RecordTypeId = :recTypePartnerID];
        }
    }
    //保存
     public PageReference saveAction(){
        try {
            upsert cusAP;
        }
        catch (Exception e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
            ApexPages.addMessages(e);
        }
     //更新银行细目记录
        if (listBankDetail.size()>0) {
            List<Custom_Approval_Managed_Item__c> lstUpdatedBankDetail = new List<Custom_Approval_Managed_Item__c>();
            for (Custom_Approval_Managed_Item__c cami : listBankDetail) {
                cami.Vendor_Bank__c = cusAP.Id;
                cami.RecordTypeId = recTypeBankDetailID;
                lstUpdatedBankDetail.add(cami);
            }
            //update lstUpdatedBankDetail;
            System.debug('*** lstUpdatedBankDetail: ' + lstUpdatedBankDetail + '');
            upsert lstUpdatedBankDetail;
        }
    //更新联系人记录
        if (listContact.size()>0) {
            List<Contact> lstUpdatedContact = new List<Contact>();
            for (Contact cnt : listContact) {
                cnt.Vendor_Contact__c = cusAP.Id;
                cnt.RecordTypeId = recTypeContactID;
                lstUpdatedContact.add(cnt);
            }
            //update lstUpdatedBankDetail;
            System.debug('*** lstUpdatedContact: ' + lstUpdatedContact + '');
            try {
            upsert lstUpdatedContact;
             }
            catch (Exception e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
            ApexPages.addMessages(e);
            }
        }
   


        //更新合作伙伴记录
        if (listContactPF.size()>0) {
            List<Contact> lstUpdatedPF = new List<Contact>();
            for (Contact cnt : listContactPF) {
                cnt.Vendor_Partner__c = cusAP.Id;
                cnt.RecordTypeId = recTypePartnerID;
                lstUpdatedPF.add(cnt);
            }
            //update lstUpdatedBankDetail;
            System.debug('*** lstUpdatedPF: ' + lstUpdatedPF + '');
            try {
            upsert lstUpdatedPF;
             }
            catch (Exception e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
            ApexPages.addMessages(e);
            }
        }
//当编辑删除子表时，删除对应的记录
        if (isDeletedStatus) {
            if (delListContactPF.size()>0) {
                DELETE delListContactPF;
            }
            if (delListContact.size()>0) {
                DELETE delListContact;
            }
            if (delListBankDetail.size()>0) {
                DELETE delListBankDetail;
            }
         
        }

    return new PageReference('/' + cusAP.Id);
     }
     //取消
    public PageReference cancelAction(){
    	return new PageReference('/apex/ApprovalHome?sfdc.tabName=01rO0000000Dz6T');
    }



    //查询
    public PageReference queryVendor() {
        //供应商代码 
        String szVendorCode = !String.isBlank(cusAP.Vendor_Number__c)?cusAP.Vendor_Number__c:'';
        //供应商名称
        String szVendorName = !String.isBlank(cusAP.Vendor_Name__c)?cusAP.Vendor_Name__c:'';
        //公司代码
        String szCorpCode =  !String.isBlank(cusAP.Corporation__c)?cusAP.Corporation__c:'';
        //采购组织 
        String szPurchaseOrg =  !String.isBlank(cusAP.Purchase_Org__c)?cusAP.Purchase_Org__c:'';
        // 账户组  
        String szAccountGroup   =  !String.isBlank(cusAP.Account_Group__c)?cusAP.Account_Group__c:'';

        String str1 = SapQueryArgCreate.createSapVendorArgs(szVendorCode,szVendorName,szCorpCode,szPurchaseOrg,szAccountGroup);
        System.debug(str1);
        String str2 = Utils.postToSAP(str1);
        SapWebServiceReturnArgs args = (SapWebServiceReturnArgs)JSON.deserialize(str2, SapWebServiceReturnArgs.class);

        System.debug(LoggingLevel.INFO, '*** args: ' + args);
        camList = new List<Custom_Approval_Managed__c>();
        contentList = args.content;
       for(SapContentOfReturnArgs arg : contentList){
           Custom_Approval_Managed__c vendor = (Custom_Approval_Managed__c)JSON.deserialize(JSON.serialize(arg.main), Custom_Approval_Managed__c.class);
           camList.add(vendor);
       }

        displayQueryResult=true;
        return  null;
    }
 public Integer VendorRow{get;set;}


 public PageReference selectVendor(){

         cusAP =  (Custom_Approval_Managed__c)JSON.deserialize(JSON.serialize(contentList.get(VendorRow).main), Custom_Approval_Managed__c.class);
         cusAP.RecordTypeId = HarryUtils.getRecordTypeIdByDevNameAndObjName('Customer','Custom_Approval_Managed__c');
        // System.debug(LoggingLevel.INFO, '*** cusAPSelect: ' + cusAP);
        listBankDetail = (List<Custom_Approval_Managed_Item__c>)JSON.deserialize(JSON.serialize(contentList.get(VendorRow).details.get('banks')), List<Custom_Approval_Managed_Item__c>.class);
        listContact = (List<Contact>)JSON.deserialize(JSON.serialize(contentList.get(VendorRow).details.get('contacts')), List<Contact>.class);
        listContactPF = (List<Contact>)JSON.deserialize(JSON.serialize(contentList.get(VendorRow).details.get('partners')), List<Contact>.class);
        // listTaxType = (List<Custom_Approval_Managed_Item__c>)JSON.deserialize(JSON.serialize(contentList.get(customerRow).details.get('taxs')), List<Custom_Approval_Managed_Item__c>.class);
         displayQueryResult=false;
        return null;
    }
    public PageReference addContact(){
        Contact addItem = new Contact();
        listContact.add(addItem);
        System.debug('*** Add listContact: ' + listContact + '');
        return null;
    }
    public PageReference addPF(){
        Contact addItem = new Contact();
        listContactPF.add(addItem);
        System.debug('*** listContactPF: ' + listContactPF + '');
        return null;
    }
     
    public PageReference addBankDetail(){
        Custom_Approval_Managed_Item__c addItem = new Custom_Approval_Managed_Item__c();
        listBankDetail.add(addItem);
        System.debug('*** listBankDetail: ' + listBankDetail + '');
        return null;
    }
    public PageReference deleteBankDetail(){
            System.debug('*** rowID: ' + rowID + '');
            if (listBankDetail[rowID-1].Id != null) {
            delListBankDetail.add(listBankDetail[rowID-1]);
        }
            listBankDetail.remove(rowID-1);
        return null;
    }
    public PageReference removeContact(){
        if (listContact[rowID-1].Id != null) {
            delListContact.add(listContact[rowID-1]);
        }
        listContact.remove(rowID-1);
        return null;
    }
    public PageReference removePF(){
        if (listContactPF[rowID-1].Id != null) {
            delListContactPF.add(listContactPF[rowID-1]);
        }
        listContactPF.remove(rowID-1);
        return null;
    }
   
}