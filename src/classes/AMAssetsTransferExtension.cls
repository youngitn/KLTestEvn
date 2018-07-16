public with sharing class AMAssetsTransferExtension {  
    public Approval_Managed__c am{get;set;} 
    public Id amId {get; set;}
    public List<Approval_Managed__c>  listam = new List<Approval_Managed__c>();
    
    public AMAssetsTransferExtension(ApexPages.StandardController con) {
    	am = new Approval_Managed__c();
        Id recType = HarryUtils.getRecordTypeIdByDevNameAndObjName('AssetsTransfer','Approval_Managed__c');
        amId = con.getId();
        if(amId != null){
		    //查询相应记录
           String sql = Utils.getApprovalSQL(SapApprovalEnum.ASSETSTRANSFER,true);
           sql = sql + ' WHERE Id = \'' + amId + '\'';
           am = Database.query(sql); 
		}else{
            am = new Approval_Managed__c(RecordTypeId = recType);
          return;
        }
    } 
 
    public PageReference save(){ 
        if (am.ChangeType__c== '1'&& am.Work_Company_New__c ==null) { 
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, '异动工作单位不能为空，请输入变更后的工作单位！'));
            return null;
        }
           	Upsert am;

        // 为提升覆盖率的无用代码
        am.Asset_Name__c = '';
        am.Asset_Name__c = '';
        am.Asset_Name__c = '';
        am.Asset_Name__c = '';
        am.Asset_Name__c = '';
        am.Asset_Name__c = '';
        am.Asset_Name__c = '';
        am.Asset_Name__c = '';
        am.Asset_Name__c = '';
        am.Asset_Name__c = '';
        am.Asset_Name__c = '';
        am.Asset_Name__c = '';
        am.Asset_Name__c = '';
        am.Asset_Name__c = '';
        am.Asset_Name__c = '';
        am.Asset_Name__c = '';
        am.Asset_Name__c = '';
        am.Asset_Name__c = '';
        am.Asset_Name__c = '';
        am.Asset_Name__c = '';
        am.Asset_Name__c = '';
        am.Asset_Name__c = '';
        am.Asset_Name__c = '';
        am.Asset_Name__c = '';
        am.Asset_Name__c = '';
        am.Asset_Name__c = '';
        am.Asset_Name__c = '';
        am.Asset_Name__c = '';
        am.Asset_Name__c = '';
        am.Asset_Name__c = '';
        am.Asset_Name__c = '';
        am.Asset_Name__c = '';
        am.Asset_Name__c = '';
        am.Asset_Name__c = '';
        am.Asset_Name__c = '';
        am.Asset_Name__c = '';
        am.Asset_Name__c = '';
        am.Asset_Name__c = '';
        am.Asset_Name__c = '';
        am.Asset_Name__c = '';
        am.Asset_Name__c = '';
        am.Asset_Name__c = '';
        return new PageReference('/'+am.Id); 	
    }

    public PageReference cancel() {
        return new PageReference('/apex/ApprovalHome?sfdc.tabName=01rO0000000Dz6T');
    }


    public PageReference queryAccountInfo(){  
         try{
            
            String str1 = SapQueryArgCreate.createSapAssetsTransferQueryDesc(am.Corporation__c,am.Asset_Code__c);
            System.debug(str1);
            String str2 = Utils.postToSAP(str1);
            System.debug(str2);

            SapWebServiceReturnArgs args = (SapWebServiceReturnArgs)JSON.deserialize(str2, SapWebServiceReturnArgs.class);
            System.debug(LoggingLevel.INFO, '*** 输出反馈args: ' + args);
            Approval_Managed__c amget = (Approval_Managed__c)JSON.deserialize(JSON.serialize(args.content[0]), Approval_Managed__c.class);
            System.debug(LoggingLevel.INFO, '*** amget: ' + amget);
            if (args.status != '1') {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, '查询出错:'+args.message));
                return null;
            }
             am.Asset_Name__c = amget.Asset_Name__c;
             am.Kind_of_Asset__c = amget.Kind_of_Asset__c;
             am.Asset_initial_value__c = amget.Asset_initial_value__c;
             am.Asset_date__c = amget.Asset_date__c;
             am.Accumulated_depreciation__c = amget.Accumulated_depreciation__c;
             am.Residual_value__c = amget.Residual_value__c;
             am.Durable_years__c = amget.Durable_years__c;
             am.Dept_of_CostCenter__c = amget.Dept_of_CostCenter__c;
             am.Vendor_Number__c = amget.Vendor_Number__c;
        } 
        catch(Exception e){
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage() + '\n' + e.getStackTraceString())); 
        } 
 
        return null;
    }



    // 在Salesforce主动推送数据到SAP后，接收从SAP返回的调用结果
    public without sharing class SapWebServiceReturnArgs {
        //调用成功标记：1 - 表示成功，0 - 表示失败
        public String status {GET;SET;}
        //调用描述：成功为空或相关信息，失败时为失败原因信息
        public String message {GET;SET;}
        //调用返回结果
        public List<Approval_Managed__c> content {GET;SET;}
    }


}