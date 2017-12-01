public with sharing class DatumExtension {
	public List<Document> DocumentList{Get;Set;}
	public String language{Get;Set;}
    public DatumExtension(ApexPages.StandardController controller) {
         language=Apexpages.currentPage().getParameters().get('language');
         if(language=='')
         {
            language='zh-CN';
         }
         //获取文档对象文件夹为客户门户目录的文档信息
        DocumentList=[SELECT Id, Name,Description,DeveloperName 
                        FROM Document 
                        WHERE FolderId='00lO0000000gNA1IAM'];
    }
}