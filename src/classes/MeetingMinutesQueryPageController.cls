global with sharing class MeetingMinutesQueryPageController {

	private final sObject mysObject;
    public KL_Systems__c kls {set;get;}
    // The extension constructor initializes the private member
    // variable mysObject by using the getRecord method from the standard
    // controller.
  
    //queryApplicantNum 應該是查詢請假人而非申請人
    @RemoteAction
    global static String doQuery(String queryString)
    {

        //      System.debug(JSON.serialize(amis));
        return QueryController.doQuery(queryString);
    }

}