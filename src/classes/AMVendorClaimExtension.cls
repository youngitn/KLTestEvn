public with sharing class AMVendorClaimExtension extends BaseExtension
{

    public Custom_Approval_Managed__c cam  {Get; Set;}
   
    public AMVendorClaimExtension(ApexPages.StandardController con)
    {
        super('Custom_Approval_Managed__c','供應商索賠',con);
        System.debug('OK');
        cam = (Custom_Approval_Managed__c)sobj;
        System.debug(cam);
        if (con.getId() != null)
        {
            cam = (Custom_Approval_Managed__c)con.getRecord();
        }
      
    }

    public override PageReference saveAction()
    {
        upsert cam;
        return new PageReference('/' + cam.Id);
    }
}