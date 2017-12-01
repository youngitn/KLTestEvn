/**
 *  工具类
 * created by Harry 2016-12-08 21:22:18
 */
public without sharing class HarryUtils {
    //最小日期
    public static final String MIN_DATE_TIME = '2000-01-01 00:00:00';
    public static final String DATE_FORMAT_STR = 'yyyy-MM-dd';//默认日期文本格式
    public static final String DATETIME_FORMAT_STR = 'yyyy-MM-dd HH:mm:ss';//默认时间文本格式
    //记录类型缓存
    private static Map<String, Map<String, Id>> recordTypeCache = new Map<String, Map<String, Id>>();
    //初始化记录类型缓存
    static {
        List<RecordType> recordTypeList = [SELECT Id, DeveloperName, SobjectType, Name FROM RecordType];
        for (RecordType recordType : recordTypeList) {
            Map<String, Id> tmpMap = null;
            if (null == recordTypeCache.get(recordType.SobjectType)) {
                tmpMap = new Map<String, Id>();
            } else {
                tmpMap = recordTypeCache.get(recordType.SobjectType);
            }
            tmpMap.put(recordType.DeveloperName, recordType.Id);
            tmpMap.put(recordType.Name, recordType.Id);
            recordTypeCache.put(recordType.SobjectType, tmpMap);
        }
    }


    /*
       往一个字符串input中的指定位置index插入字符串str
     */
    public static String insertString (String input, String str, Integer index) {
        if (input == null || index < 0 || index > input.length()) {
            return input;
        }
        return input.substring(0, index) + str + input.substring(index, input.length());
    }

    /*
        往一个文本中添加换行符，在生成pdf时用
     */
    public static String wrapWordInPdf(String input, String character, Integer width) {
        if (input == null || width <= 0) {
            return input;
        }
        Integer cnt = input.length() / width;
        String buf = input;
        String target = '</br>';
        for (Integer i = 1; i <= cnt; i++) {
            buf = insertString(buf, character, width * i + character.length() * (i - 1));
        }
        return buf;
    }
    /*
        日期转字符串
     */
    public static String date2string(Datetime dt) {
        return null == dt ? '' : dt.format(DATETIME_FORMAT_STR);
    }
    /*
        日期转指定格式的字符串
     */
    public static String date2string(Datetime dt, String formatString) {
        if (null == dt) {
            return '';
        }
        return String.isEmpty(formatString) ? date2string(dt) : dt.format(formatString);
    }
    /*
        时间转字符串
     */
    public static String date2string(Date d) {
        return null == d ? '' : Datetime.newInstance(d.year(), d.month(), d.day()).format(DATE_FORMAT_STR);
    }
    /*
        时间转指定格式的字符串
     */
    public static String date2string(Date d, String formatString) {
        if (null == d) {
            return '';
        }
        return String.isEmpty(formatString) ? date2string(d) : Datetime.newInstance(d.year(), d.month(), d.day()).format(formatString);
    }
    /*
        获取记录类型ID，参数name可以为developerName也可以是Name，sobjectType是对象名称
    */
    public static Id getRecordTypeIdByDevNameAndObjName(String name, String sobjectType) {
        return recordTypeCache.get(sobjectType).get(name);
    }
    /*
        获取指定角色的所有下属角色ID
    */
    public static Set<ID> getAllSubRoleIds(Set<ID> roleIds) {
        Set<ID> currentRoleIds = new Set<ID>();
        for (UserRole userRole : [select Id from UserRole where ParentRoleId
                                  IN :roleIds AND ParentRoleID != null]) {
            currentRoleIds.add(userRole.Id);
        }
        if (currentRoleIds.size() > 0) {
            currentRoleIds.addAll(getAllSubRoleIds(currentRoleIds));
        }
        return currentRoleIds;
    }
    /**
    *  比较对象类型,若对象compare的类型为checkType返回true,否则false
    */
    public static boolean compareObjtype(SObject compare, String checkType) {
        try {
            Schema.SObjectType targetType = Schema.getGlobalDescribe().get(checkType);
            if (targetType == null) {
                return false;
            } else if ( compare.getSObjectType() == targetType) {
                return true;
            } else {
                return false;
            }
        } catch (Exception e) {
            return false;
        }
        return false;
    }
    /**
    *   s
    */
    public static Datetime str2Dt(String dtStr){
        try{
            dtStr = dtStr.replaceAll('^(\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2})$', '$1:00');
            return Datetime.valueOf(dtStr);
        }catch(Exception e){
            return null; 
        }
    }

    public static Date str2Date(String dStr){
        try{
            return Date.valueOf(dStr);
        }catch(Exception e){
            return null;
        }
    }
    public static boolean hlyBooleanConvert(String bl){
        return bl.toUpperCase()=='Y'?true:false;
    }
}