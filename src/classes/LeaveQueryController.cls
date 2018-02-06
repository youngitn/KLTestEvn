global with sharing class LeaveQueryController
{
    public Approval_Managed_item__c ami {set; get;}
    public Approval_Managed__c am {set; get;}
    public LeaveQueryController()
    {
        am = new Approval_Managed__c();
        ami = new Approval_Managed_item__c();
    }

    //queryApplicantNum 應該是查詢請假人而非申請人
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
		inputMap.put('LeaveManage__r.Employee_Code__c',queryApplicantNum);//工號用來查請假人才正確
		inputMap.put('LeaveManage__r.RecordTypeId',recType);
        
        System.debug(inputMap);
        sql += ' '+Utils.checkStringToBuildSOQLString(inputMap,true) ;
        System.debug(sql);
        List<Approval_Managed_item__c> amis = Database.query(sql);

        System.debug(JSON.serialize(amis));
        return JSON.serialize(amis).unescapeHtml4();
    }

    @RemoteAction
    global static String getEmpId(String cId )
    {
        
        return Peoples.getInstance().KlAllContactMapGetById.get(cId).Number__c;
    }

}