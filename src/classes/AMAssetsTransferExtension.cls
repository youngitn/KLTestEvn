public with sharing class AMAssetsTransferExtension { 
    public Approval_Managed__c am{get;set;} 
    //public Boolean isDeletedStatus{GET;SET;} 
    public Approval_Managed__c am2{get;set;} 
    //public List<Approval_Managed__c>  list {get;set;} 
    public List<Approval_Managed__c>  listam = new List<Approval_Managed__c>();

    public AMAssetsTransferExtension(ApexPages.StandardController con) {
    	am = new Approval_Managed__c();
        am2 = new Approval_Managed__c();

        am.RecordTypeId = HarryUtils.getRecordTypeIdByDevNameAndObjName('AssetsTransfer','Approval_Managed__c');
    	if(con.getId() == null){
		}else{
			am = (Approval_Managed__c)con.getRecord();
		}
    }
    public PageReference save(){
    	Upsert am;
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
            System.debug(args);
            if (args.status != '1') {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, '查询出错:'+args.message));
                return null;
            }
            listam = args.materialdata;
        } 
        catch(Exception e){
            ApexPages.addMessages(e);
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
        public List<Approval_Managed__c> materialdata{GET;SET;}
    }


}