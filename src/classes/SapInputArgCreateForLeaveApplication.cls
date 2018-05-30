public with sharing class SapInputArgCreateForLeaveApplication {
	//员工请假
    //创建传送给SAP Web Service的请假参数STEP1
    public static String createSapAmleaveInputArgs(String amleaveId){
        String sql = 'Select ' + SObjectUtils.getAllFields('Approval_Managed__c').get('Approval_Managed__c')+' from Approval_Managed__c ' ;
        sql = sql + ' WHERE Id = \'' + amleaveId + '\'';
        System.debug(sql);
        List<Approval_Managed__c> lstItems = Database.query(sql);
        
        if(lstItems.size() > 0){
            return createSapAmleaveInputArgs(lstItems.get(0));
        }else{
            return '';
        }
    }
    //创建传送给SAP Web Service的请假参数STEP2
    //20180420 select 增加 TypesOfLeave__c 台灣假別代碼欄位
    public static String createSapAmleaveInputArgs(Approval_Managed__c amleave){
        List<Approval_Managed_Item__c> items = 
       [SELECT Id,SAPID__c,Leave_type__c,TypesOfLeave__c,Leave_reason__c,Start_date__c,Start_Time__c,End_date__c,End_Time__c
        FROM Approval_Managed_Item__c 
             WHERE LeaveManage__c = :amleave.Id];
        
            System.debug('*** xxxxxxxxxxx：' + amleave.Id);
            System.debug(LoggingLevel.INFO, '*** items: ' + items);
        return createSapAmleaveInputArgs(amleave,items);
    }
    //创建传送给SAP Web Service的请假参数STEP3
    public static String createSapAmleaveInputArgs(Approval_Managed__c amleave,List<Approval_Managed_Item__c> items){
        String strArgs = '';
        try{
            Map<String,String> main = Utils.convertSObjectToMap(amleave);
            System.debug('*** main' + main);
            Map<String,List<Map<String,String>>> details = new Map<String,List<Map<String,String>>>();

            if(items != null){
                List<Map<String,String>> lstItems = new List<Map<String,String>>();
                for(Approval_Managed_Item__c item : items){
                    lstItems.add(Utils.convertSObjectToMap(item));
                }
                details.put('items', lstItems);
            }

            System.debug(LoggingLevel.INFO, '*** step3: ');
            String operate = 'INSERT';
            strArgs = Utils.serializeToJson(operate,SapApprovalEnum.LEAVE,main,details);
        }catch(Exception ex){
            System.debug('*** 生成员工请假推送参数错误：' + ex.getMessage() + '\n' + ex.getStackTraceString());
        }

        return strArgs;
    }
}