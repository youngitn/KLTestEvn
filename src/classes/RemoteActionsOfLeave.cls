public with sharing class RemoteActionsOfLeave {
	
    //本不應將此動作放在此
    public static String queryVacation(String cId)
    {
        System.debug(LoggingLevel.INFO, '*** 查詢SAP特假&調休 cId: ' + cId);
        if (String.isBlank(cId))
        {
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.WARNING, '請假人不可為空'));
            return null;
        }
        System.debug('cId=' + cId);

        //use Peoples
        Contact con = Peoples.getInstance().KlAllContactMapGetById.get(cId);
        System.debug('con=' + con);
        String ret;
        try
        {
            String str1                     = createSAPQueryByEmpNum(con.Number__c,'VacationQuery');
            String str2                     = Utils.postToSAP(str1);
            SapWebServiceReturnArgs args    = (SapWebServiceReturnArgs)JSON.deserialize(str2, SapWebServiceReturnArgs.class);
            System.debug(LoggingLevel.INFO, '*** args: ' + args);
            //Approval_Managed__c amget       = (Approval_Managed__c)JSON.deserialize(JSON.serialize(args.content[0].main), Approval_Managed__c.class);
            // am.Employee_Code__c = amget.Employee_Code__c;
            // am.Annual_leave__c  = amget.Annual_leave__c;
            // am.Adjustable_vacation__c  = amget.Adjustable_vacation__c;
            ret = JSON.serialize(args.content[0].main);
        }
        catch(Exception ex)
        {
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage() + '\n' + ex.getStackTraceString()));
        }
        return ret;
    }

    //本不應將此動作放在此
    public static String queryVacationTW(String cId)
    {
        System.debug(LoggingLevel.INFO, '*** 查詢SAP特假&調休 cId: ' + cId);
        if (String.isBlank(cId))
        {
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.WARNING, '請假人不可為空'));
            return null;
        }
        System.debug('cId=' + cId);

        //use Peoples
        Contact con = Peoples.getInstance().KlAllContactMapGetById.get(cId);
        System.debug('con=' + con);
        String ret;
        try
        {
            String str1                     = createSAPQueryByEmpNum(con.Number__c,'VacationQueryTW');
            String str2                     = Utils.postToSAP(str1);
            SapWebServiceReturnArgs args    = (SapWebServiceReturnArgs)JSON.deserialize(str2, SapWebServiceReturnArgs.class);
            System.debug(LoggingLevel.INFO, '*** args: ' + args);
            //Approval_Managed__c amget       = (Approval_Managed__c)JSON.deserialize(JSON.serialize(args.content[0].main), Approval_Managed__c.class);
            // am.Employee_Code__c = amget.Employee_Code__c;
            // am.Annual_leave__c  = amget.Annual_leave__c;
            // am.Adjustable_vacation__c  = amget.Adjustable_vacation__c;
            ret = JSON.serialize(args);
        }
        catch(Exception ex)
        {
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage() + '\n' + ex.getStackTraceString()));
        }
        return ret;
    }


    public static String createSAPQueryByEmpNum(String pernr,String callSAPFuncName){
        List<Map<String,String>> lstCon = new List<Map<String,String>>();
        Integer index = 1;
        if(!String.isBlank(pernr)){
            lstCon.add(SapQueryArgCreate.createCondition(index,'Employee_Code__c','String','=',pernr));
            index = index + 1;
        }
        System.debug(LoggingLevel.INFO, '*** lstCon[0]: ' + lstCon[0]);
        return JSON.serialize(SapQueryArgCreate.createQueryArg(callSAPFuncName,lstCon));
    }

    public static String createSapLeaveApplicationInsertArgs(Approval_Managed__c master,List<Approval_Managed_Item__c> details){
        String strArgs = '';
        try{
            //請假單表頭
            Map<String,String> main = convertSObjectToMap(master);
            System.debug('*** main' + main);
            Integer i = 0;
            //請假明細
            Map<String,List<Map<String,String>>> detailMap = new Map<String,List<Map<String,String>>>();
            //银行
            if(details != null){
                List<Map<String,String>> lstDetail = new List<Map<String,String>>();

                for(Approval_Managed_Item__c detail : details){
                   
                    lstDetail.add(convertSObjectToMap(detail,i));
                    i++;
                }
                detailMap.put('leaveItem', lstDetail);
            }
           

            //String operate = (master.Status__c == '新建' ? SapOperateEnum.INSERTED : SapOperateEnum.UPDATED);
            String operate = SapOperateEnum.INSERTED;
            strArgs = Utils.serializeToJson(operate,'LEAVE_TW',main,detailMap);
        }catch(Exception ex){
            System.debug('*** 生成請假單參數錯誤：' + ex.getMessage() + '\n' + ex.getStackTraceString());
        }
        return strArgs;
    }
    
    public static Map<String, String> convertSObjectToMap(SObject obj)
    {
        Map<String, String> mapFieldValue = new Map<String, String>();
        System.debug('*** 序列化后数据：' + JSON.serialize(obj));
        JSONParser parse = JSON.createParser(JSON.serialize(obj));
        while(parse.nextToken() != null)
        {
            parse.nextValue();
            String name = parse.getCurrentName();
            if(String.isBlank(name) || name == 'attributes')
            {
                parse.skipChildren();
            }
            else
            {
                mapFieldValue.put(name, parse.getText());
            }
        }
        return mapFieldValue;
    }
    //增加序號參數
    public static Map<String, String> convertSObjectToMap(SObject obj,Integer i)
    {
        Map<String, String> mapFieldValue = new Map<String, String>();
        System.debug('*** 序列化后数据：' + JSON.serialize(obj));
        JSONParser parse = JSON.createParser(JSON.serialize(obj));
        while(parse.nextToken() != null)
        {
            mapFieldValue.put('No', String.valueOf(i));
            parse.nextValue();
            String name = parse.getCurrentName();
            if(String.isBlank(name) || name == 'attributes')
            {
                parse.skipChildren();
            }
            else
            {
                mapFieldValue.put(name, parse.getText());
            }
        }
        return mapFieldValue;
    }

}