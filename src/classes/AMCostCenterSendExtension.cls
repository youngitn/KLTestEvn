/**************************************************************************************************
 * Name: AccountDataController
 * Object: Custom_Approval_Managed__c
 * Purpose: 自定义成本中心发料作业维护
 * Requirement:
 * Author: zhonghui
 * Create Date: 2017-5-15
 * Modify History: 
 * 物料描述为空不能保存 BY 张旭 2017/01/10
***************************************************************************************************/
public without sharing class AMCostCenterSendExtension {
    public Custom_Approval_Managed__c cusAP{get;set;}
    public List<Custom_Approval_Managed_Item__c> listRowInfo{get;set;}//行细目列表
    public String recTypeBankDetailID = '';
    public Integer rowID {GET;SET;}   //页面子表行数
    public Integer resultRowID{GET;SET;}
    public Integer selectRow{GET;SET;}
    public List<Custom_Approval_Managed_Item__c> dellistRowInfo{get;set;}
    public List<Custom_Approval_Managed_Item__c> listQueryResult{get;set;}
    public Boolean isDeletedStatus{GET;SET;}
    public Boolean isQuery{get;set;}
     //页面字段级控制变量
    public String szAbleEditFields{get;set;}
    public Boolean isClosed{get;set;}
    public AMCostCenterSendExtension(ApexPages.StandardController con) {
        cusAP = new Custom_Approval_Managed__c();
        listRowInfo = new List<Custom_Approval_Managed_Item__c>();
        dellistRowInfo = new List<Custom_Approval_Managed_Item__c>();
        listQueryResult = new List<Custom_Approval_Managed_Item__c>();
        isDeletedStatus = false;
        isQuery = false;
        isClosed = true;
        Id recType = HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.COSTCENTERSEND, 'Custom_Approval_Managed__c');
        //用来计算页面字段级控制
        Id amId = con.getId();
        szAbleEditFields = Utils.getApprovalPageEditFields(amId,recType);
        if (!String.isBlank(szAbleEditFields)) {
            isClosed = false;
        }
        System.debug('*** con.getRecord(): ' + con.getRecord() + '!');
        //设置记录类型为成本中心发料作业
        cusAP.RecordTypeId = recType;
        //查询各子表的对应记录类型ID
        recTypeBankDetailID = HarryUtils.getRecordTypeIdByDevNameAndObjName('Dep_Cost_Center','Custom_Approval_Managed_Item__c');
        //判断是新建还是编辑
        if (con.getId() != null) {
            isDeletedStatus = true;
            //查询相应记录
            String sql = Utils.getApprovalSQL(SapApprovalEnum.COSTCENTERSEND,true);
            sql = sql + ' WHERE Id = \'' + con.getId() + '\'';
            cusAP = Database.query(sql);
             System.debug('*** cusAP: ' + cusAP + '');

             //查询银行细目子表
            listRowInfo = [SELECT Id,RecordTypeId,Material_Number__c,Qty__c, Material_Description__c, Location_of_Storage__c, Batch__c, Qty_Stock__c, Qty_Send__c, Factory__c
                          FROM Custom_Approval_Managed_Item__c  
                          Where CostCenter_Approval__c = :con.getId() AND RecordTypeId = :recTypeBankDetailID];
        }
       
    }
    public PageReference saveAction(){
           //当物料号为空时不允许保存
        for (Custom_Approval_Managed_Item__c cami : listRowInfo) {
            if (String.isBlank(cami.Material_Description__c)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, '请先查询物料号，带出物料描述'));
                return null;
            }      
        }         
        try {
            upsert cusAP;

             System.debug('*** listRowInfo: ' + listRowInfo + '');
            //更新成本中心发料作业详细记录
            if (listRowInfo.size()>0) {
                List<Custom_Approval_Managed_Item__c> lstUpdatedBankDetail = new List<Custom_Approval_Managed_Item__c>();
                for (Custom_Approval_Managed_Item__c cami : listRowInfo) {
                    cami.CostCenter_Approval__c = cusAP.Id;
                    cami.RecordTypeId = recTypeBankDetailID;
                    lstUpdatedBankDetail.add(cami);
                }
                upsert lstUpdatedBankDetail;
            }
            //当编辑删除子表时，删除对应的记录
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

    public PageReference addBankDetail(){
        Custom_Approval_Managed_Item__c addItem = new Custom_Approval_Managed_Item__c();
        if (String.isNotBlank(cusAP.Factory__c) && String.isNotBlank(cusAP.Address_of_Stock__c)) {
            addItem.Factory__c = cusAP.Factory__c;
            addItem.Location_of_Storage__c = cusAP.Address_of_Stock__c;
            addItem.Row_Index__c = String.valueOf(listRowInfo.size()+1);
        }else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, '请先输入工厂和库存地点'));
            return null;
        }

        listRowInfo.add(addItem);
        System.debug('*** listRowInfo: ' + listRowInfo + '');
        return null;
    }
    public PageReference deleteBankDetail(){
            System.debug('*** rowID: ' + rowID + '');
            if (listRowInfo[rowID-1].Id != null) {
            dellistRowInfo.add(listRowInfo[rowID-1]);
        }
            listRowInfo.remove(rowID-1);
        return null;
    }
    public PageReference queryMaterial(){
        System.debug(LoggingLevel.INFO, '*** resultRowID: ' + resultRowID);
        isQuery = true;
        Custom_Approval_Managed_Item__c item = listRowInfo[resultRowID-1];
        System.debug(LoggingLevel.INFO, '*** item: ' + item);
        if (String.isBlank(item.Material_Number__c) ) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, '先输入一个物料号码'));
            isQuery =false;
            return null;
        }
        try{
            String str1 = SapQueryArgCreate.createSapMaterialQueryArgs(item.Factory__c,item.Location_of_Storage__c,item.Material_Number__c);
            System.debug(str1);
            String str2 = Utils.postToSAP(str1);
            SapWebServiceReturnArgs args = (SapWebServiceReturnArgs)JSON.deserialize(str2, SapWebServiceReturnArgs.class);
            if (args.status != '1') {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, '查询出错:'+args.message));
                isQuery= false;
                return null;
            }
            listQueryResult = args.materialdata;
            System.debug(LoggingLevel.INFO, '*** listQueryResult: ' + listQueryResult);
        } 
        catch(Exception e){
            ApexPages.addMessages(e);
        }  

        return null;
    }
    public PageReference selectMaterial(){
        System.debug(LoggingLevel.INFO, '*** selectRow: ' + selectRow);
        isQuery = false;
        Custom_Approval_Managed_Item__c item = listQueryResult[selectRow];
        listRowInfo[resultRowID-1].Material_Description__c = item.Material_Description__c;
        listRowInfo[resultRowID-1].Batch__c = item.Batch__c;
        listRowInfo[resultRowID-1].Qty_Stock__c = item.Qty_Stock__c;
        return null;
    }

    public without sharing class SapWebServiceReturnArgs {
    //调用成功标记：1 - 表示成功，0 - 表示失败
    public String status {GET;SET;}
    //调用描述：成功为空或相关信息，失败时为失败原因信息
    public String message {GET;SET;}
    //调用返回结果
    public List<Custom_Approval_Managed_Item__c> materialdata{GET;SET;}
    }
}