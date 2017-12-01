/*
    材质下载模板
 */


global class MaterialDownload {
    public String language {get; set;} // EL CN
    public String orient {get; set;} // H V
    public String company {get; set;} // KL PL FF
    public String tableType {get; set;} // 1
    public String header {get; set;}
    public SapMaterialCertificate.MaterialCertificate mc {get; set;}
    public MaterialDownload() {
        Map<String, String> params = ApexPages.currentPage().getParameters();

        String certificate_no = params.get('certificate_no');
        String str1 = SapQueryArgCreate.createMaterialCertificateArgs(certificate_no, '', '', '', '');
        String str2 = Utils.postToSAP(str1);
        SapMaterialCertificate certificates = (SapMaterialCertificate)JSON.deserialize(str2, SapMaterialCertificate.class);
        mc = certificates.content.get(0);

        System.debug(LoggingLevel.INFO, '*** mc: ' + mc);
        language = 'EL';
        orient = 'H';
        company = 'KL';
        tableType = '1';
        header = '1';
        if (mc.Template_Name == 'ZSD023HENKLTFFVB008') {
            language = 'EL';
            orient = 'H';
            company = 'KL';
            tableType = '1';
        }
        if (mc.Template_Name == 'ZSD023VZHKLFFFVB008') {
            language = 'CN';
            orient = 'V';
            company = 'KL';
            tableType = '1';
        }


    }
}