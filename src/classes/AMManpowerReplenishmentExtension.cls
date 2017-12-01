public with sharing class AMManpowerReplenishmentExtension { 
    PUBLIC Approval_Managed__c am{GET;SET;}
    public List<Approval_Managed_Item__c> listDetail{get;set;}//行细目列表
    public Integer rowID {GET;SET;}//页面子表行数
    public List<Approval_Managed_Item__c> dellistRowInfo{get;set;}
    public Boolean isDeletedStatus{GET;SET;}
    public String recTypeInterviewerID = ''; 

    //构造方法 
    public AMManpowerReplenishmentExtension(ApexPages.StandardController con) {
        rowID = 1; 
        am = new Approval_Managed__c();
        listDetail = new List<Approval_Managed_Item__c>();
        dellistRowInfo = new List<Approval_Managed_Item__c>();
        isDeletedStatus = true;
 
        //设置记录类型为HR人力补充
        am.RecordTypeId = HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.MANPOWERREPLENISHMENT,'Approval_Managed__c');
        //查询子表的对应记录类型ID
        recTypeInterviewerID = HarryUtils.getRecordTypeIdByDevNameAndObjName('ManpowerReplenishment_details','Approval_Managed_Item__c');
           //判断是新建还是编辑   !null是编辑
        if (con.getId() != null) {
            isDeletedStatus = true;
            //查询相应记录
            String sql = Utils.getApprovalSQL(SapApprovalEnum.MANPOWERREPLENISHMENT,true);
            sql = sql + ' WHERE Id = \'' + con.getId() + '\'';
            am = Database.query(sql);
            //面试主管子表
            listDetail = [SELECT Id, RecordTypeId, Row_Index__c, Header_Code__c,Header_Name__c,Header__c
            FROM Approval_Managed_Item__c Where Manpower__c = :con.getId() AND RecordTypeId = :recTypeInterviewerID];
            System.debug(LoggingLevel.INFO, '*** step2: ' );

        }       
    } 
    //保存 
    public PageReference save(){
        //执行失败回滚所有操作
        System.Savepoint savepoint = Database.setSavepoint();
        try {
            System.debug(LoggingLevel.INFO, '*** Step0: ' + '');
            upsert am;
            Map<id,Contact> mapContact = new Map<id,Contact>([SELECT Id, Name, Number__c FROM Contact WHERE RecordType.DeveloperName = 'Staff']) ;
            Integer count = 1;
            for (Approval_Managed_Item__c ami : listDetail ) {
                if (String.isNotBlank(ami.Header__c) && mapContact.containsKey(ami.Header__c)) {
                    ami.Header_Code__c = mapContact.get(ami.Header__c).Number__c;
                    ami.Header_Name__c = mapContact.get(ami.Header__c).Name;
                }
                ami.RecordTypeId = recTypeInterviewerID;
                //子表与主表相关联
                ami.Manpower__c = am.Id;
                ami.Row_Index__c = String.valueOf(count);
                count ++;
            }
            UPSERT listDetail;

             //当编辑删除子表时，删除对应的记录
            if (isDeletedStatus) {
                if (dellistRowInfo.size()>0) {
                    DELETE dellistRowInfo;
                }
            }
        } catch (Exception e) {
            Database.rollback(savepoint);
            System.debug('The following exception has occurred: ' + e.getMessage());
            ApexPages.addMessages(e);
            return null;
        }
      return new PageReference('/'+am.Id);
    }

    public PageReference cancel() {
        return new PageReference('/apex/ApprovalHome?sfdc.tabName=01rO0000000Dz6T');
    }
  
    //新增
    public PageReference addDetail(){ 
        Approval_Managed_Item__c addItem = new Approval_Managed_Item__c();
        addItem.Row_Index__c = String.valueOf(listDetail.size()+1);
        additem.RecordTypeId = recTypeInterviewerID;
        listDetail.add(addItem);
        System.debug('*** listDetail: ' + recTypeInterviewerID);
        System.debug(LoggingLevel.INFO, '*** listDetail.size(): ' + listDetail.size()); 
        return null;
    }

    //删除
    public PageReference deleteDetail(){
        if (listDetail[rowID-1].Id != null) {
            dellistRowInfo.add(listDetail[rowID-1]);
        }
        listDetail.remove(rowID-1);
        return null;
    }  


  
}