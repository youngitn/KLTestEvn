/**************************************************************************************************
 * Name: AccountDataController
 * Object: Custom_Approval_Managed__c
 * Purpose: 自定义客户主数据维护
 * Requirement:
 * Author: zhonghui
 * Create Date: 2017-4-11
 * Modify History: 
 * 
***************************************************************************************************/
public without sharing class AMCustomerExtension {
	public Custom_Approval_Managed__c cusAP{get;set;}//客户
    public List<Custom_Approval_Managed_Item__c> listBankDetail{get;set;}//客户银行细目列表
    public List<Contact> listContact{get;set;}//联系人列表
    public List<Custom_Approval_Managed_Item__c> listTaxType {get;set;}//税收类别子表
    public List<Contact> listContactPF{get;set;}  //合伙人列表
    public String recTypeBankDetailID = '';
    public String recTypeTaxID = '';
    public String recTypeContactID = '';
    public String recTypePartnerID = '';
    public Integer rowID {GET;SET;}   //页面子表行数
    public List<Custom_Approval_Managed_Item__c> delListBankDetail{get;set;}
    public List<Contact> delListContact{get;set;} 
    public List<Custom_Approval_Managed_Item__c> delListTaxType {get;set;}
    public List<Contact> delListContactPF{get;set;}
    public Boolean isDeletedStatus{GET;SET;}
    public AMCustomerExtension(ApexPages.StandardController con) {
        displayQueryResult = false;
    	cusAP = new Custom_Approval_Managed__c();
        listBankDetail = new List<Custom_Approval_Managed_Item__c>();
        listContact = new List<Contact>();
        listTaxType = new List<Custom_Approval_Managed_Item__c>();
        listContactPF = new List<Contact>();
        delListBankDetail = new List<Custom_Approval_Managed_Item__c>();
        delListContact = new List<Contact>();
        delListTaxType = new List<Custom_Approval_Managed_Item__c>();
        delListContactPF = new List<Contact>();
        isDeletedStatus = false;
        System.debug('*** con.getRecord(): ' + con.getRecord() + '!');
        //设置记录类型为客户
        cusAP.RecordTypeId = HarryUtils.getRecordTypeIdByDevNameAndObjName('Customer','Custom_Approval_Managed__c');
        cusAP.Language__c = null;
        //查询各子表的对应记录类型ID
            recTypeBankDetailID = HarryUtils.getRecordTypeIdByDevNameAndObjName('Custmer_Bank_Detail','Custom_Approval_Managed_Item__c');
            recTypeTaxID = HarryUtils.getRecordTypeIdByDevNameAndObjName('Tax_Type','Custom_Approval_Managed_Item__c');
            recTypeContactID = HarryUtils.getRecordTypeIdByDevNameAndObjName('Account_Contact','Contact');
            recTypePartnerID = HarryUtils.getRecordTypeIdByDevNameAndObjName('Account_Partner','Contact');
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
            //税收子表
            listTaxType = [SELECT Id, RecordTypeId, Is_Checked__c, Country__c, Category_of_Tax__c, Type_of_Tax__c 
                            FROM Custom_Approval_Managed_Item__c 
                            Where Customer_Tax__c = :con.getId() AND RecordTypeId = :recTypeTaxID];
            //联系人
            listContact = [SELECT Id, RecordTypeId, Is_Checked__c, LastName, Phone, Department__c, Functionally__c, MobilePhone, Fax, Extension_Number__c, Extension_Number_Fax__c, Email 
                            FROM Contact 
                            Where Customer_Contact__c = :con.getId() AND RecordTypeId = :recTypeContactID];
            //合作伙伴
            listContactPF = [SELECT Id, RecordTypeId, LastName,PF__c, Number_Partner__c, Description_of_Partner__c 
            FROM Contact Where Customer_Partner__c = :con.getId() AND RecordTypeId = :recTypePartnerID];
        }
       
    }
    public PageReference saveAction(){
		try {
		    upsert cusAP;
		}
		catch (Exception e) {
		    System.debug('The following exception has occurred: ' + e.getMessage());
            ApexPages.addMessages(e);
            return null;
		}
        System.debug('*** listBankDetail: ' + listBankDetail + '');

        //更新银行细目记录
        if (listBankDetail.size()>0) {
            List<Custom_Approval_Managed_Item__c> lstUpdatedBankDetail = new List<Custom_Approval_Managed_Item__c>();
            for (Custom_Approval_Managed_Item__c cami : listBankDetail) {
                cami.Customer_Bank__c = cusAP.Id;
                cami.RecordTypeId = recTypeBankDetailID;
                lstUpdatedBankDetail.add(cami);
            }
            //update lstUpdatedBankDetail;
            System.debug('*** lstUpdatedBankDetail: ' + lstUpdatedBankDetail + '');
            upsert lstUpdatedBankDetail;
        }
         //更新税收记录
        if (listTaxType.size()>0) {
            List<Custom_Approval_Managed_Item__c> lstUpdatedTax = new List<Custom_Approval_Managed_Item__c>();
            for (Custom_Approval_Managed_Item__c cami : listTaxType) {
                cami.Customer_Tax__c = cusAP.Id;
                cami.RecordTypeId = recTypeTaxID;
                lstUpdatedTax.add(cami);
            }
            //update lstUpdatedBankDetail;
            System.debug('*** lstUpdatedTax: ' + lstUpdatedTax + '');
            try {
            upsert lstUpdatedTax;
             }
            catch (Exception e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
            ApexPages.addMessages(e);
            return null;
            }
        }
        //更新联系人记录
        if (listContact.size()>0) {

            List<Contact> lstUpdatedContact = new List<Contact>();
            for (Contact cnt : listContact) {
                cnt.Customer_Contact__c = cusAP.Id;
                cnt.RecordTypeId = recTypeContactID;
                lstUpdatedContact.add(cnt);
            }
            try {
            upsert lstUpdatedContact;
             }
            catch (Exception e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
            ApexPages.addMessages(e);
            return null;
            }
        }

         //更新合作伙伴记录
        if (listContactPF.size()>0) {
            List<Contact> lstCon = [SELECT Number__c, LastName FROM Contact WHERE RecordType.DeveloperName = 'Staff'];
            Map<string,string> mapCon = new Map<string,string>();
            for (Contact con : lstCon) {
                mapCon.put(con.Number__c, con.LastName);
            }
            List<Contact> lstUpdatedPF = new List<Contact>();
            for (Contact cnt : listContactPF) {
                cnt.Customer_Partner__c = cusAP.Id;
                cnt.RecordTypeId = recTypePartnerID;
                if (String.isNotBlank(cnt.Number_Partner__c) && String.isBlank(cnt.Name) && mapCon.containsKey(cnt.Number_Partner__c)) {
                    cnt.LastName = mapcon.get(cnt.Number_Partner__c);
                }
                else{
                    cnt.LastName = cnt.Number_Partner__c;
                }
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
            return null;
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
            if (delListTaxType.size()>0) {
                DELETE delListTaxType;
            }
        }
        System.debug('*** cusAP: ' + cusAP + '');
    	return new PageReference('/' + cusAP.Id);
    }
    public PageReference cancelAction(){
    	return new PageReference('/apex/ApprovalHome?sfdc.tabName=01rO0000000Dz6T');
    }

    public PageReference addBankDetail(){
        Custom_Approval_Managed_Item__c addItem = new Custom_Approval_Managed_Item__c();
        listBankDetail.add(addItem);
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
    public PageReference addTax(){
        Custom_Approval_Managed_Item__c addItem = new Custom_Approval_Managed_Item__c();
        listTaxType.add(addItem);
        return null;
    }

 public PageReference clear(){
            cusAP = new Custom_Approval_Managed__c();

        return  null;
    }

    public PageReference removeTax(){
        if (listTaxType[rowID-1].Id != null) {
            delListTaxType.add(listTaxType[rowID-1]);
        }
        listTaxType.remove(rowID-1);
        return null;
    }
    public PageReference addContact(){
        Contact addItem = new Contact();
        listContact.add(addItem);
        System.debug('*** Add listContact: ' + listContact + '');
        return null;
    }
     public PageReference removeContact(){
        if (listContact[rowID-1].Id != null) {
            delListContact.add(listContact[rowID-1]);
        }
        listContact.remove(rowID-1);
        return null;
    }
    public PageReference addPF(){
        Contact addItem = new Contact();
        listContactPF.add(addItem);
        System.debug('*** listContactPF: ' + listContactPF + '');
        return null;
    }
     public PageReference removePF(){
        if (listContactPF[rowID-1].Id != null) {
            delListContactPF.add(listContactPF[rowID-1]);
        }
        listContactPF.remove(rowID-1);
        return null;
    }

    public Boolean displayQueryResult {get; set;}

    public List<Custom_Approval_Managed__c> camList {get; set;}

    public List<SapContentOfReturnArgs> contentList {get;set;}

    public Integer customerRow{get;set;}


    public PageReference queryCustomer() {
        //客户代码
        System.debug(LoggingLevel.INFO, '*** 进入查询: '+cusAP);
        String szCustomerCode = !String.isBlank(cusAP.Account_Number__c)?cusAP.Account_Number__c:'';
        //客户名称
        String szCustomerName = !String.isBlank(cusAP.Account_Name__c)?cusAP.Account_Name__c:'';
        if (String.isBlank(szCustomerName) && String.isBlank(szCustomerCode)) {
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.WARNING,'请至少输入一个客户代码或名称'));    
            return null;
        }
        //公司代码
        String szCorpCode =  !String.isBlank(cusAP.Corporation__c)?cusAP.Corporation__c:'';
        //销售组织
        String szSaleOrg =  !String.isBlank(cusAP.Sales_Org__c)?cusAP.Sales_Org__c:'';
        //分销渠道
        String szDistrbution =  !String.isBlank(cusAP.Distribution_Channel__c)?cusAP.Distribution_Channel__c:'';
        //产品组
        String szProduct =  !String.isBlank(cusAP.Product_Group__c)?cusAP.Product_Group__c:'';
        //科目组
        String szSubject =  !String.isBlank(cusAP.Subject_Group__c)?cusAP.Subject_Group__c:'';

        try{
            String str1 = SapQueryArgCreate.createSapCustomerArgs(szCustomerCode,szCustomerName,szCorpCode,szSaleOrg,szDistrbution,szProduct,szSubject);
            
            System.debug(str1);
            String str2 = Utils.postToSAP(str1);
            SapWebServiceReturnArgs args = null;
            args = (SapWebServiceReturnArgs)JSON.deserialize(str2, SapWebServiceReturnArgs.class);

            System.debug(LoggingLevel.INFO, '*** args: ' + args);
            camList = new List<Custom_Approval_Managed__c>();
            contentList = args.content;
            for(SapContentOfReturnArgs arg : contentList){
                Custom_Approval_Managed__c customer = (Custom_Approval_Managed__c)JSON.deserialize(JSON.serialize(arg.main), Custom_Approval_Managed__c.class);
                camList.add(customer);
            }
        }catch(Exception ex){
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage() + '\n' + ex.getStackTraceString()));    
        }
        displayQueryResult=true;
        return null;
    }
    
    public PageReference selectCustomer(){

        cusAP =  (Custom_Approval_Managed__c)JSON.deserialize(JSON.serialize(contentList.get(customerRow).main), Custom_Approval_Managed__c.class);
        cusAP.RecordTypeId = HarryUtils.getRecordTypeIdByDevNameAndObjName('Customer','Custom_Approval_Managed__c');
        cusAP.type__c = 'U';
        System.debug(LoggingLevel.INFO, '*** cusAPSelect: ' + cusAP);
        System.debug(LoggingLevel.INFO, '*** : cusAp' + cusAp);
        //因为SAP同步过来的国家，地区，省，市为代码或名字，得转化对应的ID类型
        List<Metadata__c> lstAllcounty =  [SELECT  Id, Country_Code__c FROM Metadata__c WHERE RecordType.DeveloperName = 'Country'];
        Map<String,Id>  mapAllCountry= new Map<String,Id>();
        for (Metadata__c meta: lstAllcounty) {
            mapAllCountry.put(meta.Country_Code__c, meta.Id);
        }
        Map<String,Id>  mapCountry= new Map<String,Id>();
        List<Metadata__c> lstMetaCoutry = [SELECT Name,Id FROM Metadata__c 
                        WHERE RecordType.DeveloperName = 'Privince' OR RecordType.DeveloperName = 'City'];
        for (Metadata__c m : lstMetaCoutry) {
            mapCountry.put(m.Name, m.Id);
        }
        if (String.isNotBlank(cusAP.Province_Name__c) && mapCountry.containsKey(cusap.Province_Name__c)) {
            cusAP.Province__c = mapCountry.get(cusAP.Province_Name__c);
        }
        if (String.isNotBlank(cusAP.City_Name__c) && mapCountry.containsKey(cusap.City_Name__c)) {
            cusAP.City__c = mapCountry.get(cusAP.City_Name__c);
        }
        if (String.isNotBlank(cusAP.Province_Name_of_Shopping__c) && mapCountry.containsKey(cusap.Province_Name_of_Shopping__c)) {
            cusAP.Province_of_Shopping__c = mapCountry.get(cusAP.Province_Name_of_Shopping__c);
        }
        if (String.isNotBlank(cusAP.City_Name_of_Shopping__c) && mapCountry.containsKey(cusap.City_Name_of_Shopping__c)) {
            cusAP.City_of_Shopping__c = mapCountry.get(cusAP.City_Name_of_Shopping__c);
         }
        if (String.isNotBlank(cusAP.Country_Code__c) && mapAllCountry.containsKey(cusAp.Country_Code__c)) {
            Id idCountry = mapAllCountry.get(cusap.Country_Code__c);
            cusAp.Country__c = idCountry;
            if (String.isNotBlank(cusAP.area_code__c)){
            List<Metadata__c> lstMetaArea = [SELECT Name,Id FROM Metadata__c 
                         WHERE  RecordType.DeveloperName = 'Area' AND Country__c =:idCountry];          
                if (lstMetaArea.size()>0) {
                cusAp.Area__c = lstMetaArea[0].Id;
                }
            }

         }
         
        listBankDetail = (List<Custom_Approval_Managed_Item__c>)JSON.deserialize(JSON.serialize(contentList.get(customerRow).details.get('banks')), List<Custom_Approval_Managed_Item__c>.class);
        for (Custom_Approval_Managed_Item__c cami : listBankDetail) {
            if (String.isNotBlank(cami.Country_Code__c) && mapAllCountry.containsKey(cami.Country_Code__c)) {
                cami.Country__c = mapAllCountry.get(cami.Country_Code__c);
            }
        }
        listContact = (List<Contact>)JSON.deserialize(JSON.serialize(contentList.get(customerRow).details.get('contacts')), List<Contact>.class);
        listContactPF = (List<Contact>)JSON.deserialize(JSON.serialize(contentList.get(customerRow).details.get('partners')), List<Contact>.class);
        List<Contact> lstCon = [SELECT Number__c, LastName FROM Contact WHERE RecordType.DeveloperName = 'Staff'];
        Map<string,string> mapCon = new Map<string,string>();
        for (Contact con : lstCon) {
            mapCon.put(con.Number__c, con.LastName);
        }
        for ( Contact con : listContactPF) {
            if (mapCon.containsKey(con.Number_Partner__c)) {
                con.LastName = mapCon.get(con.Number_Partner__c);
            }else{
                con.LastName = con.Number__c;
            }
        }
        listTaxType = (List<Custom_Approval_Managed_Item__c>)JSON.deserialize(JSON.serialize(contentList.get(customerRow).details.get('taxs')), List<Custom_Approval_Managed_Item__c>.class);
        //对应的国家id
        for (Custom_Approval_Managed_Item__c cami : listTaxType) {
            if (String.isNotBlank(cami.Country_Code__c) && mapAllCountry.containsKey(cami.Country_Code__c)) {
                cami.Country__c = mapAllCountry.get(cami.Country_Code__c);
            }
        }
        displayQueryResult=false;
        return null;
    }
}