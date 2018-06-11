public with sharing class AMSalesReturnExtension {

public Custom_Approval_Managed__c am {get; set;}

    public Id amId {get; set;}
    public List<Custom_Approval_Managed_Item__c> list1 {get; set;}
    public Integer list1Row {get; set;}
    //明细记录类型ID
    private Id recTypeDetailId = null;

    public AMSalesReturnExtension(ApexPages.StandardController con) {

        recTypeDetailId = HarryUtils.getRecordTypeIdByDevNameAndObjName('SALESRETURNDETAILS','Custom_Approval_Managed_Item__c');
        System.debug(LoggingLevel.INFO, '*** recTypeDetailId1: ' + recTypeDetailId);
        list1Row = 0;
        amId = con.getId();
        System.debug(LoggingLevel.INFO, '*** con.getId: ' + con.getId());
        System.debug(LoggingLevel.INFO, '*** amId: ' + amId);
        
        if (isInsert()) {
            am = new Custom_Approval_Managed__c();
            am.RecordTypeId = HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.SALESRETURN, 'Custom_Approval_Managed__c');
            list1 = new List<Custom_Approval_Managed_Item__c>();
            return;
        }

        //获取到当前记录信息，目标获取后跳转到自定义PAGE里面有这条数据
        String sql = Utils.getApprovalSQL(SapApprovalEnum.SALESRETURN, true);
        sql = sql + ' WHERE Id = \'' + amId + '\'';
        am = Database.query(sql);

        list1 = [SELECT RecordTypeId,SALESRETURN_DETAILS__c,Index_Item__c,Material_Number__c,Material_Description__c,Qty__c,Batch__c,Unit__c,IS_GOODS__c,FIX_NO__c,FIX_NUMBER__c,IS_SCRAP__c,SCRAP_NUMBER__c,ALLOCATE_NO__c  FROM Custom_Approval_Managed_Item__c 
                  WHERE SALESRETURN_DETAILS__c = :amid AND RecordType.DeveloperName = 'SALESRETURNDETAILS'];

    }

    public PageReference save() {

        try {

            if (am.SAP_STATUS__c <> 'X') {
                ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.WARNING,'对应销售订单尚未审批'));    
                return null;
            }

            if (string.isBlank(am.Approval_User2__c)) {
                am.Approval_User2__c = am.Approval_User1__c;
            }

            if (string.isBlank(am.Approval_User4__c)) {
                am.Approval_User4__c = am.Approval_User3__c;
            }

            if (string.isBlank(am.Approval_User5__c)) {
                am.Approval_User5__c = am.Approval_User3__c;
            }

            if (string.isBlank(am.Approval_User6__c)) {
                am.Approval_User6__c = am.Approval_User3__c;
            }

            upsert am;
            am.IS_SCRAP__c = false;
            System.debug(LoggingLevel.INFO, '*** am: ' + am);
            for (Custom_Approval_Managed_Item__c ami : list1) {
                ami.RecordTypeId = recTypeDetailId;
                ami.SALESRETURN_DETAILS__c = am.Id;
                am.Head_description__c = '物料号：' + ami.Material_Number__c ;
                if (ami.IS_SCRAP__c) {
                    am.IS_SCRAP__c = true;
                }
            }

            upsert list1;
            upsert am;
        }
        catch (Exception e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
            ApexPages.addMessages(e);
            return null;
        }
        System.debug(LoggingLevel.INFO, '*** am.Id: ' + am.Id);
        return new PageReference('/' + am.Id);

	
    } 

    public PageReference cancel() {
        return new PageReference('/apex/ApprovalHome?sfdc.tabName=01rO0000000Dz6T');
    }
    
    public Boolean isInsert() {
        return amId == null;
    }

    public PageReference querySalesReturn() {
        System.debug(LoggingLevel.INFO, '*** 进入查询: '+am);
        if (String.isBlank(am.Bill_No__c)) {
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.WARNING,'请输入交货单号'));    
            return null;
        }
        if (am.Approval_Status__c == 'A') {
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.WARNING,'已通过的单据不允许再次查询'));    
            return null;
        }
        try{
            //拼接对应的JSON数据
            String strJson = '{\"approval\":\"ZSALESFORCE_SD_RETURN_QUERY\",\"VBELN\":\"' +
                              am.Bill_No__c + '\",\"STATUS\":\"' + am.SAP_STATUS__c + '\"}';
            //获取对应的SAP异常信息
            HttpRest httprest = new HttpRest();
            String str2 = httprest.HttpPostSap(strJson);  
            SapWebServiceReturnArgs args = (SapWebServiceReturnArgs)JSON.deserialize(str2, SapWebServiceReturnArgs.class);
            System.debug(LoggingLevel.INFO, '*** args: ' + args);

            Custom_Approval_Managed__c amget = (Custom_Approval_Managed__c)JSON.deserialize(JSON.serialize(args.content[0].main), Custom_Approval_Managed__c.class);
            am.SAP_STATUS__c  = amget.SAP_STATUS__c;

            list1 = (list<Custom_Approval_Managed_Item__c>)JSON.deserialize(JSON.serialize(args.content[0].details.get('lips')), list<Custom_Approval_Managed_Item__c>.class);

        }catch(Exception ex){
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage() + '\n' + ex.getStackTraceString()));    
        }
        return null;
    }

    
}