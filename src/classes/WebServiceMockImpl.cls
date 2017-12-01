@isTest
global class WebServiceMockImpl implements WebServiceMock {
   	public String returnJson{GET;SET;}
   	global void doInvoke(Object stub,Object request,Map<String, Object> response,String endpoint,String soapAction,String requestName,String responseNS,String responseName,String responseType) {
        SapSoapFunctions.ZwbSalesforceResponse_element elec = new SapSoapFunctions.ZwbSalesforceResponse_element();
        elec.SalesforceJosnExport = returnJson;
        response.put('response_x', elec); 
   }
}