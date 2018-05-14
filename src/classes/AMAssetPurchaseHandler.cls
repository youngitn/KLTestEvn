/**********************************************************************
 名    称：资产购置审批流程
 目    的：设置资产购置审批流程各节点审批人
 作    者：刘文俊(liuwenjun@bluelinksys.com)
 创建日期：2017-04-25
 修 改 人：
 修改日期：
 修改原因：
 备    注：
          节点  1 稽核单位审批          相关用户：*审批用户01  最终拒绝
          节点  2 一阶主管审批          相关用户：*审批用户02  最终拒绝
          节点  3 评估单位             相关用户：*审批用户03  *审批用户11 最终拒绝
          节点  4 采购员议价-非6000     相关用户：*审批用户04  最终拒绝
          节点  5 采购员议价-6000       相关用户：*审批用户05  最终拒绝
          节点  6 采购主管审批-非6000   相关用户：*审批用户06  返回 1 步
          节点  7 采购主管审批          相关用户：*审批用户07  返回 1 步
          节点  8 总经理室审批          相关用户：*审批用户08  返回 1 步
          节点  9 资产会计-1000         相关用户：*审批用户09  最终拒绝
          节点  10  资产会计-其他        相关用户：*审批用户10  返回 1 步
          节点  11  采购下单-非6000      相关用户：*审批用户04  返回 1 步
          节点  12  采购下单-6000       相关用户：*审批用户05  返回 1 步
          节点  13  评估单位验收         相关用户：*审批用户03  返回 1 步
          节点  14  采购确认回厂-模具     相关用户：*审批用户12  返回 1 步
          节点  15  采购确认回厂-非模具    相关用户：*审批用户13  返回 1 步
          节点  16  仓库103收货-1000     相关用户：*审批用户14 返回 1 步
          节点  17  仓库103收货-2000     相关用户：*审批用户15  返回 1 步
          节点  18  设备部安装            相关用户: *审批用户16、*审批用户17 返回 1 步
          节点  19  使用部门验收          相关用户：*审批用户02  返回 1 步
          节点  20  设备验收             用户:李 俊杰 返回 1 步
          节点  21  仓库105收货-1000      基于首次回复的批准   相关用户: *审批用户14、*审批用户18  返回 1 步
          节点  22  仓库105收货-2000      相关用户：*审批用户15  返回 1 步
          节点  23  资产会计确认-1000     相关用户：*审批用户09  返回 1 步
          节点  24  资产会计确认-其他      相关用户：*审批用户10  返回 1 步
          节点  25  IE部门统计            相关用户：*审批用户19  返回 1 步
 **********************************************************************/
