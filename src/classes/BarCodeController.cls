public without sharing class BarCodeController {
	public  Barcodebg.BarcodeAufnr wa_bg   {get; set;}
    
     public String goodsName {get;set;}
     public String sss {get;set;}
    
    public BarCodeController() {
    }
    
    public void ttest(){

    	sss = 'xxx';
    	wa_bg.enamrFirst = 'aaa';
    	wa_bg.aufnr = '111';
    }
    
    public void getPernr(){
    	wa_bg.enamrFirst = 'aaa';
    	wa_bg.aufnr = '111';
    }  

    public void getEqunr(){
    	wa_bg.enamrFirst = '1aaa';
    	wa_bg.aufnr = '2111';
    	
    }  

    public void getAufnr(){
    	wa_bg.enamrFirst = '3aaa';
    	wa_bg.aufnr = '3111';
    	
    }  
}