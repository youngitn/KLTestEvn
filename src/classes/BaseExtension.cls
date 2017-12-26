public virtual  class BaseExtension implements IExtension
{

    //get SObj type
    //get recId
    //getSObjRtyId(SobjName,rtyName)
    //getSObjRtyIdBySAE(SAE)
    //getSObjAllField()
    public SObject sobj {set; get;}
    public Id recordTypeId {set; get;}
    public Map<Id, Contact> contactsById {get;private set;}
    public Map<String, Contact> contactsByNum {get;private set;}
    public Map<Id, User> usersById {get;private set;}
    public Map<String, User> usersByNum {get;private set;} 

    public BaseExtension(String sobjName,String ApprovalName,ApexPages.StandardController con)
    {
        this.recordTypeId 	= Schema.getGlobalDescribe().get(sobjName).getDescribe().getRecordTypeInfosByName().get(ApprovalName).getRecordTypeId();
        //System.debug(this.recordTypeId);
        this.sobj 			= (SObject)Type.forName(sobjName).newInstance();
        this.sobj.put('Approval_Name__c',ApprovalName);

        this.sobj.put('RecordTypeId',this.recordTypeId);

        this.contactsById 	= Peoples.getInstance().KlAllContactMapGetById;
        this.contactsByNum 	= Peoples.getInstance().KlAllContactMapGetByNum;
        this.usersById 		= Peoples.getInstance().KlAllUserMapGetById;
        this.usersByNum 	= Peoples.getInstance().KlAllUserMapGetByNum;

        
    }
    public virtual PageReference saveAction()
    {
        return new PageReference('/'  + sobj.Id);
    }

    public virtual PageReference cancelAction()
    {
        return new PageReference('/apex/ApprovalHome?sfdc.tabName=01rO0000000Dz6T');
    }

}