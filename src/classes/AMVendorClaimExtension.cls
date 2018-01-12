public with sharing class AMVendorClaimExtension extends VFShowInApprovalExtension
{

    public Custom_Approval_Managed__c cam  {Get; Set;}
   
    public AMVendorClaimExtension(ApexPages.StandardController con)
    {
        super('Custom_Approval_Managed__c','供應商索賠',con,null,null,null);
        System.debug('OK');
        cam = (Custom_Approval_Managed__c)this.sobj;
        System.debug(cam);
        
      
    }

    public override PageReference saveAction()
    {
        upsert cam;
        return this.goPage(cam.Id);
    }
}