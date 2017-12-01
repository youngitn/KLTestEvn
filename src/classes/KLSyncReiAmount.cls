/**********************************************************************
 * 
 *
 * @url: /services/apexrest/KL/syncReiAmount
 * @data:
 *  {
        
    }
*************************************************************************/
@RestResource(urlMapping='/KL/SyncReiAmount')
global with sharing class KLSyncReiAmount {
    @HttpPost
    global static KLSyncReiAmountReturn doPost(String strPernr,String strDate) {
 
        Integer year = Integer.valueOf(strDate.substring(0,4));
        Integer mon = Integer.valueOf(strDate.substring(5, 7));
        KLSyncReiAmountReturn klreturn = new KLSyncReiAmountReturn();
        
        /*
         List<Approval_Managed__c> amlist = [
        		SELECT Amount_of_Total__c
        		FROM Approval_Managed__c 
        		WHERE RecordType.DeveloperName = 'ExpenseReimburse'
        		AND CALENDAR_YEAR(Bill_Date__c) = :year
        		AND CALENDAR_MONTH(Bill_Date__c) = :mon
        		AND Employee_Code__c = :strPernr
        		]; 
        */
       
        AggregateResult[] groupedResults  = [
            SELECT SUM(Amount_of_Total__c)mysum
            FROM Approval_Managed__c 
        		WHERE RecordType.DeveloperName like '%ExpenseReimburse%'
        		AND Approval_Status__c = 'A'
        		AND CALENDAR_YEAR(Bill_Date__c) = :year
        		AND CALENDAR_MONTH(Bill_Date__c) = :mon
        		AND Employee_Code__c = :strPernr
            ];

         Object sumAmount = groupedResults[0].get('mysum');
         klreturn.sMoney = String.valueOf(sumAmount);
        return klreturn;
    }

}