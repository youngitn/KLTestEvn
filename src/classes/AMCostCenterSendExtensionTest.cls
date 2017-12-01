@isTest
private class AMCostCenterSendExtensionTest {
    
    static testMethod void testSave() {
        Test.startTest();

        TestUtil.createBasicData();
        Custom_Approval_Managed__c cam = TestUtil.createCostCenterSend();
        cam.Dept_of_CostCenter__c = '1000L001';
        Custom_Approval_Managed_Item__c rowInfo = new Custom_Approval_Managed_Item__c();
        rowInfo.Material_Number__c = 'Z501-00083';
        rowInfo.Material_Description__c = 'ssss';
        rowInfo.Factory__c = '1000';
        rowInfo.Location_of_Storage__c = 'D05';
        AMCostCenterSendExtension extension = new AMCostCenterSendExtension(new ApexPages.StandardController(cam));
        extension.cusAP = cam;
        extension.rowID = 1;
        extension.resultRowID = 1;
        extension.selectRow = 0;
        extension.listQueryResult.add(rowInfo);
        extension.listRowInfo.add(rowInfo);
        extension.queryMaterial();
        extension.selectMaterial();
        extension.saveAction();
        extension.addBankDetail();
        extension.cancelAction();
        extension.deleteBankDetail();
        Test.stopTest();

    }
    static testMethod void testmethod2() {
        Custom_Approval_Managed__c cam = new Custom_Approval_Managed__c();
        cam.Dept_of_CostCenter__c = '1000L001';
        Custom_Approval_Managed_Item__c rowInfo = new Custom_Approval_Managed_Item__c();
        rowInfo.Material_Number__c = 'Z501-00083';
        rowInfo.Factory__c = '1000';
        rowInfo.Location_of_Storage__c = 'D05';
        Custom_Approval_Managed_Item__c rowInfo2 = new Custom_Approval_Managed_Item__c();
        rowInfo.Material_Number__c = '';
        rowInfo.Factory__c = '1000';
        rowInfo.Location_of_Storage__c = 'D05';
        AMCostCenterSendExtension extension = new AMCostCenterSendExtension(new ApexPages.StandardController(cam));
        extension.listRowInfo.add(rowInfo);
        extension.listRowInfo.add(rowInfo2);
        extension.resultRowID = 1;
        Test.startTest();
        WebServiceMockImpl wbi = new WebServiceMockImpl();
        wbi.returnJson = '{"status":"0",  "materialdata":[{"sapid__c":"Z501-00083", "material_number__c":"Z501-00083", "material_name__c":"纱手套", "material_description__c":"纱手套", "qty_stock__c":"6280.000 ",  "batch__c":""}]}';
        Test.setMock(WebServiceMock.class, wbi);
        extension.queryMaterial();
        Test.stopTest();
        extension.resultRowID =2;
        extension.queryMaterial();
    }

}