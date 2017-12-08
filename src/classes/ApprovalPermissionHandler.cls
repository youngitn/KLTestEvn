/**********************************************************************
 名    称：ApprovalPermissionHandler
 目    的：在审批过程中，判断用户是否有权限修改记录
 作    者：刘文俊(liuwenjun@bluelinksys.com)
 创建日期：2017-06-19
 修 改 人：Young
 修改日期：20171201
 修改原因：必輸訊息欄位顯示標簽名稱
 备    注：
*************************************************************************/
public without sharing class ApprovalPermissionHandler implements Triggers.Handler {
    public void handle() {
        System.debug(LoggingLevel.INFO, '*** 我进去了: ');
        if (Trigger.isBefore && Trigger.isUpdate) {
            System.debug('*** 进入用户权限检查Handler');
            if(System.isScheduled() || System.isBatch() || System.isFuture()){
                System.debug('*** 正在计划任务或Future中运行，可以修改记录');
                return;
            }
            //系统管理员
            Map<Id,Profile> mapPF = new Map<Id,Profile>([SELECT Id,Name FROM Profile WHERE Name='系统管理员' OR Name='Administrator']);
            Id uId = UserInfo.getUserId();
            System.debug(LoggingLevel.INFO, '*** uId: ' + uId);
            Id pId = UserInfo.getProfileId();
            //记录所有人
            Id ownerId = null;
            //记录创建人
            Id creatorId = null;
            //记录ID
            Id targetId = null;
            //记录类型ID
            Id recTypeID = null;
            //权限对象
            String sobjectName = '';
            if(mapPF.containsKey(pId)){
                //如果是系统管理员，可以修改记录
                System.debug('*** 是系统管理员，可以修改记录');
                return;
            }
            System.debug('*** 进入权限判断');
            Object newValue = null;//字段新值
            Object oldValue = null;//字段旧值


            List<Schema.SObjectField> fields = new List<Schema.SObjectField>();
            for(SObject obj : Trigger.new){
                fields = obj.getSObjectType().getDescribe().fields.getMap().values();
                targetId = String.valueOf(obj.get('Id'));
                ownerId = String.valueOf(obj.get('OwnerId'));
                creatorId = String.valueOf(obj.get('CreatedById'));
                recTypeID = String.valueOf(obj.get('RecordTypeId'));
                sobjectName = String.valueOf(obj.getSObjectType());
                
                //记录当前审批人
                Set<Id> aId = Utils.getApprovalUser(targetId);
                //如果记录未提交待审批，不计算权限
                if(aId == null){
                    continue;
                }
                 //当前审批人的代理人也得有权限
                for (User u :[SELECT DelegatedApproverId FROM User WHERE Id IN:aId AND DelegatedApproverId != null AND IsActive =true]) {
                    if (!aId.contains(u.DelegatedApproverId)) {
                        aId.add(u.DelegatedApproverId);
                    }
                }
                System.debug(LoggingLevel.INFO, '*** Limits.getAggregateQueries(): ' + Limits.getAggregateQueries());
                //如果是记录所有人或记录创建人或者当前审批人，可以修改记录
                System.debug(LoggingLevel.INFO, '*** 创建人ID: ' + creatorId+' 记录所有人:'+ownerId+'当前审批人：'+aId+' 当前用户:'+uId);
                if(ownerId == uId  || creatorId == uId ||  aId.contains(uId)){
                    System.debug('*** 是记录所有人或记录创建人或者当前审批人，可以修改记录');
                    //得到当前审批节点可以更新字段集合
                    Map<String,Set<String>> updateFields = Utils.getNodeEditFields(targetId,recTypeID);

                    //判断表头可编辑字段
                    Set<String> ableUpdateFields = updateFields.get('main');
                    //判断表头必输字段
                    Set<String> mainRequireFields = updateFields.get('mainrequire');
                    for(Schema.SObjectField fld : fields){
                        String field = String.valueOf(fld);
                        //审批用户字段不包含在检查中
                        if(field.toLowerCase().startsWith('approval_user') && field.endsWith('__c')){
                            continue;
                        }

                        newValue = obj.get(field);
                        
                        System.debug('*** 判断编辑');
                        //是自定义字段且不包含在节点可编辑字段设置中
                        if(field.endsWith('__c') && !ableUpdateFields.contains(field)){
                            //获取字段新旧值
                            
                            oldValue = Trigger.oldMap.get(targetId).get(field);
                            //比较值是否发生变动
                            if(newValue != oldValue){
                                System.debug('*** 更新字段不在可更新设置中!字段:' +field+' 新值：'+newValue+'旧值:'+oldValue);
                                obj.addError(Label.No_Permission+'字段:' +field+' 新值：'+newValue+'旧值:'+oldValue);
                                break;
                            }
                        }
                        System.debug('*** 判断必输');
                        //是自定义字段且包含在节点必输字段设置中
                        if(field.endsWith('__c') && mainRequireFields.contains(field)){
                            //获取字段值
                            newValue = obj.get(field);

                            //比较值是否发生变动
                            if(newValue == null){
                                System.debug('*** 必输字段:' +field );
                                //20171201取得欄位字段標籤
                                Map<String, Schema.SObjectField> myFields = obj.getSObjectType().getDescribe().fields.getMap();
                                obj.addError('字段:' +myFields.get(field).getDescribe().getLabel() +' 必输');
                                break;
                            }
                        }
                    }


                }else{
                    System.debug('*** 无编辑对象权限!');
                    obj.addError(Label.No_Permission);
                    break;
                }
            }
        }
    }
}