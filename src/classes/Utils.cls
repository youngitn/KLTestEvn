/*
    目    的：工具类
    作    者：刘文俊(liuwenjun@bluelinksys.com)
    创建日期：2017-03-29
    修 改 人：Young
    修改日期：20171206
    修改原因：增加子項必填資訊回傳方法:getDetailRequireFields
    备    注：所有公共方法都放在此类中，公共方法都为: public static
*/
public without sharing class Utils
{
    /*
        目　的：从SF传送数据到SAP
        参数 1：approvalName - 流程名称(对应SapApprovalEnum)
        参数 2：approvalID - 流程ＩＤ
        参数 3：operateName - 操作名称(新建/修改/冻结)
        返回值：
    */
    public static void addToSendQueue(String approvalName, String approvalID, String operateName)
    {
        Metadata__c md = new Metadata__c();
        md.RecordTypeId = getRecordTypeId('Metadata__c', 'SF_To_SAP_Queue');
        md.ApprovalID__c = approvalID;
        md.Approval_Name__c = approvalName;
        md.Operate__c =  (operateName == '新建' ? SapOperateEnum.INSERTED : operateName == '修改' ? SapOperateEnum.UPDATED : SapOperateEnum.FROZEN);
        md.Is_Send_Succeed__c = false;
        md.Send_Direction__c = 'SF_TO_SAP';
        Insert md;

        //生成一个计划任务去同步数据到SAP
        // SyncFromSfToSapSchedule.createNewSchedule();

        /*
        changed by zhonghui  17-12-19
        两种方式调用发送数据接口，可系统设置
        true:   接口及时发送数据，不用计划任务发送.试用，看能否防止单据重复发送情况
        false: 接口通过计划任务发送数据到SAP
        */
        SAP_Interface_Setting__c sis = SAP_Interface_Setting__c.getValues('SapSetting');
        if (sis.Is_Now_To_Sap__c)
        {
            SyncFromSfToSapSchedule.syncToSAP_Now(md.Id, true);
        }
        else
        {
            SyncFromSfToSapSchedule.createNewSchedule();
        }
    }
    /*
        目　的：从SAP同步数据到SF
        参数 1：approvalName - 流程名称(对应SapApprovalEnum)
        参数 2：keyno - SAP同步Keyno值
        参数 3：syncSucceed - 同步是否成功
        参数 4：message - 同步失败时的错误信息
        返回值：
    */
    public static void addToSyncQueue(String approvalName, String keyno, Boolean syncSucceed, String message)
    {
        if(String.isBlank(keyno))
        {
            return;
        }
        List<Metadata__c> jobs = [
                                     SELECT Id, Approval_Name__c, ApprovalID__c, Operate__c, Is_Send_Succeed__c, Send_Count__c,
                                     Send_Error_Message__c, Send_DateTime__c, Send_Direction__c, Is_Notify_Sap__c
                                     FROM Metadata__c
                                     WHERE ApprovalID__c = :keyno
                                             AND Send_Direction__c = 'SAP_TO_SF'
                                                     AND RecordType.DeveloperName = 'SF_To_SAP_Queue'];
        Metadata__c md = null;
        if(jobs.size() > 0)
        {
            md = jobs[0];
            md.Send_Count__c = md.Send_Count__c + 1;
        }
        else
        {
            md = new Metadata__c();
            md.Send_Count__c = 1;
            md.RecordTypeId = getRecordTypeId('Metadata__c', 'SF_To_SAP_Queue');
        }
        md.ApprovalID__c = keyno;
        md.Approval_Name__c = approvalName;
        md.Is_Notify_Sap__c = false;
        md.Operate__c =  SapOperateEnum.INSERTED;
        md.Is_Send_Succeed__c = syncSucceed;
        md.Send_Error_Message__c = message;
        md.Send_DateTime__c = Datetime.now();
        md.Send_Direction__c = 'SAP_TO_SF';
        UPSERT md;

        System_Setting__c ssc = System_Setting__c.getValues('Setting');
        Integer maxSendCount = Integer.valueOf(ssc.SF_Send_Count__c);
        String emailAddr = ssc.Error_Message_Email__c;
        //发送邮件提醒
        if(md.Send_Count__c >= maxSendCount && !message.containsIgnoreCase('成功'))
        {
            Messaging.SingleEmailMessage el = new Messaging.SingleEmailMessage();
            //发送地址
            List<String> address = new List<String>();
            address.add(emailAddr);
            el.setToAddresses(address);
            el.setSubject('从SAP同步数据到Salesforce出错');
            el.setHtmlBody('管理员：<br/> 【keyno:' + keyno + '】从SAP同步到Salesforce时出错，请处理!<br/>错误原因：' + message);
            //发送邮件
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {el});
        }
    }
    /*
        目　的：查询流程在审批状态中可以编辑的字段
        参  数：targetId - 流程ID
        参  数：recType -对应的记录类型Id
        返回值：String 可编辑字段的字符串拼接
    */
    public static String getApprovalPageEditFields(String targetId, String recType)
    {
        Set<String> ableUpdateFields = new Set<String>();
        String szAbleEditFields = '';
        //如果没有当前审批人，则记录不在审批状态，都可以编辑，如果在审批状态,则计算哪些字段或编辑
        Set<Id> aId = Utils.getApprovalUser(targetId);
        Id uId = UserInfo.getUserId();
        if(aId != null && aId.contains(uId))
        {
            Map<String, Set<String>> updateFields = Utils.getNodeEditFields(targetId, recType);
            ableUpdateFields = updateFields.get('main');
            Set<String> dmap = updateFields.get('detail');
            for(String field : dmap)
            {
                if(!ableUpdateFields.contains(field))
                {
                    ableUpdateFields.add(field);
                }
            }
            for (String s : ableUpdateFields)
            {
                szAbleEditFields = szAbleEditFields + ',' + s;
            }
        }
        return szAbleEditFields;
    }
    /*
        目　的：返回列表中指定位置的值
        参数 1：lstIds - 流程名称(对应SapApprovalEnum)
        参数 2：index - 流程ＩＤ
        返回值：Id
    */
    public static Id getByIndex(List<Id> lstIds, Integer index)
    {
        if (lstIds == null)
        {
            return null;
        }
        if(lstIds.size() >= index + 1)
        {
            return lstIds[index];
        }
        else if(index > 0 && lstIds.size() > 0)
        {
            return lstIds[0];
        }
        else
        {
            return null;
        }
    }
    /*
        目　的：从SAP查询或传送数据到SAP
        参　数：jsonArgs - JSON字符串
        返回值：JSON字符串
    */
    public static String postToSAP(String jsonArgs)
    {
        SAP_Interface_Setting__c sis = SAP_Interface_Setting__c.getValues('SapSetting');
        SapSoapFunctions.ZWB_SF callWeb = new SapSoapFunctions.ZWB_SF();
        callWeb.endpoint_x = sis.EndPoint__c;//http://59.120.231.208:8000/sap/bc/srt/rfc/sap/zwb_sf/620/zwb_sf/zwb_sf
        callWeb.clientCert_x = sis.UserName__c;//'ZSAP03';
        callWeb.clientCertPasswd_x = sis.Password__c;//'sexrabbits';
        callWeb.timeout_x = Integer.valueOf(sis.Timeout__c);//60000
        Map<String, String> header = new Map<String, String>();
        header.put('Content-Type', 'text/xml;charset=UTF-8');
        callWeb.inputHttpHeaders_x = header;
        String str = '';
        String args = jsonArgs.replaceAll(': *?"(\\d{4})-(\\d{2})-(\\d{2})"', ': "$1$2$3"');

        System.debug('*** SF传送给SAP的数据: ' + args);

        //如果调用出错,调用5次
        Integer maxTimes = Integer.valueOf(sis.Max_Repeat_Time__c);
        Integer icount = 0;
        while(icount < maxTimes)
        {
            try
            {
                str = callWeb.ZwbSalesforce(args);
                icount = maxTimes;
            }
            catch(Exception ex)
            {
                icount = icount + 1;
                System.debug('*** 调用SAP Web Service错误：' + ex.getMessage() + '\n' + ex.getStackTraceString());
            }
        }
        //处理SAP返回的NULL值
        str = str.replace('"00000000"', '""').replace('"9999-12-31"', '"2099-12-31"').replace('"0000-00-00"', '""');
        //处理JSON字符串太长的问题
        String jsonResult = '';
        Boolean bl = true;
        Integer maxLen = 50000;
        while(bl)
        {
            if(str.length() > maxLen)
            {
                String tmp = str.substring(0, maxLen);
                str = str.substring(maxLen);
                Integer ind = tmp.lastIndexOf('},');
                str = tmp.substring(ind + 1) + str;
                tmp = tmp.substring(0, ind + 1);
                tmp = tmp.replaceAll('"*(\\w+)"*:\\s*(["\\[{])', '"$1":$2');
                tmp = tmp.replaceAll('"\\w+": {0,1}"",', '');
                tmp = tmp.replaceAll(', {0,1}"\\w+": {0,1}"" {0,1}}', '}');
                jsonResult = jsonResult + tmp;
            }
            else
            {
                str = str.replaceAll('"*(\\w+)"*:\\s*(["\\[{])', '"$1":$2');
                str = str.replaceAll('"\\w+": {0,1}"",', '');
                str = str.replaceAll(', {0,1}"\\w+": {0,1}"" {0,1}}', '}');
                jsonResult = jsonResult + str;
                bl = false;
            }
        }

        System.debug('*** SAP返回结果JSON: ' + jsonResult);

        return jsonResult;
    }
    /*
        目　的：查询流程对应的SQL
        参　数：approvalName - 流程名称
        返回值：SQL
    */
    public static String getApprovalSQL(String approvalName, Boolean isLong)
    {
        List<Metadata__c> sqls = [SELECT SQL_Long__c, SQL_Short__c
                                  FROM Metadata__c
                                  WHERE RecordType.DeveloperName = 'Query_SQL'
                                          AND Approval_Name__c = : approvalName];
        System.debug(LoggingLevel.INFO, '*** approvalName: ' + approvalName);
        System.debug(LoggingLevel.INFO, '*** sqls: ' + sqls);
        if(sqls.size() > 0)
        {
            if(isLong)
            {
                return sqls[0].SQL_Long__c;
            }
            else
            {
                return sqls[0].SQL_Short__c;
            }
        }
        else
        {
            return '';
        }
    }
    /*
        目 的：查询记录类型
        参数1：sobjectName - 对象名称
        参数2：developerName_OR_Name - 记录类型名称或API名称
    */
    public static Id getRecordTypeId(String sobjectName, String developerName_OR_Name)
    {
        List<RecordType> rtList = [SELECT Id, DeveloperName, SobjectType, Name
                                   FROM RecordType
                                   WHERE SobjectType = : sobjectName
                                           AND (DeveloperName = : developerName_OR_Name OR Name = : developerName_OR_Name)];
        if(rtList.size() > 0)
        {
            return rtList[0].Id;
        }
        else
        {
            return null;
        }
    }
    /*
        目 的：通过用户ID查询联系人ID
        参数1：uID - 用户ID
    */
    public static Id getContactIdByUserID(String uID)
    {
        if (String.isBlank(uID))
        {
            return null;
        }
        User sUser = [SELECT Id, Number__c FROM User WHERE Id = : uID];
        List<Contact> lstContact = new List<Contact>();
        if (!String.isBlank(sUser.Number__c))
        {
            lstContact = [SELECT Id FROM Contact Where Number__c = :sUser.Number__c];
        }
        if(lstContact.size() > 0)
        {
            return lstContact[0].Id;
        }
        else
        {
            return null;
        }
    }
    /*
        目 的：通过联系人ID查询用户ID
        参数1：cID - 联系人ID
    */
    public static Id getUserIdByContactID(String cID)
    {
        List<Contact> lstContact = [SELECT Id, Number__c, SF_User__c FROM Contact WHERE Id = : cID AND SF_User__r.IsActive = true];
        if(lstContact.size() > 0)
        {
            return lstContact[0].SF_User__c;
        }
        else
        {
            return null;
        }
    }
    /*
        目  的：把SapWebServiceInputArgs序列化为Json字符串
        参数 1：operate - 操作方式(INSERT : 新建  UPDATE : 更新)
        参数 2：approval - 流程名称
        参数 3：main - 主记录数据
        参数 4：details - 明细项数据
        结  果：Json字符串
    */
    public static String serializeToJson(String operate, String approval, Map<String, String> main, Map<String, List<Map<String, String>>>details)
    {
        SapContentOfArgs content = new SapContentOfArgs();
        content.main = main;
        content.details = details;
        SapWebServiceInputArgs args = new SapWebServiceInputArgs();
        args.operate = operate;
        args.approval = approval;
        args.content = content;

        return JSON.serialize(args);
    }
    /*
        目 的：把SObject类型转换为Map数组
        参 数：SObject类型
        结 果：字段名值对的一个Map
    */
    public static Map<String, String> convertSObjectToMap(SObject obj)
    {
        Map<String, String> mapFieldValue = new Map<String, String>();
        System.debug('*** 序列化后数据：' + JSON.serialize(obj));
        JSONParser parse = JSON.createParser(JSON.serialize(obj));
        while(parse.nextToken() != null)
        {
            parse.nextValue();
            String name = parse.getCurrentName();
            if(String.isBlank(name) || name == 'attributes')
            {
                parse.skipChildren();
            }
            else
            {
                mapFieldValue.put(name, parse.getText());
            }
        }
        return mapFieldValue;
    }
    /*
        目 的：审批节点设置中，通过指定部门找到对应的部门主管用户,没有则找上级部门主管
        参数1：deptID - 指定部门ID
        返回值：返回相关部门主管用户Id：

    */
    public static Id approvalSearchUserByDept(Id deptID)
    {
        if (String.isBlank(deptID))
        {
            return null;
        }
        Organizational__c org = [SELECT Id, Dept_Post_Number__c, Dept_Number__c, Parent_Number__c
                                 FROM Organizational__c
                                 WHERE Id = : deptID];
        //通过部门的主岗位编号查询岗位负责人
        System.debug(LoggingLevel.INFO, '查找: ' + org.Dept_Post_Number__c);
        List<Organizational__c> lstorgJob = [SELECT Id, Post_Number__c, Post_Manager__c, Post_Dept_Number__c, Post_Manager__r.SF_User__c
                                             FROM Organizational__c
                                             WHERE  Post_Number__c = :org.Dept_Post_Number__c AND RecordType.SObjectType = 'Organizational__c'
                                                     AND RecordType.DeveloperName = 'Job_Title'
                                                             LIMIT 1];
        if (lstorgJob.size() > 0)
        {
            if (!String.isBlank(lstorgJob[0].Post_Manager__c))
            {
                return lstorgJob[0].Post_Manager__r.SF_User__c;
            }
            else
            {
                //找上级部门的负责人
                return Utils.approvalSearchUserByDept(org.Parent_Number__c);
            }
        }
        else
        {
            System.debug(LoggingLevel.INFO, '*** 未找到相关部门岗位负责人！部门: ' + org);
            //找上级部门的负责人
            return Utils.approvalSearchUserByDept(org.Parent_Number__c);
            //return null;
        }
    }
    /*
        目 的：审批节点设置中，通过指定部门找到对应的层级的部门主管用户
        参数1：deptID - 指定部门ID
        参数2: deptLevel - 指定的部门层级
        返回值：返回对应层级部门主管用户Id：

    */
    public static Id approvalSearchUserByDept(Id deptID, Integer deptLevel)
    {
        if (String.isBlank(deptID))
        {
            return null;
        }
        Organizational__c org = [SELECT Id, Dept_Post_Number__c, Dept_Level__c, Dept_Number__c, Parent_Number__c
                                 FROM Organizational__c
                                 WHERE Id = : deptID];

        System.debug('*** This org: ' + org + '');
        if(org == null)
        {
            return null;
        }

        if (org.Dept_Level__c == deptLevel)
        {
            //通过部门的主岗位编号查询岗位负责人
            List<Organizational__c> orgJob = [SELECT Id, Post_Manager__c, Post_Dept_Number__c, Post_Manager__r.SF_User__c
                                              FROM Organizational__c
                                              WHERE  Post_Number__c = :org.Dept_Post_Number__c AND RecordType.SObjectType = 'Organizational__c'
                                                      AND RecordType.DeveloperName = 'Job_Title'
                                                              LIMIT 1];
            if(orgJob.size() > 0)
            {
                return orgJob[0].Post_Manager__r.SF_User__c;
            }
            else
            {
                return null;
            }
        }
        else if(org.Dept_Level__c > deptLevel)
        {
            //找指定部门主管
            return Utils.approvalSearchUserByDept(org.Parent_Number__c, deptLevel);
        }
        else
        {
            return null;
        }
    }
    /*
        目 的：审批节点设置中，通过指定岗位找到对应的岗位主管用户
        参数1：jobID - 指定岗位ID
        返回值：返回相关指定岗位负责人或所属人员用户Id：

    */
    public static List<Id> approvalSearchUserByJob(Id jobID)
    {
        List<Id>  lstId = new List<Id>();
        Set<Id>  setSFID = new Set<Id>();
        if (String.isBlank(jobID))
        {
            return null;
        }
        Organizational__c orgJob = [SELECT Id, Post_Manager__c, Post_Dept_Number__c, Post_Manager__r.SF_User__c
                                    FROM Organizational__c
                                    WHERE Id = : jobID];
        List<Contact> lstCon = [SELECT Number__c, SF_User__c FROM Contact WHERE Post_Number__c = :jobID AND RecordType.DeveloperName = 'Staff'];
        //指定岗位逻辑，先找岗位负责人，然后再找岗位下的人员
        if (!String.isBlank(orgJob.Post_Manager__c))
        {
            lstId.add(orgJob.Post_Manager__r.SF_User__c);
            setSFID.add(orgJob.Post_Manager__r.SF_User__c);
        }
        if (lstCon.size() > 0)
        {
            for (Contact con : lstCon)
            {
                if (!String.isBlank(con.SF_User__c) && !setSFID.contains(con.SF_User__c))
                {
                    lstId.add(con.SF_User__c);
                    setSFID.add(con.SF_User__c);
                }
            }
        }
        return lstId;
    }
    /*
        目 的：审批节点设置中，通过申请人找到申请人上级主管
        参数1：applicationID - 申请人ID
        参数2：isUserId - ture:用户ID，false:联系人id
        返回值：返回相关上级主管用户Id：

    */
    public static Id approvalSearchManagerByApplication(Id applicationID, Boolean isUserId)
    {
        if (String.isBlank(applicationID))
        {
            return null;
        }
        Id IdContact = isUserId ? Utils.getContactIdByUserID(applicationID) : applicationID;
        Contact con = [SELECT Id, Dept_Number__c, Is_Manager__c, Dept_Number__r.Parent_Number__c
                       FROM Contact
                       WHERE Id = :IdContact];
        //当前用户为主管则找所属部门主管，不是，则找上级部门主管
        if (con.Is_Manager__c == false)
        {
            return Utils.approvalSearchUserByDept(con.Dept_Number__c);
        }
        else
        {
            return Utils.approvalSearchUserByDept(con.Dept_Number__r.Parent_Number__c);
        }
    }
    /*
        目 的：审批节点设置中，通过申请人找到申请人部门或一阶主管
        参数1：applicationID - 申请人ID
        参数2：isUserId - ture:用户ID，false:联系人id
        返回值：返回相关部门主管用户Id：

    */
    public static Id approvalSearchSpecificManagerByApplication(Id applicationID, Integer deptLevel, Boolean isUserId)
    {
        System.debug('*** applicationID: ' + applicationID + '');
        if (String.isBlank(applicationID))
        {
            return null;
        }
        Id IdContact = isUserId ? Utils.getContactIdByUserID(applicationID) : applicationID;
        Contact con = [SELECT Id, Dept_Number__c, Is_Manager__c, Dept_Number__r.Parent_Number__c
                       FROM Contact
                       WHERE Id = :IdContact];
        return Utils.approvalSearchUserByDept(con.Dept_Number__c, deptLevel);
    }
    /*
        目 的：返回部门和岗位数据的Map列表
        返回值：Map<String,Map<String,Organizational__c>>
                第一个key包含：deptIdMap/jobNoMap/jobIdMap
                第二个key为deptID或jobID或岗位编号
    */
    public static Map<String, Map<String, Organizational__c>> getDeptAndJob()
    {
        Map<String, Map<String, Organizational__c>> resultMap = new Map<String, Map<String, Organizational__c>>();
        Map<String, Organizational__c> deptIdMap = new Map<String, Organizational__c>();
        Map<String, Organizational__c> jobNoMap = new Map<String, Organizational__c>();
        Map<String, Organizational__c> jobIdMap = new Map<String, Organizational__c>();
        List<Organizational__c> rowlist = [
                                              SELECT Id, Dept_Post_Number__c, Dept_Number__c, Parent_Number__c, Dept_Level__c,
                                              Post_Number__c, Post_Manager__c, Post_Dept_Number__c,
                                              Post_Manager__r.SF_User__c, RecordType.DeveloperName
                                              FROM Organizational__c
                                              WHERE RecordType.DeveloperName = 'Job_Title'
                                                      OR RecordType.DeveloperName = 'Organizational'];
        for(Organizational__c row : rowlist)
        {
            if(row.RecordType.DeveloperName == 'Organizational')
            {
                if(!deptIdMap.containsKey(row.Id))
                {
                    deptIdMap.put(row.Id, row);
                }
            }
            else if(row.RecordType.DeveloperName == 'Job_Title')
            {
                if(!jobNoMap.containsKey(row.Post_Number__c))
                {
                    jobNoMap.put(row.Post_Number__c, row);
                }
                if(!jobIdMap.containsKey(row.Id))
                {
                    jobIdMap.put(row.Id, row);
                }
            }
        }
        resultMap.put('deptIdMap', deptIdMap);
        resultMap.put('jobNoMap', jobNoMap);
        resultMap.put('jobIdMap', jobIdMap);
        return resultMap;
    }
    /*
        目 的：返回员工数据的Map列表
        返回值：Map<String,Map<String,List<Contact>>>
                第一个key包含：contactJobIdMap/contactIdMap
                第二个key为岗位Id或员工ID

    */
    public static Map<String, Map<String, List<Contact>>> getContact()
    {
        Map<String, Map<String, List<Contact>>> resultMap = new Map<String, Map<String, List<Contact>>>();
        Map<String, List<Contact>> contactJobIdMap = new Map<String, List<Contact>>();
        Map<String, List<Contact>> contactIdMap = new Map<String, List<Contact>>();
        List<Contact> rowlist = [
                                    SELECT SF_User__c, Number__c, Dept_Number__c, Is_Manager__c, Post_Number__c,
                                    SF_User__r.Is_First_Manager__c, SF_User__r.Is_Manager__c, Dept_Number__r.Parent_Number__c
                                    FROM Contact
                                    WHERE RecordType.DeveloperName = 'Staff'];
        for(Contact row : rowlist)
        {
            if(contactJobIdMap.containsKey(row.Post_Number__c))
            {
                contactJobIdMap.get(row.Post_Number__c).add(row);
            }
            else
            {
                List<Contact> conlst = new List<Contact>();
                conlst.add(row);
                contactJobIdMap.put(row.Post_Number__c, conlst);
            }
            contactIdMap.put(row.Id, new List<Contact> {row});
        }
        resultMap.put('contactJobIdMap', contactJobIdMap);
        resultMap.put('contactIdMap', contactIdMap);
        return resultMap;
    }
    /*
        目 的：返回用户数据的Map列表
        返回值：Map<String,User>
                key为用户Id
    */
    public static Map<String, User> getUsers()
    {
        Map<String, User> userIdMap = new Map<String, User>([SELECT Id, Number__c, Is_Manager__c, Is_First_Manager__c, Dept_Number__c, Job_Title_Number__c FROM User WHERE IsActive = true]);
        return userIdMap;
    }
    /*
        目 的：审批节点设置中，通过指定部门找到对应的部门主管用户,没有则找上级部门主管
        参 数：deptIdMap - 部门集合(key为部门ID)
               jobNoMap - 岗位集合(key为岗位编号)
               deptID - 指定部门ID
        返 回：返回相关部门主管的用户Id
        备 注:
    */
    public static Id approvalSearchUserByDept(Map<String, Organizational__c> deptIdMap, Map<String, Organizational__c> jobNoMap, Id deptID)
    {
        if(String.isBlank(deptID) || deptIdMap == null || !deptIdMap.containsKey(deptID))
        {
            return null;
        }
        Organizational__c org = deptIdMap.get(deptID);
        //通过部门的主岗位编号查询岗位负责人
        if (jobNoMap.containsKey(org.Dept_Post_Number__c))
        {
            Organizational__c job = jobNoMap.get(org.Dept_Post_Number__c);
            if (!String.isBlank(job.Post_Manager__c))
            {
                return job.Post_Manager__r.SF_User__c;
            }
            else
            {
                //找上级部门的负责人
                return Utils.approvalSearchUserByDept(deptIdMap, jobNoMap, org.Parent_Number__c);
            }
        }
        else
        {
            System.debug(LoggingLevel.INFO, '*** 未找到相关部门岗位负责人！部门: ' + org);
            //找上级部门的负责人
            return Utils.approvalSearchUserByDept(deptIdMap, jobNoMap, org.Parent_Number__c);
            //return null;
        }
    }
    /*
        目 的：审批节点设置中，通过指定部门找到对应的层级的部门主管用户
        参 数：deptIdMap - 部门集合(key为部门ID)
               jobNoMap - 岗位集合(key为岗位编号)
               deptID - 指定部门ID
               deptLevel - 指定的部门层级
        返回值：返回对应层级部门主管的用户Id
    */
    public static Id approvalSearchUserByDept(Map<String, Organizational__c> deptIdMap, Map<String, Organizational__c> jobNoMap, Id deptID, Integer deptLevel)
    {
        if (String.isBlank(deptID) || deptIdMap == null || !deptIdMap.containsKey(deptID))
        {
            return null;
        }
        Organizational__c org = deptIdMap.get(deptID);
        if (org.Dept_Level__c == deptLevel)
        {
            //通过部门的主岗位编号查询岗位负责人
            Organizational__c orgJob = null;
            if(jobNoMap.containsKey(org.Dept_Post_Number__c))
            {
                orgJob = jobNoMap.get(org.Dept_Post_Number__c);
            }
            if(orgJob != null )
            {
                return orgJob.Post_Manager__r.SF_User__c;
            }
            else
            {
                return null;
            }
        }
        else if(org.Dept_Level__c > deptLevel)
        {
            //找指定部门主管
            return Utils.approvalSearchUserByDept(deptIdMap, jobNoMap, org.Parent_Number__c, deptLevel);
        }
        else
        {
            return null;
        }
    }
    /*
        目 的：审批节点设置中，通过指定岗位找到对应的岗位主管用户
        参 数：jobIdMap - 岗位集合(key为岗位ID)
               contactJobIdMap - 联系人集合(key为岗位ID)
               jobID - 指定岗位ID
        返 回：返回相关指定岗位负责人或所属人员的用户Id
    */
    public static List<Id> approvalSearchUserByJob(Map<String, Organizational__c> jobIdMap, Map<String, List<Contact>> contactJobIdMap, Id jobID)
    {
        Set<Id> setSFID = new Set<Id>();
        if (String.isBlank(jobID) || jobIdMap == null || !jobIdMap.containsKey(jobId))
        {
            return null;
        }
        Organizational__c orgJob = jobIdMap.get(jobId);

        List<Contact> lstCon = null;
        if(contactJobIdMap.containsKey(jobId))
        {
            lstCon = contactJobIdMap.get(jobId);
        }
        //指定岗位逻辑，先找岗位负责人，然后再找岗位下的人员
        if (!String.isBlank(orgJob.Post_Manager__c))
        {
            setSFID.add(orgJob.Post_Manager__r.SF_User__c);
        }
        if (lstCon != null && lstCon.size() > 0)
        {
            for (Contact con : lstCon)
            {
                if (!String.isBlank(con.SF_User__c) && !setSFID.contains(con.SF_User__c))
                {
                    setSFID.add(con.SF_User__c);
                }
            }
        }
        List<Id> lst = new List<Id>();
        for(Id uId : setSFID)
        {
            lst.add(uId);
        }
        return lst;
    }
    /*
        目 的：审批节点设置中，通过申请人找到申请人上级主管
        参 数：contactIdMap - 联系人集合(key为联系人Id)
               userIdMap - 用户集合(key为用户Id)
               applicationID - 申请人ID
               isUserId - ture:用户Id，false:联系人Id
        返回值：返回相关上级主管用户Id

    */
    public static Id approvalSearchManagerByApplication(Map<String, List<Contact>> contactIdMap, Map<String, User> userIdMap, Id applicationID, Boolean isUserId)
    {
        if (String.isBlank(applicationID))
        {
            return null;
        }
        Id IdContact = applicationID;
        if(isUserId)
        {
            IdContact = null;
            if(userIdMap.containsKey(applicationID))
            {
                String numberNO = userIdMap.get(applicationID).Number__c;
                Set<String> conids = contactIdMap.keySet();
                for(String conId : conids)
                {
                    List<Contact> conlist = contactIdMap.get(conId);
                    if(conlist != null && conlist.size() > 0 && conlist[0].Number__c == numberNO)
                    {
                        IdContact = conId;
                        break;
                    }
                }
            }
        }
        Contact con = null;
        if(contactIdMap.containsKey(IdContact))
        {
            con = contactIdMap.get(IdContact)[0];
        }
        //当前用户为主管则找所属部门主管，不是，则找上级部门主管
        if(con != null)
        {
            if (con.Is_Manager__c == false)
            {
                return Utils.approvalSearchUserByDept(con.Dept_Number__c);
            }
            else
            {
                return Utils.approvalSearchUserByDept(con.Dept_Number__r.Parent_Number__c);
            }
        }
        else
        {
            System.debug(LoggingLevel.INFO, '*** 联系人不存在！ID: ' + IdContact);
            return null;
        }
    }
    /*
        目 的：审批节点设置中，通过申请人找到申请人部门或一阶主管
        参 数：contactIdMap - 联系人集合(key为联系人Id)
               userIdMap - 用户集合(key为用户Id)
               deptIdMap - 部门集合(key为部门ID)
               jobNoMap - 岗位集合(key为岗位编号)
               applicationID - 申请人ID
               deptLevel - 部门层级
               isUserId - ture:用户Id，false:联系人Id
        返回值：返回相关部门主管用户Id：

    */
    public static Id approvalSearchSpecificManagerByApplication(
        Map<String, List<Contact>> contactIdMap,
        Map<String, User> userIdMap, Id applicationID,
        Map<String, Organizational__c> deptIdMap,
        Map<String, Organizational__c> jobNoMap,
        Integer deptLevel,
        Boolean isUserId)
    {
        System.debug('*** applicationID: ' + applicationID + '');
        if (String.isBlank(applicationID))
        {
            return null;
        }
        Id IdContact = applicationID;
        if(isUserId)
        {
            IdContact = null;
            if(userIdMap.containsKey(applicationID))
            {
                String numberNO = userIdMap.get(applicationID).Number__c;
                Set<String> conids = contactIdMap.keySet();
                for(String conId : conids)
                {
                    List<Contact> conlist = contactIdMap.get(conId);
                    if(conlist != null && conlist.size() > 0 && conlist[0].Number__c == numberNO)
                    {
                        IdContact = conId;
                        break;
                    }
                }
            }
        }
        Contact con = null;
        if(IdContact != null && contactIdMap.containsKey(IdContact))
        {
            con = contactIdMap.get(IdContact)[0];
            return Utils.approvalSearchUserByDept(deptIdMap, jobNoMap, con.Dept_Number__c, deptLevel);
        }
        else
        {
            return null;
        }
    }
    /*
        目 的：得到审批流程配置步骤
        参数1：ApprovalAPIName - 流程API名称
        返回值：审批流程配置
    */
    public static Map<Decimal, Organizational__c> getApprovalStepByAPIName(String approvalAPIName)
    {
        //客户流程各节点配置
        List<Organizational__c> lstApproval = [
                SELECT Id, Approval_Name__c, Approval_Step__c, Approval_Step_Name__c, Approval_Rule__c,
                Approval_Department__c, Approval_Post__c, Approval_Personnel__c, Approval_Personnel__r.SF_User__c,Approval_Special_Field__c
                FROM Organizational__c
                WHERE Approval_Name__c = : approvalAPIName
                                         AND RecordType.SObjectType = 'Organizational__c'
                                                 AND RecordType.DeveloperName = 'Approval_Config'];
        Map<Decimal, Organizational__c>  mapSpecify = new Map<Decimal, Organizational__c>();
        for (Organizational__c org : lstApproval)
        {
            mapSpecify.put(org.Approval_Step__c, org);
        }
        return mapSpecify;
    }

    /*
        目 的：得到审批流程配置步骤
        参数1：org - 具体流程配置
        参数2：contactID - 指定联系人或作业人，没有传null
        返回值：审批流程配置
    */
    /*指定人上级主管
    人员的上级主管，如果没有就继续找上级知道找到
    指定人部门主管

    人员为公司级主管-新莱的总经理
    人员为一阶主管-上级主管
    人员为二级主管-一阶主管 未找到为空
    人员为二级以下-先找二级主管-未找到找一阶主管

    指定人一阶主管
    人员为公司级主管-新莱的总经理
    人员为一阶主管-上级主管
    人员为二级及二级以下- 一阶主管 未找到为空*/

    public static List<Id> approvalSearchApprrovalerByRule(Organizational__c org, Id contactID)
    {
        List<Id>  setSFID = new List<Id>();
        Contact con = null;
        if(org == null)
        {
            return setSFID;
        }
        System.debug(LoggingLevel.INFO, '*** org : ' + org + 'contactID:' + contactID);
        if (org.Approval_Rule__c == '指定部门')
        {
            setSFID.add(Utils.approvalSearchUserByDept(org.Approval_Department__c));
        }
        else if(org.Approval_Rule__c == '指定岗位')
        {
            setSFID = Utils.approvalSearchUserByJob(org.Approval_Post__c);
        }
        else if(org.Approval_Rule__c == '指定人员')
        {
            setSFID.add(org.Approval_Personnel__r.SF_User__c);
        }
        else if(org.Approval_Rule__c == '指定人具体字段')
        {
            setSFID.add(Utils.getUserIdByContactID(contactID));
        }
        else if(org.Approval_Rule__c == '指定人上级主管')
        {
            con = !String.isBlank(contactID) ? [SELECT SF_User__c, Number__c, SF_User__r.Is_First_Manager__c, SF_User__r.Is_Manager__c, Corp_Code__c FROM Contact WHERE Id = :contactID] : null;
            //特例，当申请人为子公司层的主管时，上级都为新莱子公司层的主管
            if (con != null && !String.isBlank(Utils.checkSubCorpManager(con.Number__c)))
            {
                setSFID.add(Utils.checkSubCorpManager(con.Number__c));
            }
            else
            {
                setSFID.add(Utils.approvalSearchManagerByApplication(contactID, false));
            }

        }
        else if(org.Approval_Rule__c == '指定人部门主管')
        {
            con = !String.isBlank(contactID) ? [SELECT SF_User__c, Number__c, SF_User__r.Is_First_Manager__c, SF_User__r.Is_Manager__c, Corp_Code__c FROM Contact WHERE Id = :contactID] : null;
            //特例，当申请人为子公司层的主管时，上级都为新莱子公司层的主管
            if (con != null && !String.isBlank(Utils.checkSubCorpManager(con.Number__c)))
            {
                setSFID.add(Utils.checkSubCorpManager(con.Number__c));
            }
            //如果申请人为一阶主管，他的部门主管为上级主管
            else if (con != null && con.SF_User__r.Is_First_Manager__c)
            {
                setSFID.add(Utils.approvalSearchManagerByApplication(contactID, false));
            }
            //如果申请人为部门(二阶)主管，他的部门主管为一阶主管
            else if (con != null && con.SF_User__r.Is_Manager__c)
            {
                setSFID.add(Utils.approvalSearchSpecificManagerByApplication(contactID, 3, false));
            }
            //其他情况为固定的一阶，二阶主管
            else
            {
                Id idUser =  Utils.approvalSearchSpecificManagerByApplication(contactID, 4, false);
                //如果没有部门主管则一阶主管审批
                if (String.isBlank(idUser))
                {
                    System.debug(LoggingLevel.INFO, '*** 指定人部门主管为空，找一阶主管: ');
                    idUser = Utils.approvalSearchSpecificManagerByApplication(contactID, 3, false);
                }
                setSFID.add(idUser);
            }
        }
        else if(org.Approval_Rule__c == '指定人一阶主管')
        {
            System.debug('***:String.isBlank(contactID): ' + String.isBlank(contactID) + '');
            con = !String.isBlank(contactID) ? [SELECT SF_User__c, Number__c, SF_User__r.Is_First_Manager__c, SF_User__r.Is_Manager__c, Corp_Code__c FROM Contact WHERE Id = :contactID] : null;
            //特例，当申请人为子公司层的主管时，上级都为新莱子公司层的主管
            if (con != null && !String.isBlank(Utils.checkSubCorpManager(con.Number__c)))
            {
                setSFID.add(Utils.checkSubCorpManager(con.Number__c));
            }
            //如果申请人为一阶主管，他的一阶主管为上级主管
            else if (con != null && con.SF_User__r.Is_First_Manager__c)
            {
                setSFID.add(Utils.approvalSearchManagerByApplication(contactID, false));
            }
            else
            {
                System.debug('*** con: ' + con + '');
                setSFID.add(Utils.approvalSearchSpecificManagerByApplication(contactID, 3, false));
            }

        }
        /**
         * 20180112 當申請人=主管職&&公司別=台灣新萊&&審批人找不到
         * 審批人一律設為總經理.
         */
        if (con != null && (setSFID.size() == 0 || setSFID.get(0) == null) && con.Corp_Code__c == '3000' && con.SF_User__r.Is_First_Manager__c)
        {
            setSFID.add(Id.valueOf('00528000006nvgB'));
        }
        return setSFID;
    }
    /*
        目 的：特例，当申请人为子公司层的主管时，上级都为新莱子公司层的主管
        参数1：code - 员工编号
        返回值：是否当前申请人是特例，如果是返回配置审批用户，否返回null
    */
    public static Id checkSubCorpManager(String code)
    {
        System_Setting__c ssc = System_Setting__c.getValues('Setting');
        String   szSpecialEmployee   =  ssc.Specify_Approval__c;
        String   szApprover   =  ssc.Specify_Approal_Employee__c;
        if (szSpecialEmployee.contains(code))
        {
            return Utils.getUserByEmployeeCode(szApprover);
        }
        else
        {
            return null;
        }

    }
    /*
       目 的：得到流程中申请人所属部门
       参数1：部门ID - 部门ID
       返回值：所属部门
    */
    public static String generateDeptName(Id deptID)
    {
        System.debug(LoggingLevel.INFO, '*** 找寻所属部门deptID: ' + deptID);
        if (String.isBlank(deptID))
        {
            return null;
        }
        Organizational__c orgDept =  [SELECT Description__c, Dept_Level__c, Parent_Number__c  FROM Organizational__c WHERE Id = :deptID];
        if (orgDept.Dept_Level__c == 1)
        {
            return  orgDept.Description__c;
        }
        else
        {
            return Utils.generateDeptName(orgDept.Parent_Number__c) + '-' + orgDept.Description__c;
        }
    }
    /*
        目 的：通过员工编号找寻对应的SF用户
        参数1：number_code - 员工编号
        返回值：
    */
    public static Id getUserByEmployeeCode(String number_code)
    {
        List<Contact> lstCon = [SELECT Number__c, SF_User__c FROM Contact WHERE Number__c = :number_code AND RecordType.DeveloperName = 'Staff'];
        if (lstCon.size() > 0)
        {
            if (lstCon[0].SF_User__c != null)
            {
                return lstCon[0].SF_User__c;
            }
            else
            {
                System.debug(LoggingLevel.INFO, '***: 通过员工编号未找到对应的SF用户,员工编号：' + number_code);
                return null;
            }
        }
        else
        {
            System.debug(LoggingLevel.INFO, '***: 通过员工编号未找到对应的SF用户,员工编号：' + number_code);
            return null;
        }
    }
    /*
        目 的：得到指定记录ID当前审批节点可更新&必输字段集合
        参数1：targetId - 记录ID
        返回值：Map<String,Set<String>>
    */
    public static Map<String, Set<String>> getNodeEditFields(String targetId, String recID)
    {
        Set<String> mainUpdateFields = new Set<String>();
        Set<String> detailUpdateFields = new Set<String>();
        Set<String> mainRequireFields = new Set<String>();
        Set<String> detailRequireFields = new Set<String>();

        //在审批中不做权限拦截的字段
        System_Setting__c ssc = System_Setting__c.getValues('Setting');
        String setFields = ssc.No_Permission_Fields__c;
        setFields = setFields.replace('，', ',');
        setFields = setFields.removeEnd(',');
        setFields = setFields.removeStart(',');
        List<String> fieldlist = setFields.split(',');
        for(String field : fieldlist)
        {
            if(!mainUpdateFields.contains(field))
            {
                mainUpdateFields.add(field);
            }
        }
        List<ProcessInstanceNode> nodes =
            [SELECT Id, ProcessNodeId, ProcessNode.DeveloperName, ProcessInstance.ProcessDefinition.DeveloperName
             FROM ProcessInstanceNode
             WHERE ProcessInstance.TargetObjectId = :targetId
                     ORDER BY CreatedDate DESC
                     LIMIT 1];
        if(nodes.size() > 0)
        {
            String nodeAPI = nodes[0].ProcessNode.DeveloperName;
            String approvalName = '';
            if (String.isBlank(recID))
            {
                approvalName = nodes[0].ProcessInstance.ProcessDefinition.DeveloperName;
            }
            else
            {
                List<RecordType> lstR = [SELECT DeveloperName FROM RecordType WHERE Id = :recID OR DeveloperName = :recID];
                if (lstR.size() > 0)
                {
                    approvalName = lstR[0].DeveloperName;
                }
            }
            List<Organizational__c> setlist = [
                                                  SELECT Id, Node_Edit_Fields__c, Node_DetailEdit_Fields__c,
                                                  Node_Require_Fields__c, Node_DetailRequire_Fields__c
                                                  FROM Organizational__c
                                                  WHERE RecordType.DeveloperName = 'Node_Edit_Field'
                                                          AND Node_API__c = : nodeAPI
                                                                  AND Approval_Name__c = : approvalName];
            if(setlist.size() > 0)
            {
                //表头可编辑字段
                String fields = setlist[0].Node_Edit_Fields__c;
                if(!String.isBlank(fields))
                {
                    fields = fields.replace('，', ',');
                    fields = fields.removeEnd(',');
                    fields = fields.removeStart(',');
                    List<String> flist = fields.split(',');
                    for(String field : flist)
                    {
                        if(!mainUpdateFields.contains(field))
                        {
                            mainUpdateFields.add(field);
                        }
                    }
                }

                //项次可编辑
                String flds = setlist[0].Node_DetailEdit_Fields__c;
                if(!String.isBlank(flds))
                {
                    flds = flds.replace('，', ',');
                    flds = flds.removeEnd(',');
                    flds = flds.removeStart(',');
                    List<String> flist = flds.split(',');
                    for(String field : flist)
                    {
                        if(!detailUpdateFields.contains(field))
                        {
                            detailUpdateFields.add(field);
                        }
                    }
                }

                //表头必输字段
                String fields2 = setlist[0].Node_Require_Fields__c;
                if(!String.isBlank(fields2))
                {
                    fields2 = fields2.replace('，', ',');
                    fields2 = fields2.removeEnd(',');
                    fields2 = fields2.removeStart(',');
                    List<String> flist = fields2.split(',');
                    for(String field : flist)
                    {
                        if(!mainRequireFields.contains(field))
                        {
                            mainRequireFields.add(field);
                        }
                    }
                }


                //项次必输
                String flds2 = setlist[0].Node_DetailRequire_Fields__c;
                if(!String.isBlank(flds2))
                {
                    flds2 = flds2.replace('，', ',');
                    flds2 = flds2.removeEnd(',');
                    flds2 = flds2.removeStart(',');
                    List<String> flist = flds2.split(',');
                    for(String field : flist)
                    {
                        if(!detailRequireFields.contains(field))
                        {
                            detailRequireFields.add(field);
                        }
                    }
                }

            }
        }
        Map<String, Set<String>> result = new Map<String, Set<String>>();
        result.put('main', mainUpdateFields);
        result.put('detail', detailUpdateFields);
        result.put('mainrequire', mainRequireFields);
        result.put('detailrequire', detailRequireFields);
        return result;
    }
    /*
        2017-12-06建置
        目 的：得到指定记录ID当前审批节点Detail必输字段集合
        参数1：targetId - 记录ID
        返回值：Map<String,Map<String,Set<String>>>

        須於審批節點編輯字段設置中,於項次必輸欄位輸入格式= 子項API名稱@字段1,字段2;子項API名稱2@字段1,字段2;
    */
    public static Map<String, Map<String, Set<String>>> getDetailRequireFields(String targetId, String recID)
    {

        //20171206增加子項必填
        Map<String, Set<String>> detailRequireFields  = new Map<String, Set<String>>();
        //在审批中不做权限拦截的字段

        List<ProcessInstanceNode> nodes =
            [SELECT Id, ProcessNodeId, ProcessNode.DeveloperName, ProcessInstance.ProcessDefinition.DeveloperName
             FROM ProcessInstanceNode
             WHERE ProcessInstance.TargetObjectId = :targetId
                     ORDER BY CreatedDate DESC
                     LIMIT 1];
        if(nodes.size() > 0)
        {
            String nodeAPI = nodes[0].ProcessNode.DeveloperName;
            String approvalName = '';
            if (String.isBlank(recID))
            {
                approvalName = nodes[0].ProcessInstance.ProcessDefinition.DeveloperName;
            }
            else
            {
                List<RecordType> lstR = [SELECT DeveloperName FROM RecordType WHERE Id = :recID OR DeveloperName = :recID];
                if (lstR.size() > 0)
                {
                    approvalName = lstR[0].DeveloperName;
                }
            }
            List<Organizational__c> setlist = [
                                                  SELECT Id, Node_DetailRequire_Fields__c //20171206增加子項必填
                                                  FROM Organizational__c
                                                  WHERE RecordType.DeveloperName = 'Node_Edit_Field'
                                                          AND Node_API__c = : nodeAPI
                                                                  AND Approval_Name__c = : approvalName];
            if(setlist.size() > 0)
            {

                //項次必输字段 //20171206增加子項必填
                String dfields = setlist[0].Node_DetailRequire_Fields__c;
                if(!String.isBlank(dfields))
                {
                    dfields = dfields.replace('，', ',');
                    dfields = dfields.removeEnd(',');
                    dfields = dfields.removeStart(',');

                    List<String> flist = dfields.split(';');
                    for(String field : flist)
                    {
                        List<String> fieldList = field.split('@');
                        List<String> inflist = fieldList.get(1).split(',');
                        Set<String> st = new Set<String>();
                        for (String infield : inflist)
                        {
                            if(!st.contains(infield))
                            {
                                st.add(infield);
                            }
                        }

                        detailRequireFields.put(fieldList.get(0), st);

                    }
                }
            }
        }
        Map<String, Map<String, Set<String>>> result = new Map<String, Map<String, Set<String>>>();

        //20171206增加子項必填
        result.put('detailrequire', detailRequireFields);
        return result;
    }
    /*
        目 的：得到指定记录ID当前审批节点当前审批人
        参数1：targetId - 记录ID
        返回值：Id(User)
    */
    public static Set<Id> getApprovalUser(String targetId)
    {
        if(String.isBlank(targetId))
        {
            return null;
        }
        Set<Id> setId = new Set<Id>();
        List<ProcessInstanceWorkitem> lstWorkItem =
            [SELECT Id, ProcessInstanceId, OriginalActorId, ActorId
             FROM ProcessInstanceWorkitem
             WHERE ProcessInstance.TargetObjectId = :targetId];
        if(lstWorkItem.size() > 0)
        {
            for (ProcessInstanceWorkitem piw : lstWorkItem)
            {
                setId.add(piw.ActorId);
            }
            return setId;
        }
        else
        {
            return null;
        }
    }
    /*
        目 的：得到指定用户是否在权限集中设置了指定对象的权限
        参数1：uId - 用户ID
        参数2：sobjectName - 对象名API
        返回值：true / false
    */
    public static Boolean userHasPermission(Id uId, String sobjectName)
    {
        Boolean bl = false;
        System.debug('*** 用户ID：' + uId + '; 对象名称：' + sobjectName);
        //PermissionsCreate,PermissionsDelete,PermissionsRead,PermissionsViewAllRecords
        //现有权限集中是否已分配给当前用户
        List<PermissionSetAssignment> psetlist = [SELECT Id, AssigneeId, PermissionSetId
                FROM PermissionSetAssignment
                WHERE PermissionSet.IsOwnedByProfile = false
                        AND AssigneeId = :uId];
        if(psetlist.size() > 0)
        {
            Set<Id> pset = new Set<Id>();
            for(PermissionSetAssignment pss : psetlist)
            {
                if(!pset.contains(pss.PermissionSetId))
                {
                    pset.add(pss.PermissionSetId);
                }
            }
            //分配给当前用户的权限集中是否有对指定对象的编辑权限
            List<ObjectPermissions> oplist = [SELECT Id, SobjectType, PermissionsEdit, PermissionsModifyAllRecords FROM ObjectPermissions WHERE ParentId IN:pset AND SobjectType = :sobjectName];
            if(oplist.size() > 0)
            {
                for(ObjectPermissions op : oplist)
                {
                    if(op.PermissionsEdit || op.PermissionsModifyAllRecords)
                    {
                        bl = true;
                        break;
                    }
                }
            }
        }
        System.debug('*** 用户是否有权限：' + bl);
        return bl;
    }
    /*
        目 的：手动共享记录给审批人
        参 数：uId - 用户ID
              sobjectName - 对象名API
              targetId - 记录ID
        返回值：
    */
    public static void ManualShareRecordToUsers(Set<String> userIds, String sobjectName, String targetId)
    {
        List<Custom_Approval_Managed__Share> camShare = new List<Custom_Approval_Managed__Share>();
        List<Approval_Managed__Share> amShare = new List<Approval_Managed__Share>();
        List<Approval_Managed1__Share> am1Share = new List<Approval_Managed1__Share>();
        List<Approval_Managed2__Share> am2Share = new List<Approval_Managed2__Share>();
        System.debug(LoggingLevel.INFO, '*** 进入权限共享设置: ');
        Map<Id, User> mapUser = new Map<Id, User>([SELECT Id FROM User WHERE IsActive = true]);
        for(String uid : userIds)
        {
            if(uid == null || !mapUser.containsKey(uId))
            {
                continue;
            }
            if(sobjectName == 'Custom_Approval_Managed__c')
            {
                Custom_Approval_Managed__Share cams = new Custom_Approval_Managed__Share();
                cams.ParentId = targetId;
                cams.AccessLevel = 'Edit';
                cams.RowCause = Schema.Custom_Approval_Managed__Share.RowCause.Manual;
                cams.UserOrGroupId = uId;
                camShare.add(cams);
            }
            else if(sobjectName == 'Approval_Managed__c')
            {
                Approval_Managed__Share ams = new Approval_Managed__Share();
                ams.ParentId = targetId;
                ams.AccessLevel = 'Edit';
                ams.RowCause = Schema.Approval_Managed__Share.RowCause.Manual;
                ams.UserOrGroupId = uId;
                amShare.add(ams);
            }
            else if(sobjectName == 'Approval_Managed1__c')
            {
                Approval_Managed1__Share ams1 = new Approval_Managed1__Share();
                ams1.ParentId = targetId;
                ams1.AccessLevel = 'Edit';
                ams1.RowCause = Schema.Approval_Managed__Share.RowCause.Manual;
                ams1.UserOrGroupId = uId;
                am1Share.add(ams1);
            }
            else if(sobjectName == 'Approval_Managed2__c')
            {
                Approval_Managed2__Share ams2 = new Approval_Managed2__Share();
                ams2.ParentId = targetId;
                ams2.AccessLevel = 'Edit';
                ams2.RowCause = Schema.Approval_Managed__Share.RowCause.Manual;
                ams2.UserOrGroupId = uId;
                am2Share.add(ams2);
            }
        }
        try
        {
            if(camShare.size() > 0)
            {
                Database.INSERT(camShare, false);
            }
            if(amShare.size() > 0)
            {
                Database.INSERT(amShare, false);
            }
            if(am1Share.size() > 0)
            {
                Database.INSERT(am1Share, false);
            }
            if(am2Share.size() > 0)
            {
                Database.INSERT(am2Share, false);
            }
        }
        catch(Exception ex)
        {
            System.debug('*** 手动共享记录出错！【' + sobjectName + ' / ' + targetId + '】' + ex.getMessage() + '; ' + ex.getStackTraceString());
        }
    }
    /*
        得到自定义审批对象中的审批流程名称集合
    */
    public static Set<String> getCAMApprovalName()
    {
        Set<String> approval_Custom = new Set<String>();
        //Object = Custom_Approval_Managed__c, approval counts = 16
        approval_Custom.add(SapApprovalEnum.CUSTOMER);//客户主数据维护流程
        approval_Custom.add(SapApprovalEnum.VENDOR);//供应商主数据维护流程
        approval_Custom.add(SapApprovalEnum.BUSINESSTRAVEL);//员工出差管理流程
        approval_Custom.add(SapApprovalEnum.SALEORDER);//销售订单审批流程
        approval_Custom.add(SapApprovalEnum.COSTCENTERSEND);//成本中心发料作业流程
        approval_Custom.add(SapApprovalEnum.WASTEDISPOSE);//废料处理流程
        approval_Custom.add(SapApprovalEnum.PURCHASEINFORMATION);//采购信息记录维护流程
        approval_Custom.add(SapApprovalEnum.RFQ);//RFQ作业流程
        approval_Custom.add(SapApprovalEnum.SALESAPPLICATION);//标准销售申请流程
        approval_Custom.add(SapApprovalEnum.OVERTIMEWORK);//加班管理流程
        approval_Custom.add(SapApprovalEnum.MODIFYPAY);//员工调薪管理流程
        approval_Custom.add(SapApprovalEnum.INTERNALCONTACT);//内部联络单流程
        approval_Custom.add(SapApprovalEnum.HR_MANPOWERSUPPLEMENT);//HR人力补充申请流程
        approval_Custom.add(SapApprovalEnum.PERIODOFPROBATION);//员工试用期转正管理流程
        approval_Custom.add(SapApprovalEnum.CUSTOMERDISPATCH);//客户派车申请流程
        approval_Custom.add(SapApprovalEnum.SALESPRICING);//销售定价业务流程
        return approval_Custom;
    }
    /*
        得到标准审批对象中的审批流程名称集合
    */
    public static Set<String> getAMApprovalName()
    {
        Set<String> approval_Standard = new Set<String>();
        //Object = Approval_Managed__c, approval counts = 16
        approval_Standard.add(SapApprovalEnum.STAFFTRANSFER); //员工异动管理流程
        approval_Standard.add(SapApprovalEnum.STAFFLEAVEOFFICE);//员工主动离职流程
        approval_Standard.add(SapApprovalEnum.ABNORMALQUALITY);//品质异常单流程
        approval_Standard.add(SapApprovalEnum.PURCHASEORDER);//标准采购订单作业流程
        approval_Standard.add(SapApprovalEnum.EXPENSEREIMBURSE);//费用报销流程
        approval_Standard.add(SapApprovalEnum.ASSETPURCHASE);//资产购置流程
        approval_Standard.add(SapApprovalEnum.ADVANCECHARGE);//预付款申请流程
        approval_Standard.add(SapApprovalEnum.PURCHASEAPPLICATION);//采购申请作业流程
        approval_Standard.add(SapApprovalEnum.IT_SERVICEAPPLICATION);//IT服务申请流程
        approval_Standard.add(SapApprovalEnum.ABNORMALATTENCE);//考勤异常处理申请流程
        approval_Standard.add(SapApprovalEnum.LEAVE);//请假管理流程
        approval_Standard.add(SapApprovalEnum.ASSETSTRANSFER);//资产转移报废停用申请流程
        approval_Standard.add(SapApprovalEnum.ASSETLIQUIDATIONSALE);//资产清理出售流程
        approval_Standard.add(SapApprovalEnum.ASSETSALE);//资产出售流程
        approval_Standard.add(SapApprovalEnum.ORGANIZATIONALCHANGE);//组织架构变更调整流程
        approval_Standard.add(SapApprovalEnum.ENTERTAINECOST);//交际应酬费申请流程
        return approval_Standard;
    }
    /*
        得到标准审批对象1中的审批流程名称集合
    */
    public static Set<String> getAM1ApprovalName()
    {
        Set<String> am1 = new Set<String>();
        //Object = Approval_Managed1__c, approval counts = 16
        am1.add(SapApprovalEnum.TRAINING);//教育训练申请流程
        am1.add(SapApprovalEnum.VISITORHOSTS);//来宾接待流程
        am1.add(SapApprovalEnum.IRS_INFORMATIONSERVICE);//IRS资讯需求服务流程
        am1.add(SapApprovalEnum.INTERNALLYPILOTING);//内控不符合项流程
        am1.add(SapApprovalEnum.SEALAPPLICATION);//用印申请流程
        am1.add(SapApprovalEnum.EXPORTAPPLICATION);//出口申请流程
        am1.add(SapApprovalEnum.CREWSCHEDULING);//排班管理流程
        am1.add(SapApprovalEnum.RETURNHOME);//台干返乡探视申请流程
        am1.add(SapApprovalEnum.CREDITAUDITING);//客户单笔信货核发申请流程
        am1.add(SapApprovalEnum.TECHNICALSUPPORT);//技术支持流程
        am1.add(SapApprovalEnum.PIPELINESAMPLE);//管道样品申请流程
        am1.add(SapApprovalEnum.CREDITLOAN);//客戶信用贷款主数据申请流程
        am1.add(SapApprovalEnum.QUOTEAPPLICATION);//报价申请流程
        am1.add(SapApprovalEnum.BOOKDINNER);//订餐申请流程
        am1.add(SapApprovalEnum.VENDORCLAIM);//供应商索赔流程
        am1.add(SapApprovalEnum.SHIFTCHANGE);//班次变更申请流程
        am1.add(SapApprovalEnum.IRS_INFORMATIONSERVICE);//資訊需求服務單
        am1.add(SapApprovalEnum.INTERNALMEMO);//內部連絡單
        return am1;
    }
    /*
        得到标准审批对象2中的审批流程名称集合
    */
    public static Set<String> getAM2ApprovalName()
    {
        Set<String> am2 = new Set<String>();
        //Object = Approval_Managed2__c, approval counts = 15
        am2.add(SapApprovalEnum.INVENTORYAPPLICATION);//盘盈亏申请流程
        am2.add(SapApprovalEnum.CANCELTECO);//SAP生产工单取消TECO申请流程
        am2.add(SapApprovalEnum.SCRAPAPPLICATION);//报废申请流程
        am2.add(SapApprovalEnum.PM_NOTICE);//PM通知流程
        am2.add(SapApprovalEnum.INVENTORYPROCESS);//盘盈盘亏流程
        am2.add(SapApprovalEnum.MR_SAMPLE);//MR模具申请流程
        am2.add(SapApprovalEnum.STOCKALLOCATION);//库存调拨申请流程
        am2.add(SapApprovalEnum.PRIMECOST);//成本要素主数据维护流程
        am2.add(SapApprovalEnum.BUDGETCHANGE);//部门预算金额变更申请流程
        am2.add(SapApprovalEnum.QTW_CUSTOMERCOMPLAINT);//QTW客诉流程
        am2.add(SapApprovalEnum.INACTIVEMATERIALTRANSFER);//呆滞物料转用工作流程
        am2.add(SapApprovalEnum.SAP_PROJECTCODE);//SAP专案代号申请流程
        am2.add(SapApprovalEnum.SEV1_VENDORPERIODICASSESSMENT);//SEV1供应商定期评核流程
        am2.add(SapApprovalEnum.SEV2_VENDOREVALUATION);//SEV2供应商评鉴流程
        am2.add(SapApprovalEnum.EXP_APPLICATIONFEE);//EXP费用申请流程
        return am2;
    }

    //20180117 參數給一個<欄位名稱,欄位值>的map
    //這個方法會判斷map的值是不是空的 而產生SQL查詢字串
    public static String checkStringToBuildSOQLString(Map<String, String> inputMap, Boolean isfirst)
    {
        String ret = '';
        String WHEREs = ' WHERE ';
        Integer i = 1;
        Map<String, String> newMap = new Map<String, String>();
        if (inputMap != null && inputMap.size() != 0)
        {
            for (String k : inputMap.keySet())
            {

                if(inputMap.get(k) != null && inputMap.get(k).trim().length() != 0)
                {
                    newMap.put(k, inputMap.get(k));
                }
            }

        }
        for (String nk : newMap.keySet())
        {
            String lowkey = nk.toLowerCase();
            i++;
            if(lowkey.contains('start') && lowkey.contains('date'))
            {
                ret = ret + nk + '>=' + newMap.get(nk) + ' ';

            }
            else if(lowkey.contains('end') && lowkey.contains('date'))
            {
                ret = ret + nk + '<=' + newMap.get(nk) + ' ';

            }
            else
            {
                ret = ret + nk + '=\'' + newMap.get(nk) + '\'';
            }

            if(i <= newMap.size())
            {
                ret += ' AND ';

            }

        }

        if (i > 1)
        {
            ret = WHEREs + ret;
        }
        return ret;
    }


    @future(callout = true)


    public static void getTaskFromCRM(Id amiID, String activityNumber, String recordTypeName)
    {
        // System.debug(LoggingLevel.INFO, '*** test: ' + test);
        //ActivityFunctionCode     APPOINTMENT / TASK
        String fields = 'ActivityId,LeadName,OpportunityName,AccountName,ActivityFunctionCode,ActivityPartialDescription,CreatedBy,CreationDate,OwnerName,Subject,Lead2_Id_c,Lead2_c,Opportunity2_Id_c,Opportunity2_c,Customer2_Id_c,Customer2_c';
        SAP_Interface_Setting__c sis = SAP_Interface_Setting__c.getValues('CRMSetting');
        String url = sis.EndPoint__c + '?onlyData=true';
        url = url + '&finder=PrimaryKey;ActivityId=' + activityNumber;
        url = url + '&fields=' + fields;
        System.debug('*** POST URL: ' + url);
        //生成POST请求
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        //POST数据到CRM服务器
        req.setHeader('content-type', 'application/vnd.oracle.adf.resourceitem+json');
        req.setHeader('cache-control', 'application/vnd.oracle.adf.resourceitem+json');
        req.setHeader('authorization', sis.UserName__c);
        req.setHeader('postman-token', sis.Password__c);
        req.setMethod('GET');

        //发送请求并取得返回结果
        HttpResponse response = null;
        //设置提交超时时间(毫秒)
        req.setTimeout(Integer.valueOf(sis.Timeout__c));
        Http httpProtocol = new Http();
        try
        {
            response = httpProtocol.send(req);
            String result = response.getBody();
            System.debug('*** 发送返回结果: ' + result);
            result = result.replace('"count"', '"CRM_count"');
            result = result.replace('"limit"', '"CRM_limit"');
            result = result.replace('"offset"', '"CRM_offset"');
            CRMReturnArg args = (CRMReturnArg)JSON.deserialize(result, CRMReturnArg.class);
            System.debug('*** 返回结果反序列化成功: ' + args);
            //Travel_Manage / Payment_Detail
            List<Sobject> saveList = new List<Sobject>();
            for(CRMReturnItem arg : args.items)
            {
                Sobject row = null;
                if(recordTypeName == 'Travel_Manage')
                {
                    List<Custom_Approval_Managed_Item__c> camItems = [
                                SELECT Id, LeadName__c, OpportunityName__c, AccountName__c, ActivityPartialDescription__c,
                                OwnerName__c, TaskSubject__c, Lead2_Id__c, Lead2__c, Opportunity2_Id__c, Opportunity2__c,
                                Customer2_Id__c, Customer2__c
                                FROM Custom_Approval_Managed_Item__c
                                WHERE Id = : amiID];
                    if(camItems.size() > 0)
                    {
                        row = camItems[0];
                    }
                }
                else if(recordTypeName == 'Payment_Detail')
                {
                    List<Approval_Managed_Item__c> amItems = [
                                SELECT Id, LeadName__c, OpportunityName__c, AccountName__c, ActivityPartialDescription__c,
                                OwnerName__c, TaskSubject__c, Lead2_Id__c, Lead2__c, Opportunity2_Id__c, Opportunity2__c,
                                Customer2_Id__c, Customer2__c
                                FROM Approval_Managed_Item__c
                                WHERE Id = : amiID];
                    if(amItems.size() > 0)
                    {
                        row = amItems[0];
                    }
                }
                if(row == null)
                {
                    continue;
                }
                //ActivityFunctionCode,CreatedBy,CreationDate
                //LeadName,OpportunityName,AccountName,ActivityPartialDescription,OwnerName,Subject,
                //Lead2_Id_c,Lead2_c,Opportunity2_Id_c,Opportunity2_c,Customer2_Id_c,Customer2_c
                row.put('LeadName__c', arg.LeadName);
                row.put('OpportunityName__c', arg.OpportunityName);
                row.put('AccountName__c', arg.AccountName);
                row.put('ActivityPartialDescription__c', arg.ActivityPartialDescription);
                row.put('OwnerName__c', arg.OwnerName);
                row.put('TaskSubject__c', arg.Subject);
                row.put('Lead2_Id__c', arg.Lead2_Id_c);
                row.put('Lead2__c', arg.Lead2_c);
                row.put('Opportunity2_Id__c', arg.Opportunity2_Id_c);
                row.put('Opportunity2__c', arg.Opportunity2_c);
                row.put('Customer2_Id__c', arg.Customer2_Id_c);
                row.put('Customer2__c', arg.Customer2_c);
                saveList.add(row);
            }
            if(saveList.size() > 0)
            {
                UPDATE saveList;
            }
        }
        catch(Exception ex)
        {
            System.debug('*** 获取CRM数据出错：' + ex.getMessage());
        }
    }
    /*
        CRM活动或任务返回参数
    */
    public class CRMReturnArg
    {
        public String CRM_count {GET; SET;}
        public String hasMore {GET; SET;}
        public String CRM_limit {GET; SET;}
        public String CRM_offset {GET; SET;}
        public List<CRMReturnItem> items {GET; SET;}
        public List<CRMReturnLink> links {GET; SET;}
    }
    public class CRMReturnItem
    {
        public String ActivityId {GET; SET;}
        public String ActivityPartialDescription {GET; SET;}
        public String ActivityFunctionCode {GET; SET;}
        public String Subject {GET; SET;}
        public String CreatedBy {GET; SET;}
        public String CreationDate {GET; SET;}
        public String AccountName {GET; SET;}
        public String OwnerName {GET; SET;}
        public String LeadName {GET; SET;}
        public String OpportunityName {GET; SET;}
        public String Lead2_Id_c {GET; SET;}
        public String Lead2_c {GET; SET;}
        public String Opportunity2_Id_c {GET; SET;}
        public String Opportunity2_c {GET; SET;}
        public String Customer2_Id_c {GET; SET;}
        public String Customer2_c {GET; SET;}
    }
    public class CRMReturnLink
    {
        public String rel {GET; SET;}
        public String href {GET; SET;}
        public String name {GET; SET;}
        public String kind {GET; SET;}
    }


}