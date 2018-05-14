/**
 * @Process 客户单笔信贷核发申请
 * @author  杨旺
 * @Time   2018/4/19
 * 
 */

public  class AMClientApplyExtension {   
      PUBLIC Approval_Managed__c am{GET;SET;}
    public List<Approval_Managed_Item__c> listDetail{GET;SET;}//行细目列表 
  
    public List<Approval_Managed_Item__c> listson{GET;SET;}//查询列表 

    public Integer rowID {GET;SET;}//页面子表行数
   
    // 子表
    public List<Approval_Managed_Item__c> dellistDetail{GET;SET;} 
 

    public Boolean isDeletedStatus{GET;SET;}
    // 子表记录类型ID
    public String recTypeInterviewerID = '';
    public String recTypeInterviewerID2 = ''; 

    public Integer selectRow{GET;SET;} 
    public Integer resultRowID{GET;SET;}  
  
    //构造方法  
    public AMClientApplyExtension(ApexPages.StandardController con) {
        rowID = 1;
        
        am = new Approval_Managed__c();
        listson = new List<Approval_Managed_Item__c>();
        listDetail = new List<Approval_Managed_Item__c>();
    
        dellistDetail = new List<Approval_Managed_Item__c>();
    
        isDeletedStatus = false;
  
        //设置记录类型为销售定价业务
        am.RecordTypeId = HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.CLIENTAPPLY,'Approval_Managed__c');
        //查询子表的对应记录类型ID
        recTypeInterviewerID = HarryUtils.getRecordTypeIdByDevNameAndObjName('Cus_App_Son_Table','Approval_Managed_Item__c');
       
           //判断是新建还是编辑   !null是编辑
        if (con.getId() != null) { 
            isDeletedStatus = true;
            //查询相应记录
            String sql = Utils.getApprovalSQL(SapApprovalEnum.CLIENTAPPLY,true);
            sql = sql + ' WHERE Id = \'' + con.getId() + '\'';
            am = Database.query(sql);
            // 客户单笔信贷核发申请业务子表
            listDetail = [SELECT Row_Index__c, Del_Scrip__c,Ref_scrip__c,Sal_Evi__c,Customer_Code__c,
            Customer_Name__c,Dan_Cus__c,Sho_AllMon__c,Ove_AllMon__c,Now_Mon__c,Ove_Perc__c,
            Cre_Quo__c,No_Mon__c,Pay_Req__c,Ord_Mon__c,Pur_Ord__c,Pre_Mon__c,Cau_Rem__c
            FROM Approval_Managed_Item__c 
            Where SalesPricing_son_table__c = :con.getId() AND RecordTypeId = :recTypeInterviewerID];
            System.debug(LoggingLevel.INFO, '*** step2: ' );
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

  


  

    public PageReference queryClientApply(){
        System.debug('*** resultRowID: ' + resultRowID);
        System.debug(LoggingLevel.INFO, '*** resultRowID: ' + resultRowID);
        isDeletedStatus = true;
        Approval_Managed_Item__c amic = listDetail[resultRowID-1];
        System.debug(LoggingLevel.INFO, '*** amic: ' + amic);
        if (String.isBlank(amic.Sal_Evi__c) ) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, '先输入一个销售凭证'));
            isDeletedStatus =false; 
            return null;
        } 
         try{
            String str1 = SapQueryArgCreate.createClientApplyQueryDesc(amic.Sal_Evi__c);
            System.debug(str1);
            String str2 = Utils.postToSAP(str1);
            System.debug(str2);
            SapWebServiceReturnArgs args = (SapWebServiceReturnArgs)JSON.deserialize(str2, SapWebServiceReturnArgs.class);
            System.debug(args);
            System.debug(LoggingLevel.INFO, '*** listDetail: ' + listDetail);
            if (args.status != '1') {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, '查询出错:'+args.message));
                isDeletedStatus= false;
                System.debug(LoggingLevel.INFO, '*** listDetail: ' + listDetail);
                return null;
            }
            listson = args.materialdata;
            System.debug(LoggingLevel.INFO, '*** listDetail: ' + listDetail);
        } 
        catch(Exception e){
            ApexPages.addMessages(e);
        } 
 
        return null;
    }


    public PageReference selectMaterial(){
        System.debug(LoggingLevel.INFO, '*** selectRow: ' + selectRow);
        isDeletedStatus = false;
        Approval_Managed_Item__c item = listson[selectRow];
        listDetail[resultRowID-1].Sal_Evi__c = item.Sal_Evi__c;
        return null;
    }
  

  public PageReference save(){ 
    /*if (am.ConditionType__c == 'PR01' && am.KeyCombination__c == '510') {
        if (String.isBlank(am.Price_Group__c)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, '价格组不能为空'));
            return null;
        }
    }*/
    
  //当物料号为空时不允许保存
    for (Approval_Managed_Item__c amic : listDetail) {
        if (String.isBlank(amic.Sal_Evi__c)) { 
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, '请先查询物料号，带出物料描述'));
            return null;
        }      
    } 

     try {
            upsert am;

            System.debug('*** listDetail: ' + listDetail + '');
            //更新详细记录
            if (listDetail.size()>0) {
                List<Approval_Managed_Item__c> lstUpdatedBankDetail = new List<Approval_Managed_Item__c>();
                for (Approval_Managed_Item__c amic : listDetail) {
                    amic.SalesPricing_son_table__c = am.Id;
                    amic.RecordTypeId = recTypeInterviewerID;
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

// 在Salesforce主动推送数据到SAP后，接收从SAP返回的调用结果
    public without sharing class SapWebServiceReturnArgs {
        //调用成功标记：1 - 表示成功，0 - 表示失败
        public String status {GET;SET;}
        //调用描述：成功为空或相关信息，失败时为失败原因信息
        public String message {GET;SET;}
        //调用返回结果
        public List<Approval_Managed_Item__c> materialdata{GET;SET;}
    }




    }