public without sharing class AMAssetPurchaseHandler implements Triggers.Handler {
    public void handle() {
        //获取资产购置流程各节点配置
        Map<Decimal,Organizational__c>  mapSpecify = null;
        Id rtId = HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.ASSETPURCHASE,'Approval_Managed__c');
        if (Trigger.isBefore && Trigger.isInsert) {
            for (Approval_Managed__c cam : (List<Approval_Managed__c>)Trigger.new) {
                if (cam.RecordTypeId == rtId) {
                    if(mapSpecify == null){
                        mapSpecify = Utils.getApprovalStepByAPIName(SapApprovalEnum.ASSETPURCHASE);
                    }
                    setApprovalUser(mapSpecify,cam);
                }
            }
        }
        if (Trigger.isBefore && Trigger.isUpdate) {
            for (Approval_Managed__c cam : (List<Approval_Managed__c>)Trigger.new) {
                if (cam.RecordTypeId == rtId && cam.Is_Reset_Approvaler__c) {
                    if(mapSpecify == null){
                        mapSpecify = Utils.getApprovalStepByAPIName(SapApprovalEnum.ASSETPURCHASE);
                    }
                    setApprovalUser(mapSpecify,cam);
                    cam.Is_Reset_Approvaler__c = false;
                    cam.head_description__c  = cam.Reason_of_Purchase__c;
                }
                
            }
        }
    }
    public void setApprovalUser(Map<Decimal,Organizational__c> mapSpecify,Approval_Managed__c cam){
          //节点一
          cam.Approval_User1__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(1),null),0);
          //节点二
          cam.Approval_User2__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(2),cam.Applicant__c),0);
          //节点三 特殊计算
          List<Id> lstID = specialCal1(cam);
          if (lstID!=null && lstID.size()==4) {
          cam.Approval_User3__c  = lstID[0];
          cam.Approval_User11__c = lstID[1];
          cam.Approval_User20__c = lstID[2];
          cam.Approval_User7__c  = lstID[3];
          }else if(lstID!=null && lstID.size()==3) {
          cam.Approval_User3__c  = lstID[0];
          cam.Approval_User11__c = lstID[1];
          cam.Approval_User20__c = lstID[2];
          cam.Approval_User7__c  = lstID[2];
          }else if(lstID!=null && lstID.size()==2) {
          cam.Approval_User3__c  = lstID[0];
          cam.Approval_User11__c = lstID[1];
          cam.Approval_User20__c = lstID[1];
          cam.Approval_User7__c  = lstID[1];
          }else if(lstID!=null && lstID.size()==1){
          cam.Approval_User3__c  = lstID[0];
          cam.Approval_User11__c = lstID[0];
          cam.Approval_User20__c = lstID[0];
          cam.Approval_User7__c  = lstID[0];
          }
          //节点四
          cam.Approval_User4__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(4),null),0);
          //节点五
          cam.Approval_User5__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(5),null),0);
          //节点六
          cam.Approval_User6__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(6),null),0);
          //节点七
          //cam.Approval_User7__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(7),null),0);
          //节点八
          if (cam.Asset_Type__c  == '03' ) {
            //cam.Approval_User8__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(8),null),0);
            cam.Approval_User8__c = utils.getUserByEmployeeCode('10210000');
            cam.Approval_User18__c = utils.getUserByEmployeeCode('10210000');
          }else if (cam.Asset_Type__c  == '04' ){
            cam.Approval_User8__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(8),null),0);
            cam.Approval_User18__c  = utils.getUserByEmployeeCode('30210004');
          }else{
            cam.Approval_User8__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(8),null),0);
            cam.Approval_User18__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(8),null),0);
          }
          //节点九 
          //cam.Approval_User9__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(9),null),0); 
          List<Id> lstID3 = specialCal3(cam); 
          if (lstID3!=null) {
            cam.Approval_User9__c = lstID3[0];
          }
          //节点十
          cam.Approval_User10__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(10),null),0);
          //节点十一
            //审批用户同节点4
          //节点十二
            //审批用户同节点5
          //节点十三
          List<Id> lstID2 = specialCal2(cam);    
          if (lstID2!=null && lstID2.size()==2) {
          cam.Approval_User21__c = lstID2[0];
          cam.Approval_User22__c = lstID2[1];
          }else if(lstID2!=null && lstID2.size()==1){
          cam.Approval_User21__c = lstID2[0];
          cam.Approval_User22__c = lstID2[0];
          }

          //节点十四 
          //cam.Approval_User12__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(14),null),0);
          //节点十五
          cam.Approval_User13__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(15),null),0);
          //节点十六
          cam.Approval_User14__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(16),null),0);
          //节点十七
          cam.Approval_User15__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(17),null),0);
          //节点十八  两个审批用户 需一致审批
          cam.Approval_User16__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(18),null),0);
          cam.Approval_User17__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(19),null),0);
          //节点十九
            //审批用户同节点2 
          //节点二十
           // cam.Approval_User24__c  = utils.getUserByEmployeeCode('10212251');
          Set<String> userIds = new Set<String>(); 
          userIds.add('00528000006p2Jc');
          Utils.ManualShareRecordToUsers(userIds, 'Approval_Managed__c', id.valueOf('a010I00001hR2gZQAS'));
          //节点二十一 两个审批用户
          
          //节点二十二
           //审批用户同节点16
          //节点二十三
          //节点二十四
          //节点二十五
          cam.Approval_User19__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(26),null),0);

          cam.Approval_User23__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(27),cam.Applicant__c),0);

          //USER12 合并采购确认回厂-模具和103收货1000，空出USER12 用来通知张凤巧
          cam.Approval_User12__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(50),null),0);
    }

    //评估单位审批节点
    public List<Id> specialCal1(Approval_Managed__c cam){
      List<Id> lstID = new List<Id>();

        //类型为01 厂务工程-固资类
        if (cam.Asset_Type__c  == '01' ) {
          lstID.add(utils.getUserByEmployeeCode('10210533'));
          lstID.add(utils.getUserByEmployeeCode('10210841')); 
        }

        //类型为02 其他
        if (cam.Asset_Type__c  == '02' ) {
          lstID.add(utils.getUserByEmployeeCode('10210841'));
        }

        //类型为03 生产及辅助设备
        if (cam.Asset_Type__c  == '03' ) {
          lstID.add(utils.getUserByEmployeeCode('10210350'));
          lstID.add(utils.getUserByEmployeeCode('10211101'));
          lstID.add(utils.getUserByEmployeeCode('10210841'));
          lstID.add(utils.getUserByEmployeeCode('10211573'));
        }

        //类型为04 资讯办公设备
        if (cam.Asset_Type__c  == '04' ) {
          lstID.add(utils.getUserByEmployeeCode('10210225'));
          //lstID.add(utils.getUserByEmployeeCode('30210004'));
        }

        //类型为05 总务办公设备
        if (cam.Asset_Type__c  == '05' ) {
          lstID.add(utils.getUserByEmployeeCode('10210533'));
        }

        //类型为06 检验设备
        if (cam.Asset_Type__c  == '06' ) {
            List<Organizational__c> lstOrg = [SELECT Id FROM Organizational__c 
                                              WHERE RecordType.DeveloperName = 'Job_Title' AND Post_Number__c = '30002326'];
            if (lstOrg.size()>0) {
              lstID = utils.approvalSearchUserByJob(lstOrg[0].Id);
            }
        }

        //类型为07 模具
        if (cam.Asset_Type__c  == '07' ) {
          lstID.add(utils.getUserByEmployeeCode('10210216'));
        }

        //类型为08 厂务工程-修缮类
        if (cam.Asset_Type__c  == '08' ) {
          lstID.add(utils.getUserByEmployeeCode('10210533'));
        }

        return lstID;
    }

      //评估单位验收节点
        public List<Id> specialCal2(Approval_Managed__c cam){
      List<Id> lstID2 = new List<Id>();

        //类型为01 厂务工程-固资类
        if (cam.Asset_Type__c  == '01' ) {
          lstID2.add(utils.getUserByEmployeeCode('10210533'));
          lstID2.add(utils.getUserByEmployeeCode('10210841')); 
        }

        //类型为02 其他
        if (cam.Asset_Type__c  == '02' ) {
          lstID2.add(utils.getUserByEmployeeCode('10210841'));
        }

        //类型为03 生产及辅助设备
        /*if (cam.Asset_Type__c  == '03' ) {
          lstID2.add(utils.getUserByEmployeeCode('10210350'));
          lstID2.add(utils.getUserByEmployeeCode('10211101'));
          lstID2.add(utils.getUserByEmployeeCode('10210841'));
        }*/

        //类型为04 资讯办公设备
        if (cam.Asset_Type__c  == '04' ) {
          lstID2.add(utils.getUserByEmployeeCode('10210225'));
        }

        //类型为05 总务办公设备
        if (cam.Asset_Type__c  == '05' ) {
          lstID2.add(utils.getUserByEmployeeCode('10210533'));
        }

        //类型为06 检验设备
        if (cam.Asset_Type__c  == '06' ) {
            List<Organizational__c> lstOrg = [SELECT Id FROM Organizational__c 
                                              WHERE RecordType.DeveloperName = 'Job_Title' AND Post_Number__c = '30002326'];
            if (lstOrg.size()>0) {
              lstID2 = utils.approvalSearchUserByJob(lstOrg[0].Id);
            }
        }

        //类型为07 模具
        if (cam.Asset_Type__c  == '07' ) {
          lstID2.add(Utils.getUserIdByContactID(cam.Applicant__c));
        }

        //类型为08 厂务工程-修缮类
        if (cam.Asset_Type__c  == '08' ) {
          lstID2.add(utils.getUserByEmployeeCode('10210533'));
        }
        return lstID2;
    }

    //资产会计-1000节点
    public List<Id> specialCal3(Approval_Managed__c cam){
      List<Id> lstID3 = new List<Id>();
      Set<String> set3 = new Set<String>{'1000F072','1000F073','1000F075','1000F076','1000F077','ZG7PBJY01','ZG7ZZBZ01','ZG7ZZHJ01','ZG7ZZKZ01','ZG7ZZPG01','ZG7ZZQX01','ZG7ZZWC01','ZG7ZZZP01'};
        
        if (cam.Factory__c == '1000' && set3.contains(cam.Dept_of_CostCenter__c)) {
          lstID3.add(utils.getUserByEmployeeCode('10210776'));
        }else{
          lstID3.add(utils.getUserByEmployeeCode('10210900'));
        }
        return lstID3;
    }

    


}