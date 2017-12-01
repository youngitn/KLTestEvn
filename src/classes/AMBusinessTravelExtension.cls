/*
    目的：自定义流程管理的出差管理流程的Extension
    作者：李忠辉
    创建时间：2017-05-03
*/
public with sharing class AMBusinessTravelExtension {
    //出差管理
    public Custom_Approval_Managed__c travelManage {Get;Set;}
    //出差管理明细集合
    public List<Custom_Approval_Managed_Item__c> travelManageItemList {Get;Set;}
    public Id recTypeDetailId {get;set;}
    public Integer rowID {GET;SET;}//页面子表行数
    public String szStartTime {GET;SET;}
    public String szEndTime {GET;SET;}
    public List<Custom_Approval_Managed_Item__c> deletetravelManageItemList{get;set;}
    public AMBusinessTravelExtension(ApexPages.StandardController con) {
        //szStartTime = '';
        //szEndTime = '';
        travelManage = new Custom_Approval_Managed__c();
        travelManageItemList = new List<Custom_Approval_Managed_Item__c>();
        deletetravelManageItemList = new List<Custom_Approval_Managed_Item__c>();
        //查询出差明细记录类型ID
        Id recTypeId = HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.BUSINESSTRAVEL, 'Custom_Approval_Managed__c');
        travelManage.RecordTypeId = recTypeId;
        //查询出差明细子项记录类型ID
        recTypeDetailId = HarryUtils.getRecordTypeIdByDevNameAndObjName('Travel_Manage', 'Custom_Approval_Managed_Item__c');
        //判断是新建还是编辑
        if (con.getId() != null) {
            //查询相应记录
            String sql = Utils.getApprovalSQL(SapApprovalEnum.BUSINESSTRAVEL,true);
            System.debug(LoggingLevel.INFO, '*** sql: ' + sql);
            sql = sql + ' WHERE Id = \'' + con.getId() + '\'';
            System.debug(LoggingLevel.INFO, '*** sql: ' + sql);
            List<Custom_Approval_Managed__c> lstItems = Database.query(sql);

            if(lstItems.size() > 0){
                travelManage = lstItems[0];
            }
            System.debug('*** travelManage: ' + travelManage + '');

             //查询内容子表
            travelManageItemList = [SELECT Id,RecordTypeId,Visit_Date__c, Corportion_Name__c, Address__c, Reason__c, Interviewee__c, Phone_of_Interviewee__c, Campaign__c FROM Custom_Approval_Managed_Item__c  Where Customer_Bank__c = :con.getId() AND RecordTypeId = :recTypeDetailId];
        }
    }
    public PageReference saveBusinessTravel(){
        //转化JS日期格式为SF日期格式
        System.debug('*** szStartTime: ' + szStartTime);
        System.debug('*** szEndTime: ' + szEndTime);
        szStartTime = szStartTime.replace('T', ' ')+':00.0800';
        szEndTime = szEndTime.replace('T', ' ')+':00.0800';
        System.debug('*** szStartTime: ' + szStartTime + '');
        System.debug('*** szEndTime: ' + szEndTime + '');
        travelManage.Start_Travel_Datetime__c = Datetime.valueOf(szStartTime);
        travelManage.Start_Travel_Date__c = Datetime.valueOf(szStartTime).format('yyyyMMdd');
        travelManage.Start_Travel_Time__c = Datetime.valueOf(szStartTime).format('HHmm');
        travelManage.End_Travel_Datetime__c = Datetime.valueOf(szEndTime);
        travelManage.End_Travel_Date__c = Datetime.valueOf(szEndTime).format('yyyyMMdd');
        travelManage.End_Travel_Time__c = Datetime.valueOf(szEndTime).format('HHmm');
        System.debug('*** : travelManage.Start_Travel_Date__c' +  travelManage.Start_Travel_Date__c+ '');
        System.debug('*** : travelManage.Start_Travel_Time__c' + travelManage.Start_Travel_Time__c + '');
        try {
            upsert travelManage;
        }
        catch (Exception e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
            ApexPages.addMessages(e);
            return null;
        }
        System.debug('*** travelManageItemList: ' + travelManageItemList + '');

        //更新银行细目记录
        if (travelManageItemList.size()>0) {
            List<Custom_Approval_Managed_Item__c> lstUpdatedDetail = new List<Custom_Approval_Managed_Item__c>();
            for (Custom_Approval_Managed_Item__c cami : travelManageItemList) {
                cami.Travel_Approval__c = travelManage.Id;
                cami.RecordTypeId = recTypeDetailId;
                lstUpdatedDetail.add(cami);
            }
            System.debug('*** lstUpdatedDetail: ' + lstUpdatedDetail + '');
            upsert lstUpdatedDetail;
        }
        //当编辑删除子表时，删除对应的记录
        if (deletetravelManageItemList.size()>0) {
            DELETE deletetravelManageItemList;
        }
        
        System.debug('*** travelManage: ' + travelManage + '');
        return new PageReference('/'+travelManage.Id);
    }
    public PageReference cancelAction(){
        return new PageReference('/apex/ApprovalHome?sfdc.tabName=01rO0000000Dz6T');
    }

    public PageReference addDetail(){
        Custom_Approval_Managed_Item__c addItem = new Custom_Approval_Managed_Item__c();
        travelManageItemList.add(addItem);
        System.debug('*** travelManageItemList: ' + travelManageItemList + '');
        return null;
    }
    public PageReference deleteDetail(){
            System.debug('*** rowID: ' + rowID + '');
            if (String.isBlank(travelManageItemList[rowID-1].Id)) {
                deletetravelManageItemList.add(travelManageItemList[rowID-1]);
            }
            travelManageItemList.remove(rowID-1);
        return null;
    }

}