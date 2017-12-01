// **************************************************************************************************
//  * Name: BillExtension
//  * Object:
//  * Purpose: 获取账单信息Extension
//  * Requirement:
//  * Author: luoxin
//  * Create Date: 2017-3-24
//  * Modify History:
// *****************************************************************************************************

global with sharing class BillExtension {
    public String language {Get; Set;}
    public BillExtension() {
    }

    @RemoteAction
    global static Object queryBill(String customercode, Boolean hasBeenInvoiced, Boolean notInvoiced, Boolean prepayment) {
        String str1 = SapQueryArgCreate.createSapCustomerBillingQueryArgs(customercode,hasBeenInvoiced,notInvoiced,prepayment);
        System.debug(LoggingLevel.INFO, '*** str1: ' + str1);
        String str2  = Utils.postToSAP(str1);
        return JSON.deserializeUntyped(str2);
    }
}