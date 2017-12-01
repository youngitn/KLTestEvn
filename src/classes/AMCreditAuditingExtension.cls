public without sharing class AMCreditAuditingExtension {
    public Approval_Managed1__c cusAP{get;set;}
    public List<Custom_Approval_Managed_Item__c> listRowInfo{get;set;}//行细目列表
    public String recTypeBankDetailID = '';
    public Integer rowID {GET;SET;}   //頁面子表行數
    public Integer resultRowID{GET;SET;}
    public Integer selectRow{GET;SET;}
    public List<Custom_Approval_Managed_Item__c> dellistRowInfo{get;set;}
    public List<Custom_Approval_Managed_Item__c> delListItemDetail{get;set;}
    public List<Custom_Approval_Managed_Item__c> listQueryResult{get;set;}
    public Boolean isDeletedStatus{GET;SET;}
    public Boolean isQuery{get;set;}
    public AMCreditAuditingExtension(ApexPages.StandardController con) {
        cusAP = new Approval_Managed1__c();
        listRowInfo = new List<Custom_Approval_Managed_Item__c>();
        dellistRowInfo = new List<Custom_Approval_Managed_Item__c>();
        listQueryResult = new List<Custom_Approval_Managed_Item__c>();
        isDeletedStatus = false;
        isQuery = false;
        System.debug('*** con.getRecord(): ' + con.getRecord() + '!');
        //設置紀錄類行為
        cusAP.RecordTypeId = HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.CREDITAUDITING,'Approval_Managed1__c');
        //查询各子表的對應紀錄類型ID
        recTypeBankDetailID = HarryUtils.getRecordTypeIdByDevNameAndObjName('CreditAuditing','Custom_Approval_Managed_Item__c');
        //判断是新建還是編輯
        if (con.getId() != null) {
            isDeletedStatus = true;
            //查詢相應記錄
            String sql = Utils.getApprovalSQL(SapApprovalEnum.CREDITAUDITING,true);
            sql = sql + ' WHERE Id = \'' + con.getId() + '\'';
            cusAP = Database.query(sql);
             System.debug('*** cusAP: ' + cusAP + '');

             //查銀行细目子表
            listRowInfo = [SELECT Id,RecordTypeId,Sales_name__c,Customer_code__c,Customer_name__c,Risk_category__c
                                 ,Total_amount_receivable__c,Overdue_amount__c
                                 ,Estimated_amount__c,Overdue_proportion__c,Letter_limit__c
                                 ,Open_amount__c,Prepayment_conditions__c,order_amount__c
                                 ,Purchase_Order_Number__c,Prepaid_accounts__c
                                 ,Processing_opinion_description__c,Reasons_for_refusal__c
                                 ,Reason_Notes__c,Row_Index__c
                          FROM Custom_Approval_Managed_Item__c  
                          Where Customer_credit__c = :con.getId() AND RecordTypeId = :recTypeBankDetailID];
        }
       
    }
    public PageReference saveAction(){
        //   當銷售憑證為空時不允許保存
         for (Custom_Approval_Managed_Item__c cami : listRowInfo) {
             if (String.isBlank(cami.Customer_code__c)) {
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, '請先查詢銷售憑證,帶出客戶'));
                 return null;
            }      
         }         
        try {
            upsert cusAP;

             System.debug('*** listRowInfo: ' + listRowInfo + '');
            //更新
            if (listRowInfo.size()>0) {
                List<Custom_Approval_Managed_Item__c> lstUpdatedBankDetail = new List<Custom_Approval_Managed_Item__c>();
                for (Custom_Approval_Managed_Item__c cami : listRowInfo) {
                    cami.Customer_credit__c = cusAP.Id;
                    cami.RecordTypeId = recTypeBankDetailID;
                    lstUpdatedBankDetail.add(cami);
                }
                upsert lstUpdatedBankDetail;
            }
            //當编辑删除子表時，删除對應的紀錄
            if (isDeletedStatus) {
                if (dellistRowInfo.size()>0) {
                    DELETE dellistRowInfo;
                }
            }
        }
        catch (Exception e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
            ApexPages.addMessages(e);
            return null;
        }
        System.debug('*** cusAP: ' + cusAP + '');
        return new PageReference('/'+cusAP.Id);
    }
    public PageReference cancelAction(){
        return new PageReference('/apex/ApprovalHome?sfdc.tabName=01rO0000000Dz6T');
    }
