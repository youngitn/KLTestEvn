global with sharing class QueryController
{



    //master-detail
    public SObject sobj {set; get;}

    public QueryController()
    {
        //sobj = (SObject)Type.forName(sobjName).newInstance();
    }

    //queryApplicantNum 應該是查詢請假人而非申請人
    @RemoteAction
    global static String doQuery(String queryString)
    {
        Map<String, String> mapx = new Map<String, String>();

        mapx = (Map<String, String>)JSON.deserialize(queryString, Map<String, String>.class);
        String sobjName = mapx.get('sobjName');
        Id recType = mapx.get('recordTypeId');

        String soql = mapx.get('SOQL');

        //      Map<String,String> inputMap = new Map<String,String>();
        //inputMap.put('Start_date__c',sQueryDate);
        //inputMap.put('End_date__c',eQueryDate);
        //inputMap.put('End_date__c',eQueryDate);

        //inputMap.put('LeaveManage__r.RecordTypeId',recType);

        //      System.debug(inputMap);
        //      sql += ' '+Utils.checkStringToBuildSOQLString(inputMap,true) ;
        //      System.debug(sql);
        String listType = 'List<' + sobjName + '>';
        List<SObject> SObjList = (List<SObject>)Type.forName(listType).newInstance();
        SObjList = Database.query(soql);

        //      System.debug(JSON.serialize(amis));
        return JSON.serialize(SObjList).unescapeHtml4();
    }

    @RemoteAction
    global static String getEmpId(String cId )
    {

        return Peoples.getInstance().KlAllContactMapGetById.get(cId).Number__c;
    }
}