public with sharing class TestPage01PdfExt {
	public String pernr{get;set;}
	public String ename{get;set;}
    public TestPage01PdfExt() {
         Map<String,String> params = ApexPages.currentPage().getParameters();

        pernr = params.get('pernr');
        ename = params.get('ename');
    }
}