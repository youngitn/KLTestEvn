public with sharing class SObjectUtils
{
    // 物件取得所有欄位
    public static Map<String, String> getAllFields(String sobjectname)
    {
        if(!Schema.getGlobalDescribe().containsKey(sobjectname)) return new Map<String, String> {'Exception' => 'Invalid object name'};
        Map<String, Schema.SObjectField> fields = Schema.getGlobalDescribe().get(sobjectname).getDescribe().SObjectType.getDescribe().fields.getMap();
        System.debug('fields:'+fields);
        List<String> accessiblefields = new List<String>();

        for(Schema.SObjectField field : fields.values())
        {
            if(field.getDescribe().isAccessible())
                accessiblefields.add(field.getDescribe().getName());
        }
        System.debug('accessiblefields:'+accessiblefields);
        String allfields = '';

        for(String fieldname : accessiblefields)
            allfields += fieldname + ',';

        allfields = allfields.subString(0, allfields.length() - 1);

        return new Map<String, String> {sobjectname => allfields};
    }

    public static SObject init(SObject sobj)
    {
        sobj.put('Applicant_Name__c', UserInfo.getName());
        User u                      = Peoples.getInstance().KlAllUserMapGetById.get(UserInfo.getUserId());
        if (u.Number__c != null && !String.isBlank(u.Number__c))
        {
            Contact c               = Peoples.getInstance().KlAllContactMapGetByNum.get(u.Number__c);
            System.debug(c);
            System.debug(u);
            if (c.Corp_Code__c == null){
                sobj.put('Corp_Code__c','');
            }else{
                sobj.put('Corp_Code__c', c.Corp_Code__c);
            }
            if (c.Dept_Number__r.Name == null){
                sobj.put('Dept_Name__c','');
            }else{
                sobj.put('Dept_Name__c', c.Dept_Number__r.Name);
            }
            if (c.Dept_Number__r.Name == null){
                sobj.put('Dept_Name__c','');
            }else{
                sobj.put('Dept_Name__c', c.Dept_Number__r.Name);
            }
            sobj.put('Applicant_Code__c', u.Number__c);
            

        }
        //sobj.put('Approval_Name__c', '請假申請流程');
        sobj.put('Bill_Date__c', Date.today());

        //Schema.SObjectType = controllerObject.getSObjectType();
        System.debug('getDescribe = ' + sobj.getSObjectType().getDescribe());

        return sobj;
    }
}