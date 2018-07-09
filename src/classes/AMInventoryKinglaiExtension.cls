public with sharing class AMInventoryKinglaiExtension { 
    PUBLIC Approval_Managed__c am{GET;SET;}
    public List<Approval_Managed_Item__c> listDetail{GET;SET;}//行细目列表 
    public List<Approval_Managed_Item__c> listson{GET;SET;}//子行细目列表 
    public Integer rowID {GET;SET;}//页面子表行数
    public List<Approval_Managed_Item__c> dellistDetail{GET;SET;}
    public Boolean isDeletedStatus{GET;SET;} 
    public String recTypeInterviewerID = ''; 
    public Integer selectRow{GET;SET;} 
    public Integer resultRowID{GET;SET;}  

    //构造方法  
    public AMInventoryKinglaiExtension(ApexPages.StandardController con) {
        rowID = 1; 
        am = new Approval_Managed__c();
        listson = new List<Approval_Managed_Item__c>();
        listDetail = new List<Approval_Managed_Item__c>();
        dellistDetail = new List<Approval_Managed_Item__c>();
        isDeletedStatus = false;
  
        //设置记录类型为盘盈盘亏 
        am.RecordTypeId = HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.INVENTORYKINGLAI,'Approval_Managed__c');
        //查询子表的对应记录类型ID
        recTypeInterviewerID = HarryUtils.getRecordTypeIdByDevNameAndObjName('InventoryKinglai_son','Approval_Managed_Item__c');
           //判断是新建还是编辑   !null是编辑
        if (con.getId() != null) {
            isDeletedStatus = true;
            //查询相应记录
            String sql = Utils.getApprovalSQL(SapApprovalEnum.INVENTORYKINGLAI,true);
            sql = sql + ' WHERE Id = \'' + con.getId() + '\'';
            am = Database.query(sql);
            //盘盈盘亏子表
            listDetail = [SELECT Id, RecordTypeId, Row_Index__c, Material_Number__c,Material_Description__c,Storage__c,batch__c,Quantity__c,Tprice__c,Amount_Price__c
            FROM Approval_Managed_Item__c 
            Where InventoryKinglai_table__c = :con.getId() AND RecordTypeId = :recTypeInterviewerID];
            System.debug(LoggingLevel.INFO, '*** step2: ' );
            System.debug('listDetail:'+ listDetail);


        }       
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
        System.debug('*** rowID: ' + rowID);
        if (listDetail[rowID-1].Id != null) {
            dellistDetail.add(listDetail[rowID-1]);
        }
        listDetail.remove(rowID-1);
        return null;
    }  

    public PageReference queryMaterial(){
        System.debug('*** resultRowID: ' + resultRowID);
        System.debug(LoggingLevel.INFO, '*** resultRowID: ' + resultRowID);
        isDeletedStatus = true;
        Approval_Managed_Item__c amic = listDetail[resultRowID-1];
        System.debug(LoggingLevel.INFO, '*** amic: ' + amic);
        if (String.isBlank(amic.Material_Number__c) ) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, '先输入一个物料号码'));
            isDeletedStatus =false; 
            return null;
        }  
        try{
            String str1 = SapQueryArgCreate.createSapInventoryQueryDesc(am.Factory__c,amic.Material_Number__c);
            System.debug(str1);
            String str2 = Utils.postToSAP(str1);
            System.debug(str2);
            SapWebServiceReturnArgs args = (SapWebServiceReturnArgs)JSON.deserialize(str2, SapWebServiceReturnArgs.class);
            System.debug(LoggingLevel.INFO, '*** args: ' + args);
            if (args.status != '1') {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, '查询出错:'+args.message));
                isDeletedStatus= false;
                return null;
            }
            listson = args.materialdata;
            System.debug(LoggingLevel.INFO, '*** listson: ' + listson);
        } 
        catch(Exception e){
            ApexPages.addMessages(e);
        }  

        return null;
    }


    public PageReference selectMaterial(){
        System.debug(LoggingLevel.INFO, '*** listson: ' + listson);
        isDeletedStatus = false;
        Approval_Managed_Item__c item = listson[selectRow];
         System.debug(LoggingLevel.INFO, '*** selectRow: ' + selectRow);
        listDetail[resultRowID-1].Material_Description__c = item.Material_Description__c;
        return null;
    }
  


  public PageReference save(){ 
  //当物料号为空时不允许保存
    for (Approval_Managed_Item__c amic : listDetail) {
        if (String.isBlank(amic.Material_Description__c)) { 
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, '请先查询物料号，带出物料描述'));
            return null;
        }      
    }           
     try {
            upsert am;

            System.debug('*** listDetail: ' + listDetail + '');
            //更新盘盈盘亏详细记录
            if (listDetail.size()>0) {
                List<Approval_Managed_Item__c> lstUpdatedBankDetail = new List<Approval_Managed_Item__c>();
                for (Approval_Managed_Item__c amic : listDetail) {
                    amic.InventoryKinglai_table__c = am.Id;
                    amic.RecordTypeId = recTypeInterviewerID;
                    amic.Amount_Price__c = amic.Quantity__c*amic.Tprice__c;
                    lstUpdatedBankDetail.add(amic);
                }
                upsert lstUpdatedBankDetail;
            }
            //当编辑删除子表时，删除对应的记录
            if (isDeletedStatus) {
                if (dellistDetail.size()>0) {
                    DELETE dellistDetail;
                }
            }
        }
        catch (Exception e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
            ApexPages.addMessages(e);
            return null;
        }
        System.debug('*** am: ' + am + '');
        return new PageReference('/'+am.Id);

    }


    public without sharing class SapWebServiceReturnArgs {
        //调用成功标记：1 - 表示成功，0 - 表示失败
        public String status {GET;SET;}
        //调用描述：成功为空或相关信息，失败时为失败原因信息
        public String message {GET;SET;}
        //调用返回结果
        public List<Approval_Managed_Item__c> materialdata{GET;SET;}
    }
}