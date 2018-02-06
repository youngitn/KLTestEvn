public with sharing class xxftest {
	public String exeHttpPost(){
		HttpRequest req = new HttpRequest();
		//dev
	    String Url = 'http://59.120.231.206:8000/sap/bc/zhttp_rest?sap-client=400';
	    req.setEndpoint(Url);
	    req.setMethod('POST');

        /*
	    String username = 'zsap03';
	    String password = 'sexrabbits';
	    Blob headerValue = Blob.valueOf(username + ':' + password);
	    String authorizationHeader = 'BASIC ' +
	    EncodingUtil.base64Encode(headerValue);
	    System.debug('************ ' +  authorizationHeader  );	   

	    req.setHeader('Authorization', authorizationHeader);
	     */

	    req.setBody('{\"approval\":\"SF_SYNC_PT60\"}');

	    Http http = new Http();
	    HTTPResponse res = http.send(req);
	    System.debug('************ xxf2');

	    String str = res.getBody();
	    //System.debug(res.getBody());

	    str = KlCommon.FormatSapJsonToSf(str);
	    System.debug(str);
	    return '';
	}
}