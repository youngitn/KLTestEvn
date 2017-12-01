global with sharing class PropertyExtension {
    public PropertyExtension() {
        
    }

    @RemoteAction
    global static Object queryMaterial(String materialCertificateCode, String materialNumber, String stockingNO, String contractNO, String batchNO){
        String str1 = SapQueryArgCreate.createMaterialCertificateArgs(materialCertificateCode,materialNumber,stockingNO,contractNO,batchNO);
        String str2 = Utils.postToSAP(str1);
        return JSON.deserializeUntyped(str2);
    }
}