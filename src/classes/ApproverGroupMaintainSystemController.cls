public with sharing class ApproverGroupMaintainSystemController {

	public Organizational__c mysObject{set;get;}
    public Id rtId {set;get;}
    // The extension constructor initializes the private member
    // variable mysObject by using the getRecord method from the standard
    // controller.
    public ApproverGroupMaintainSystemController(ApexPages.StandardController stdController) {
        this.mysObject = (Organizational__c)stdController.getRecord();
        rtId = HarryUtils.getRecordTypeIdByDevNameAndObjName('ApproverGroup', 'Organizational__c');
        this.mysObject.RecordTypeId  = rtId;
    }

    public String getRecordName() {
        return 'Hello ' + (String)mysObject.get('name') + ' (' + (Id)mysObject.get('Id') + ')';
    }

    @RemoteAction
    public static String addGroup(String groupName) {
        Id rtId = HarryUtils.getRecordTypeIdByDevNameAndObjName('ApproverGroup', 'Organizational__c');
        return 'alert("ok")';

    }

    public String addApproverIntoGroup() {
        return 'Hello ' + (String)mysObject.get('name') + ' (' + (Id)mysObject.get('Id') + ')';
    }


}