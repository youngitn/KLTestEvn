global with sharing class LeaveQueryController
{
    public Approval_Managed_item__c ami {set; get;}
    public Approval_Managed__c am {set; get;}
    public LeaveQueryController()
    {
        am = new Approval_Managed__c();
        ami = new Approval_Managed_item__c();
    }

    @RemoteAction
    global static String doQuery(String sQueryDate,String  eQueryDate,String queryAplStatus,String queryTypesOfLeave,String queryApplicantNum )
    {
    	
        String sobjName = 'Approval_Managed_item__c';
        Id recType = HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.LEAVEAPPLICATION, 'Approval_Managed__c');
        
        String sql = 'Select LeaveManage__r.Approval_Status__c,' + SObjectUtils.getAllFields(sobjName).get(sobjName) + ' from ' + sobjName;

        Map<String,String> inputMap = new Map<String,String>();
		inputMap.put('Start_date__c',sQueryDate);
		inputMap.put('End_date__c',eQueryDate);
		inputMap.put('TypesOfLeave__c',queryTypesOfLeave);
		inputMap.put('LeaveManage__r.Approval_Status__c',queryAplStatus);
		inputMap.put('LeaveManage__r.Applicant_Code__c',queryApplicantNum);
		inputMap.put('LeaveManage__r.RecordTypeId',recType);
        
        System.debug(inputMap);
        sql += ' '+Utils.checkStringToBuildSOQLString(inputMap,true) ;
        System.debug(sql);
        List<Approval_Managed_item__c> amis = Database.query(sql);

        System.debug(JSON.serialize(amis));
        return JSON.serialize(amis).unescapeHtml4();
    }

}