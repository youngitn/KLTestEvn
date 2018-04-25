/*
* Name                 : Custom_Approval_Managed__c  Approval_Managed__c Trigger
* Object               : UpdateBillHeaderInfoHander
* Requirement          :保存各审批流程记录时，自动写入单据头信息
* Refer classes        :
* Author               :zhonghui
* Create Date          :2017年4月19日
* Modify History       :
*
*/
public without sharing class UpdateBillHeaderInfoHandler implements Triggers.Handler {
	public void handle()  {
		if (Trigger.isInsert) {
			Map<Id, Contact>  mapCon = new Map<Id, Contact>([SELECT Id, Number__c, Name, Corp_Code__c, Dept_Number__c, Dept_Number__r.Description__c FROM Contact WHERE RecordType.DeveloperName = 'Staff']);
			Map<Id, SObject> mapOld = Trigger.oldMap;
			for (SObject obj : Trigger.new) {
				//不同对象对应的处理
				if (HarryUtils.compareObjtype(obj, 'Custom_Approval_Managed__c')) {
					Custom_Approval_Managed__c cam = (Custom_Approval_Managed__c)obj;
					//不同流程对应的处理
					if (String.isBlank(cam.Status__c)) {
						cam.Status__c = '新建'; //单据状态
					}
					if (cam.Bill_Date__c == null) {
						cam.Bill_Date__c = Date.today(); //单据日期
					}
					if (String.isBlank(cam.Applicant__c)) {
						System.debug('*** cam.Applicant__c: ' + cam.Applicant__c + '');
						cam.Applicant__c = Utils.getContactIdByUserID(UserInfo.getUserId());//申请人
					}
					if (String.isBlank(cam.Dept_Name__c) && !String.isBlank(cam.Applicant__c)) {
						if (mapCon.containsKey(cam.Applicant__c)) {
							System.debug(LoggingLevel.INFO, '*** : 员工所属部门' + mapCon.get(cam.Applicant__c).Dept_Number__c);
							cam.Dept_Name__c = mapCon.get(cam.Applicant__c).Dept_Number__r.Description__c; //所属部门
						}
					}
					//申请人工号
					if (String.isBlank(cam.Applicant_Code__c) && !String.isBlank(cam.Applicant__c)) {
						if (mapCon.containsKey(cam.Applicant__c)) {
							cam.Applicant_Code__c = mapCon.get(cam.Applicant__c).Number__c;
						}
					}
					//申请人公司姓名
					if (String.isBlank(cam.Applicant_Name__c) && !String.isBlank(cam.Applicant__c)) {
						if (mapCon.containsKey(cam.Applicant__c)) {
							cam.Applicant_Name__c = mapCon.get(cam.Applicant__c).Name;
						}
					}
					//申请人公司代码
					if (String.isBlank(cam.Applicant_Corp_Code__c) && !String.isBlank(cam.Applicant__c)) {
						if (mapCon.containsKey(cam.Applicant__c)) {
							cam.Applicant_Corp_Code__c = mapCon.get(cam.Applicant__c).Corp_Code__c;
						}
					}

					//不同流程对应不同流程名称
					if (cam.RecordTypeId == HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.CUSTOMER, 'Custom_Approval_Managed__c')) {
						cam.Approval_Name__c = '客户主数据维护'; //流程名称
					} else if (cam.RecordTypeId == HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.VENDOR, 'Custom_Approval_Managed__c')) {
						cam.Approval_Name__c = '供应商主数据维护'; //流程名称
					} else if (cam.RecordTypeId == HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.BUSINESSTRAVEL, 'Custom_Approval_Managed__c')) {
						cam.Approval_Name__c = '员工出差管理流程'; //流程名称
					} else if (cam.RecordTypeId == HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.PURCHASEINFORMATION, 'Custom_Approval_Managed__c')) {
						cam.Approval_Name__c = '采购信息记录维护申请单'; //流程名称
					} else if (cam.RecordTypeId == HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.COSTCENTERSEND, 'Custom_Approval_Managed__c')) {
						cam.Approval_Name__c = '计划外(成本中心)发料作业'; //流程名称
					} else if (cam.RecordTypeId == HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.WASTEDISPOSE, 'Custom_Approval_Managed__c')) {
						cam.Approval_Name__c = '废料处理流程'; //流程名称
					} else if (cam.RecordTypeId == HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.SALEORDER, 'Custom_Approval_Managed__c')) {
						cam.Approval_Name__c = '销售订单流程'; //流程名称
					} else if (cam.RecordTypeId == HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.SALESAPPLICATION, 'Custom_Approval_Managed__c')) {
						cam.Approval_Name__c = '标准销售申请流程 '; //流程名称
					} else if (cam.RecordTypeId == HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.RFQ, 'Custom_Approval_Managed__c')) {
						cam.Approval_Name__c = '采购询价作业流程'; //流程名称
					} else if (cam.RecordTypeId == HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.OVERTIMEWORK, 'Custom_Approval_Managed__c')) {
						cam.Approval_Name__c = '加班管理流程'; //流程名称
					} else if (cam.RecordTypeId == HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.MODIFYPAY, 'Custom_Approval_Managed__c')) {
						cam.Approval_Name__c = '员工调薪管理流程'; //流程名称
					} else if (cam.RecordTypeId == HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.INTERNALCONTACT, 'Custom_Approval_Managed__c')) {
						cam.Approval_Name__c = '内部联络单流程'; //流程名称
					} else if (cam.RecordTypeId == HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.CUSTOMERDISPATCH, 'Custom_Approval_Managed__c')) {
						cam.Approval_Name__c = '客户派车申请流程'; //流程名称
					} else if (cam.RecordTypeId == HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.PERIODOFPROBATION, 'Custom_Approval_Managed__c')) {
						cam.Approval_Name__c = '员工试用期转正管理流程'; //流程名称
					}else if (cam.RecordTypeId == HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.SCCSUPPLIERCLAIM, 'Custom_Approval_Managed__c')) {
						cam.Approval_Name__c = 'SCC供应商索赔申请流程流程'; //流程名称
					}
					else if (cam.RecordTypeId == HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.SALESRETURN, 'Custom_Approval_Managed__c')) {
						cam.Approval_Name__c = '退货申请流程'; //流程名称
					}


				} else if (HarryUtils.compareObjtype(obj, 'Approval_Managed__c')) {
					Approval_Managed__c cam = (Approval_Managed__c)obj;
					//不同流程对应的处理
					if (String.isBlank(cam.Status__c)) {
						cam.Status__c = '新建'; //单据状态
					}
					if (cam.Bill_Date__c == null) {
						cam.Bill_Date__c = Date.today(); //单据日期
					}
					if (String.isBlank(cam.Applicant__c)) {
						System.debug('*** cam.Applicant__c: ' + cam.Applicant__c + '');
						cam.Applicant__c = Utils.getContactIdByUserID(UserInfo.getUserId());//申请人
					}
					if (String.isBlank(cam.Dept_Name__c) && !String.isBlank(cam.Applicant__c)) {
						if (mapCon.containsKey(cam.Applicant__c)) {
							System.debug(LoggingLevel.INFO, '*** : 员工所属部门' + mapCon.get(cam.Applicant__c).Dept_Number__c);
							cam.Dept_Name__c = mapCon.get(cam.Applicant__c).Dept_Number__r.Description__c; //所属部门
						}
					}
					//申请人工号
					if (String.isBlank(cam.Applicant_Code__c) && !String.isBlank(cam.Applicant__c)) {
						if (mapCon.containsKey(cam.Applicant__c)) {
							cam.Applicant_Code__c = mapCon.get(cam.Applicant__c).Number__c;
						}
					}
					//申请人公司姓名
					if (String.isBlank(cam.Applicant_Name__c) && !String.isBlank(cam.Applicant__c)) {
						if (mapCon.containsKey(cam.Applicant__c)) {
							cam.Applicant_Name__c = mapCon.get(cam.Applicant__c).Name;
						}
					}
					//申请人公司代码
					if (String.isBlank(cam.Applicant_Corp_Code__c) && !String.isBlank(cam.Applicant__c)) {
						if (mapCon.containsKey(cam.Applicant__c)) {
							cam.Applicant_Corp_Code__c = mapCon.get(cam.Applicant__c).Corp_Code__c;
						}
					}

					//不同流程对应不同流程名称
					if (cam.RecordTypeId == HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.EXPENSEREIMBURSE, 'Approval_Managed__c')) {
						cam.Approval_Name__c = '费用报销流程'; //流程名称
					} else if (cam.RecordTypeId == HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.ADVANCECHARGE, 'Approval_Managed__c')) {
						cam.Approval_Name__c = '预付款申请流程'; //流程名称
					} else if (cam.RecordTypeId == HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.STAFFTRANSFER, 'Approval_Managed__c')) {
						cam.Approval_Name__c = '员工异动管理流程'; //流程名称
					} else if (cam.RecordTypeId == HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.ASSETPURCHASE, 'Approval_Managed__c')) {
						cam.Approval_Name__c = '资产购置流程'; //流程名称
					} else if (cam.RecordTypeId == HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.PURCHASEORDER, 'Approval_Managed__c')) {
						cam.Approval_Name__c = '标准采购订单作业流程'; //流程名称
					} else if (cam.RecordTypeId == HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.ABNORMALQUALITY, 'Approval_Managed__c')) {
						cam.Approval_Name__c = '品质异常单流程'; //流程名称
					} else if (cam.RecordTypeId == HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.PURCHASEAPPLICATION, 'Approval_Managed__c')) {
						cam.Approval_Name__c = '采购申请作业流程'; //流程名称
					} else if (cam.RecordTypeId == HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.ABNORMALATTENCE, 'Approval_Managed__c')) {
						cam.Approval_Name__c = '考勤异常处理申请流程'; //流程名称
					} else if (cam.RecordTypeId == HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.LEAVE, 'Approval_Managed__c')) {
						cam.Approval_Name__c = '请假管理流程'; //流程名称
					} else if (cam.RecordTypeId == HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.ENTERTAINECOST, 'Approval_Managed__c')) {
						cam.Approval_Name__c = '费用申请流程'; //流程名称
					}  else if (cam.RecordTypeId == HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.ASSETLIQUIDATIONSALE, 'Approval_Managed__c')) {
						cam.Approval_Name__c = '资产清理出售流程'; //流程名称
					} else if (cam.RecordTypeId == HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.ASSETSALE, 'Approval_Managed__c')) {
						cam.Approval_Name__c = '资产出售流程'; //流程名称
					} else if (cam.RecordTypeId == HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.ORGANIZATIONALCHANGE, 'Approval_Managed__c')) {
						cam.Approval_Name__c = '组织架构变更调整流程'; //流程名称
					}else if (cam.RecordTypeId == HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.STAFFLEAVEOFFICE, 'Approval_Managed__c')) {
						cam.Approval_Name__c = '员工主动离职流程'; //流程名称
					}else if (cam.RecordTypeId == HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.MEASURINGINSTREQUEST, 'Approval_Managed__c')){
						cam.Approval_Name__c = '计量器具请购申请流程'; //流程名称
					}else if (cam.RecordTypeId == HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.SIGNETUSE, 'Approval_Managed__c')){
						cam.Approval_Name__c = '用印流程';  //流程名称
					}else if (cam.RecordTypeId == HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.MANPOWERREPLENISHMENT, 'Approval_Managed__c')){
						cam.Approval_Name__c = 'HR人力补充申请流程';  //流程名称
					}else if (cam.RecordTypeId == HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.OVERTIMEMANAGER, 'Approval_Managed__c')){
						cam.Approval_Name__c = '加班管理流程';  //流程名称
					}else if (cam.RecordTypeId == HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.PMTICKET, 'Approval_Managed__c')){
						cam.Approval_Name__c = 'PM通知单';  //流程名称
					}else if (cam.RecordTypeId == HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.INVENTORYKINGLAI, 'Approval_Managed__c')){
						cam.Approval_Name__c = '盘盈盘亏申请流程';  //流程名称
					}else if (cam.RecordTypeId == HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.SALESPRICE, 'Approval_Managed__c')) {
						cam.Approval_Name__c = '销售定价业务流程'; //流程名称
					} else if (cam.RecordTypeId == HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.MRDIEREQUEST, 'Approval_Managed__c')) {
						cam.Approval_Name__c = 'MR模具申请流程'; //流程名称
					}else if (cam.RecordTypeId == HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.CUSTOMERCREDITLOAN, 'Approval_Managed__c')) {
						cam.Approval_Name__c = '客户信用贷款主数据申请'; //流程名称
					}else if (cam.RecordTypeId == HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.ASSETSTRANSFER, 'Approval_Managed__c')) {
						cam.Approval_Name__c = '资产转移报废停用申请流程'; //流程名称
					}    

				} else if (HarryUtils.compareObjtype(obj, 'Approval_Managed1__c')) {
					Approval_Managed1__c cam = (Approval_Managed1__c)obj;
					//不同流程对应的处理
					 if (String.isBlank(cam.Status__c)) {
					 	cam.Status__c = '新建'; //单据状态
					 }
					 if (cam.Bill_Date__c == null) {
					 	cam.Bill_Date__c = Date.today(); //单据日期
					 }
					 if (String.isBlank(cam.Applicant__c)) {
					 	System.debug('*** cam.Applicant__c: ' + cam.Applicant__c + '');
					 	cam.Applicant__c = Utils.getContactIdByUserID(UserInfo.getUserId());//申请人
					 }
					 if (String.isBlank(cam.Dept_Name__c) && !String.isBlank(cam.Applicant__c)) {
					 	if (mapCon.containsKey(cam.Applicant__c)) {
					 		System.debug(LoggingLevel.INFO, '*** : 员工所属部门' + mapCon.get(cam.Applicant__c).Dept_Number__c);
					 		cam.Dept_Name__c = mapCon.get(cam.Applicant__c).Dept_Number__r.Description__c; //所属部门
					 	}
					 }
					 //申请人工号
					 if (String.isBlank(cam.Applicant_Code__c) && !String.isBlank(cam.Applicant__c)) {
					 	if (mapCon.containsKey(cam.Applicant__c)) {
					 		cam.Applicant_Code__c = mapCon.get(cam.Applicant__c).Number__c;
					 //		cam.reception_emp_no__c = mapCon.get(cam.Applicant__c).Number__c;
					 	}
					 }
					//申请人公司姓名
					if (String.isBlank(cam.Applicant_Name__c) && !String.isBlank(cam.Applicant__c)) {
						if (mapCon.containsKey(cam.Applicant__c)) {
							cam.Applicant_Name__c = mapCon.get(cam.Applicant__c).Name;
						}
					}
					 //申请人公司代码
					 if (String.isBlank(cam.Applicant_Corp_Code__c) && !String.isBlank(cam.Applicant__c)) {
					 	if (mapCon.containsKey(cam.Applicant__c)) {
					 		cam.Applicant_Corp_Code__c = mapCon.get(cam.Applicant__c).Corp_Code__c;
					 	}
					 }

					 if (cam.RecordTypeId == HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.VISITORHOSTS, 'Approval_Managed1__c')) {
					  cam.Approval_Name__c = '来宾接待流程';//流程名称
					  } else if (cam.RecordTypeId == HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.IRS_InformationService, 'Approval_Managed1__c')) {
						cam.Approval_Name__c = 'IT服务申请流程'; //流程名称
					 }else if (cam.RecordTypeId == HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.INTERNALMEMO, 'Approval_Managed1__c')) {
					 	cam.Approval_Name__c = '內部联络申请流程'; //流程名称
					 }else if (cam.RecordTypeId == HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.CREDITAUDITING, 'Approval_Managed1__c')) {
				    	cam.Approval_Name__c = '客户单笔信货核发申请流程'; //流程名称
					 }else if (cam.RecordTypeId == HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.CREDITLOAN, 'Approval_Managed1__c')) {
					 	cam.Approval_Name__c = '客戶信用贷款主数据申请流程'; //流程名称
					 }else if (cam.RecordTypeId == HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.POSTSALESERVICE, 'Approval_Managed1__c')) {
						cam.Approval_Name__c = '售后服务申请流程'; //流程名称
					 }else if (cam.RecordTypeId == HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.CREWSCHEDULING, 'Approval_Managed1__c')) {
					 	cam.Approval_Name__c = '排班管理流程'; //流程名称
					 } else if (cam.RecordTypeId == HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.CHANGEJOBS, 'Approval_Managed1__c')) {
					 	cam.Approval_Name__c = '岗位变更流程'; //流程名称
					 } 
					// else if (cam.RecordTypeId == HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.EXPORTAPPLICATION, 'Approval_Managed1__c')) {
					// 	cam.Approval_Name__c = '出口申请流程'; //流程名称
					// } else if (cam.RecordTypeId == HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.RETURNHOME, 'Approval_Managed1__c')) {
					// 	cam.Approval_Name__c = '台干返乡探视申请流程'; //流程名称
					// } else if (cam.RecordTypeId == HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.TECHNICALSUPPORT, 'Approval_Managed1__c')) {
					// 	cam.Approval_Name__c = '技术支持流程'; //流程名称
					// } else if (cam.RecordTypeId == HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.PIPELINESAMPLE, 'Approval_Managed1__c')) {
					// 	cam.Approval_Name__c = '管道样品申请流程'; //流程名称
					
					// } else if (cam.RecordTypeId == HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.QUOTEAPPLICATION, 'Approval_Managed1__c')) {
					// 	cam.Approval_Name__c = '报价申请流程'; //流程名称
					     else if (cam.RecordTypeId == HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.BOOKDINNER, 'Approval_Managed1__c')) {
					 	cam.Approval_Name__c = '订餐&派车申请流程'; //流程名称
					 }
					     else if (cam.RecordTypeId == HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.QCC, 'Approval_Managed1__c')) {
					 	cam.Approval_Name__c = 'QCC客诉申请流程'; //流程名称
					 }
					// } else if (cam.RecordTypeId == HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.VENDORCLAIM, 'Approval_Managed1__c')) {
					// 	cam.Approval_Name__c = '供应商索赔流程'; //流程名称
					// } else if (cam.RecordTypeId == HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.SHIFTCHANGE, 'Approval_Managed1__c')) {
					// 	cam.Approval_Name__c = '班次变更申请流程'; //流程名称
					// } else if (cam.RecordTypeId == HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.CREWSCHEDULING, 'Approval_Managed1__c')) {
					// 	cam.Approval_Name__c = '排班管理流程'; //流程名称
					// } else if (cam.RecordTypeId == HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.TRAINING, 'Approval_Managed1__c')) {
					// 	cam.Approval_Name__c = '教育训练申请流程'; //流程名称
					// } else if (cam.RecordTypeId == HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.VISITORHOSTS, 'Approval_Managed1__c')) {
					//  cam.Approval_Name__c = '来宾接待流程'; //流程名称
					// } else if (cam.RecordTypeId == HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.IRS_INFORMATIONSERVICE, 'Approval_Managed1__c')) {
					// 	cam.Approval_Name__c = 'IT服务申请流程'; //流程名称
					// } else if (cam.RecordTypeId == HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.INTERNALLYPILOTING, 'Approval_Managed1__c')) {
					// 	cam.Approval_Name__c = '内控不符合项流程'; //流程名称
					
				} else if (HarryUtils.compareObjtype(obj, 'Approval_Managed2__c')) {
					Approval_Managed2__c cam = (Approval_Managed2__c)obj;
					//不同流程对应的处理
					 if (String.isBlank(cam.Status__c)) {
					 	cam.Status__c = '新建'; //单据状态
					 }
					 if (cam.Bill_Date__c == null) {
					 	cam.Bill_Date__c = Date.today(); //单据日期
					 }
					 if (String.isBlank(cam.Applicant__c)) {
					 	System.debug('*** cam.Applicant__c: ' + cam.Applicant__c + '');
					 	cam.Applicant__c = Utils.getContactIdByUserID(UserInfo.getUserId());//申请人
					 }
					 if (String.isBlank(cam.Dept_Name__c) && !String.isBlank(cam.Applicant__c)) {
					 	if (mapCon.containsKey(cam.Applicant__c)) {
					 		System.debug(LoggingLevel.INFO, '*** : 员工所属部门' + mapCon.get(cam.Applicant__c).Dept_Number__c);
					 		cam.Dept_Name__c = mapCon.get(cam.Applicant__c).Dept_Number__r.Description__c; //所属部门
					 	}
					 }
					 //申请人工号
					 if (String.isBlank(cam.Applicant_Code__c) && !String.isBlank(cam.Applicant__c)) {
					 	if (mapCon.containsKey(cam.Applicant__c)) {
					 		cam.Applicant_Code__c = mapCon.get(cam.Applicant__c).Number__c;
					 	}
					 }
					 //申请人公司代码
					 if (String.isBlank(cam.Applicant_Corp_Code__c) && !String.isBlank(cam.Applicant__c)) {
					 	if (mapCon.containsKey(cam.Applicant__c)) {
					 		cam.Applicant_Corp_Code__c = mapCon.get(cam.Applicant__c).Corp_Code__c;
					 	}
					 }
					 if (cam.RecordTypeId == HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.INVENTORYPROCESS, 'Approval_Managed2__c')) {
					 	cam.Approval_Name__c = '盘盈盘亏流程'; //流程名称
					 } else if (cam.RecordTypeId == HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.CANCELTECO, 'Approval_Managed2__c')) {
					 	cam.Approval_Name__c = 'SAP生产工单取消TECO申请流程'; //流程名称
					 }// else if (cam.RecordTypeId == HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.SCRAPAPPLICATION, 'Approval_Managed2__c')) {
					// 	cam.Approval_Name__c = '报废申请流程'; //流程名称
					// } else if (cam.RecordTypeId == HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.PM_NOTICE, 'Approval_Managed2__c')) {
					// 	cam.Approval_Name__c = 'PM通知流程'; //流程名称
					// } else if (cam.RecordTypeId == HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.INVENTORYAPPLICATION, 'Approval_Managed2__c')) {
					// 	cam.Approval_Name__c = '盘盈亏申请流程'; //流程名称
					// } else if (cam.RecordTypeId == HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.MR_SAMPLE, 'Approval_Managed2__c')) {
					// 	cam.Approval_Name__c = 'MR模具申请流程'; //流程名称
					// } else if (cam.RecordTypeId == HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.STOCKALLOCATION, 'Approval_Managed2__c')) {
					// 	cam.Approval_Name__c = '库存调拨申请流程'; //流程名称
					// } else if (cam.RecordTypeId == HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.PRIMECOST, 'Approval_Managed2__c')) {
					// 	cam.Approval_Name__c = '成本要素主数据维护流程'; //流程名称
					// } else if (cam.RecordTypeId == HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.BUDGETCHANGE, 'Approval_Managed2__c')) {
					// 	cam.Approval_Name__c = '部门预算金额变更申请流程'; //流程名称
					// } else if (cam.RecordTypeId == HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.QTW_CUSTOMERCOMPLAINT, 'Approval_Managed2__c')) {
					// 	cam.Approval_Name__c = 'QTW客诉流程'; //流程名称
					// } else if (cam.RecordTypeId == HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.INACTIVEMATERIALTRANSFER, 'Approval_Managed2__c')) {
					// 	cam.Approval_Name__c = '呆滞物料转用工作流程'; //流程名称
					// } else if (cam.RecordTypeId == HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.SAP_PROJECTCODE, 'Approval_Managed2__c')) {
					// 	cam.Approval_Name__c = 'SAP专案代号申请流程'; //流程名称
					// } else if (cam.RecordTypeId == HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.SEV1_VENDORPERIODICASSESSMENT, 'Approval_Managed2__c')) {
					// 	cam.Approval_Name__c = 'SEV1供应商定期评核流程'; //流程名称
					// } 
					else if (cam.RecordTypeId == HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.SEV2_VENDOREVALUATION, 'Approval_Managed2__c')) {
					 	cam.Approval_Name__c = 'SEV2供应商评鉴流程'; //流程名称
					 } else if (cam.RecordTypeId == HarryUtils.getRecordTypeIdByDevNameAndObjName(SapApprovalEnum.EXP_APPLICATIONFEE, 'Approval_Managed2__c')) {
						cam.Approval_Name__c = 'EXP费用申请流程'; //流程名称
					 }
				}
			}
		}
	}
}