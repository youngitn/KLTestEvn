/*
 * Name                 : Custom_Approval_Managed_Item__c Trigger
 * Object               : UpdateLookupInfoHandler
 * Requirement          :生产相应的描述与代码对于查找字段以发送到SAP
 * Refer classes        :
 * Author               :zhonghui
 * Create Date          :2017年5月11日
 * Modify History       :
 *
 */
public without sharing class UpdateLookupInfoHandler implements Triggers.Handler{
    public void handle()  {    	
        if (Trigger.isBefore && (Trigger.isUpdate || Trigger.isInsert)) {
            Map<Id,Metadata__c> mapCountry;
            Set<Id> setRecTypeID = new Set<Id>();
            setRecTypeID.add(HarryUtils.getRecordTypeIdByDevNameAndObjName('Custmer_Bank_Detail','Custom_Approval_Managed_Item__c'));
            setRecTypeID.add(HarryUtils.getRecordTypeIdByDevNameAndObjName('Vendor_Bank_Info','Custom_Approval_Managed_Item__c'));
            setRecTypeID.add(HarryUtils.getRecordTypeIdByDevNameAndObjName('Tax_Type','Custom_Approval_Managed_Item__c'));
            for (Custom_Approval_Managed_Item__c cam : (List<Custom_Approval_Managed_Item__c>)Trigger.new) {
                if (setRecTypeID.contains(cam.RecordTypeId)) {
                    //自动生成相应的查找字段的代码与名称
                    if (!String.isBlank(cam.Country__c)) {
                        if (mapCountry == null) {
                            mapCountry = new Map<Id,Metadata__c>([SELECT Id,Country_Code__c,Name, Area_Code__c, City_Code__c, Privince_Code__c FROM Metadata__c WHERE RecordType.DeveloperName  = 'Country' AND RecordType.SobjectType = 'Metadata__c']);
                        }
                        cam.Country_Code__c = mapCountry.get(cam.Country__c).Country_Code__c;
                        cam.Country_Name__c = mapCountry.get(cam.Country__c).Name;
                    }
                }
            }
        }
    }
}