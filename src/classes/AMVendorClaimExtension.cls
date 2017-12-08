public with sharing class AMVendorClaimExtension {

    public Custom_Approval_Managed__c cam  {Get; Set;}
    public List<Contact> c  {Get; Set;}

    // The extension constructor initializes the private member
    // variable mysObject by using the getRecord method from the standard
    // controller.
    public AMVendorClaimExtension(ApexPages.StandardController con) {
       cam = new Custom_Approval_Managed__c();

        cam.RecordTypeId = HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.VENDORCLAIM, 'Custom_Approval_Managed__c');

        cam.Approval_Name__c = [SELECT Name FROM RecordType WHERE Id = :cam.RecordTypeId].get(0).Name;

        if (con.getId() != null)
        {
            cam = (Custom_Approval_Managed__c)con.getRecord();
        }
        c =  [SELECT Id,Name FROM Contact LIMIT 100];
    }

    public String getRecordName() {
        return 'Hello ' + (String)cam.get('name') + ' (' + (Id)cam.get('Id') + ')';
    }
     public Component.Apex.Detail getDynamicfDetail() {
        Component.Apex.Detail detail = new Component.Apex.Detail();
        detail.expressions.subject = '{!acct.Id}';
        detail.relatedList = false;
        detail.title = false;
        return detail;
    }
    public Approval_Managed1__c acct {
        get { return [SELECT Id FROM Approval_Managed1__c WHERE Approval_Name__c = 'EducationTraining' LIMIT 1]; }
    }
}