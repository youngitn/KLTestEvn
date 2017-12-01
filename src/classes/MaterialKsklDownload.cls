global class  MaterialKsklDownload {
    public String tableType {get; set;} // 1
    public String header {get; set;}
    public String direction {get; set;}  //方向
    public String logo {get; set;}       //logo
    public String langu {get; set;}      //语言
    public String is_bpe {get; set;}     //是否BPE
    public String is_stamp {get; set;}   //是否有图章
    public String is_quan {get; set;}    //是否带数量
    public String is_order {get; set;}   //是否从工单出
    public SapMaterialCertificate.MaterialCertificate mc {get; set;}

    public MaterialKsklDownload() {
        Map<String, String> params = ApexPages.currentPage().getParameters();

        String certificate_no = params.get('certificate_no');
        String str1 = SapQueryArgCreate.createMaterialCertificateArgs(certificate_no, '', '', '', '');
        String str2 = Utils.postToSAP(str1);
        SapMaterialCertificate certificates = (SapMaterialCertificate)JSON.deserialize(str2, SapMaterialCertificate.class);
        mc = certificates.content.get(0);

        System.debug(LoggingLevel.INFO, '*** mc: ' + mc);
        tableType = '1';
        header = '2';

           
        str2 = mc.json_controller.replace('\\\"', '\"');
        //将SAP的非标准JSON格式替换为能识别的格式
        str2 = JsonFormatSapToSf.FormatSapToSf(str2);

        //System.debug('*** :mc.json_controller: ' + str2  + '\n');

        SiteMaterialJsonReturn args = (SiteMaterialJsonReturn)JSON.deserialize(str2,SiteMaterialJsonReturn.class);
        
        /*
        System.debug('***************************************** \n');
        System.debug('*** :direction: ' + args.direction + '\n');
        System.debug('*** :logo: ' + args.logo + '\n');
        System.debug('*** :langu: ' + args.langu + '\n');
        System.debug('*** :is_bpe: ' + args.is_bpe + '\n');
        System.debug('*** :is_stamp: ' + args.is_stamp + '\n');
        System.debug('*** :is_quan: ' + args.is_quan + '\n');
        System.debug('*** :is_order: ' + args.is_order + '\n');
        System.debug('***************************************** \n');
        */

        direction     = args.direction;
        logo          = args.logo;
        langu         = args.langu;
        is_bpe        = args.is_bpe;
        is_stamp      = args.is_stamp;
        is_quan       = args.is_quan;
        is_order      = args.is_order;

        /*
        if (mc.Template_Name == 'ZSD023HENKLTFFVB008') {
            direction = 'H';
            tableType = '1';
        }
        if (mc.Template_Name == 'ZSD023VZHKLFFFVB008') {
            direction= 'V';
            tableType = '1';
        }
        */

    }
}