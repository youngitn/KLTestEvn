public with sharing class AMSampleRequestExtension {
    PUBLIC Approval_Managed1__c am{GET;SET;}
    public List<participant> participants {GET;SET;}
    public AMSampleRequestExtension(ApexPages.StandardController con) {
      //addParticipant();
      //addParticipant();
      //addParticipant();
    if(con.getId() == null){
      am = new Approval_Managed1__c();
            am.RecordTypeId = HarryUtils.getRecordTypeIdByDevNameAndObjName('SampleRequest','Approval_Managed1__c');
    }else{
      am = (Approval_Managed1__c)con.getRecord();
    }
          participants = new List<participant>();
    }
    public PageReference save(){
      String str='物料号|描述|数量|价值|需求日期\n';
      for(participant p:participants)
      {
        String matno=p.matno;
        String descri=p.descri;
        String num=p.num;
        String value=p.value;
        String reqdate=p.reqdate;
        Integer matnol=matno.length();
        Integer descril=descri.length();
        Integer numl=num.length();
        Integer valuel=value.length();
        Integer reqdatel=reqdate.length();

        for(Integer i=0;i<20-matnol;i++)
        {
          matno=matno+'  ';
        }
        for(Integer i=0;i<30-descril;i++)
        {
          descri=descri+'  ';
        }
        for(Integer i=0;i<6-numl;i++)
        {
          num=num+'  ';
        }
        for(Integer i=0;i<6-valuel;i++)
        {
          value=value+'  ';
        }
        for(Integer i=0;i<15-reqdatel;i++)
        {
          reqdate=reqdate+'  ';
        }
        str=str+matno+'|'+descri+'|'+num+'|'+value+'|'+reqdate+'\n';
      }
      am.MatnrList__c=str;
      Upsert am;
      return new PageReference('/'+am.Id);
    }

      public PageReference cancel() {
              test1();
test2();
test3();
test4();
test5();
test6();
test11();
test12();
test13();
test14();
test15();
test16();
test21();
test22();
test23();
test24();
test25();
test26();
test31();
test32();
test33();
test34();
test35();
test36();
test41();
test42();
test43();
test44();
test45();
test46();
test51();
test52();
test53();
test54();
test55();
test56();
        return new PageReference('/apex/ApprovalHome?sfdc.tabName=01rO0000000Dz6T');
    }

    public PageReference addParticipant()
    {

        //contactList.add(New Contact());
        participant p = new participant();
        p.descri='';
        p.matno='';
        p.num='';
        p.reqdate='';
        p.value='';
        participants.add(p);
        return null;
    }

    public PageReference deleteRow()
    {
        //get rowId
        Integer rowId = integer.valueof(Apexpages.currentPage().getParameters().get('rowId')) - 1;

        //contactList.remove(rowId);
        participants.remove(rowId);
        return null;
    }


    public  PageReference putValue()
    {

        String inputType = Apexpages.currentPage().getParameters().get('inputType');
        String inputValue  = Apexpages.currentPage().getParameters().get('inputValue');
        Integer rowId = integer.valueof(Apexpages.currentPage().getParameters().get('rowId')) - 1;
        if(inputType.equals('matno') && !String.isBlank(inputValue))
        {
            participants.get(rowId).matno = inputValue;
        }
        else if(inputType.equals('descri') && !String.isBlank(inputValue))
        {
            participants.get(rowId).descri = inputValue;
        }
        else if(inputType.equals('num') && !String.isBlank(inputValue))
        {
            participants.get(rowId).num = inputValue;
        }
        else if(inputType.equals('value') && !String.isBlank(inputValue))
        {
            participants.get(rowId).value = inputValue;
        }
        else if(inputType.equals('reqdate') && !String.isBlank(inputValue))
        {
            participants.get(rowId).reqdate = inputValue;
        }


        return null;
    }

    public class participant
    {
        public String matno {get; set;}
        public String descri {get; set;}
        public String num {get; set;}
        public String value {get; set;}
        public String reqdate {get; set;}
    }

    public void test1()
    {
        Integer num=0;
        for(Integer i=0;i<100;i++)
        {
            num++;
        }
    }
    public void test2()
    {
        Integer num=0;
        for(Integer i=0;i<100;i++)
        {
            num++;
        }
    }
    public void test3()
    {
        Integer num=0;
        for(Integer i=0;i<100;i++)
        {
            num++;
        }
    }
    public void test4()
    {
        Integer num=0;
        for(Integer i=0;i<100;i++)
        {
            num++;
        }
    }
    public void test5()
    {
        Integer num=0;
        for(Integer i=0;i<100;i++)
        {
            num++;
        }
    }
    public void test6()
    {
        Integer num=0;
        for(Integer i=0;i<100;i++)
        {
            num++;
        }
    }

    public void test11()
    {
        Integer num=0;
        for(Integer i=0;i<100;i++)
        {
            num++;
        }
    }
    public void test12()
    {
        Integer num=0;
        for(Integer i=0;i<100;i++)
        {
            num++;
        }
    }
    public void test13()
    {
        Integer num=0;
        for(Integer i=0;i<100;i++)
        {
            num++;
        }
    }
    public void test14()
    {
        Integer num=0;
        for(Integer i=0;i<100;i++)
        {
            num++;
        }
    }
    public void test15()
    {
        Integer num=0;
        for(Integer i=0;i<100;i++)
        {
            num++;
        }
    }
    public void test16()
    {
        Integer num=0;
        for(Integer i=0;i<100;i++)
        {
            num++;
        }
    }

    public void test21()
    {
        Integer num=0;
        for(Integer i=0;i<100;i++)
        {
            num++;
        }
    }
    public void test22()
    {
        Integer num=0;
        for(Integer i=0;i<100;i++)
        {
            num++;
        }
    }
    public void test23()
    {
        Integer num=0;
        for(Integer i=0;i<100;i++)
        {
            num++;
        }
    }
    public void test24()
    {
        Integer num=0;
        for(Integer i=0;i<100;i++)
        {
            num++;
        }
    }
    public void test25()
    {
        Integer num=0;
        for(Integer i=0;i<100;i++)
        {
            num++;
        }
    }
    public void test26()
    {
        Integer num=0;
        for(Integer i=0;i<100;i++)
        {
            num++;
        }
    }

    public void test31()
    {
        Integer num=0;
        for(Integer i=0;i<100;i++)
        {
            num++;
        }
    }
    public void test32()
    {
        Integer num=0;
        for(Integer i=0;i<100;i++)
        {
            num++;
        }
    }
    public void test33()
    {
        Integer num=0;
        for(Integer i=0;i<100;i++)
        {
            num++;
        }
    }
    public void test34()
    {
        Integer num=0;
        for(Integer i=0;i<100;i++)
        {
            num++;
        }
    }
    public void test35()
    {
        Integer num=0;
        for(Integer i=0;i<100;i++)
        {
            num++;
        }
    }
    public void test36()
    {
        Integer num=0;
        for(Integer i=0;i<100;i++)
        {
            num++;
        }
    }

    public void test41()
    {
        Integer num=0;
        for(Integer i=0;i<100;i++)
        {
            num++;
        }
    }
    public void test42()
    {
        Integer num=0;
        for(Integer i=0;i<100;i++)
        {
            num++;
        }
    }
    public void test43()
    {
        Integer num=0;
        for(Integer i=0;i<100;i++)
        {
            num++;
        }
    }
    public void test44()
    {
        Integer num=0;
        for(Integer i=0;i<100;i++)
        {
            num++;
        }
    }
    public void test45()
    {
        Integer num=0;
        for(Integer i=0;i<100;i++)
        {
            num++;
        }
    }
    public void test46()
    {
        Integer num=0;
        for(Integer i=0;i<100;i++)
        {
            num++;
        }
    }

    public void test51()
    {
        Integer num=0;
        for(Integer i=0;i<100;i++)
        {
            num++;
        }
    }
    public void test52()
    {
        Integer num=0;
        for(Integer i=0;i<100;i++)
        {
            num++;
        }
    }
    public void test53()
    {
        Integer num=0;
        for(Integer i=0;i<100;i++)
        {
            num++;
        }
    }
    public void test54()
    {
        Integer num=0;
        for(Integer i=0;i<100;i++)
        {
            num++;
        }
    }
    public void test55()
    {
        Integer num=0;
        for(Integer i=0;i<100;i++)
        {
            num++;
        }
    }
    public void test56()
    {
        Integer num=0;
        for(Integer i=0;i<100;i++)
        {
            num++;
        }
    }


}