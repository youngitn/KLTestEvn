/**************************************************************************************************
 * Name: AMWasteDisposeExtension
 * Object: Custom_Approval_Managed__c
 * Purpose: 废料处理
 * Requirement:
 * Author: zhonghui
 * Create Date: 2017-5-15
 * Modify History: 
 * 
***************************************************************************************************/
public without sharing class AMWasteDisposeExtension {
    public Custom_Approval_Managed__c wasteHandle{get;set;}
    public List<Custom_Approval_Managed_Item__c> listRowInfo{get;set;}//行细目列表
    public String recTypeBankDetailID = '';
    public Integer rowID {GET;SET;}   //页面子表行数
    public List<Custom_Approval_Managed_Item__c> dellistRowInfo{get;set;}
    public Boolean isDeletedStatus{GET;SET;}
    public AMWasteDisposeExtension(ApexPages.StandardController con) {
        wasteHandle = new Custom_Approval_Managed__c();
        listRowInfo = new List<Custom_Approval_Managed_Item__c>();
        dellistRowInfo = new List<Custom_Approval_Managed_Item__c>();
        isDeletedStatus = false;
        rowID = 1; 
        System.debug('*** con.getRecord(): ' + con.getRecord() + '!');
        //设置记录类型为废料处理 
        wasteHandle.RecordTypeId = HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.WASTEDISPOSE,'Custom_Approval_Managed__c');
        System.debug(wasteHandle.RecordTypeId);
        //查询各子表的对应记录类型ID
        recTypeBankDetailID = HarryUtils.getRecordTypeIdByDevNameAndObjName('Waste_Handle','Custom_Approval_Managed_Item__c');
        //判断是新建还是编辑
        if (con.getId() != null) {
            isDeletedStatus = true;
            //查询相应记录
            String sql = Utils.getApprovalSQL(SapApprovalEnum.WASTEDISPOSE,true);
            sql = sql + ' WHERE Id = \'' + con.getId() + '\'';
            wasteHandle = Database.query(sql);
             System.debug('*** wasteHandle: ' + wasteHandle + '');

            listRowInfo = [SELECT Id,RecordTypeId,Material_Name__c,Qty__c, Weight_Actual__c, Price__c, Amount__c FROM Custom_Approval_Managed_Item__c
                          Where Waste_Approval__c = :con.getId() AND RecordTypeId = :recTypeBankDetailID];
        }
       
    }


    public PageReference saveAction(){
        try {
             System.debug('*** listRowInfo: ' + listRowInfo + '');
             upsert wasteHandle;
            //更新成本中心发料作业详细记录
            if (listRowInfo.size()>0) {
                List<Custom_Approval_Managed_Item__c> lstUpdatedBankDetail = new List<Custom_Approval_Managed_Item__c>();
                for (Custom_Approval_Managed_Item__c cami : listRowInfo) {
                    cami.Waste_Approval__c = wasteHandle.Id;
                    if (cami.Price__c != null && cami.Qty__c != null) {
                        cami.Amount__c = cami.Price__c*cami.Qty__c;
                    }
                    cami.RecordTypeId = recTypeBankDetailID;
                    lstUpdatedBankDetail.add(cami);
                    System.debug('*** lstUpdatedBankDetail: ' + lstUpdatedBankDetail + '');
                    wasteHandle.Head_description__c = cami.Material_Name__c;   //流程备注
                }

                upsert listRowInfo;
                upsert lstUpdatedBankDetail;
            } 

            upsert wasteHandle;
            System.debug('*** listRowInfo: ' + listRowInfo + '');
            
            //当编辑删除子表时，删除对应的记录
            if (isDeletedStatus) {
                if (dellistRowInfo.size()>0) {
                    DELETE dellistRowInfo;
                }
            }
            
        }catch (Exception e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
            ApexPages.addMessages(e);
            return null;
        }
        System.debug('*** wasteHandle: ' + wasteHandle + '');
        return new PageReference('/'+wasteHandle.Id);
    }


    public PageReference cancelAction(){
        return new PageReference('/apex/ApprovalHome?sfdc.tabName=01rO0000000Dz6T');
    }

    public PageReference addBankDetail(){
        Custom_Approval_Managed_Item__c addItem = new Custom_Approval_Managed_Item__c();
        addItem.Row_Index__c = String.valueOf(listRowInfo.size()+1);
        additem.RecordTypeId = recTypeBankDetailID;
        listRowInfo.add(addItem);
        System.debug('*** listRowInfo: ' + listRowInfo + '');
        return null;
    }
    public PageReference deleteRow(){
            System.debug('*** rowID: ' + rowID + '');
            if (listRowInfo[rowID-1].Id != null) {
            dellistRowInfo.add(listRowInfo[rowID-1]);
        }
            listRowInfo.remove(rowID-1);
        return null;
    }
}