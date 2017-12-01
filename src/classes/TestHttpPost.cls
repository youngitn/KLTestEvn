@RestResource(urlMapping='/KL/TestHttpPost')
global with sharing class TestHttpPost {
    @HttpPost 	
    global static String doPost(String myString) {
    	return '+++' + myString;
    }
}