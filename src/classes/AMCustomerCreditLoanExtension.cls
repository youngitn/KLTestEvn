public class AMCustomerCreditLoanExtension {     
 
    public Approval_Managed__c am {get;set;} 
    public Id amId {get; set;}
    public Boolean isDeletedStatus{get;set;}

    public AMCustomerCreditLoanExtension(ApexPages.StandardController con) {
      am = new Approval_Managed__c();
      isDeletedStatus = true; 
      Id recType = HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.CUSTOMERCREDITLOAN, 'Approval_Managed__c');
      amId = con.getId();
      if (amId != null) {
          //查询相应记录
          String sql = Utils.getApprovalSQL(SapApprovalEnum.CUSTOMERCREDITLOAN,true);
          sql = sql + ' WHERE Id = \'' + amId + '\'';
          am = Database.query(sql);
          System.debug('*** am: ' + am + '');
      }else{
          am = new Approval_Managed__c(RecordTypeId = recType);
          return;
      }

    }    
 
     public PageReference save() {

      if (String.isNotBlank(am.Account__c)) {
            list<Account> con = [SELECT AccountNumber, Name FROM Account WHERE Id = :am.Account__c];
            if (con.size() > 0) {
              am.Account_Number__c = con[0].AccountNumber;
              am.Account_Name__c = con[0].Name;
            } 
        }
        try {
            upsert am;
            System.debug(LoggingLevel.INFO, '*** am: ' + am); 
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


    public PageReference queryAccountInfo() { 
        System.debug(LoggingLevel.INFO, '*** 进入查询: '+am); 
        if (String.isBlank(am.Account__c)) {
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.WARNING,'请输入客户名称'));    
            return null;
        } 
        Account con = [SELECT Name, AccountNumber FROM Account WHERE Id = :am.Account__c ];
        try{
            String str1 = SapQueryArgCreate.createSapCreditLoanQueryDesc(con.AccountNumber,am.CreditArea__c);
            
            System.debug(str1);  
            String str2 = Utils.postToSAP(str1);
            System.debug(str2); 
            SapWebServiceReturnArgs args = (SapWebServiceReturnArgs)JSON.deserialize(str2, SapWebServiceReturnArgs.class);
            System.debug(LoggingLevel.INFO, '*** 输出反馈args: ' + args);
            Approval_Managed__c amget = (Approval_Managed__c)JSON.deserialize(JSON.serialize(args.content[0]), Approval_Managed__c.class);
            System.debug(amget); 
            am.Account_Number__c = con.AccountNumber;
            am.credit_line__c = amget.credit_line__c;
            am.Currency__c = amget.Currency__c;
            am.Amount_receivable__c = amget.Amount_receivable__c;
            am.Special_current_debt__c = amget.Special_current_debt__c;
            am.Credit_account_numbe__c = amget.Credit_account_numbe__c;
            am.Used_Credit_amount__c = amget.Used_Credit_amount__c;
            am.Sales_value__c = amget.Sales_value__c;
            // am.Credit_validity__c = amget.Credit_validity__c;
            am.Total_credit_risk__c = amget.Total_credit_risk__c;
            am.Guarantee_amount_receivable__c = amget.Guarantee_amount_receivable__c;
            am.Risk_kind__c = amget.Risk_kind__c;
            am.Risk_kind_describe__c = amget.Risk_kind_describe__c;
            am.Not_received_Amount__c = amget.Not_received_Amount__c;
            am.Overdue_amount__c = amget.Overdue_amount__c;
           
            
        }catch(Exception ex){  
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage() + '\n' + ex.getStackTraceString()));    
        }
       
        return null;
    }


     public without sharing class SapWebServiceReturnArgs {
        //调用成功标记：1 - 表示成功，0 - 表示失败
        public String status {GET;SET;}
        //调用描述：成功为空或相关信息，失败时为失败原因信息
        public String message {GET;SET;}
        //调用返回结果
        public List<Approval_Managed__c> content{GET;SET;}
    }

}