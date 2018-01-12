@RestResource(urlMapping='/test20180112/*')
global with sharing class CaseMgmtService
{

     @HttpPost
    global static String doPost(String a,
        String b, String c) {
        
        return a+' '+b+' '+c;
    }
}