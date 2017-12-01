// 品质异常单流程

public with sharing class AMAbnormalQualityExtension {
    public Approval_Managed__c am {get; set;}

    public Id amId {get; set;}
    public List<Approval_Managed_Item__c> problemList {get; set;}
    public List<Approval_Managed_Item__c> rectifyList {get; set;}
    public List<Approval_Managed_Item__c> containmentList {get; set;}

    public List<Approval_Managed_Item__c> preDeleteRectifyList {get; set;}
    public List<Approval_Managed_Item__c> preDeleteContainmentList {get; set;}
    public Map<Integer,List<Approval_Managed_Item__c>> mapRectify{get;set;}
    public Approval_Managed_Item__c currentProblems{GET;SET;}
    public Integer problemRow {get; set;}
    public Integer rectifyRow {get; set;}
    public Integer containmentRow {get; set;}
    public Boolean isRedered {get;set;}
    public ApexPages.StandardController apS{get;set;}
     //页面字段级控制变量
    public String szAbleEditFields{get;set;}
    public Boolean isClosed{get;set;}
    // public Id recRectifyId{get;set;}
    // public Id recContainmentId{get;set;}

    public AMAbnormalQualityExtension(ApexPages.StandardController con) {
        // Id amId = PageReference.getParameters().get('id');

        //品质异常单SF边只做修改，不会创建
        mapRectify = new Map<Integer,List<Approval_Managed_Item__c>>();
        isRedered = false;
        amId = con.getId();
        isClosed = true;
        Id recType = HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.ABNORMALQUALITY, 'Approval_Managed__c');
        //用来计算页面字段级控制
        Id amId = con.getId();
        szAbleEditFields = Utils.getApprovalPageEditFields(amId,recType);
        if (!String.isBlank(szAbleEditFields)) {
            isClosed = false;
        }
        apS = con;
        //检索当前记录数据
        String sql = Utils.getApprovalSQL(SapApprovalEnum.ABNORMALQUALITY,true);
        sql = sql + ' WHERE Id = \'' + amId + '\'';
        am = Database.query(sql);

        //检索子表problem记录
        problemList = [SELECT Id,RecordTypeId,Abnormal_Problem__c, Row_Index__c, Project__c, Project_No__c, Code_Group__c,
                       Type_of_Bug__c, Type_Description_Bug__c, Text__c
                       FROM Approval_Managed_Item__c Where Abnormal_Problem__c = :amId ];
        System.debug('*** problemList: ' + problemList + '');
        
        if (problemList.size()>0) {
            for (Integer i=0;i<problemList.size() ; i++) {
                List<Approval_Managed_Item__c> lstSelectedRectify= [SELECT Id,RecordTypeId,Abnormal_Rectify__c, Row_Index__c, Plan_Completed_Date__c, Header__c,
                            Header_Code__c, Header_Name__c, Text_Long__c,Parent_Row_Index__c
                        FROM Approval_Managed_Item__c Where Abnormal_Rectify__c = :problemList[i].Id];
                mapRectify.put(i,lstSelectedRectify);
            }
        }
         rectifyList = new List<Approval_Managed_Item__c>();
        
        containmentList = [SELECT Id,RecordTypeId,Abnormal_Containment__c, Row_Index__c, Header__c, Header_Code__c,
                           Header_Name__c, Text_Long__c FROM Approval_Managed_Item__c
                           Where Abnormal_Containment__c = :amId ];

        preDeleteRectifyList = new List<Approval_Managed_Item__c>();
        preDeleteContainmentList = new List<Approval_Managed_Item__c>();

    }


    public PageReference save() {

        //执行失败回滚所有操作
        System.Savepoint savepoint = Database.setSavepoint();
        try {
            update am;
            System.debug('*** rectifyList: ' + rectifyList + '');
            System.debug(LoggingLevel.INFO, '*** mapRectify.values(): ' + mapRectify.values());
            List<Approval_Managed_Item__c>  lstUpdateRectify= new List<Approval_Managed_Item__c>();
            for (Integer i=0;i<mapRectify.keySet().size() ;i++ ) {
                if (mapRectify.containsKey(i)) {
                     lstUpdateRectify.addAll(mapRectify.get(i));
                }
            }
            Map<id,Contact> mapContact = new Map<id,Contact>([SELECT Id, Name, Number__c FROM Contact WHERE RecordType.DeveloperName = 'Staff']) ;
            Integer count  =1;
            for (Approval_Managed_Item__c ami : lstUpdateRectify ) {
                if (String.isNotBlank(ami.Header__c) && mapContact.containsKey(ami.Header__c)) {
                    ami.Header_Code__c = mapContact.get(ami.Header__c).Number__c;
                    ami.Header_Name__c = mapContact.get(ami.Header__c).Name;
                }
                ami.Row_Index__c = String.valueOf(count);
                count ++;
            }
            count = 1;
            for (Approval_Managed_Item__c ami : containmentList ) {
                if (String.isNotBlank(ami.Header__c) && mapContact.containsKey(ami.Header__c)) {
                    ami.Header_Code__c = mapContact.get(ami.Header__c).Number__c;
                    ami.Header_Name__c = mapContact.get(ami.Header__c).Name;
                }
                ami.Row_Index__c = String.valueOf(count);
                count ++;
            }
            //更新子表
            UPSERT lstUpdateRectify;

            if (containmentList.size()>0) {
                UPSERT containmentList;
            }
            System.debug('*** preDeleteRectifyList: ' + preDeleteRectifyList + '');
            if (preDeleteRectifyList.size()>0) {
                DELETE preDeleteRectifyList;
            }
            if (preDeleteContainmentList.size()>0) {
                DELETE preDeleteContainmentList;
            }
        } catch (Exception e) {
            Database.rollback(savepoint);
            System.debug('The following exception has occurred: ' + e.getMessage());
            ApexPages.addMessages(e);
            return null;
        }
        return new PageReference('/' + am.Id);
    }

    public PageReference cancel() {
        System.debug(LoggingLevel.INFO, '*** apS.view(): ' + apS.view());
        return apS.view();
    }
    
    public PageReference selectedProblem() {
        System.debug('*** problemRow: ' + problemRow + '');
        isRedered = true;
        currentProblems = problemList[problemRow];
        rectifyList = mapRectify.get(problemRow);
        System.debug(LoggingLevel.INFO, '*** selected rectifyList: ' + rectifyList);
        return null;
    }
    public PageReference deleteRectify() {
        System.debug('*** rectifyRow: ' + rectifyRow + '');
        if (rectifyList[rectifyRow].Id != null) {
            preDeleteRectifyList.add(rectifyList[rectifyRow]);
        }
        mapRectify.get(problemRow).remove(rectifyRow);
        System.debug(LoggingLevel.INFO, '*** delete rectifyList: ' + rectifyList);
        return null;
    }
    public PageReference deleteContainment() {
        if (containmentList[containmentRow].Id != null) {
            preDeleteContainmentList.add(containmentList[containmentRow]);
        }
        containmentList.remove(containmentRow);
        return null;
    }
    public PageReference newRectify() {
        System.debug('*** currentProblems: ' + currentProblems + '');
        Approval_Managed_Item__c ami = new Approval_Managed_Item__c(Abnormal_Rectify__c = currentProblems.Id,Abnormal_Header__c = am.Id,
                                                        Parent_Row_Index__c = currentProblems.Row_Index__c);
        //设置品质异常纠正措施的记录类型ID
        ami.RecordTypeId = HarryUtils.getRecordTypeIdByDevNameAndObjName('Corrective_Action','Approval_Managed_Item__c');
        mapRectify.get(problemRow).add(ami);
        System.debug(LoggingLevel.INFO, '*** add rectifyList: ' + rectifyList);
        return null;
    }
    public PageReference newContainment() {

        //设置品质异常围堵措施的数据
        containmentList.add(new Approval_Managed_Item__c(Abnormal_Containment__c = am.Id,RecordTypeId = HarryUtils.getRecordTypeIdByDevNameAndObjName('Containment_Action','Approval_Managed_Item__c')));
        return null;
    }

}