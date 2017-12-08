public with sharing class AMSupplierClaimExtension {

	public Custom_Approval_Managed__c cam  {Get; Set;}

    // The extension constructor initializes the private member
    // variable mysObject by using the getRecord method from the standard
    // controller.
    public AMSupplierClaimExtension(ApexPages.StandardController stdController) {
        this.cam = new Custom_Approval_Managed__c();
    }

    public String getRecordName() {
        return 'Hello ' + (String)cam.get('name') + ' (' + (Id)cam.get('Id') + ')';
    }
}