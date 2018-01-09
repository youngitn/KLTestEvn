/**********************************************************************
 名    称：IT服务申请流程
 目    的：设置IT服务申请流程各节点审批人
 作    者：张旭
 创建日期：2017-07-07
 修 改 人：
 修改日期：
 修改原因：
 备    注：昆山&台湾共同使用该流程
 
 
 **********************************************************************/
public without sharing class AMInformationServiceHandler implements Triggers.Handler {
    public void handle() {
        //获取IT服务申请流程各节点配置
        Map<Decimal,Organizational__c>  mapSpecify = null;
        Id rtId = HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.IRS_INFORMATIONSERVICE,'Approval_Managed1__c');
        if (Trigger.isBefore && Trigger.isInsert) {
            for (Approval_Managed1__c cam : (List<Approval_Managed1__c>)Trigger.new) {
                if (cam.RecordTypeId == rtId) {
                    if(mapSpecify == null){
                        mapSpecify = Utils.getApprovalStepByAPIName(SapApprovalEnum.IRS_INFORMATIONSERVICE);
                    }
                    setApprovalUser(mapSpecify,cam);
                }
            }
        }
        if (Trigger.isBefore && Trigger.isUpdate) {
            for (Approval_Managed1__c cam : (List<Approval_Managed1__c>)Trigger.new) {
                if (cam.RecordTypeId == rtId && cam.Is_Reset_Approvaler__c) {
                    if(mapSpecify == null){
                        mapSpecify = Utils.getApprovalStepByAPIName(SapApprovalEnum.IRS_INFORMATIONSERVICE);
                    }
                    setApprovalUser(mapSpecify,cam);
                    cam.Is_Reset_Approvaler__c = false;
                }
                cam.head_description__c  = cam.Service_Desc__c;
            }
        }
    }
    public void setApprovalUser(Map<Decimal,Organizational__c> mapSpecify,Approval_Managed1__c cam){
        //节点一
        cam.Approval_User1__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(1),cam.Applicant__c),0);
        //节点二
        cam.Approval_User2__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(2),cam.Applicant__c),0);
        //节点三
        cam.Approval_User3__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(3),null),0);
        //节点四特殊计算
        //cam.Approval_User4__c  = Utils.getByIndex(specialCal1(cam),0);
           List<Id> lstID2 = specialCal5(cam);
        if (lstID2!=null && lstID2.size()>=2) {
            cam.Approval_User4__c  = lstID2[0];
            cam.Approval_User12__c = lstID2[1];
        }
        else if(lstID2!=null && lstID2.size()==1){
            cam.Approval_User4__c  = lstID2[0];
            cam.Approval_User12__c = lstID2[0];
        }
        //节点五
        cam.Approval_User5__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(5),null),0);
        //节点六特殊计算
        List<Id> lstID = specialCal6(cam);
        if (lstID!=null && lstID.size()>=2) {
            cam.Approval_User6__c  = lstID[0];
            cam.Approval_User10__c = lstID[1];
        }
        else if(lstID!=null && lstID.size()==1){
            cam.Approval_User6__c  = lstID[0];
            cam.Approval_User10__c = lstID[0];
        }
        //节点七特殊计算
         List<Id> lstID1 = specialCal7(cam);
        if (lstID1!=null && lstID1.size()==3) {
            cam.Approval_User7__c  = lstID1[0];
            cam.Approval_User11__c = lstID1[1];
            cam.Approval_User13__c = lstID1[2];

        }
        else if(lstID1!=null && lstID1.size()==2){
            cam.Approval_User7__c  = lstID1[0];
            cam.Approval_User11__c = lstID1[1];
            cam.Approval_User13__c = lstID1[1];
        }
        else if(lstID1!=null && lstID1.size()==1){
            cam.Approval_User7__c  = lstID1[0];
            cam.Approval_User11__c = lstID1[0];
            cam.Approval_User13__c = lstID1[0];
        }
        else if (lstID1!=null && lstID1.size()==4) {
            cam.Approval_User7__c  = lstID1[0];
            cam.Approval_User11__c = lstID1[1];
            cam.Approval_User13__c = lstID1[2];
            cam.Approval_User14__c = lstID1[3];        
        }


        //节点八
        cam.Approval_User8__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(8),cam.Applicant__c),0);
        //节点九
        cam.Approval_User9__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(9),null),0);

        if (cam.Factory__c == '3000'){      //TW 节点九與节点七同一人
        cam.Approval_User9__c = cam.Approval_User7__c;
        }
       
    }
        //相关主管确认
 // public List<Id> specialCal1(Approval_Managed1__c cam){

  //  List<Id> lstID = new List<Id>();//&& String.isBlank(cam.ServiceCategory__c)
      public List<Id> specialCal5(Approval_Managed1__c cam){
            List<Id> lstID = new List<Id>();
        if (cam.Factory__c != '3000' && (cam.ServiceCategory__c == '240' || cam.ServiceCategory__c == '250' ||
         cam.ServiceCategory__c == '260') ) {
          lstID.add(utils.getUserByEmployeeCode('10210000')); //李水波
        }
        if (cam.Factory__c != '3000' && cam.ServiceCategory__c == '220' &&  cam.Profit_Center__c == 'BU01') {
          lstID.add(utils.getUserByEmployeeCode('10210006')); //崇嘉兴
        }
        if (cam.Factory__c != '3000' && cam.ServiceCategory__c == '220' &&  cam.Profit_Center__c == 'BU02') {
          lstID.add(utils.getUserByEmployeeCode('10210010')); //郭星云
        }
        if (cam.Factory__c != '3000' && cam.ServiceCategory__c == '220' &&  cam.Profit_Center__c == 'BU03') {
          lstID.add(utils.getUserByEmployeeCode('10210610')); //邵学红
        }
        if (cam.Factory__c != '3000' && cam.ServiceCategory__c == '220' &&  cam.Profit_Center__c == 'BU04') {
          lstID.add(utils.getUserByEmployeeCode('10210177')); //王继水
        }
        if (cam.Factory__c != '3000' && cam.ServiceCategory__c == '220' &&  cam.Profit_Center__c == 'BU05') {
          lstID.add(utils.getUserByEmployeeCode('10210025')); //袁如旺
        }
        if (cam.Factory__c != '3000' && cam.ServiceCategory__c == '220' &&  (cam.Profit_Center__c == 'BU97' ||
          cam.Profit_Center__c == 'BU98' || cam.Profit_Center__c == 'BU99')) {
          lstID.add(utils.getUserByEmployeeCode('10210216')); //李洪庆
        }
        if (cam.Factory__c != '3000' && cam.ServiceCategory__c == '141') {
          lstID.add(utils.getUserByEmployeeCode('10210363')); //卢鹤松
        }
        if (cam.Factory__c != '3000' && cam.ServiceCategory__c != '140' ) {
          lstID.add(utils.getUserByEmployeeCode('10210225')); //徐井西
        }
        if (cam.Factory__c == '3000'){
          lstID.add(utils.getUserByEmployeeCode('30210240')); //李軏瀚
        }

        return lstID;
    }


        //业务专员
          public List<Id> specialCal6(Approval_Managed1__c cam){
            List<Id> lstID = new List<Id>();

        if (cam.Factory__c != '3000' && cam.ModuleName__c == '100' && cam.ServiceCategory__c != '100' 
          && cam.ServiceCategory__c != '110' && cam.ServiceCategory__c != '999' && cam.ServiceCategory__c != '160'
          && cam.ServiceCategory__c != '170' && cam.ServiceCategory__c != '180') {
          lstID.add(utils.getUserByEmployeeCode('10210900')); //汪军义
        } if (cam.Factory__c != '3000' && cam.ModuleName__c == '110' && cam.ServiceCategory__c != '100' 
          && cam.ServiceCategory__c != '110' && cam.ServiceCategory__c != '999' && cam.ServiceCategory__c != '160'
          && cam.ServiceCategory__c != '170' && cam.ServiceCategory__c != '180') {
          lstID.add(utils.getUserByEmployeeCode('10210352')); //张晓燕
        }
          if (cam.Factory__c != '3000' && cam.ModuleName__c == '120' && cam.ServiceCategory__c != '100' 
          && cam.ServiceCategory__c != '110' && cam.ServiceCategory__c != '999' && cam.ServiceCategory__c != '160'
          && cam.ServiceCategory__c != '170' && cam.ServiceCategory__c != '180') {
          lstID.add(utils.getUserByEmployeeCode('10210588')); //张金坤
        }
          if (cam.Factory__c != '3000' && cam.ModuleName__c == '130' && cam.ServiceCategory__c != '100' 
          && cam.ServiceCategory__c != '110' && cam.ServiceCategory__c != '999' && cam.ServiceCategory__c != '160'
          && cam.ServiceCategory__c != '170' && cam.ServiceCategory__c != '180') {
          lstID.add(utils.getUserByEmployeeCode('20210107')); //徐芳
        }
          if (cam.Factory__c != '3000' && cam.ModuleName__c == '140' && cam.ServiceCategory__c != '100' 
          && cam.ServiceCategory__c != '110' && cam.ServiceCategory__c != '999' && cam.ServiceCategory__c != '160'
          && cam.ServiceCategory__c != '170' && cam.ServiceCategory__c != '180') {
          lstID.add(utils.getUserByEmployeeCode('10210089')); //范红梅
        }
          if (cam.Factory__c != '3000' && cam.ModuleName__c == '150' && cam.ServiceCategory__c != '100' 
          && cam.ServiceCategory__c != '110' && cam.ServiceCategory__c != '999' && cam.ServiceCategory__c != '160'
          && cam.ServiceCategory__c != '170' && cam.ServiceCategory__c != '180') {
          lstID.add(utils.getUserByEmployeeCode('10210156')); //李燕
        } 
          if (cam.Factory__c != '3000' && cam.ModuleName__c == '160' && cam.ServiceCategory__c != '100' 
          && cam.ServiceCategory__c != '110' && cam.ServiceCategory__c != '999' && cam.ServiceCategory__c != '160'
          && cam.ServiceCategory__c != '170' && cam.ServiceCategory__c != '180') {
          lstID.add(utils.getUserByEmployeeCode('10210223')); //郑宾
        }
          if (cam.Factory__c != '3000' && cam.ModuleName__c == '170' && cam.ServiceCategory__c != '100' 
          && cam.ServiceCategory__c != '110' && cam.ServiceCategory__c != '999' && cam.ServiceCategory__c != '160'
          && cam.ServiceCategory__c != '170' && cam.ServiceCategory__c != '180') {
          lstID.add(utils.getUserByEmployeeCode('10210018')); //崔雪莉
          lstID.add(utils.getUserByEmployeeCode('10210403')); //赵敏
        }
       
        return lstID;
    }


            //技术专员
          public List<Id> specialCal7(Approval_Managed1__c cam){List<Id> lstID = new List<Id>();

        if (cam.Factory__c != '3000' && (cam.ServiceCategory__c== '130' || cam.ServiceCategory__c == '150')) {
          lstID.add(utils.getUserByEmployeeCode('10210224')); //许晓峰
        } 
        if (cam.Factory__c != '3000' && (cam.ServiceCategory__c == '100' || cam.ServiceCategory__c == '999'|| cam.ServiceCategory__c == '111'|| cam.ServiceCategory__c == '240'
          || cam.ServiceCategory__c == '250'|| cam.ServiceCategory__c == '260')) {
          List<Organizational__c> lstOrg = [SELECT Id FROM Organizational__c 
                                              WHERE RecordType.DeveloperName = 'Job_Title' AND Post_Number__c = '30000010'];
            if (lstOrg.size()>0) {
              lstID = utils.approvalSearchUserByJob(lstOrg[0].Id);
            }
        }

        if (cam.Factory__c != '3000' && cam.ServiceCategory__c == '110' &&(cam.Account_type__c.contains('a') )) {
          List<Organizational__c> lstOrg = [SELECT Id FROM Organizational__c 
                                              WHERE RecordType.DeveloperName = 'Job_Title' AND Post_Number__c = '30000010'];
            if (lstOrg.size()>0) {
              lstID = utils.approvalSearchUserByJob(lstOrg[0].Id);
            }
        }

        if (cam.Factory__c != '3000' && cam.ServiceCategory__c == '110' &&(cam.Account_type__c.contains('p') || cam.Account_type__c.contains('c') )) {
             lstID.add(utils.getUserByEmployeeCode('10210961')); //张旭
        }

        if (cam.Factory__c != '3000' && cam.ServiceCategory__c == '110' &&(cam.Account_type__c.contains('s') || cam.Account_type__c.contains('f') )) {
            lstID.add(utils.getUserByEmployeeCode('10210225')); //徐井西
        }

        if (cam.Factory__c != '3000' && cam.ServiceCategory__c =='120') {
          lstID.add(utils.getUserByEmployeeCode('10210225')); //徐井西
        }

         if (cam.Factory__c != '3000' && cam.ServiceCategory__c == '120') {
          lstID.add(utils.getUserByEmployeeCode('10210225')); //徐井西
        }

         if (cam.Factory__c != '3000' && (cam.ServiceCategory__c == '170' || cam.ServiceCategory__c == '181'
          || cam.ServiceCategory__c == '180' || cam.ServiceCategory__c == '150')) {
          lstID.add(utils.getUserByEmployeeCode('10212257')); //刘忠林
        }

         if (cam.Factory__c != '3000' && (cam.ServiceCategory__c == '170' || cam.ServiceCategory__c == '181'
          || cam.ServiceCategory__c == '180' || cam.ServiceCategory__c == '150')) {
          lstID.add(utils.getUserByEmployeeCode('10212275')); //王思佳
        
        } if (cam.Factory__c != '3000' && cam.ServiceCategory__c == '140'){
         lstID.add(utils.getUserByEmployeeCode('10210776')); //张榕
        }

         if (cam.Factory__c != '3000' && (cam.ServiceCategory__c == '190' || cam.ServiceCategory__c == '200'
          || cam.ServiceCategory__c == '210' || cam.ServiceCategory__c == '150')) {
          lstID.add(utils.getUserByEmployeeCode('10210911')); //丁鹏
        }

         if (cam.Factory__c != '3000' && (cam.ServiceCategory__c == '170' || cam.ServiceCategory__c == '181'
          || cam.ServiceCategory__c == '180' || cam.ServiceCategory__c == '150')) {
          lstID.add(utils.getUserByEmployeeCode('10210961')); //张旭
        }

          if (cam.Factory__c != '3000' && (cam.ServiceCategory__c == '160' || cam.ServiceCategory__c == '220')) {
          lstID.add(utils.getUserByEmployeeCode('10210454')); //贡呈慧
        }
          if (cam.Factory__c != '3000' && cam.ServiceCategory__c == '230') {
           // List<Organizational__c> lstOrg = [SELECT Id FROM Organizational__c 
           //                                    WHERE RecordType.DeveloperName = 'Job_Title' AND Post_Number__c = '30000535'];
           //  if (lstOrg.size()>0) {
           //    lstID = utils.approvalSearchUserByJob(lstOrg[0].Id);
           //  }
            lstID.add(utils.getUserByEmployeeCode('10212364')); //王金苹


        }

        //TW 
        if (cam.Factory__c == '3000' && (cam.ServiceCategory__c == '100' || cam.ServiceCategory__c == '110'|| cam.ServiceCategory__c == '111'))
        {
          lstID.add(utils.getUserByEmployeeCode('30210086')); //
        }
        if (cam.Factory__c == '3000' && (cam.ServiceCategory__c == '160' || cam.ServiceCategory__c == '170'|| cam.ServiceCategory__c == '180'|| cam.ServiceCategory__c == '181'))
        {
          lstID.add(utils.getUserByEmployeeCode('30210088')); //
        }
        if (cam.Factory__c == '3000' && (cam.ServiceCategory__c == '999'))
        {
          lstID.add(utils.getUserByEmployeeCode('30210086')); //
        }
        if (cam.Factory__c == '3000' && (cam.ServiceCategory__c == '120' || cam.ServiceCategory__c == '130'|| cam.ServiceCategory__c == '150'
                                       || cam.ServiceCategory__c == '190'|| cam.ServiceCategory__c == '200'|| cam.ServiceCategory__c == '210'))
        {
             if (cam.ModuleName__c == '100' || cam.ModuleName__c == '110' || cam.ModuleName__c == '130' || cam.ModuleName__c == '140' || cam.ModuleName__c == '160' )
             { 
          lstID.add(utils.getUserByEmployeeCode('30210088')); //
             }
             if (cam.ModuleName__c == '120' || cam.ModuleName__c == '150' || cam.ModuleName__c == '170' )
             { 
          lstID.add(utils.getUserByEmployeeCode('30210086')); //
             }
        }

        //TW 

        return lstID;
    }
}