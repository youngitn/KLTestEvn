public with sharing class MeetingMinutesMainPageController {
	public String Participant　{ set; get;}
	public MeetingMinutesMainPageController() {
		
	}

	



	@RemoteAction
    global static String getRefreshTable(String empId,String act)
    {
       


       return RemoteActionsOfLeave.queryVacationTW(empId);
    } 

	public class ParticipantRow{
		String name;
		String empid;
		String taskNote;
	}
}