public PageReference addDetail(){
        Custom_Approval_Managed_Item__c addItem = new Custom_Approval_Managed_Item__c();
        listRowInfo.add(addItem);
        System.debug('*** listRowInfo: ' + listRowInfo + '');
        return null;
    }

   public PageReference deleteDetail(){
            System.debug('*** rowID: ' + rowID + '');
            if (listRowInfo[rowID-1].Id != null) {
               dellistRowInfo.add(listRowInfo[rowID-1]);
        }
            listRowInfo.remove(rowID-1);
        return null;
    
    }
    public PageReference queryClient(){
        System.debug(LoggingLevel.INFO, '*** resultRowID: ' + resultRowID);
        isQuery = true;
        Custom_Approval_Managed_Item__c item = listRowInfo[resultRowID-1];
        System.debug(LoggingLevel.INFO, '*** item: ' + item);
        if (String.isBlank(item.Sales_name__c) ) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, '先输入一個銷售憑證'));
            isQuery =false;
            return null;
        }
        try{
            String str1 = SapQueryArgCreate.createSapClientQueryArgs(item.Sales_name__c);
            System.debug(str1);
            String str2 = Utils.postToSAP(str1);
            SapWebServiceReturnArgs args = (SapWebServiceReturnArgs)JSON.deserialize(str2, SapWebServiceReturnArgs.class);
            if (args.status != '1') {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, '查询出错:'+args.message));
                isQuery= false;
                return null;
            }
            listQueryResult = args.clientdata;
            System.debug(LoggingLevel.INFO, '*** listQueryResult: ' + listQueryResult);
        } 
        catch(Exception e){
            ApexPages.addMessages(e);
        }  
  
        
        return null;
    }
    public PageReference selectClient(){
        System.debug(LoggingLevel.INFO, '*** selectRow: ' + selectRow);
        isQuery = false;
        Custom_Approval_Managed_Item__c item = listQueryResult[selectRow];
        listRowInfo[resultRowID-1].Sales_name__c = item.Sales_name__c;
        listRowInfo[resultRowID-1].Customer_code__c = item.Customer_code__c;
        listRowInfo[resultRowID-1].Customer_name__c = item.Customer_name__c;
        listRowInfo[resultRowID-1].Risk_category__c = item.Risk_category__c;
        listRowInfo[resultRowID-1].Total_amount_receivable__c = item.Total_amount_receivable__c;
        listRowInfo[resultRowID-1].Overdue_amount__c = item.Overdue_amount__c;
        listRowInfo[resultRowID-1].Estimated_amount__c = item.Estimated_amount__c;
        listRowInfo[resultRowID-1].Overdue_proportion__c = item.Overdue_proportion__c;
        listRowInfo[resultRowID-1].Letter_limit__c = item.Letter_limit__c;
        listRowInfo[resultRowID-1].Open_amount__c = item.Open_amount__c;
        listRowInfo[resultRowID-1].Prepayment_conditions__c = item.Prepayment_conditions__c;
        listRowInfo[resultRowID-1].order_amount__c = item.order_amount__c;
        listRowInfo[resultRowID-1].Purchase_Order_Number__c = item.Purchase_Order_Number__c;
        listRowInfo[resultRowID-1].Prepaid_accounts__c = item.Prepaid_accounts__c;
        return null;
    }

    public without sharing class SapWebServiceReturnArgs {
    //调用成功标记：1 - 表示成功，0 - 表示失败
    public String status {GET;SET;}
    //调用描述：成功为空或相关信息，失败时为失败原因信息
    public String message {GET;SET;}
    //调用返回结果
    public List<Custom_Approval_Managed_Item__c> clientdata{GET;SET;}
    }
}