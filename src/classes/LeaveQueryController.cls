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
    global static String doQuery(String queryApplicantNum, String sQueryDate, String eQueryDate, String queryAplStatus, String queryTypesOfLeave, String queryLeave_reason)
    {
        String sobjName = 'Approval_Managed_item__c';
        Id recType = HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.LEAVEAPPLICATION, 'Approval_Managed__c');
        System.debug(recType);
        
        Set<Id> amIds = new Set<id>();
        for ( Approval_Managed__c am :  [SELECT Id From Approval_Managed__c WHERE Applicant_Code__c = :queryApplicantNum AND RecordTypeId = :recType])
        {
        	 amIds.add(am.Id);
        }

        String sql = 'Select LeaveManage__r.Approval_Status__c,' + SObjectUtils.getAllFields(sobjName).get(sobjName) + ' from ' + sobjName;
        sql += ' WHERE LeaveManage__c in :amIds';
        //List<String> sqlAndString = 
        List<Approval_Managed_item__c> amis = Database.query(sql);

        System.debug(JSON.serialize(amis));
        return JSON.serialize(amis).unescapeHtml4();
    }

    // public List<sObject> objects(String setName, String soqlString){
    //     return Database.query(soqlString.replace('XXX',setName));
    // }

    // public void soqlExecuter1(){
    //     ami.clear();
    //     ami = objects('set1', soql1);

    // }
}