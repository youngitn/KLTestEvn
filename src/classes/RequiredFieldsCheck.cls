public without sharing class RequiredFieldsCheck implements Triggers.Handler
{
    public void handle()
    {
        //System.debug(getAllFields('Approval_Managed1__c').get('Approval_Managed1__c'));
        //Approval_Managed1__c am = [SELECT Id FROM Approval_Managed1__c WHERE Name = 'AN1-171115-00000562'].get(0);

        //介面
        //SObject obj  = Database.query('SELECT ' + getAllFields('Approval_Managed__c').get('Approval_Managed__c') + ' FROM Approval_Managed__c WHERE Name = ' + '\'AN-170824-00001564\'').get(0);
        
        //String oId = String.valueOf(obj.get('Id'));
        for(SObject obj : Trigger.new)
        {
            //查子項 問題在於detail中記錄masterId的欄位並未統一 以及 子項可能超過一個 目前看採購
            // List<SObject> obj_detail_ami = [SELECT * FROM Approval_Managed_Item__c where Purchase_Info_Inquiry__c = :oId];
            //List<SObject> obj_detail_cami = [SELECT * FROM Custom_Approval_Managed_Item__c where Purchase_Info_Inquiry__c = :oId];

            System.debug(obj.get('Approval_Name__c'));
            Map<String, Map<String, Set<String>>> req = Utils.getDetailRequireFields(String.valueOf(obj.get('Id')), String.valueOf(obj.get('RecordTypeId')));

            Map<String, Set<String>> subItem = req.get('detailrequire');

            //System.debug();//取得子項必輸資訊
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