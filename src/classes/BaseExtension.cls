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
        sobj            = (SObject)Type.forName(sobjName).newInstance();
        recordTypeId    = getReCTypeId(sobjName,approvalName);

        System.debug(this.recordTypeId);

        sobj.put('RecordTypeId', recordTypeId);
        try
        {
            sobj.put('Approval_Name__c', approvalName);
            System.debug('BaseExtension approvalName = ' + approvalName);

            System.debug('BaseExtension recordTypeId = ' + recordTypeId);
        }
        catch(Exception e)
        {
            System.debug('Exception caught: ' + e.getMessage());
        }
        finally
        {

            System.debug('finally');
        }

    }
    public virtual PageReference saveAction()
    {
        return new PageReference('/'  + sobj.Id);
    }
    
    public Id getReCTypeId(String sobjName, String approvalName)
    {
        return HarryUtils.getRecordTypeIdByDevNameAndObjName(approvalName, sobjName);
        //return Schema.getGlobalDescribe().get( sobjName ).getDescribe().getRecordTypeInfosByName().get( approvalName ).getRecordTypeId();
    }
    public virtual PageReference cancelAction()
    {
        return new PageReference('/apex/ApprovalHome?sfdc.tabName=01rO0000000Dz6T');
    }




}