public with sharing class MeetingMinutesMainPageController extends VFShowInApprovalExtension{
	
	public String Participant　{ set; get;}
	public List<ParticipantRow> participantList { set; get;}
	
	public KL_Systems__c kls {set;get;}



	public MeetingMinutesMainPageController(ApexPages.StandardController con) {
		
		super('KL_Systems__c','Meeting_Minutes',con,null,null,null);
		participantList = new List<ParticipantRow>();
		kls = (KL_Systems__c)this.sobj;
        if (con.getId() != null){
        		
               if (kls.Participant__c != null){
               		List<String> pList = kls.Participant__c.split(',');
               		for(String p:pList){
               			String empid = p.substringBetween('-','@');
               			String name = p.substringBefore('-');
               			String tasknote = p.substringAfter('@');
               			ParticipantRow inp = new ParticipantRow();
               			inp.empid = empid;
               			inp.name = name;
               			inp.taskNote = tasknote;
               			participantList.add(inp);
               		}
               }

        }
	}



    public PageReference addParticipant()
    {

        //contactList.add(New Contact());
        ParticipantRow p = new ParticipantRow();
        participantList.add(p);
        return null;
    }
    public PageReference deleteRow()
    {
        //get rowId
        Integer rowId = integer.valueof(Apexpages.currentPage().getParameters().get('rowId')) - 1;

        //contactList.remove(rowId);
        participantList.remove(rowId);
        return null;
    }

    public  PageReference putValue()
    {

        String inputType = Apexpages.currentPage().getParameters().get('inputType');
        String inputValue  = Apexpages.currentPage().getParameters().get('inputValue');
        Integer rowId = integer.valueof(Apexpages.currentPage().getParameters().get('rowId')) - 1;
        if (inputType.equals('empid') && !String.isBlank(inputValue))
        {
            participantList.get(rowId).empid = inputValue;
            List<Contact> cont = [SELECT Name, Dept_Number__r.Name FROM CONTACT WHERE number__c = :inputValue];
            if(cont.size() < 1 )
            {
                participantList.get(rowId).name = '查無此人';

            }
            else
            {
                participantList.get(rowId).name = cont.get(0).name;
        
            }

        }
        else if (inputType.equals('name') && !String.isBlank(inputValue))
        {
            participantList.get(rowId).name = inputValue;
        }else if (inputType.equals('taskNote') && !String.isBlank(inputValue))
        {
            participantList.get(rowId).taskNote = inputValue;
        }

        return null;
    }

	public class ParticipantRow{
		public String name {get; set;}
		public String empid {get; set;}
		public String taskNote {get; set;}
	}

	public override PageReference saveAction()
    {   
    	String persons = '';
    	integer count = participantList.size();
    	if (count > 0){
    		for (ParticipantRow row :participantList){

    			persons += row.name + '-' + row.empid + '@' + row.taskNote ;
    			count--;
    			if(count > 0){
    				persons += ',';
    			}
    		}

    		kls.Participant__c = persons;
    	}
    	 
    	upsert kls;
    	return this.goPage(kls.Id);
    }
}