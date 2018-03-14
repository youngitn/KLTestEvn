/* 
    xxf at 20180227
    因APEX不分大小写；所以有String json= '';会导致JSON.deserialize无法正常使用
*/
global class AmSapVaxxController {

	public String InfoText {get;set;}
	public Custom_Approval_Managed__c main {get;set;}
	public Map<String,Custom_Approval_Managed_Item__c> mapItems {get;set;}
	public List<Custom_Approval_Managed_item__c> items {get;set;}
	public List<Custom_Approval_Managed_item__c> zrows {get;set;}
	public List<Custom_Approval_Managed_item__c> headers {get;set;}
	public List<Contact> partners  {get;set;}
    
    public String param{get;set;}

    public AmSapVaxxController() {
    	Map<String, String> params = ApexPages.currentPage().getParameters();
    	if(params.containsKey('vbeln')){
	    	String Vbeln = params.get('vbeln');
	    	InfoText = '订单:' + Vbeln;
	    	ListSapVaxx(Vbeln);
	    }
	    else{
            InfoText = '未找到订单编号';
	    }
    }

    public void ListSapVaxx(String Vbeln){
    	//从SAP中获取单据信息
    	String SapJson = GetSapVaxx(Vbeln); 
    	if(SapJson== null || SapJson.equals('')){
    		return;
    	}

    	//解析
    	try{    
    	    FillItems(sapJson); 
    	}catch(Exception ex){
            InfoText = '解析从SAP获取到的数据发生异常';
            System.debug('************************************************');
            System.debug('' + ex.getMessage() + '\n' + ex.getStackTraceString());
            System.debug('************************************************');
            return;
    	}

    }

    public String GetSapVaxx(String Vbeln){
    	 //拼接对应的JSON数据:随便用旧的方式（WEBSERVICES）还是新的方式(HTTP REST)
    	String strReturn = '';
        String strJson = 'fun_name =sfsapvaxx&vbeln=';
        strJson = strJson + Vbeln;
        //获取对应的SAP信息
        try{
	        HttpRest httprest = new HttpRest();
	        strReturn = httprest.HttpGetSap(strJson);    
        }catch(Exception ex){
        	InfoText = '从SAP获取数据失败';
            System.debug('************************************************');
            System.debug('' + ex.getMessage() + '\n' + ex.getStackTraceString());
            System.debug('************************************************');
            System.debug(strJson);
            return '';
        }
        return strReturn ;

    }

    public void FillItems(String sapJson){

    	SyncSapToSfReturnArgs args = null;
    	try{
	    	args = (SyncSapToSfReturnArgs)JSON.deserialize(sapJson,SyncSapToSfReturnArgs.class);
    	}catch(Exception ex){
            InfoText = '从SAP获取数据失败';
            System.debug('************************************************');
            System.debug('' + ex.getMessage() + '\n' + ex.getStackTraceString());
            System.debug('************************************************');
            return;
    	}
    	//填充到行项目
    	main = (Custom_Approval_Managed__c)JSON.deserialize(JSON.serialize(args.content.main), Custom_Approval_Managed__c.class);
        System.debug(LoggingLevel.INFO, '*** main: ' + main);

        mapItems = new Map<String,Custom_Approval_Managed_Item__c>();
        items = new List<Custom_Approval_Managed_item__c> ();
        zrows = new List<Custom_Approval_Managed_item__c> ();
        headers = new List<Custom_Approval_Managed_item__c> ();
        partners = new List<Contact> ();

        if(args.content.details.containsKey('items')){
            items = (List<Custom_Approval_Managed_item__c>)JSON.deserialize(JSON.serialize(args.content.details.get('items')), List<Custom_Approval_Managed_item__c>.class);
            for(Custom_Approval_Managed_item__c citems:items){
                //因为公式字段不能赋值，所以前台用其他未用到的变量进行显示
                //citems.Price_Net_P__c = citems.Price_Net__c; 
                citems.Price_of_Last__c = citems.Price_Net__c;
            }
        }
        if(args.content.details.containsKey('zrows')){
            zrows = (List<Custom_Approval_Managed_item__c>)JSON.deserialize(JSON.serialize(args.content.details.get('zrows')), List<Custom_Approval_Managed_item__c>.class);
        }

        if(args.content.details.containsKey('partners')){
           partners = (List<Contact>)JSON.deserialize(JSON.serialize(args.content.details.get('partners')), List<Contact>.class);
       }

       if(args.content.details.containsKey('headers')){
           headers = (List<Custom_Approval_Managed_item__c>)JSON.deserialize(JSON.serialize(args.content.details.get('headers')), List<Custom_Approval_Managed_item__c>.class);
        }


    }
    
    /* 测试行项目再开窗
    public PageReference redirectToBlankPage(){
        system.debug('=============param : ' + param);
        String newPage = '/apex/TextPage001';
        newPage = newPage + '?vbeln='+main.SAPID__c+'&posnr=' + param;
        PageReference ref = new PageReference(newPage);
        return ref;
    }
    */
}