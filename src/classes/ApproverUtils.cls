public without sharing class ApproverUtils
{

    /**
    * [取得指定類型的所屬人員SF ID 透過單例模式減少SOQL使用次數]
    * @param  org       [流程配置]
    * @param  contactID [聯絡人ID]
    * @return           [SD ID]
    *
    * 指定人上级主管
    * 人员的上级主管，如果没有就继续找上级知道找到
    * 指定人部门主管
    *
    * 人员为公司级主管-新莱的总经理
    * 人员为一阶主管-上级主管
    * 人员为二级主管-一阶主管 未找到为空
    * 人员为二级以下-先找二级主管-未找到找一阶主管
    *
    * 指定人一阶主管
    * 人员为公司级主管-新莱的总经理
    * 人员为一阶主管-上级主管
    * 人员为二级及二级以下- 一阶主管 未找到为空
    */
    public static List<Id> approvalSearchApprrovalerByRuleWithOutSOQL(Organizational__c org, Id contactID)
    {
        List<Id>  setSFID = new List<Id>();
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
            setSFID.add(Peoples.getInstance().KlAllContactMapGetById.get(contactID).SF_User__c);
        }
        else if(org.Approval_Rule__c == '指定人上级主管')
        {
            Contact con = !String.isBlank(contactID) ? Peoples.getInstance().KlAllContactMapGetById.get(contactID) : null;
            //特例，当申请人为子公司层的主管时，上级都为新莱子公司层的主管
            if (con != null && !String.isBlank(ApproverUtils.checkSubCorpManagerWithOutSOQL(con.Number__c)))
            {
                setSFID.add(ApproverUtils.checkSubCorpManagerWithOutSOQL(con.Number__c));
            }
            else
            {
                setSFID.add(Utils.approvalSearchManagerByApplication(contactID, false));
            }
        }
        else if(org.Approval_Rule__c == '指定人部门主管')
        {
            Contact con = !String.isBlank(contactID) ? Peoples.getInstance().KlAllContactMapGetById.get(contactID) : null;
            //特例，当申请人为子公司层的主管时，上级都为新莱子公司层的主管
            if (con != null && !String.isBlank(ApproverUtils.checkSubCorpManagerWithOutSOQL(con.Number__c)))
            {
                setSFID.add(ApproverUtils.checkSubCorpManagerWithOutSOQL(con.Number__c));
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
            Contact con = !String.isBlank(contactID) ? Peoples.getInstance().KlAllContactMapGetById.get(contactID) : null;
            //特例，当申请人为子公司层的主管时，上级都为新莱子公司层的主管
            if (con != null && !String.isBlank(ApproverUtils.checkSubCorpManagerWithOutSOQL(con.Number__c)))
            {
                setSFID.add(ApproverUtils.checkSubCorpManagerWithOutSOQL(con.Number__c));
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
        return setSFID;
    }

    /*
        目 的：特例，当申请人为子公司层的主管时，上级都为新莱子公司层的主管
        参数1：code - 员工编号
        返回值：是否当前申请人是特例，如果是返回配置审批用户，否返回null
    */
    public static Id checkSubCorpManagerWithOutSOQL(String code)
    {
        System_Setting__c ssc = System_Setting__c.getValues('Setting');
        String   szSpecialEmployee   =  ssc.Specify_Approval__c;
        String   szApprover   =  ssc.Specify_Approal_Employee__c;
        if (szSpecialEmployee.contains(code))
        {
            return Peoples.getInstance().KlAllUserMapGetByNum.get(szApprover).Id;
        }
        else
        {
            return null;
        }

    }
    /*
        目 的：审批节点设置中，通过申请人找到申请人上级主管
        参数1：applicationID - 申请人ID
        参数2：isUserId - ture:用户ID，false:联系人id
        返回值：返回相关上级主管用户Id：

    */
    public static Id approvalSearchManagerByApplicationWithOutSOQL(Id applicationID, Boolean isUserId)
    {
        if (String.isBlank(applicationID))
        {
            return null;
        }

        Id IdContact = isUserId ? Peoples.getInstance().KlAllContactMapGetByNum.get(Peoples.getInstance().KlAllUserMapGetById.get(applicationID).Number__c).Id: applicationID;
        Contact con = Peoples.getInstance().KlAllContactMapGetById.get(IdContact);
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
}