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
}