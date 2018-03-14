trigger MeetingMinutesTaskTrigger on Task (before insert) {
	
    //for (Task t : trigger.new)
    //{
    //   KL_Systems__c k = [select Toastmaster__c from KL_Systems__c where id =:t.whatId limit 1];
    //   t.addError('error:'+ k + 'now user' + UserInfo.getUserId());
    //}


}