public with sharing class MeetingMinutesMainPageHandler implements Triggers.Handler{
	
    public void handle()
    {


        Map<Decimal, Organizational__c>  mapSpecify = null;
        Id rtId =  HarryUtils.getRecordTypeIdByDevNameAndObjName('Meeting_Minutes', 'KL_Systems__c');
        System.debug(rtId);
        Boolean haveSfID = true;
        if (Trigger.isBefore && Trigger.isInsert)
        {
            Set<String> userIds = new Set<String>();
            for (KL_Systems__c cam : (List<KL_Systems__c>)Trigger.new)
            {
                if (cam.RecordTypeId == rtId)
                {
                          
               
                    /*if (Peoples.getInstance().KlAllContactMapGetById.get(cam.Employee__c).SF_user__r.Id != null){
                        userIds.add(Peoples.getInstance().KlAllContactMapGetById.get(cam.Employee__c).SF_user__r.Id);
                    }else if(Peoples.getInstance().KlAllUserMapGetByNum.get(cam.Employee_code__c) != null){
                        userIds.add(Peoples.getInstance().KlAllUserMapGetByNum.get(cam.Employee_code__c).Id);
                    }*/     

                    if(userIds.size() > 0)
                    {
                        Utils.ManualShareRecordToUsers(userIds, 'KL_Systems__c', String.valueOf(cam.get('Id')));
                    }
                   
                }

                
            }
        }
        if (Trigger.isBefore && Trigger.isUpdate)
        {
            System.debug('##################');

            for (KL_Systems__c cam : (List<KL_Systems__c>)Trigger.new)
            {

                if (cam.RecordTypeId == rtId )
                {
                             
                }

            }

        }
    }

}