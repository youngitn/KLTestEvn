/**
 * 以master-detail架構的表單,將資料組建程json以推送至SAP.
 */
public with sharing class SapJsonStringBuilder
{

    public SObject master;
    public List<SObject> details;

    public void setMaster(String sobjId, String sobjName)
    {

        String sql = getSelectFieldString(sobjName,null) + ' from ' + sobjName + ' ' + ' WHERE Id = \'' + sobjId + '\'';
        System.debug(sql);
        List<SObject> lstItems = Database.query(sql);
        setMaster(lstItems.get(0));
        //return lstItems.get(0);
    }

    public void setMaster(String sobjId, String sobjName, List<String> fieldList)
    {

        String fields = '';
        for(String fieldName : fieldList)
        {
            fields += fieldName + ',';
        }
        String sql = getSelectFieldString(sobjName,fieldList) + ' from ' + sobjName + ' ' + ' WHERE Id = \'' + sobjId + '\'';
        System.debug(sql);
        List<SObject> lstItems = Database.query(sql);
        setMaster(lstItems.get(0));
        System.debug('master-->' + this.master);

    }

    //沒有id可直接給物件
    //適用存檔前物件
    public void setMaster(SObject inputMaster)
    {

        this.master = inputMaster;

    }

    //不指定查詢明細欄位
    public void setDetails(String msaterSobjId, String sobjName, String relationFieldName)
    {

        String sql = getSelectFieldString(sobjName,null) + ' from ' + sobjName + ' '+' WHERE ' + relationFieldName + ' = \'' + msaterSobjId + '\'' ;
        System.debug(sql);
        setDetails(Database.query(sql));
        System.debug('details-->' + this.details);

    }

    //指定查詢明細欄位
    public void setDetails(String msaterSobjId, String sobjName, String relationFieldName, List<String> fieldList)
    {
 
        String sql = getSelectFieldString(sobjName,fieldList) + ' from ' + sobjName + ' '+' WHERE ' + relationFieldName + ' = \'' + msaterSobjId + '\'' ;
        System.debug(sql);
        setDetails(Database.query(sql));
        System.debug('details-->' + this.details);

    }

    public void setDetails(List<SObject> inputdDetails)
    {

        this.details = inputdDetails;

    }

    public String getSelectFieldString(String sobjName, List<String> fieldList)
    {

        String fields = '';
        if(fieldList != null)
        {
            for(String fieldName : fieldList)
            {
                fields += fieldName + ',';
            }
            fields = fields.removeEnd(',');
        }else{
            fields = SObjectUtils.getAllFields(sobjName).get(sobjName);
        }

        return 'Select ' + fields + ' ';

    }

    /**
     * [getJson 取得推送SAP的JSON]
     * @param  sapFuncName [SAP函數名稱]
     * @param  detailKey   [明細資料List在json的根屬性名稱]
     * @param  operate     [SapOperateEnum.INSERTED or SapOperateEnum.XXXX... 看是要新增還是更新 沒指定可給null]
     * @return             [json]
     */
    public String getJson(String sapFuncName, String detailKey, String operate)
    {
        String strArgs = '';
        try
        {
            //請假單表頭
            Map<String, String> main = convertSObjectToMap(this.master);
            System.debug('*** main' + main);
            Integer i = 0;
            //請假明細
            Map<String, List<Map<String, String>>> detailMap = new Map<String, List<Map<String, String>>>();
            //银行
            if(this.details != null)
            {
                List<Map<String, String>> lstDetail = new List<Map<String, String>>();

                for(SObject detail : this.details)
                {

                    lstDetail.add(convertSObjectToMap(detail, i));
                    i++;
                }
                detailMap.put(detailKey, lstDetail);
            }

            //String operate = SapOperateEnum.INSERTED;
            strArgs = Utils.serializeToJson(operate, sapFuncName, main, detailMap);
        }
        catch(Exception ex)
        {
            System.debug('*** 生成SAPJSON錯誤：' + ex.getMessage() + '\n' + ex.getStackTraceString());
        }
        return strArgs;
    }

    /********************************以下開始為靜態方法*************************************************************************************/
    /**
     * [createSapLeaveApplicationInsertArgs description]
     * @param  master      [主表物件]
     * @param  details     [明細物件List]
     * @param  sapFuncName [SAP函數名稱]
     * @param  detailKey   [明細資料List在json的根屬性名稱]
     * @return             [json]
     */
    //public static String getJson(SObject master, List<SObject> details, String sapFuncName, String detailKey)
    //{
    //    String strArgs = '';
    //    try
    //    {
    //        //請假單表頭
    //        Map<String, String> main = convertSObjectToMap(master);
    //        System.debug('*** main' + main);
    //        Integer i = 0;
    //        //請假明細
    //        Map<String, List<Map<String, String>>> detailMap = new Map<String, List<Map<String, String>>>();
    //        //银行
    //        if(details != null)
    //        {
    //            List<Map<String, String>> lstDetail = new List<Map<String, String>>();

    //            for(SObject detail : details)
    //            {

    //                lstDetail.add(convertSObjectToMap(detail, i));
    //                i++;
    //            }
    //            detailMap.put(detailKey, lstDetail);
    //        }


    //        //String operate = (master.Status__c == '新建' ? SapOperateEnum.INSERTED : SapOperateEnum.UPDATED);
    //        String operate = SapOperateEnum.INSERTED;
    //        strArgs = Utils.serializeToJson(operate, sapFuncName, main, detailMap);
    //    }
    //    catch(Exception ex)
    //    {
    //        System.debug('*** 生成SAPJSON錯誤：' + ex.getMessage() + '\n' + ex.getStackTraceString());
    //    }
    //    return strArgs;
    //}


    ////如果送到SAP無需序號做識別,則用此方法
    public static Map<String, String> convertSObjectToMap(SObject obj)
    {
        Map<String, String> mapFieldValue = new Map<String, String>();
        System.debug('*** 序列化后数据：' + JSON.serialize(obj));
        JSONParser parse = JSON.createParser(JSON.serialize(obj));
        while(parse.nextToken() != null)
        {
            parse.nextValue();
            String name = parse.getCurrentName();
            if(String.isBlank(name) || name == 'attributes')
            {
                parse.skipChildren();
            }
            else
            {
                mapFieldValue.put(name, parse.getText());
            }
        }
        return mapFieldValue;
    }

    //如果送到SAP需要有序號做識別,則用此方法-增加序號參數
    public static Map<String, String> convertSObjectToMap(SObject obj, Integer i)
    {
        Map<String, String> mapFieldValue = new Map<String, String>();
        System.debug('*** 序列化后数据：' + JSON.serialize(obj));
        JSONParser parse = JSON.createParser(JSON.serialize(obj));
        while(parse.nextToken() != null)
        {
            mapFieldValue.put('No', String.valueOf(i));
            parse.nextValue();
            String name = parse.getCurrentName();
            if(String.isBlank(name) || name == 'attributes')
            {
                parse.skipChildren();
            }
            else
            {
                mapFieldValue.put(name, parse.getText());
            }
        }
        return mapFieldValue;
    }

}