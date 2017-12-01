global without sharing class SiteMaterialExtension {
	public String url_Customer {Get; Set;}
    public SiteMaterialExtension() {
        System_Setting__c ssc = System_Setting__c.getValues('Setting');
        url_Customer = ssc.URL_Customer__c;
    }

    @RemoteAction
    global static Object queryMaterial(String materialCertificateCode, String materialNumber, String stockingNO, String contractNO, String batchNO){
        String str1 = SapQueryArgCreate.createMaterialCertificateArgs(materialCertificateCode,materialNumber,stockingNO,contractNO,batchNO);
        String str2 = Utils.postToSAP(str1);
        return JSON.deserializeUntyped(str2);
    }
}