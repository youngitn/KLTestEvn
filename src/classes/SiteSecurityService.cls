public without sharing class SiteSecurityService {
    public void SiteSecurityService() {

    }
    public static Boolean userValidation(PageReference page,String rtName) {
        System.debug('*** 进入Cookie检查:');

        Cookie un = page.getCookies().get('un');
        Cookie pw = page.getCookies().get('pw');
        try {
            System.debug('*** un: ' +un );
            String userName = un.getValue();
            List<Account> acc = [SELECT SAPID__c, Customer_Password__c 
                                FROM Account 
                                WHERE (SAPID__c = :userName OR Vendor_Number__c =:userName OR Customer_Number__c =:userName) 
                                AND RecordType.DeveloperName =:rtName];
            System.debug('*** acc: ' +acc );
            if (acc.size() < 1) {
                return false;
            }
            Blob requestBlob = Blob.valueOf(acc.get(0).Customer_Password__c);
            Blob hash = Crypto.generateDigest('MD5', requestBlob);
            String requestSignature = EncodingUtil.convertToHex(hash);
            System.debug('*** PW: ' + pw.getValue() );
            System.debug('*** MD5-PW: ' + requestSignature );
            if (pw.getValue() == requestSignature) {
                return true;
            } else {
                return false;
            }
            
        } catch (Exception e) {
            return false;
        }
    }
}