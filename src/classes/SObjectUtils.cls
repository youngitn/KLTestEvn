public with sharing class SObjectUtils {
	// 物件取得所有欄位
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