/**********************************************************************
 * 
 *
 * @url: /services/apexrest/KL/SyncKlSapToSf
 * @data:
 *  {
        SAP同步直接调用此函数
    }
*************************************************************************/
@RestResource(urlMapping='/KL/SyncKlSapToSf')
global with sharing class SyncKlSapToSf {
    @HttpPost
    global static KlSapToSfRerurn doPost(String strSapKey) {
        KlSapToSfRerurn sReturn = new KlSapToSfRerurn();
        //SyncFromSapToSfSchedule.syncFromSap(strSapKey); 因为SAP无法连接测试机，防止意外，注销
        sReturn.sflag = strSapKey;
       return sReturn;
    }

}