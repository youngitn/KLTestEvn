@isTest
private class AMAbnormalQualityExtensionTest {
	//测试AMAbnormalQualityExtension save方法
    static testMethod void testSave() {
        
        Test.startTest();

        TestUtil.createBasicData();

        List<Contact> cons = [SELECT Id FROM Contact WHERE RecordType.DeveloperName='Staff' LIMIT 20];
        Approval_Managed__c am =TestUtil.createAbnormalQuality();
        am.Operator_Abnormal__c = cons[1].Id;

        AMAbnormalQualityExtension ext = new AMAbnormalQualityExtension(new ApexPages.StandardController(am));
        ext.containmentRow = 0;
        ext.problemRow = 0;
        ext.rectifyRow = 0;
        ext.save();
        ext.cancel();
        ext.newContainment();
        ext.deleteContainment();
        ext.selectedProblem();
        ext.newRectify();
        ext.deleteRectify();

        //测试更新操作
        //Approval_Managed__c am1 = [SELECT Id,Operator_Abnormal__c FROM Approval_Managed__c WHERE Id =:am.Id];
        //am1.Operator_Abnormal__c = cons[15].Id;
        //UPDATE am1;

        Test.stopTest();
    }
}