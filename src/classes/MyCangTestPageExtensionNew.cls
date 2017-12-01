global with sharing class MyCangTestPageExtensionNew {

	    public String test1 {Get; Set;}

  		public String test2 {Get; Set;}
	
    public MyCangTestPageExtensionNew() {
            test1 = '你好';
    }
     //刷新页面更换语言
     public void refresh()
     {

		
     }
	@RemoteAction
    global static Object queryCustomer(String test2){
    	//SapQueryArgCreate.createCustomerTestcateArgs 对数据处理 返回Json
    	String statusName =system.currentPageReference().getParameters().get('test2');
      	System.debug(LoggingLevel.INFO, '*** test2: ' + statusName);
        return test2;
    }

}