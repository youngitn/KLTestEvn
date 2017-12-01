/**
	目的：从SAP查询数据相关参数创建类的测试类
	作者：Lily
	创建时间：2017-06-07
**/
@isTest
private class SapQueryArgCreateTest {
    static testMethod void testSapQueryArgCreate() {
        User thisUser = [select Id from User where Id = :UserInfo.getUserId()];
        System.runAs (thisUser) {
        	TestUtil.createBasicData();

        	SapQueryArgCreate.createSapOrganizationalQueryArgs();
        	SapQueryArgCreate.createSapRoleQueryArgs();
        	SapQueryArgCreate.createSapStaffQueryArgs();
        	SapQueryArgCreate.createSapMaterialQueryArgs('1','2','3');
        	SapQueryArgCreate.createSapMaterialQueryArgs('1','2','3','4');
        	SapQueryArgCreate.createSapCustomerOrderQueryArgs('1','待发货','2',System.today(),System.today());
        	SapQueryArgCreate.createSapCustomerContractMaterialArgs('1');
        	SapQueryArgCreate.createSapCustomerContractMaterialArgs('');
        	SapQueryArgCreate.createSapCustomerBillingQueryArgs('1',true,true,true);
        	SapQueryArgCreate.createSapOrderDetailQueryArgs('1');
            SapQueryArgCreate.createSapStaffTravelQueryArgs('1');
        	SapQueryArgCreate.createSapCustomerArgs('1');
        	SapQueryArgCreate.createSapCustomerArgs('1','2','3','4','5','6','7');
            SapQueryArgCreate.createMaterialCertificateArgs('1');
            SapQueryArgCreate.createMaterialCertificateArgs('1','2','3','4','5');
            SapQueryArgCreate.formatSAPDate(System.today());         
            SapQueryArgCreate.createVacationQuery('10210911');
        }
    }
}