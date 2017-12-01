global class ApprovalSyncCheckSchedule implements Schedulable {
    global void execute(SchedulableContext sc) {
        //查询需要同步记录
        List<Metadata__c> datas = [
                SELECT ApprovalID__c,Is_Send_Succeed__c,CreatedDate,SystemModstamp 
                FROM Metadata__c 
                WHERE RecordType.DeveloperName='Approval_SyncCheck'
                AND Is_Send_Succeed__c = false ORDER BY SystemModstamp DESC
                LIMIT 4];
        if(datas.size() < 1){
            return;
        }
        System.debug(LoggingLevel.INFO, '*** datas: ' + datas);
        for (Metadata__c data :datas) {
            String targetId  = data.ApprovalID__c;
            try {
                 DELETE data;
            }
            catch (Exception e) {
                System.debug(LoggingLevel.INFO, '*** 删除节点检查数据异常: '+e.getMessage());
                continue;
            } 

            //获取当前记录的记录类型名称
            String recTypeName =  getRecordTypeName(targetId);
            System.debug(LoggingLevel.INFO, '*** recTypeName: ' + recTypeName);
            //检测记录当前审批到哪个节点
            List<ProcessInstanceNode> nodesList = 
                    [SELECT Id,ProcessNode.DeveloperName
                    FROM ProcessInstanceNode 
                    WHERE ProcessInstance.TargetObjectId =:targetId 
                    ORDER BY CreatedDate DESC ];
            System.debug(LoggingLevel.INFO, '*** nodesList: ' + nodesList);
            if(nodesList.size() < 1){
                continue;
            }
            ProcessInstanceNode node = nodesList[0];

            //检测当前审批节点是否已跳过需同步结点
            List<Organizational__c> setList =[
                    SELECT Id,Approval_Name__c,Approval_Step__c,Is_SyncCheck__c,Node_API__c  
                    FROM Organizational__c 
                    WHERE RecordType.DeveloperName = 'Node_Edit_Field'  
                    AND (Node_API__c =: node.ProcessNode.DeveloperName OR Is_SyncCheck__c = true)
                    AND Approval_Name__c =: recTypeName];
            System.debug(LoggingLevel.INFO, '*** setList: ' + setList);
            if(setList.size() < 1){
                continue;
            }
            //找出当前审批节点和要同步节点
            Organizational__c currNode = null;
            Organizational__c syncNode = null;
            for(Organizational__c org : setList){
                if(org.Node_API__c == node.ProcessNode.DeveloperName){
                    currNode = org;
                }
                if(org.Is_SyncCheck__c){
                    syncNode = org;
                }
            }
            System.debug(LoggingLevel.INFO, '*** : currNode' + currNode+'syncNode:'+syncNode);
            if(currNode != null && syncNode != null){
                    //已跳过了需同步的结点，执行同步请求
                    if(currNode.Approval_Step__c > syncNode.Approval_Step__c){
                        System.debug(LoggingLevel.INFO, '*** 已跳过需同步节点,执行接口！记录：' + targetId);
                        Utils.addToSendQueue(currNode.Approval_Name__c,targetId, '新建');
                    }
                }else{
                    System.debug('*** 节点同步配置信息不完整，请完善！'+'目前节点:'+currNode+'需同步节点'+syncNode);
            }
        }

    }
    public static void runApprovalSyncCheckSchedule(){
        ApprovalSyncCheckSchedule sc = new ApprovalSyncCheckSchedule();
        Datetime dt = Datetime.now().addSeconds(10);
        List<String> args = new List<String>();
        args.add(String.valueOf(dt.second()));
        args.add(String.valueOf(dt.minute()));
        args.add(String.valueOf(dt.hour()));
        args.add(String.valueOf(dt.day()));
        args.add(String.valueOf(dt.month()));
        args.add(String.valueOf(dt.year()));
        String fmt = String.format('{0} {1} {2} {3} {4} ? {5}',args);//指定时间执行一次
        Id sid = System.schedule('执行结点同步检测_'+ dt.format('yyMMddHHmmss.SSS'), fmt, sc);
    }

    public String getRecordTypeName(String targetId){
        if (String.isBlank(targetId)) {
            return null;
        }
        String recTypeName = '';
        for (Approval_Managed__c am : [SELECT RecordType.DeveloperName FROM Approval_Managed__c WHERE Id = :targetId]) {
            recTypeName = am.RecordType.DeveloperName;
            return recTypeName;
        }
        for (Custom_Approval_Managed__c am : [SELECT RecordType.DeveloperName FROM Custom_Approval_Managed__c WHERE Id = :targetId]) {
            recTypeName = am.RecordType.DeveloperName;
            return recTypeName;
        }
        for (Approval_Managed1__c am : [SELECT RecordType.DeveloperName FROM Approval_Managed1__c WHERE Id = :targetId]) {
            recTypeName = am.RecordType.DeveloperName;

            return recTypeName;
        }
        for (Approval_Managed2__c am : [SELECT RecordType.DeveloperName FROM Approval_Managed2__c WHERE Id = :targetId]) {
            recTypeName = am.RecordType.DeveloperName;
            return recTypeName;
        }
        return null;

    }

}