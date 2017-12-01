global with sharing class TextPage01Extension {
    public TextPage01Extension() {
        
    }
    // 将 queryPa0001暴露到页面中，必须用GLOBAL，否则页面无法调用
    @RemoteAction   
    global static Object queryPa0001(String pernr){
        String str1 = createPa0001(pernr);
        String str2 = Utils.postToSAP(str1);
        return JSON.deserializeUntyped(str2);
    }
    
    // 配置搜索条件
    static String createPa0001(
        String pernr){
        List<Map<String,String>> lstCon = new List<Map<String,String>>();
        Integer index = 1;

        if(!String.isBlank(pernr)){
	        lstCon.add(SapQueryArgCreate.createCondition(index,'Pernr','String','=',pernr));
	        index = index + 1;
        }

        return JSON.serialize(SapQueryArgCreate.createQueryArg('TestXxf',lstCon));
    }
}