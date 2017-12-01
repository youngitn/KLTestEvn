/**
	目的：测试流程结点审批逻辑设置
	作者：Lily
	创建时间：2017-05-27
**/
@isTest
private class ApprovalSettingControllerTest {

    static testMethod void testApprovalSetting() {
   	    ApprovalSettingController controller = new ApprovalSettingController();
   	    //设置选择流程名称
        Metadata__c meta = new Metadata__c();
        meta.Model_Group__c = 'FI';
   	    meta.Approval_Name__c = 'ExpenseReimburse';//费用报销流程
        controller.meta = meta;
   	    //增加2个步骤
   	    controller.actionAddItem();
   	    controller.actionAddItem();
   	    //将步骤1下移
   	    controller.rowID = 1;
   	    controller.downAction();
   	    //将步骤1上移
   	    controller.upAction();
   	    //删除步骤1
   	    controller.actionDeleteItem();
        //重新选择流程名称
        controller.selectChangeAction();
   	    //保存流程
        Organizational__c org = new Organizational__c();
        org.Approval_Step_Name__c = '测试步骤';
        org.Approval_Step__c = 1;
        org.Approval_Rule__c = '指定人具体字段';
        OrganizationalWrapper orgWrapper = new OrganizationalWrapper(org);
        controller.lstApprovalSettingWarpper.add(orgWrapper);
        controller.saveAction();
    }
    /*
      补充测试
    */
    static testMethod void testSupplement(){
        //当未选择流程名称的时候就点击新增步骤的情况
        ApprovalSettingController controller = new ApprovalSettingController();
        Metadata__c meta = new Metadata__c();
        meta.Model_Group__c = '';
        meta.Approval_Name__c = '';
        controller.meta = meta;
        controller.actionAddItem();
        //当选中的行数大于1点击向上移动的情况
        Metadata__c meta1 = new Metadata__c();
        meta1.Model_Group__c = 'FI';
        meta1.Approval_Name__c = 'ExpenseReimburse';//费用报销流程
        controller.meta = meta1;
        controller.actionAddItem();
        controller.actionAddItem();
        controller.rowID = 2;
        controller.upAction();
    }
       /*
      测试从配置表中查不到数据到节点表中获取数据情况
    */
    static testMethod void testNoneSetting(){
        //
        ApprovalSettingController controller = new ApprovalSettingController();
        Metadata__c meta = new Metadata__c();
        meta.Model_Group__c = 'FI';
        meta.Approval_Name__c = 'ExpenseReimburse';
        controller.meta = meta;
        controller.selectChangeAction();
    }
}