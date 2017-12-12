public with sharing class AMVendorClaimExtension
{

    public Custom_Approval_Managed__c cam  {Get; Set;}
    public List<Contact> c  {Get; Set;}

    // The extension constructor initializes the private member
    // variable mysObject by using the getRecord method from the standard
    // controller.
    public AMVendorClaimExtension(ApexPages.StandardController con)
    {
        cam = new Custom_Approval_Managed__c();

        cam.RecordTypeId = HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.VENDORCLAIM, 'Custom_Approval_Managed__c');

        cam.Approval_Name__c = [SELECT Name FROM RecordType WHERE Id = :cam.RecordTypeId].get(0).Name;

        if (con.getId() != null)
        {
            cam = (Custom_Approval_Managed__c)con.getRecord();
        }
        c =  [SELECT Id, Name FROM Contact LIMIT 100];
        
    }

    public PageReference saveAction()
    {
        upsert cam;
        return new PageReference('/' + cam.Id);
    }

    public PageReference cancelAction()
    {
        return new PageReference('/apex/ApprovalHome?sfdc.tabName=01rO0000000Dz6T');
    }


}