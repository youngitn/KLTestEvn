global without sharing class SiteMaterialExtension {
	public String url_Customer {Get; Set;}
    public String userName {Get; Set;}
    public SiteMaterialExtension() {
        System_Setting__c ssc = System_Setting__c.getValues('Setting');
        url_Customer = ssc.URL_Customer__c;
       
        try{

            Cookie un = ApexPages.currentPage().getCookies().get('un');
            userName = un.getValue();
        }catch(Exception e){
            userName = '000';
        }
        
        //?nokunnr=x用于后门，不用账号登入
        String sflag = '';
        Map<String,String> args = Apexpages.currentPage().getParameters();
        if(args.containsKey('nokunnr')){
            sflag = Apexpages.currentPage().getParameters().get('nokunnr');
        }
        if(sflag != null &&  !sflag.equals('')){
            userName = '';
        }
       
    }

    @RemoteAction
    global static Object queryMaterial(String materialCertificateCode, String materialNumber, String stockingNO, String contractNO, String batchNO,String kunnr){
        //String str1 = SapQueryArgCreate.createMaterialCertificateArgs(materialCertificateCode,materialNumber,stockingNO,contractNO,batchNO);
        String str1 = createMaterialCertificateArgs(materialCertificateCode,materialNumber,stockingNO,contractNO,batchNO,kunnr);
        
        String str2 = Utils.postToSAP(str1);
        return JSON.deserializeUntyped(str2);
    }

    public static String createMaterialCertificateArgs(
                                            String materialCertificateCode,
                                            String materialNumber,
                                            String stockingNO,
                                            String contractNO,
                                            String batchNO,
                                            String kunnr){
        List<Map<String,String>> lstCon = new List<Map<String,String>>();
        Integer index = 1;
        if(!String.isBlank(materialCertificateCode)){
            //材证编号
            lstCon.add(SapQueryArgCreate.createCondition(index,'Material_Certificate_Code','String','=',materialCertificateCode));
            index = index + 1;
        }
        if(!String.isBlank(materialNumber)){
            //物料号
            lstCon.add(SapQueryArgCreate.createCondition(index,'Material_Number','String','=',materialNumber));
            index = index + 1;
        }
        if(!String.isBlank(stockingNO)){
            //备货单号
            lstCon.add(SapQueryArgCreate.createCondition(index,'Stocking_NO','String','=',stockingNO));
            index = index + 1;
        }
        if(!String.isBlank(contractNO)){
            //合同号
            lstCon.add(SapQueryArgCreate.createCondition(index,'Contract_NO','String','=',contractNO));
            index = index + 1;
        }
        if(!String.isBlank(batchNO)){
            //批次
            lstCon.add(SapQueryArgCreate.createCondition(index,'Batch_NO','String','=',batchNO));
            index = index + 1;
        }
        if(!String.isBlank(kunnr)){
            lstCon.add(SapQueryArgCreate.createCondition(index,'kunnr','String','=',kunnr));
            index = index + 1;
        }
        return JSON.serialize(SapQueryArgCreate.createQueryArg('MaterialCertificate',lstCon));
    }

}