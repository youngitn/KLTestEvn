public with sharing class AMRFQExtension { 

    public Id amId {get; set;}	
    public String recTypeInterviewerID = ''; 
    public Custom_Approval_Managed__c am{get;set;} 
    public List<Custom_Approval_Managed_Item__c> listDetail{GET;SET;}//行细目列表 
   
    public AMRFQExtension(ApexPages.StandardController con) { 
        amId = con.getId();
        listDetail = new List<Custom_Approval_Managed_Item__c>();
        Id recType = HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.RFQ, 'Custom_Approval_Managed__c');
        //查询子表的对应记录类型ID
        recTypeInterviewerID = HarryUtils.getRecordTypeIdByDevNameAndObjName('RFQson','Custom_Approval_Managed_Item__c');
        if (amId == null) {
            am = new Custom_Approval_Managed__c(RecordTypeId = recType);
            return;
        }
        String sql = Utils.getApprovalSQL(SapApprovalEnum.RFQ,true);
        sql = sql + ' WHERE Id = \'' + amId + '\'';
        am = Database.query(sql); 

        //RFQ子表
        listDetail = [SELECT Id, RecordTypeId, Row_Index__c, Inquiry_name__c,standard__c,requirement__c,Quantity__c,F_price__c,OfferInstructions__c,CustomerDrawing__c,SurfaceTreatment__c,specification__c,Material__c,Unit__c,Remark__c
        FROM Custom_Approval_Managed_Item__c 
        Where RFQsontab__c = :con.getId() AND RecordTypeId = :recTypeInterviewerID];
    
    }

    public PageReference save(){
        Upsert am;
        return new PageReference('/'+am.Id);
    }

    public PageReference cancel() {
        return new PageReference('/apex/ApprovalHome?sfdc.tabName=01rO0000000Dz6T');
    }


}