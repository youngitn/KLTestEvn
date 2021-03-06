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
            setSFID.add(Peoples.getInstance().KlAllContactMapGetById.get(contactID).SF_User__c);
        }
        else if(org.Approval_Rule__c == '指定人上级主管')
        {
            con = !String.isBlank(contactID) ? Peoples.getInstance().KlAllContactMapGetById.get(contactID) : null;
            //特例，当申请人为子公司层的主管时，上级都为新莱子公司层的主管
            if (con != null && !String.isBlank(ApproverUtils.checkSubCorpManagerWithOutSOQL(con.Number__c)))
            {
                setSFID.add(ApproverUtils.checkSubCorpManagerWithOutSOQL(con.Number__c));
            }
            else
            {
                setSFID.add(ApproverUtils.approvalSearchManagerByApplicationWithOutSOQL(contactID, false));
            }
        }
        else if(org.Approval_Rule__c == '指定人部门主管')
        {
            con = !String.isBlank(contactID) ? Peoples.getInstance().KlAllContactMapGetById.get(contactID) : null;
            //特例，当申请人为子公司层的主管时，上级都为新莱子公司层的主管
            if (con != null && !String.isBlank(ApproverUtils.checkSubCorpManagerWithOutSOQL(con.Number__c)))
            {
                System.debug(LoggingLevel.INFO, '*** 当申请人为子公司层的主管时，上级都为新莱子公司层的主管: ');
                setSFID.add(ApproverUtils.checkSubCorpManagerWithOutSOQL(con.Number__c));
            }
            //如果申请人为一阶主管，他的部门主管为上级主管
            else if (con != null && con.SF_User__r.Is_First_Manager__c)
            {
                System.debug(LoggingLevel.INFO, '*** 申请人为一阶主管，他的部门主管为上级主管: ');
                setSFID.add(ApproverUtils.approvalSearchManagerByApplicationWithOutSOQL(contactID, false));
            }
            //如果申请人为部门(二阶)主管，他的部门主管为一阶主管
            else if (con != null && con.SF_User__r.Is_Manager__c)
            {
                System.debug(LoggingLevel.INFO, '*** 申请人为部门(二阶)主管，他的部门主管为一阶主管: ');
                setSFID.add(ApproverUtils.approvalSearchSpecificManagerByApplicationWithOutSOQL(contactID, 3, false));
            }
            //其他情况为固定的一阶，二阶主管
            else
            {
                System.debug(LoggingLevel.INFO, '*** 其他情况为固定的一阶，二阶主管: ');
                Id idUser =  ApproverUtils.approvalSearchSpecificManagerByApplicationWithOutSOQL(contactID, 4, false);
                //如果没有部门主管则一阶主管审批
                if (String.isBlank(idUser))
                {
                    System.debug(LoggingLevel.INFO, '*** 指定人部门主管为空，找一阶主管: ');
                    idUser = ApproverUtils.approvalSearchSpecificManagerByApplicationWithOutSOQL(contactID, 3, false);
                    if (String.isBlank(idUser))
                    {
                        System.debug(LoggingLevel.INFO, '*** 一阶主管二阶主管都是空 找課長');
                        Contact c = Peoples.getInstance().KlAllContactMapGetById.get(contactID);
                        if (c != null)
                        {
                            //找同級單位的主管職(組,課級)
                            List<Contact> ll = [select name, Post_Number__r.Name,SF_User__c from Contact where Dept_Number__c = :c.Dept_Number__c AND Leave_Office_Date__c = null AND Post_Number__r.Name like '%主管職'];
                            //正常會有課長(代理課長或組長無法判斷)
                            if (ll.size() == 0)
                            {
                                System.debug('該人員單位為組');
                                //往上找課長
                                ll = [select name, Post_Number__r.Name, Dept_Number__r.Parent_Number__r.Name,SF_User__c from Contact where Dept_Number__c = :c.Dept_Number__r.Parent_Number__c AND Leave_Office_Date__c = null AND Post_Number__r.Name like '%主管職'];
                            }
                            else
                            {
                                System.debug('該人員單位為課');
                            }

                            idUser = ll.get(0).SF_User__c;
                        }

                    }
                }
                setSFID.add(idUser);
            }
        }
        else if(org.Approval_Rule__c == '指定人一阶主管')
        {
            System.debug('***:String.isBlank(contactID): ' + String.isBlank(contactID) + '');
            con = !String.isBlank(contactID) ? Peoples.getInstance().KlAllContactMapGetById.get(contactID) : null;
            //特例，当申请人为子公司层的主管时，上级都为新莱子公司层的主管
            if (con != null && !String.isBlank(ApproverUtils.checkSubCorpManagerWithOutSOQL(con.Number__c)))
            {
                setSFID.add(ApproverUtils.checkSubCorpManagerWithOutSOQL(con.Number__c));
            }
            //如果申请人为一阶主管，他的一阶主管为上级主管
            else if (con != null && con.SF_User__r.Is_First_Manager__c)
            {
                setSFID.add(ApproverUtils.approvalSearchManagerByApplicationWithOutSOQL(contactID, false));
            }
            else
            {
                System.debug('*** con: ' + con + '');
                setSFID.add(ApproverUtils.approvalSearchSpecificManagerByApplicationWithOutSOQL(contactID, 3, false));
            }

        }

        /**
         * 20180112 當申請人=主管職&&公司別=台灣新萊&&審批人找不到
         * 審批人一律設為總經理.
         */
        if (con != null && (setSFID.size() == 0 || setSFID.get(0) == null) && con.Corp_Code__c == '3000' && (con.SF_User__r.Is_First_Manager__c || con.SAP_Dept_Number__c == '10000927'))
        {
            System.debug('當申請人(目標對象)=主管職&&公司別=台灣新萊&&審批人找不到 * 審批人一律設為總經理.');
            setSFID.set(0, Peoples.getInstance().KlAllUserMapGetByNum.get('30210002').Id);

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
        String   szApprover = null;
        String   szSpecialEmployee = null;
        if (Test.isRunningTest())
        {
            szSpecialEmployee = code;
        }
        else
        {
            szSpecialEmployee   =  ssc.Specify_Approval__c;
            szApprover =  ssc.Specify_Approal_Employee__c;
        }

        if (szSpecialEmployee.contains(code) && Peoples.getInstance().KlAllUserMapGetByNum.get(szApprover) != null)
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
        Id IdContact = null;
        //如果傳進來的ID是USER ID 須轉成連絡人ID
        IdContact = checkIsUserId(isUserId, applicationID);
        Contact con = Peoples.getInstance().KlAllContactMapGetById.get(IdContact);
        //当前用户为主管则找所属部门主管，不是，则找上级部门主管
        if (con != null )
        {
            if (con.Is_Manager__c == false)
                return Utils.approvalSearchUserByDept(con.Dept_Number__c);
            else
                return Utils.approvalSearchUserByDept(con.Dept_Number__r.Parent_Number__c);
        }
        else
        {
            return null;
        }
    }

    /*
        目 的：审批节点设置中，通过申请人找到申请人部门或一阶主管
        参数1：applicationID - 申请人ID
        参数2：isUserId - ture:用户ID，false:联系人id
        返回值：返回相关部门主管用户Id：

    */
    public static Id approvalSearchSpecificManagerByApplicationWithOutSOQL(Id applicationID, Integer deptLevel, Boolean isUserId)
    {
        System.debug('*** applicationID: ' + applicationID + '');
        if (String.isBlank(applicationID))
        {
            return null;
        }
        Id IdContact = null;

        IdContact = checkIsUserId(isUserId, applicationID);

        Contact con = Peoples.getInstance().KlAllContactMapGetById.get(IdContact);
        if (con != null)
        {
            return Utils.approvalSearchUserByDept(con.Dept_Number__c, deptLevel);
        }
        else
        {
            return null;
        }

    }
    /**
     * 轉換userId為contactId
     * @param  isUserId      [傳入Id值是否為userId]
     * @param  applicationID [傳入Id]
     * @return               [回傳contactId]
     */
    public static Id checkIsUserId(Boolean isUserId, Id applicationID)
    {
        //如果傳進來的ID是USER ID 須轉成連絡人ID
        if(isUserId)
        {

            return UserIdToContactId(applicationID);

        }
        else
        {
            return applicationID;
        }
    }

    /**
     * [用USER ID 找到工號,並用此工號找所屬聯絡人]
     * @param  applicationID [description]
     * @return               [description]
     */
    public static Id UserIdToContactId(Id applicationID)
    {
        //為了取得工號欄位作聯絡人查詢,需先取得USER實體
        User inU = Peoples.getInstance().KlAllUserMapGetById.get(applicationID);

        //用USER ID 找到工號,並用此工號找所屬聯絡人
        //如果有聯絡人進入處理
        if (inU != null)
        {
            return Peoples.getInstance().KlAllContactMapGetByNum.get(inU.Number__c).Id;
        }
        else
        {
            //因查無聯絡人回傳null
            return null;
        }
    }


}