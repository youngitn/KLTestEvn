public virtual  class BaseExtension implements IExtension
{

    //get SObj type
    //get recId
    //getSObjRtyId(SobjName,rtyName)
    //getSObjRtyIdBySAE(SAE)
    //getSObjAllField()
    public SObject sobj {set; get;}
    public Id recordTypeId {set; get;}

    public BaseExtension(String sobjName, String approvalName, ApexPages.StandardController con)
    {
        recordTypeId    = getReCTypeId(sobjName, approvalName);
        //System.debug(this.recordTypeId);
        sobj            = (SObject)Type.forName(sobjName).newInstance();
        sobj.put('Approval_Name__c', approvalName);
        System.debug('BaseExtension approvalName = ' + approvalName);
        sobj.put('RecordTypeId', recordTypeId);
        System.debug('BaseExtension recordTypeId = ' + recordTypeId);
    }
    public virtual PageReference saveAction()
    {
        return new PageReference('/'  + sobj.Id);
    }
    public Id getReCTypeId(String sobjName, String approvalName)
    {
        return Schema.getGlobalDescribe().get( sobjName ).getDescribe().getRecordTypeInfosByName().get( approvalName ).getRecordTypeId();
    }
    public virtual PageReference cancelAction()
    {
        return new PageReference('/apex/ApprovalHome?sfdc.tabName=01rO0000000Dz6T');
    }

    


}