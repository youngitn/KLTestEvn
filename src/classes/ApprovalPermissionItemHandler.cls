/**********************************************************************
 名    称：ApprovalPermissionItemHandler
 目    的：在审批过程中，判断用户是否有权限修改记录
 作    者：刘文俊(liuwenjun@bluelinksys.com)
 创建日期：2017-06-20
 修 改 人：
 修改日期：
 修改原因：
 备    注：
*************************************************************************/
public without sharing class ApprovalPermissionItemHandler implements Triggers.Handler {
    public void handle() {
        if(System.isScheduled() || System.isBatch() || System.isFuture()){
                System.debug('*** 正在计划任务或Future中运行，可以修改记录');
                return;
        }
        //系统管理员简档
        Map<Id,Profile> mapPF = new Map<Id,Profile>([SELECT Id,Name FROM Profile WHERE Name='系统管理员' OR Name='Administrator']);
        Id uId = UserInfo.getUserId();
        Id pId = UserInfo.getProfileId();
        //记录所有人
        Id ownerId = null;
        //记录创建人
        Id creatorId = null;
        //父记录ID
        Id targetId = null;
        //记录ID
        Id recordID = null;
        //记录类型
        Map<Id,RecordType> rtMap = null;
        //权限对象
        String sobjectName = '';
        if(mapPF.containsKey(pId)){
            //如果是系统管理员，可以修改记录
            System.debug('*** 是系统管理员，可以修改记录');
            return;
        }
        Set<String> types = new Set<String>();
        //得到对象类型集合
        for(SObject obj : Trigger.new){
            String ty = String.valueOf(obj.getSObjectType());
            if(!types.contains(ty)){
                types.add(ty);
            }
        }
        //查询包含对象的记录类型
        rtMap = new Map<Id,RecordType>([SELECT Id,DeveloperName FROM RecordType WHERE SObjectType IN:types]);
        List<Schema.SObjectField> fields = new List<Schema.SObjectField>();
        //查询有批准代理人的用户
        Map<Id,User> mapUser = new Map<Id,User>([SELECT Id, DelegatedApproverId FROM User WHERE DelegatedApproverId != null AND IsActive=true]);
        //已取出的可编辑字段集合
        Map<String,Set<String>> existUpdateFields = new Map<String,Set<String>>();
        for(SObject obj : Trigger.new){
            fields = obj.getSObjectType().getDescribe().fields.getMap().values();
            sobjectName = String.valueOf(obj.getSObjectType());
            recordID = String.valueOf(obj.get('Id'));
            ownerId = String.valueOf(obj.get('OwnerId'));
            creatorId = String.valueOf(obj.get('CreatedById'));
            String rtId = String.valueOf(obj.get('RecordTypeId'));
            String rtName = rtMap.get(rtId).DeveloperName;
            String  masterRecordTypeName = '';
            Object newValue = null;//字段新值
            Object oldValue = null;//字段旧值

            if(sobjectName == 'Approval_Managed_Item__c'){
                //Containment_Action - 品质异常围堵措施
                if(rtName == 'Containment_Action'){
                    targetId = String.valueOf(obj.get('Abnormal_Containment__c'));
                    masterRecordTypeName = 'AbnormalQuality';
                }
                //Corrective_Action - 品质异常纠正措施
                else if(rtName == 'Corrective_Action'){
                    targetId = String.valueOf(obj.get('Abnormal_Header__c'));
                    masterRecordTypeName = 'AbnormalQuality';
                }
                //Quality_Problems - 品质异常问题列表
                else if(rtName == 'Quality_Problems'){
                    targetId = String.valueOf(obj.get('Abnormal_Problem__c'));
                    masterRecordTypeName = 'AbnormalQuality';
                }
                //Payment_Certificate - 费用报销凭证行信息
                else if(rtName == 'Payment_Certificate'){
                    targetId = String.valueOf(obj.get('Voucher_Info__c'));
                    masterRecordTypeName = 'ExpenseReimburse';
                }
                //Payment_Detail - 费用报销明细
                else if(rtName == 'Payment_Detail'){
                    targetId = String.valueOf(obj.get('Purchase_Info_Inquiry__c'));
                    masterRecordTypeName = 'ExpenseReimburse';
                }
                //Purchase_Price - 采购订单定价元素
                else if(rtName == 'Purchase_Price'){
                    targetId = String.valueOf(obj.get('Purchase_Order_Price__c'));
                    masterRecordTypeName = 'ExpenseReimburse';
                }
                //Purchase_Detail - 采购订单明细
                else if(rtName == 'Purchase_Detail'){
                    targetId = String.valueOf(obj.get('Purchase_Order__c'));
                    masterRecordTypeName = 'PurchaseOrder';
                }
                //PurchaseApp_Detail - 采购申请明细
                else if(rtName == 'PurchaseApp_Detail'){
                    targetId = String.valueOf(obj.get('Purchasing_Request__c'));
                    masterRecordTypeName = 'PurchaseApplication';
                }
            }else if(sobjectName == 'Custom_Approval_Managed_Item__c'){
                //Vendor_Bank_Info - 供应商银行细目
                if(rtName == 'Vendor_Bank_Info'){
                    targetId = String.valueOf(obj.get('Vendor_Bank__c'));
                    masterRecordTypeName = 'Vendor';
                }
                //Travel_Manage - 出差行程明细
                else if(rtName == 'Travel_Manage'){
                    targetId = String.valueOf(obj.get('Travel_Approval__c'));
                    masterRecordTypeName = 'BusinessTravel';
                }
                //Tax_Type - 客户税收类别
                else if(rtName == 'Tax_Type'){
                    targetId = String.valueOf(obj.get('Customer_Tax__c'));
                    masterRecordTypeName = 'Customer';
                }
                //Custmer_Bank_Detail - 客户银行细目
                else if(rtName == 'Custmer_Bank_Detail'){
                    targetId = String.valueOf(obj.get('Customer_Bank__c'));
                    masterRecordTypeName = 'Customer';
                }
                //Waste_Handle - 废料处理明细
                else if(rtName == 'Waste_Handle'){
                    targetId = String.valueOf(obj.get('Waste_Approval__c'));
                    masterRecordTypeName = 'WasteDispose';
                }
                //Dep_Cost_Center - 成本中心发料作业明细
                else if(rtName == 'Dep_Cost_Center'){
                    targetId = String.valueOf(obj.get('CostCenter_Approval__c'));
                    masterRecordTypeName = 'CostCenterSend';
                }
                //Purchase_Info_Price_Result - 采购信息询价结果
                else if(rtName == 'Purchase_Info_Price_Result'){
                    targetId = String.valueOf(obj.get('Purchase_Info_Inquiry__c'));
                    masterRecordTypeName = 'PurchaseInformation';
                }
                //Purchase_Info_Result_Detail - 采购信息询价结果行明细
                else if(rtName == 'Purchase_Info_Result_Detail'){
                    targetId = String.valueOf(obj.get('Purchase_Info_Inquiry_Row__c'));
                    masterRecordTypeName = 'PurchaseInformation';
                }
                //Sale_Order_Detail_Header - 销售订单头条件明细
                else if(rtName == 'Sale_Order_Detail_Header'){
                    targetId = String.valueOf(obj.get('Sales_Order_Header__c'));
                    masterRecordTypeName = 'SaleOrder';
                }
                //Sale_Order_Detail - 销售订单明细
                else if(rtName == 'Sale_Order_Detail'){
                    targetId = String.valueOf(obj.get('Sales_Order__c'));
                    masterRecordTypeName = 'SaleOrder';
                }
                //Sale_Order_Detail_Row - 销售订单行条件明细
                else if(rtName == 'Sale_Order_Detail_Row'){
                    targetId = String.valueOf(obj.get('Sales_Order_Detail__c'));
                    masterRecordTypeName = 'SaleOrder';
                }
            }else if(sobjectName == 'Contact'){
                //Vendor_Partner - 供应商合伙人功能
                if(rtName == 'Vendor_Partner'){
                    targetId = String.valueOf(obj.get('Vendor_Partner__c'));
                    masterRecordTypeName = 'Vendor';
                }
                //Vendor_Contact - 供应商联系人
                else if(rtName == 'Vendor_Contact'){
                    targetId = String.valueOf(obj.get('Vendor_Contact__c'));
                    masterRecordTypeName = 'Vendor';
                }
                //Account_Partner - 客户合伙人功能
                else if(rtName == 'Account_Partner'){
                    targetId = String.valueOf(obj.get('Customer_Partner__c'));
                    masterRecordTypeName = 'Customer';
                }
                //Account_Contact - 客户联系人
                else if(rtName == 'Account_Contact'){
                    targetId = String.valueOf(obj.get('Customer_Contact__c'));
                    masterRecordTypeName = 'Customer';
                }
                //Sale_Order_Partner - 销售订单合伙人
                else if(rtName == 'Sale_Order_Partner'){
                    targetId = String.valueOf(obj.get('Sales_Order_Partner__c'));
                    masterRecordTypeName = 'SaleOrder';
                }
            }
            Set<Id> aId = Utils.getApprovalUser(targetId);
            //如果记录未提交待审批，不计算权限
            if(aId == null){
                continue;
            }
            //审批人的批准代理人
            for (Id userID : aId) {
                if (mapUser.containsKey(userID)) {
                    aId.add(mapUser.get(userID).DelegatedApproverId);
                }
            }
            //没有父记录，则跳过
            if (targetId == null) {
                continue;
            }
            //如果是记录所有人或记录创建人或者当前审批人，可以修改记录
            if(ownerId == uId || creatorId == uId ||  aId.contains(uId)){
                System.debug('*** 是记录所有人或记录创建人或者当前审批人，可以修改记录');
                //得到当前审批节点可以更新字段集合
                Set<String> ableUpdateFields = new Set<String>();
                
                if(existUpdateFields.containsKey(targetId)){
                    ableUpdateFields = existUpdateFields.get(targetId);
                }else{
                    Map<String,Set<String>> updateFields = Utils.getNodeEditFields(targetId,masterRecordTypeName);
                    ableUpdateFields = updateFields.get('detail');
                    existUpdateFields.put(targetId,ableUpdateFields);
                }


                for(Schema.SObjectField fld : fields){
                    String field = String.valueOf(fld);
                    newValue = obj.get(field);
                    //是自定义字段且不包含在节点可编辑字段设置中
                    //比较值是否发生变动
                    if(field.endsWith('__c') && !ableUpdateFields.contains(field)){
                        oldValue = Trigger.oldMap.get(recordID).get(field);
                        if(newValue != oldValue){
                                System.debug('*** 更新字段不在可更新设置中!字段:' +field+' 新值：'+newValue+'旧值:'+oldValue);
                                obj.addError(Label.No_Permission+'字段:' +field+' 新值：'+newValue+'旧值:'+oldValue);
                            break;
                        }
                    }

                    /*由于项次有多个表行的原因，单个表可以进行必输控制，多个表就不可以进行必输控制了，因为
                    第二张表不一定需要输入这个字段，但是无法根据表的记录类型进行判断字段是否为NULL
                    */
                }

            }else{
                System.debug('*** 无编辑对象权限!');
                obj.addError(Label.No_Permission);
                break;
            }
        }
    }
}