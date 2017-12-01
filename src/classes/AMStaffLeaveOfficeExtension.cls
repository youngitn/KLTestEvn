//员工主动离职流程

public with sharing class AMStaffLeaveOfficeExtension {
        
    public Approval_Managed__c am {get; set;}

    public Id amId {get; set;}
    //页面字段级控制变量
    public String szAbleEditFields{get;set;}
    public Boolean isClosed{get;set;}
    public AMStaffLeaveOfficeExtension(ApexPages.StandardController con) {
        amId = con.getId();
        isClosed = true;
        Id recType = HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.STAFFLEAVEOFFICE, 'Approval_Managed__c');
        //用来计算页面字段级控制
        szAbleEditFields = Utils.getApprovalPageEditFields(amId,recType);
        if (!String.isBlank(szAbleEditFields)) {
            isClosed = false;
        }
        if (amId == null) {
            am = new Approval_Managed__c(RecordTypeId = recType);
            am.Question_1__c = '1.你对公司总的感觉如何？ \r\n答1:\r\n \r\n2.你得到有关你的工作表现的反馈了吗？你工作中反应的问题主管能给予满意的答复吗？\r\n \r\n3.你对薪资报酬感觉如何？\r\n \r\n4.你认为我们的福利计划如何？还需作什么改进？\r\n \r\n5.你认为工作环境为你的工作创造了良好的条件吗？\r\n \r\n6.在工作中你与同事合作得怎么样？\r\n \r\n7.你即将找到的工作，是自己主动应聘的还是公司主动找到你的？\r\n \r\n8.是什么使你想到辞职？我们可以做些什么，你仍然会留在我们公司？';
            return;
        }
        String sql = Utils.getApprovalSQL(SapApprovalEnum.STAFFLEAVEOFFICE,true);
        sql = sql + ' WHERE Id = \'' + amId + '\'';
        am = Database.query(sql);
    }
    
    public PageReference save() {
        if (String.isNotBlank(am.Employee__c)) {
            Contact con = [SELECT Number__c, Name , toLabel(Post_Category__c) FROM Contact WHERE Id = :am.Employee__c];
            am.Employee_Code__c = con.Number__c;
            am.Employee_Name__c = con.Name;
            am.Post_Category_Name__c = con.Post_Category__c;
        }
        try {
            upsert am;

        } catch (Exception e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
            ApexPages.addMessages(e);
            return null;
        }
        return new PageReference('/' + am.Id);
    }

    public PageReference cancel() {
        return new PageReference('/apex/ApprovalHome?sfdc.tabName=01rO0000000Dz6T');
    }
}