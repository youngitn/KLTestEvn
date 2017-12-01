/*
 * Name                 : Custom_Approval_Managed__c Trigger
 * Object               : UpdateCustomerVendorHander
 * Requirement          :客户主数据或供应商主数据生产时自动写入国家，省，市，地区描述
 * Refer classes        :
 * Author               :zhonghui
 * Create Date          :2017年4月13日
 * Modify History       :
 *
 */
public without sharing class UpdateCustomerVendorHandler implements Triggers.Handler{
    public void handle()  {
        if (Trigger.isBefore && (Trigger.isUpdate || Trigger.isInsert)) {
            Set<String> setRecordTypeName = new Set<String>{'Country','Area','City','Privince'};
            Map<Id,Metadata__c> mapCountry = new Map<Id,Metadata__c>([SELECT Id,Country_Code__c,Name, Area_Code__c, City_Code__c, Privince_Code__c 
                                            FROM Metadata__c 
                                            WHERE RecordType.DeveloperName  IN :setRecordTypeName AND RecordType.SobjectType = 'Metadata__c']);
            for (Custom_Approval_Managed__c cam : (List<Custom_Approval_Managed__c>)Trigger.new) {
                if (cam.RecordTypeId == HarryUtils.getRecordTypeIdByDevNameAndObjName('Customer','Custom_Approval_Managed__c') 
                    || cam.RecordTypeId == HarryUtils.getRecordTypeIdByDevNameAndObjName('Vendor','Custom_Approval_Managed__c')){
                    //自动生成相应的查找字段的代码与名称
                    System.debug('*** cam: ' + cam + '');
                    if (!String.isBlank(cam.Country__c)) {
                        System.debug('*** :mapCountry.get(cam.Country__c)' + mapCountry.get(cam.Country__c)+ '');
                        cam.Country_Code__c = mapCountry.get(cam.Country__c).Country_Code__c;
                        cam.Country_Name__c = mapCountry.get(cam.Country__c).Name;
                    }
                    if (!String.isBlank(cam.City__c)) {
                        cam.City_Code__c = mapCountry.get(cam.City__c).City_Code__c;
                        cam.City_Name__c = mapCountry.get(cam.City__c).Name;
                    }
                    if (!String.isBlank(cam.Area__c)) {
                        cam.Area_Code__c = mapCountry.get(cam.Area__c).Area_Code__c;
                        cam.Area_Name__c = mapCountry.get(cam.Area__c).Name;
                    }
                    if (!String.isBlank(cam.Province__c)) {
                        cam.Province_Code__c = mapCountry.get(cam.Province__c).Privince_Code__c;
                        cam.Province_Name__c = mapCountry.get(cam.Province__c).Name;
                    }
                    if (!String.isBlank(cam.Province_of_Shopping__c)) {
                        cam.Province_Code_of_Shopping__c = mapCountry.get(cam.Province_of_Shopping__c).Privince_Code__c;
                        cam.Province_Name_of_Shopping__c = mapCountry.get(cam.Province_of_Shopping__c).Name;
                    }
                    if (!String.isBlank(cam.City_of_Shopping__c)) {
                        cam.City_Code_of_Shopping__c = mapCountry.get(cam.City_of_Shopping__c).City_Code__c;
                        cam.City_Name_of_Shopping__c = mapCountry.get(cam.City_of_Shopping__c).Name;
                    }
                }
            }
        }
    }
}