
/**
 * 判斷表單主表與子表必填欄位.
 *
 * 可動態指定物件
 * 子項物件可動態指定,但因為query時需要知道其類型,
 * 所以在审批节点编辑字段设置中須指定子項物件名稱,
 * 在編輯 项次必输字段集合【以逗号(,)分隔】時,須符合以下格式:
 * 
 *     子項API名稱@字段1,字段2;子項API名稱2@字段1,字段2;
 *     
 * EX: Approval_Managed_Item__c@id,Material_Description__c,Dept_of_CostCenter__c
 * 一個以上的子項也適用.
 *
 * 
 * 
 */
public without sharing class RequiredFieldsCheck implements Triggers.Handler
{
    public void handle()
    {
        
        for(SObject obj : Trigger.new)
        {
            //查子項 detail中記錄masterId的欄位並未統一 以及 子項可能超過一個 目前看採購
            // List<SObject> obj_detail_ami = [SELECT * FROM Approval_Managed_Item__c where Purchase_Info_Inquiry__c = :oId];
            //List<SObject> obj_detail_cami = [SELECT * FROM Custom_Approval_Managed_Item__c where Purchase_Info_Inquiry__c = :oId];
            String errorMsg = '';
            Map<String, Map<String, Set<String>>> req = Utils.getDetailRequireFields(String.valueOf(obj.get('Id')), String.valueOf(obj.get('RecordTypeId')));
            Map<String, Set<String>> masterReq = Utils.getNodeEditFields(String.valueOf(obj.get('Id')), String.valueOf(obj.get('RecordTypeId')));

            System.debug(req);
            Map<String, Set<String>> subItem = req.get('detailrequire');
            //System.debug();
            Map<String, Schema.SObjectField> mmyFields = obj.getSObjectType().getDescribe().fields.getMap();
            for(String ms : masterReq.get('mainrequire'))
            {

                //判斷是否為空
                System.debug(obj.get('Approval_Name__c') + '主表必輸欄位 標籤:' + mmyFields.get(ms).getDescribe().getLabel() + ' API name:' + ms + ' 值:' + obj.get(ms));
                errorMsg += obj.get('Approval_Name__c') + '主表必輸欄位 標籤:' + mmyFields.get(ms).getDescribe().getLabel() + ' API name:' + ms + ' 值:' + obj.get(ms)+'<br>';
            }


            for(String s : subItem.keySet())
            {
                System.debug(s);
                Set<String> subFieldSet = subItem.get(s);
                List<SObject> objDetail = Database.query('SELECT ' + getAllFields(s).get(s) + ' FROM ' + s + ' WHERE Purchasing_Request__c =\'' + obj.get('Id') + '\'');
               
                for(SObject o : objDetail)
                {
                     Map<String, Schema.SObjectField> myFields = o.getSObjectType().getDescribe().fields.getMap();
                    for(String fieldApiName : subFieldSet)
                    {
                        //判斷是否為空
                        System.debug(o.get('Approval_Name__c') + '子項必輸欄位 標籤:' + myFields.get(fieldApiName).getDescribe().getLabel() + ' API name:' + fieldApiName + ' 值:' + o.get(fieldApiName));
                        errorMsg += o.get('Approval_Name__c') + '子項必輸欄位 標籤:' + myFields.get(fieldApiName).getDescribe().getLabel() + ' API name:' + fieldApiName + ' 值:' + o.get(fieldApiName)+'<br>';
                    }

                }

            }

            //System.debug();//取得子項必輸資訊
            if(errorMsg != ''){
                obj.addError(errorMsg);
            }
        }
    }
    public static Map<String, String> getAllFields(String sobjectname)
    {
        if(!Schema.getGlobalDescribe().containsKey(sobjectname)) return new Map<String, String> {'Exception' => 'Invalid object name'};
        Map<String, Schema.SObjectField> fields = Schema.getGlobalDescribe().get(sobjectname).getDescribe().SObjectType.getDescribe().fields.getMap();

        List<String> accessiblefields = new List<String>();

        for(Schema.SObjectField field : fields.values())
        {
            if(field.getDescribe().isAccessible())
                accessiblefields.add(field.getDescribe().getName());
        }

        String allfields = '';

        for(String fieldname : accessiblefields)
            allfields += fieldname + ',';

        allfields = allfields.subString(0, allfields.length() - 1);

        return new Map<String, String> {sobjectname => allfields};
    }
}