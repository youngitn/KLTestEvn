public with sharing class AMInventoryProcessExtension {
    PUBLIC Approval_Managed2__c am{GET;SET;}
    public Integer rowID {GET;SET;}//页面子表行数
    public List<Custom_Approval_Managed_Item__c> listDetail{get;set;}//行细目列表
    public List<Custom_Approval_Managed_Item__c> delListItemDetail{get;set;}
    public Boolean isDeletedStatus{GET;SET;}
    public String recTypeDetailID = '';

    public Integer resultRowID{GET;SET;}//物料結果行數
    public Boolean isQuery{get;set;}
    public List<Custom_Approval_Managed_Item__c> listQueryResult{get;set;}//查詢結果
    public Integer selectRow{GET;SET;}//選擇行

    public AMInventoryProcessExtension(ApexPages.StandardController con) {
        rowID = 0;
        am = new Approval_Managed2__c();
        listDetail = new List<Custom_Approval_Managed_Item__c>();
        delListItemDetail = new List<Custom_Approval_Managed_Item__c>();
        isDeletedStatus = true;
        Id recType = HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.INVENTORYPROCESS,'Approval_Managed2__c');
        System.debug('*** con.getRecord(): ' + con.getRecord() + '!');
        //设置记录类型为盤盈虧
        am.RecordTypeId = recType;
        //查询各子表的对应记录类型ID
        recTypeDetailID = HarryUtils.getRecordTypeIdByDevNameAndObjName('INVItem_Detail','Custom_Approval_Managed_Item__c');
        //判断是新建还是编辑
        if (con.getId() != null) {
            isDeletedStatus = true;
            //查询相应记录
            String sql = Utils.getApprovalSQL(SapApprovalEnum.INVENTORYPROCESS,true);
            sql = sql + ' WHERE Id = \'' + con.getId() + '\'';
            am = Database.query(sql);
            System.debug('*** am: ' + am + '');

             //查询细目子表
            listDetail = [SELECT Id, RecordTypeId, INVApply_Info__c, Row_Index__c, INV_GAIN_LOST__c, Material_Number__c, Material_Description__c, Inventory_Location__c, Storage_Grid__c, Batch_On_Account__c, Qty__c, Furnace_Number__c
                   		  FROM Custom_Approval_Managed_Item__c 
                    	  WHERE INVApply_Info__c = :con.getId() AND RecordType.DeveloperName = :recTypeDetailID];
        }
    }

    public PageReference save(){       
        //当物料号为空时不允许保存
        for (Custom_Approval_Managed_Item__c cami : listDetail) {
            if (String.isBlank(cami.Material_Description__c)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, '請先查詢物料編號，帶出物料描述'));
                return null;
            }      
        } 
        try {
            // am.RecordTypeId = HarryUtils.getRecordTypeIdByDevNameAndObjName('InventoryProcess','Approval_Managed2__c');
       	    Upsert am;
       	 	 
            System.debug('*** listDetail: ' + listDetail + '');
            //更新盤盈虧详细记录
            if (listDetail.size()>0) {
                List<Custom_Approval_Managed_Item__c> lstUpdatedDetail = new List<Custom_Approval_Managed_Item__c>();
                for (Custom_Approval_Managed_Item__c cami : listDetail) {
                    cami.INVApply_Info__c = am.Id;
                    cami.RecordTypeId = recTypeDetailID;
                    lstUpdatedDetail.add(cami);
                }
                System.debug('*** lstUpdatedDetail: ' + lstUpdatedDetail + '');
                Upsert lstUpdatedDetail;
             } 
            //当编辑删除子表时，删除对应的记录
            if (isDeletedStatus) {
                if (delListItemDetail.size()>0) {
                    DELETE delListItemDetail;
                }
            }
        }
        catch (Exception e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
            ApexPages.addMessages(e);
            return null;
        }
        System.debug('*** inventoryExtension: ' + am + '');
        return new PageReference('/'+ am.Id);
    }
    public PageReference cancel(){
        return new PageReference('/apex/ApprovalHome?sfdc.tabName=01rO0000000Dz6T');
    }
    
    public PageReference addDetail(){
        Custom_Approval_Managed_Item__c addItem = new Custom_Approval_Managed_Item__c();
        addItem.Row_Index__c = String.valueOf(listDetail.size()+1);
        listDetail.add(addItem);
        System.debug('*** listDetail: ' + listDetail + '');
        return null;
    }
    public PageReference deleteDetail(){
            System.debug('*** rowID: ' + rowID + '');
            if (listDetail[rowID-1].Id != null) {
                delListItemDetail.add(listDetail[rowID-1]);
        }
            listDetail.remove(rowID-1);
        return null;
    }

    //撈物料資訊
    public PageReference queryMaterial(){
        System.debug(LoggingLevel.INFO, '*** resultRowID: ' + resultRowID);
        isQuery = true;
        Custom_Approval_Managed_Item__c item = listDetail[resultRowID-1];
        System.debug(LoggingLevel.INFO, '*** item: ' + item);
        if (String.isBlank(item.Material_Number__c) ) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, '請輸入物料編號'));
            isQuery =false;
            return null;
        }
        try{
            String str1 = SapQueryArgCreate.createSapMaterialQueryDesc(item.Material_Number__c);
            System.debug(str1);
            String str2 = Utils.postToSAP(str1);
            SapWebServiceReturnArgs args = (SapWebServiceReturnArgs)JSON.deserialize(str2, SapWebServiceReturnArgs.class);
            if (args.status != '1') {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, '查詢錯誤: '+args.message));
                isQuery= false;
                return null;
            }
            listQueryResult = args.materialdata;
            System.debug(LoggingLevel.INFO, '*** listQueryResult: ' + listQueryResult);        
        } 
        catch(Exception e) {
            System.debug('*** ----->'+e);
            ApexPages.addMessages(e);
        }

        //除錯
        // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, '查詢結果: '+listQueryResult));
        // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, '查詢結果長度: '+listQueryResult.size()));
        
        // 判斷結果是否為單筆
        if(listQueryResult.size() == 1) {
            islistOne();
        }
        return null;
    }
    // 若回傳一筆則直接填入，若回傳多筆則以選擇填入
    public PageReference  islistOne() {
        // if (listQueryResult.size() == 1 ) {
            // isQuery = false;
            Custom_Approval_Managed_Item__c newitem = listQueryResult[0];
            listDetail[resultRowID-1].Material_Description__c = newitem.Material_Description__c;            
        // }
        return null;
    }
    //選擇物料
    public PageReference selectMaterial(){
        System.debug(LoggingLevel.INFO, '*** selectRow: ' + selectRow);
        isQuery = false;
        Custom_Approval_Managed_Item__c item = listQueryResult[selectRow];
        listDetail[resultRowID-1].Material_Description__c = item.Material_Description__c;
        listDetail[resultRowID-1].Material_Number__c = item.Material_Number__c;
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