/**
 * TW請假單RemoteAction方法集合在此
 * 混雜一些組建JSON的方法,
 * 因此這邊的方法邏輯只有請假單適用
 * 之後類別的職責需更清晰.
 */
public with sharing class RemoteActionsOfLeave {
	
    /**
     * [queryVacationTW 從SAP取得特休&補休資料]
     * @param  cId          [連絡人ID]
     * @param  sapFuncName  [SAP函數名稱]
     * @return              [JSON]
     */
    public static String queryVacationTW(String cId,String sapFuncName)
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
            String str1                     = createSAPQueryByEmpNum(con.Number__c,sapFuncName);
            String str2                     = Utils.postToSAP(str1);
            SapWebServiceReturnArgs args    = (SapWebServiceReturnArgs)JSON.deserialize(str2, SapWebServiceReturnArgs.class);
            System.debug(LoggingLevel.INFO, '*** args: ' + args);
           
            ret = JSON.serialize(args);
        }
        catch(Exception ex)
        {
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage() + '\n' + ex.getStackTraceString()));
        }
        return ret;
    }

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
           
            ret = JSON.serialize(args);
        }
        catch(Exception ex)
        {
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage() + '\n' + ex.getStackTraceString()));
        }
        return ret;
    }

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
            //推送
            String str2                     = Utils.postToSAP(str1);
            SapWebServiceReturnArgs args    = (SapWebServiceReturnArgs)JSON.deserialize(str2, SapWebServiceReturnArgs.class);
            System.debug(LoggingLevel.INFO, '*** args: ' + args);
           
            ret = JSON.serialize(args);
        }
        catch(Exception ex)
        {
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage() + '\n' + ex.getStackTraceString()));
        }
        return ret;
    }

    //組建JSON 給SAP的查詢條件 By 工號 --> Employee_Code__c = 30210001
    public static String createSAPQueryByEmpNum(String pernr,String callSAPFuncName){
        List<Map<String,String>> lstCon = new List<Map<String,String>>();
        Integer index = 1;
        if(!String.isBlank(pernr)){
            //看起來條件可以給超過一個,因為有index
            lstCon.add(SapQueryArgCreate.createCondition(index,'Employee_Code__c','String','=',pernr));
            //index = index + 1;
        }
        System.debug(LoggingLevel.INFO, '*** lstCon[0]: ' + lstCon[0]);
        return JSON.serialize(SapQueryArgCreate.createQueryArg(callSAPFuncName,lstCon));
    }

    
}