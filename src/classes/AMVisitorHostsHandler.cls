public without sharing class AMVisitorHostsHandler implements Triggers.Handler {
    public void handle() {
        Integer a;
        if (Trigger.isBefore && Trigger.isInsert) {
        	//來賓接待记录类型
        	RecordType recTypeAcc = [SELECT Id, DeveloperName, Name 
                                     FROM RecordType Where SObjectType = 'Approval_Managed1__c' 
                                     AND DeveloperName ='VisitorHosts'];
        	Map<Decimal,Organizational__c>  mapSpecify = Utils.getApprovalStepByAPIName(SapApprovalEnum.VISITORHOSTS);
        	for (Approval_Managed1__c cam : (List<Approval_Managed1__c>)Trigger.new) {
        		if (cam.RecordTypeId == recTypeAcc.Id) {
        			//节点一：申请人部门主管
        			cam.Approval_User1__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(1),cam.Applicant__c),0);
        			//节点二：指定人员
                    if (cam.Applicant_Corp_Code__c == '3000') {    //申请人公司代码
                        cam.Approval_User2__c = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(2),null),0);
                    }else {
                        cam.Approval_User2__c = utils.getUserByEmployeeCode('10210853');
                    }
        			
        			//节点三：指定人员
                    if (cam.Applicant_Corp_Code__c == '3000') {
                        cam.Approval_User3__c = utils.getUserByEmployeeCode('30210061');  //林雅純   
                        cam.Approval_User4__c = utils.getUserByEmployeeCode('30210131');  //廖淑雲   
                        cam.Approval_User5__c = utils.getUserByEmployeeCode('30210286');  //梁惠雯 
                    }else{
                         Boolean b1 = cam.souvenir_YN__c == 'Y';   //是否赠礼
                         Boolean b2 = cam.meal_YN__c=='Y' || cam.hotel_YN__c=='Y';       //是否订餐/住宿
                        // 是否安排接车/接机
                         Boolean b3 = cam.pickup_car_YN__c=='Y'||cam.deliver_car_YN__c== 'Y'||cam.pickup_plane_YN__c=='Y'||cam.deliver_plane_YN__c== 'Y';  
                       
                        if(b1 && b2 && b3){
                              //全部都有
                              cam.Approval_User3__c = utils.getUserByEmployeeCode('10210861');  //王彩虹
                              cam.Approval_User4__c = utils.getUserByEmployeeCode('10210703');  //王梦蝶
                              cam.Approval_User5__c = utils.getUserByEmployeeCode('10210156');  //李燕
                              cam.Approval_User6__c = utils.getUserByEmployeeCode('10210533');  //章国庆 
                        }else if(b1 && b3){
                            //送礼、接送飞机/车
                            cam.Approval_User3__c = utils.getUserByEmployeeCode('10210703');  //王梦蝶
                            cam.Approval_User4__c = utils.getUserByEmployeeCode('10210156');  //李燕
                            cam.Approval_User5__c = utils.getUserByEmployeeCode('10210156');  //李燕
                            cam.Approval_User6__c = utils.getUserByEmployeeCode('10210156');  //李燕
                        }else if (b2 && b3) {
                            // 吃/住/接送飞机/车
                            cam.Approval_User3__c = utils.getUserByEmployeeCode('10210861');  //王彩虹
                            cam.Approval_User4__c = utils.getUserByEmployeeCode('10210533');  //章国庆
                            cam.Approval_User5__c = utils.getUserByEmployeeCode('10210156');  //李燕
                            cam.Approval_User6__c = utils.getUserByEmployeeCode('10210156');  //李燕
                        }else if(b1 && b2){
                             //  送礼/吃/住/
                             cam.Approval_User3__c = utils.getUserByEmployeeCode('10210861');  //王彩虹
                             cam.Approval_User4__c = utils.getUserByEmployeeCode('10210703');  //王梦蝶
                             cam.Approval_User5__c = utils.getUserByEmployeeCode('10210533');  //章国庆
                             cam.Approval_User6__c = utils.getUserByEmployeeCode('10210533');  //章国庆
                         }else if(b3){
                            //接送飞机/车
                            cam.Approval_User3__c = utils.getUserByEmployeeCode('10210156');  //李燕
                            cam.Approval_User4__c = utils.getUserByEmployeeCode('10210156');  //李燕
                            cam.Approval_User5__c = utils.getUserByEmployeeCode('10210156');  //李燕
                            cam.Approval_User6__c = utils.getUserByEmployeeCode('10210156');  //李燕
                         }else if(b1){
                            //送礼
                            cam.Approval_User3__c = utils.getUserByEmployeeCode('10210703');  //王梦蝶
                            cam.Approval_User4__c = utils.getUserByEmployeeCode('10210703');  //王梦蝶
                            cam.Approval_User5__c = utils.getUserByEmployeeCode('10210703');  //王梦蝶
                            cam.Approval_User6__c = utils.getUserByEmployeeCode('10210703');  //王梦蝶
                         }else if(b2){
                            // 吃/住
                            cam.Approval_User3__c = utils.getUserByEmployeeCode('10210861');  //王彩虹
                            cam.Approval_User4__c = utils.getUserByEmployeeCode('10210533');  //章国庆
                            cam.Approval_User5__c = utils.getUserByEmployeeCode('10210533');  //章国庆
                            cam.Approval_User6__c = utils.getUserByEmployeeCode('10210533');  //章国庆
                         }
                        
                    }
        			
                    cam.Approval_User10__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(10),cam.Applicant__c),0);
                    cam.Approval_User11__c  = Utils.getByIndex(Utils.approvalSearchApprrovalerByRule(mapSpecify.get(11),cam.Applicant__c),0);
        		}
        	}
            System.debug('*** 退出节点配置: '  + '');     
        }   


    }
}