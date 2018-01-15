public with sharing class RemoteActionsOfLeave {
	
    public static String queryVacation(String empId)
    {
        System.debug(LoggingLevel.INFO, '*** 查詢SAP特假&調休 EMPID: ' + empId);
        if (String.isBlank(empId))
        {
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.WARNING, '請假人不可為空'));
            return null;
        }
        System.debug('empId=' + empId);

        //use Peoples
        Contact con = [SELECT Name, Number__c FROM Contact WHERE Id = :empId AND RecordType.DeveloperName = 'Staff' LIMIT 1];
        System.debug('con=' + con);
        String ret;
        try
        {
            String str1                     = SapQueryArgCreate.createVacationQuery(con.Number__c);
            System.debug(str1);
            String str2                     = Utils.postToSAP(str1);
            SapWebServiceReturnArgs args    = (SapWebServiceReturnArgs)JSON.deserialize(str2, SapWebServiceReturnArgs.class);
            System.debug(LoggingLevel.INFO, '*** args: ' + args);
            Approval_Managed__c amget       = (Approval_Managed__c)JSON.deserialize(JSON.serialize(args.content[0].main), Approval_Managed__c.class);
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
}