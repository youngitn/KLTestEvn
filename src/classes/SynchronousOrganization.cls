/**************************************************************************************************
 * Name: SynchronousOrganization
 * Object: 
 * Purpose: 定时同步SAP组织架构数据到SF，包括组织，岗位，员工
 * Requirement:
 * Author: zhonghui
 * Create Date: 2017-4-24
 * Modify History: 
 * 
***************************************************************************************************/
public with sharing class SynchronousOrganization {
	//同步组织架构数据function
	public static void actionDMLOrganiztaion(String JSONorg){
		Id   rtOId = HarryUtils.getRecordTypeIdByDevNameAndObjName('Organizational', 'Organizational__c'); 
		Id   rtSId = HarryUtils.getRecordTypeIdByDevNameAndObjName('Staff','Contact');
		SynchronousOrganization.OrganizationData objectData = new SynchronousOrganization.OrganizationData();
		//Sap同步过来的组织架构数据
		objectData = (SynchronousOrganization.OrganizationData)JSON.deserialize(JSONorg, SynchronousOrganization.OrganizationData.class);
		List<Organizational__c> lstSAPData= objectData.Organizationals;
		System.debug('*** 传入部门记录数：' + lstSAPData.size());
		String strStatus = objectData.status;
		String strMessage = objectData.message;

		if (!String.isBlank(strStatus) && strStatus.trim() == '1') {
			//SF现有的组织架构数据
			List<Organizational__c> lstSFData = [SELECT Id,Dept_Number__c,Parent_Number__c,Name,Description__c,Corp_Number__c,Dept_Post_Number__c FROM Organizational__c WHERE RecordTypeId = :rtOId];
			//删除的数据
			List<Organizational__c>  lstDeleteData = new List<Organizational__c>();

			//系统中存在的部门
			Map<String,Organizational__c> mapOlds = new Map<String,Organizational__c>();	
			for (Organizational__c org: lstSFData) {
				mapOlds.put(org.Dept_Number__c, org);
			}

			//组织结构第一层数据
			Map<String,Organizational__c> root1 = new Map<String,Organizational__c>();
			Map<String,Contact> mapNewContact = new Map<String,Contact>();
			for (Organizational__c org: lstSAPData) {
				if (String.isBlank(org.Parent_Number__c)) {
					if(mapOlds.containsKey(org.Dept_Number__c)){
						org.Id = mapOlds.get(org.Dept_Number__c).Id;
					}
					org.RecordTypeId = rtOId;
					org.Dept_Level__c = 1;
					if(String.isBlank(org.Name)){
						org.Name = org.Description__c;
					}
					root1.put(org.Dept_Number__c, org);
				}
			}
			Upsert root1.values();
			System.debug('*** 第一级部门记录数：' + root1.size());

			//更新组织结构第二层数据
			Map<String,Organizational__c> root2 = new Map<String,Organizational__c>();
			if(root1.size() > 0){
				for (Organizational__c org: lstSAPData) {
					if (!String.isBlank(org.Parent_Number__c) && root1.containsKey(org.Parent_Number__c)) {
						if(mapOlds.containsKey(org.Dept_Number__c)){
							org.Id = mapOlds.get(org.Dept_Number__c).Id;
						}
						//设置父级
						org.Parent_Number__c = root1.get(org.Parent_Number__c).Id;
						org.RecordTypeId = rtOId;
						//指定部门层级，子公司为1，一阶主管部门为2，部门主管为3
						org.Dept_Level__c = 2;
						if(String.isBlank(org.Name)){
							org.Name = org.Description__c;
						}
						root2.put(org.Dept_Number__c, org);
					}
				}
				Upsert root2.values();
				System.debug('*** 第二级部门记录数：' + root2.size());
			}

			//更新组织结构第三层数据
			Map<String,Organizational__c> root3 = new Map<String,Organizational__c>();
			if(root2.size() > 0){
				for (Organizational__c org: lstSAPData) {
					if (!String.isBlank(org.Parent_Number__c) && root2.containsKey(org.Parent_Number__c)) {
						if(mapOlds.containsKey(org.Dept_Number__c)){
							org.Id = mapOlds.get(org.Dept_Number__c).Id;
						}
						//设置父级
						org.Parent_Number__c = root2.get(org.Parent_Number__c).Id;
						org.RecordTypeId = rtOId;
						//指定部门层级，子公司为1，一阶主管部门为2，部门主管为3
						org.Dept_Level__c = 3;
						if(String.isBlank(org.Name)){
							org.Name = org.Description__c;
						}
						root3.put(org.Dept_Number__c, org);
					}
				}
				Upsert root3.values();
				System.debug('*** 第三级部门记录数：' + root3.size());
			}
			//更新组织结构第四层数据
			Map<String,Organizational__c> root4 = new Map<String,Organizational__c>();
			if(root3.size() > 0){
				for (Organizational__c org: lstSAPData) {
					if (!String.isBlank(org.Parent_Number__c) && root3.containsKey(org.Parent_Number__c)) {
						if(mapOlds.containsKey(org.Dept_Number__c)){
							org.Id = mapOlds.get(org.Dept_Number__c).Id;
						}
						//设置父级
						org.Parent_Number__c = root3.get(org.Parent_Number__c).Id;
						org.RecordTypeId = rtOId;
						//指定部门层级，子公司为1，一阶主管部门为2，部门主管为3
						org.Dept_Level__c = 4;
						if(String.isBlank(org.Name)){
							org.Name = org.Description__c;
						}
						root4.put(org.Dept_Number__c, org);
					}
				}
				Upsert root4.values();
				System.debug('*** 第四级部门记录数：' + root4.size());
			}

			//更新组织结构第五层数据
			Map<String,Organizational__c> root5 = new Map<String,Organizational__c>();
			if(root4.size() > 0){
				for (Organizational__c org: lstSAPData) {
					if (!String.isBlank(org.Parent_Number__c) && root4.containsKey(org.Parent_Number__c)) {
						if(mapOlds.containsKey(org.Dept_Number__c)){
							org.Id = mapOlds.get(org.Dept_Number__c).Id;
						}
						//设置父级
						org.Parent_Number__c = root4.get(org.Parent_Number__c).Id;
						org.RecordTypeId = rtOId;
						org.Dept_Level__c = 5;
						if(String.isBlank(org.Name)){
							org.Name = org.Description__c;
						}
						root5.put(org.Dept_Number__c, org);
					}
				}
				Upsert root5.values();
				System.debug('*** 第五级部门记录数：' + root5.size());
			}

			//更新组织结构第六层数据
			Map<String,Organizational__c> root6 = new Map<String,Organizational__c>();
			if(root5.size() > 0){
				for (Organizational__c org : lstSAPData) {
					if (!String.isBlank(org.Parent_Number__c) && root5.containsKey(org.Parent_Number__c)) {
						if(mapOlds.containsKey(org.Dept_Number__c)){
							org.Id = mapOlds.get(org.Dept_Number__c).Id;
						}
						//设置父级
						org.Parent_Number__c = root5.get(org.Parent_Number__c).Id;
						org.RecordTypeId = rtOId;
						org.Dept_Level__c = 6;
						if(String.isBlank(org.Name)){
							org.Name = org.Description__c;
						}
						root6.put(org.Dept_Number__c, org);
					}
				}
				Upsert root6.values();
				System.debug('*** 第六级部门记录数：' + root6.size());
			}
			//更新组织结构第七层数据
			Map<String,Organizational__c> root7 = new Map<String,Organizational__c>();
			if(root6.size() > 0){
				for (Organizational__c org : lstSAPData) {
					if (!String.isBlank(org.Parent_Number__c) && root6.containsKey(org.Parent_Number__c)) {
						if(mapOlds.containsKey(org.Dept_Number__c)){
							org.Id = mapOlds.get(org.Dept_Number__c).Id;
						}
						//设置父级
						org.Parent_Number__c = root6.get(org.Parent_Number__c).Id;
						org.RecordTypeId = rtOId;
						org.Dept_Level__c = 7;
						if(String.isBlank(org.Name)){
							org.Name = org.Description__c;
						}
						root7.put(org.Dept_Number__c, org);
					}
				}
				Upsert root7.values();
				System.debug('*** 第七级部门记录数：' + root7.size());
			}

			//查询要删除的数据
			Map<String,Organizational__c> mapNews = new Map<String,Organizational__c>();
			for (Organizational__c org : lstSAPData) {
				mapNews.put(org.Dept_Number__c, org);
			}
			for (Organizational__c org : lstSFData) {
				if(!mapNews.containsKey(org.Dept_Number__c)){
					lstDeleteData.add(org);
				}
			}
			//删除不存在的组织架构数据
			if(lstDeleteData.size() > 0){
				Delete lstDeleteData;
			}
			Integer allCount = root1.size() + root2.size() + root3.size() + root4.size() + root5.size() + root6.size() + root7.size();
			System.debug('*** 生成组织架构数据记录数(部门): ' +  allCount);
		}else{
			System.debug('*** 从SAP查询组织架构数据接口出错: ' + strMessage + '!');
		}
	}

	//同步岗位数据function
	public static void actionDMLJob(String JSONjob){
		Id   rtJId = HarryUtils.getRecordTypeIdByDevNameAndObjName('Job_Title','Organizational__c');
		Id   rtSId = HarryUtils.getRecordTypeIdByDevNameAndObjName('Staff','Contact');
		Id   rtOId = HarryUtils.getRecordTypeIdByDevNameAndObjName('Organizational', 'Organizational__c'); 
		SynchronousOrganization.Job_Title objectData = new SynchronousOrganization.Job_Title();
		//Sap同步过来的组织架构数据
		objectData = (SynchronousOrganization.Job_Title)JSON.deserialize(JSONjob, SynchronousOrganization.Job_Title.class);
		List<Organizational__c> lstSAPData= objectData.Roles;
		System.debug('*** 传入岗位记录数：' + lstSAPData.size());
		String strStatus = objectData.status;
		String strMessage = objectData.message;
		if (!String.isBlank(strStatus) && strStatus.trim() == '1') {
			//SF现有岗位数据
			List<Organizational__c> lstSFData = [SELECT Id,Post_Number__c,Post_Description__c,Name,Corp_Number__c,Post_Dept_Number__c,Post_Manager_Number__c FROM Organizational__c WHERE RecordTypeId = :rtJId];
			//SF现有部门数据
			List<Organizational__c> lstSFOrgnazation = [SELECT Id,Dept_Number__c,Parent_Number__c,Name,Description__c,Corp_Number__c,Dept_Post_Number__c FROM Organizational__c WHERE RecordTypeId = :rtOId];
			//删除的数据
			List<Organizational__c>  lstDeleteData = new List<Organizational__c>();

			Map<String,Organizational__c> mapOlds = new Map<String,Organizational__c>();
			Map<String,Organizational__c> mapOrganization = new Map<String,Organizational__c>();
			for (Organizational__c org: lstSFData) {
				mapOlds.put(org.Post_Number__c, org);
			}
			for (Organizational__c org: lstSFOrgnazation) {
				mapOrganization.put(org.Dept_Number__c, org);
			}
			//岗位负责人处理
			Set<String> setJobManager = new Set<String>();
			for (Organizational__c org: lstSAPData) {
				if (!String.isBlank(org.Post_Manager_Number__c)) {
					if(!setJobManager.contains(org.Post_Manager_Number__c)){
						setJobManager.add(org.Post_Manager_Number__c);
					}
				}
			}
			//已存在的岗位负责人
			List<Contact> lstContact =[SELECT Id,Number__c FROM Contact WHERE Number__c IN :setJobManager];
			Map<String,Contact>  mapContact = new Map<String,Contact>();
			for (Contact con : lstContact) {
				mapContact.put(con.Number__c, con);
			}
			
			//计算系统中不存在岗位负责人
			Map<String,Contact> mapNoExitDM = new Map<String,Contact>();
			for (Organizational__c org : lstSAPData) {
				if (!String.isBlank(org.Post_Manager_Number__c)) {
					if(!mapContact.containsKey(org.Post_Manager_Number__c)){
						if(!mapNoExitDM.containsKey(org.Post_Manager_Number__c)){
							Contact addCon = new Contact(Lastname = '同步岗位时自动创建', Number__c = org.Post_Manager_Number__c,RecordTypeId = rtSId);
							mapNoExitDM.put(org.Post_Manager_Number__c, addCon);
							mapContact.put(org.Post_Manager_Number__c, addCon);
						}
					}
				}
			}
			if(mapNoExitDM.size() > 0){
				Insert mapNoExitDM.values();
			}

			Map<String,Organizational__c>  mapNew = new Map<String,Organizational__c>();
			Map<String,Organizational__c> mapSAPdata = new Map<String,Organizational__c>();
			//更新岗位数据
			for (Organizational__c org : lstSAPData) {
				if(String.isBlank(org.Name)){
					org.Name = org.Post_Description__c;
				}
				mapSAPdata.put(org.Post_Number__c, org);
				if(mapOlds.containsKey(org.Post_Number__c)){
					org.Id = mapOlds.get(org.Post_Number__c).Id;
				}
				//设定岗位负责人
				org.Post_Manager__c = mapContact.containsKey(org.Post_Manager_Number__c) ? mapContact.get(org.Post_Manager_Number__c).Id : null;
				//设定岗位所属部门
				org.Post_Dept_Number__c = mapOrganization.containsKey(org.Post_Dept_Number__c) ? mapOrganization.get(org.Post_Dept_Number__c).Id : null;
				org.RecordTypeId = rtJId;
				if(!mapNew.containsKey(org.Post_Number__c)){
					mapNew.put(org.Post_Number__c, org);
				}
			}
			System.debug('*** 生成组织架构数据记录数(岗位)：' + mapNew.size());
			Upsert mapNew.values();

			//查询要删除的数据
			for (Organizational__c org : lstSFData) {
				if(!mapSAPdata.containsKey(org.Post_Number__c)){
					lstDeleteData.add(org);
				}
			}
			//删除不存在的岗位数据数据
			if(lstDeleteData.size() > 0){
				Delete lstDeleteData;
			}
		}else{
			System.debug('*** 从SAP查询岗位接口数据出错: ' + strMessage + '！');
		}
	}

	//同步员工数据function
	public static void actionDMLStaff(String JSONStaff){
		try{
			Id   rtOId = HarryUtils.getRecordTypeIdByDevNameAndObjName('Organizational', 'Organizational__c'); 
			Id   rtJId = HarryUtils.getRecordTypeIdByDevNameAndObjName('Job_Title', 'Organizational__c'); 
			Id   rtSId = HarryUtils.getRecordTypeIdByDevNameAndObjName('Staff','Contact');
			SynchronousOrganization.StaffsData objectData = new SynchronousOrganization.StaffsData();
			//Sap同步过来的组织架构数据
			objectData = (SynchronousOrganization.StaffsData)JSON.deserialize(JSONStaff, SynchronousOrganization.StaffsData.class);
			List<Contact> lstSAPData= objectData.Staffs;
			System.debug('*** 传入的员工记录数：' + lstSAPData.size());
			String strStatus = objectData.status;
			String strMessage = objectData.message;
			if (!String.isBlank(strStatus) && strStatus.trim() == '1') {
				//SF现有部门数据
				List<Organizational__c> lstSFOrgnazation = [SELECT Id,Dept_Number__c,Parent_Number__c,Name,Description__c,Corp_Number__c,Post_Number__c FROM Organizational__c WHERE RecordTypeId = :rtOId];
				//SF现有岗位数据
				List<Organizational__c> lstSFjob = [SELECT Id,Post_Number__c,Post_Description__c,Name,Corp_Number__c,Post_Dept_Number__c FROM Organizational__c WHERE RecordTypeId = :rtJId];
				Map<String,Organizational__c> mapOrganization = new Map<String,Organizational__c>();
				Map<String,Organizational__c> mapJob = new Map<String,Organizational__c>();

				for (Organizational__c org: lstSFOrgnazation) {
					mapOrganization.put(org.Dept_Number__c, org);
				}
				for (Organizational__c org: lstSFjob) {
					mapJob.put(org.Post_Number__c, org);
				}	
				List<Contact> lstSFData = [
								SELECT Id,Number__c,Lastname,Is_Manager__c,Is_SF_Account__c,Dept_Number__c,ProfileID__c,
									  Human_Range__c,SAP_Post_Number__c,SAP_Dept_Number__c,RoleID__c,
									  Post_Number__c,Post_Category__c,Job_Title_Level__c,Staff_Group__c,
									  Staff_Sub_Group__c,Take_Office_Date__c,End_Date_Contract__c,Birthdate,
									  Email,Phone,MobilePhone,Native_Place__c,Sex__c,Corp_Code__c,Salary_Manager__c,Leave_Office_Date__c
								FROM Contact 
								WHERE RecordTypeId = :rtSId];
				//删除的数据
				List<Contact>  lstDeleteData = new List<Contact>();
				//现有SF员工数据
				Map<String,Contact> mapOlds = new Map<String,Contact>();
				for (Contact con: lstSFData) {
					mapOlds.put(con.Number__c, con);
				}
				Map<String,Contact>  mapNew = new Map<String,Contact>();
				Map<String,Contact> mapSAPdata = new Map<String,Contact>();
				//更新员工数据
				for (Contact con: lstSAPData) {
					mapSAPdata.put(con.Number__c, con);
					if(mapOlds.containsKey(con.Number__c)){
						con.Id = mapOlds.get(con.Number__c).Id;
					}
					//设定所属岗位
					if (!String.isBlank(con.SAP_Post_Number__c) && mapJob.containsKey(con.SAP_Post_Number__c)) {
						con.Post_Number__c = mapJob.get(con.SAP_Post_Number__c).Id;
					}else{
						con.Post_Number__c = null;
						System.debug('*** 不存在的岗位编号：' + con.SAP_Post_Number__c + ', 员工号：' + con.Number__c);
					}
					//设定所属部门
					if (!String.isBlank(con.SAP_Dept_Number__c) && mapOrganization.containsKey(con.SAP_Dept_Number__c)) {
						con.Dept_Number__c = mapOrganization.get(con.SAP_Dept_Number__c).Id;
					}else{
						con.Dept_Number__c = null;
						System.debug('*** 员工号：' + con.Number__c + ',没有设置部门编号：' + con.SAP_Dept_Number__c);
					}
					//是否台湾员工
					if (con.Corp_Code__c == '3000') {
						con.Is_Taipei_Employee__c = true;
					}
					if(String.isBlank(con.LastName)){
						con.LastName = con.Number__c;
					}
					con.RecordTypeId = rtSId;
					if(!mapNew.containsKey(con.Number__c)){
						mapNew.put(con.Number__c, con);
					}
				}
				System.debug('*** 生成组织架构数据记录数(员工)：' + mapNew.size());
				Upsert mapNew.values();

				//查询要删除的数据
				for (Contact con : lstSFData) {
					if(!mapSAPdata.containsKey(con.Number__c)){
						con.Is_SF_Account__c = false;
						con.Staff_Group__c = '4';
						con.Leave_Office_Date__c = date.today();
						lstDeleteData.add(con);
					}
				}
				//删除不存在的员工数据
				if(lstDeleteData.size() > 0){
					//System.debug('*** 删除的员工: ' + lstDeleteData + '');
					Update lstDeleteData;
				}
			}else{
				System.debug('*** 从SAP查询岗位接口数据出错: ' + strMessage + '！');
			}
		}catch(Exception ex){
			System.debug('*** 反序列化数据出错: ' + ex.getMessage() + '\n' + ex.getStackTraceString());
		}
	}

	//同步用户数据
	public static void actionDMLUser(){
		//现有员工数据
		List<Contact> lstSFData = [SELECT Id,Number__c,Lastname,Is_Manager__c,Is_SF_Account__c,SF_User__c,Dept_Number__c,
						  Human_Range__c,SAP_Post_Number__c,SAP_Dept_Number__c,Corp_Code__c,ProfileID__c,
						  Post_Number__c,Post_Category__c,Job_Title_Level__c,Staff_Group__c,Sex__c,Extension_Number__c,
						  Staff_Sub_Group__c,Take_Office_Date__c,End_Date_Contract__c,Birthdate,RoleID__c,
						  Email,Phone,MobilePhone,Native_Place__c,Dept_Number__r.Dept_Level__c,Salary_Manager__c,FederationIdentifier__c
					FROM Contact 
					WHERE RecordType.DeveloperName = 'Staff' 
					AND RecordType.SobjectType = 'Contact'
					AND Is_SF_Account__c = true];
		Map<String,Contact> mapOlds = new Map<String,Contact>();
		for (Contact con: lstSFData) {
			if(!String.isBlank(con.Number__c) && !mapOlds.containsKey(con.Number__c)){
				mapOlds.put(con.Number__c, con);
			}
		}
		//获取要创建新用户的简档
		List<Profile> lstProfile = [SELECT Id,Name,UserLicenseId FROM Profile WHERE Name = '员工'];
		Id sProfileId;
		if (lstProfile.size()>0) {
			sProfileId = lstProfile[0].Id;
		}
		//SF现有用户
		List<User> lstUsr = 
				[SELECT Id,Number__c,Dept_Number__c,Job_Title_Number__c,IsActive,Phone,MobilePhone,
						LastName,Email,Username,Is_System_Account__c,ProfileId,UserRoleId,Title,
						EmailEncodingKey, FederationIdentifier,TimeZoneSidKey,Extension,CompanyName,
						Alias,LocaleSidKey,LanguageLocaleKey,Is_First_Manager__c,Is_Manager__c 
				FROM User 
				WHERE Is_System_Account__c = false and Profile.UserLicense.Name <> 'chatter External' and Profile.UserLicense.Name <> 'chatter Free'];

		Map<String,User> mapUsr = new Map<String,User>();
		Set<String>  setUsrName= new Set<String>();
		for (User usr: lstUsr) {
			if (!String.isBlank(usr.Number__c)) {
				mapUsr.put(usr.Number__c, usr);
			}
			if (!String.isBlank(usr.Username)) {
				setUsrName.add(usr.Username);
			}
		}
		//不存在则新建用户
		Map<String,User> mapNewUsr = new Map<String,User>();
		List<User> lstUpdateUsr = new List<User>();
		//拥有SF账户的员工
		List<Contact> lstSFAccountContact = new List<Contact>();
		//拥有SF账户员工对应的用户
		Map<String,User> mapSFUsr = new Map<String,User>();
		//更新用户
		for (Contact con:lstSFData) {
			//判断该员工是否有SF账户
			if (con.Is_SF_Account__c && !String.isBlank(con.Number__c)) {
				//要创建的用户
				String email = String.isBlank(con.Email)?con.Number__c + '@kinglai.com.cn':con.Email;
				if (!mapUsr.containsKey(con.Number__c)) {
					User sUsr = new User();
					sUsr.Is_System_Account__c = false;
					sUsr.IsActive = true;
					sUsr.LastName = con.Lastname;
					sUsr.Number__c = con.Number__c;
					if (setUsrName.contains(email)) {
						sUsr.Username = 'Re'+Math.random()+'_'+email;
					}else{
						sUsr.Username = email;
						setUsrName.add(email);
					}
					sUsr.Email = email;
					sUsr.Dept_Number__c = con.SAP_Dept_Number__c;
					sUsr.Alias = con.LastName.length() > 8 ? con.LastName.substring(0,8):con.LastName;
					sUsr.LocaleSidKey = 'zh_CN';
					sUsr.LanguageLocaleKey='zh_CN';
					sUsr.TimeZoneSidKey='Asia/Taipei';
					sUsr.EmailEncodingKey= 'ISO-8859-1';
					sUsr.ProfileId = String.isBlank(con.ProfileId__c)?sProfileId:con.ProfileId__c;
					sUsr.UserRoleId = String.isBlank(con.RoleId__c)?null:con.RoleId__c;
					//一阶主管用户
					if ((con.Dept_Number__r.Dept_Level__c == 3 || con.Dept_Number__r.Dept_Level__c == 2 ) && con.Is_Manager__c) {
						sUsr.Is_First_Manager__c = true;
					}
					//部门主管(二阶主管)用户
					if (con.Dept_Number__r.Dept_Level__c == 4 && con.Is_Manager__c) {
						sUsr.Is_Manager__c = true;
					}

					//联盟ID
					if (!STRING.isBlank(con.FederationIdentifier__c)) {
						sUsr.FederationIdentifier = con.FederationIdentifier__c;
					}	
					else{
						sUsr.FederationIdentifier = sUsr.Username;
					}
					
					//手机
					sUsr.MobilePhone = con.MobilePhone;
					//电话
					sUsr.Phone = con.Phone;
					//分机号
					sUsr.Extension = con.Extension_Number__c;
					//公司代码
					sUsr.CompanyName = con.Corp_Code__c;
					//职位
					sUsr.Job_Title_Number__c = con.SAP_Post_Number__c;

					mapNewUsr.put(con.Number__c, sUsr);
					mapSFUsr.put(con.Number__c, sUsr);
				}
				//要更新的用户
				else{
					User uUser = mapUsr.get(con.Number__c);
					uUser.IsActive = true;
					uUser.Dept_Number__c =con.SAP_Dept_Number__c;
					uUser.Email = email;
					uUser.Username = email;
					//一阶主管用户
					if (con.Dept_Number__r.Dept_Level__c == 3 && con.Is_Manager__c) {
						uUser.Is_First_Manager__c = true;
					}
					//部门主管(二阶主管)用户
					if (con.Dept_Number__r.Dept_Level__c == 4 && con.Is_Manager__c) {
						uUser.Is_Manager__c = true;
					}
					//员工号
					uUser.Number__c = con.Number__c;
					//联盟ID
					if (!STRING.isBlank(con.FederationIdentifier__c)) {
						System.debug(LoggingLevel.INFO, '*** 111: ' );
						uUser.FederationIdentifier = con.FederationIdentifier__c;
					}	
					else{
						System.debug(LoggingLevel.INFO, '*** 222: ' );
						uUser.FederationIdentifier = uUser.Username;
					}
					
					//手机
					uUser.MobilePhone = con.MobilePhone;
					//电话
					uUser.Phone = con.Phone;
					//分机号
					uUser.Extension = con.Extension_Number__c;
					//公司代码
					uUser.CompanyName = con.Corp_Code__c;
					//职位
					uUser.Job_Title_Number__c = con.SAP_Post_Number__c;
					uUser.ProfileId = String.isBlank(con.ProfileId__c)?sProfileId:con.ProfileId__c;
					uUser.UserRoleId = String.isBlank(con.RoleId__c)?null:con.RoleId__c;
					lstUpdateUsr.add(uUser);
					mapSFUsr.put(con.Number__c, uUser);
				}
				lstSFAccountContact.add(con);
			}
		}
		//查询要删除的数据
		for (User u : lstUsr) {
			if(!mapOlds.containsKey(u.Number__c)){
				u.IsActive = FALSE;
				u.Username =u.Number__c+'_LZ@kinglai.com.cn';
				lstUpdateUsr.add(u);
			}
		}

		//更新用户
		if (lstUpdateUsr.size()>0) {
			try{
				Update lstUpdateUsr;
			}catch(Exception ex){
				System.debug('*** 更新用户数据出错: ' + ex.getMessage() + '\n' + ex.getStackTraceString());
				sendEmail(ex.getMessage() + '\n' + ex.getStackTraceString());
			}
		}
		//新增用户
		if(mapNewUsr.size() > 0){
			try{
				System.debug('*** mapNewUsr插入的用户数据: ' + JSON.serializePretty(mapNewUsr) + '');
				Insert mapNewUsr.values();
			}catch(Exception ex){
				System.debug('*** 插入用户数据出错: ' + ex.getMessage() + '\n' + ex.getStackTraceString());
				sendEmail(ex.getMessage() + '\n' + ex.getStackTraceString());
			}
		}

		//更新拥有SF用户的员工
		UpdateContactMethod(mapSFUsr.keySet());

	}
	private static void sendEmail(String errMsg)
	{
		System_Setting__c ssc = System_Setting__c.getValues('Setting');
        String emailAddr = ssc.Error_Message_Email__c;

		Messaging.SingleEmailMessage el = new Messaging.SingleEmailMessage();
        //发送地址
        List<String> address = new List<String>();
        address.add(emailAddr);
        el.setToAddresses(address);
        el.setSubject('从SAP同步员工后生成SF用户出错');
        el.setHtmlBody('管理员：<br/> 从SAP同步员工后生成SF用户出错,错误原因为：' + errMsg);
        //发送邮件
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {el});
	}
	@future
	public static void UpdateContactMethod(Set<String> mapcode){

		Map<String,String> mapKey = new Map<String,String>();
		List<User> updateSFUser = [SELECT Id,Number__c FROM User WHERE Number__c IN : mapcode];
		for(User u : updateSFUser){
			mapKey.put(u.Number__c, u.Id);
		}
		List<Contact> lstSFAccountContact = [SELECT Id, SF_User__c , Number__c
									FROM Contact 
									WHERE RecordType.DeveloperName = 'Staff' 
									AND RecordType.SobjectType = 'Contact'
									AND Is_SF_Account__c = true];
		for (Contact con : lstSFAccountContact ) {
			if (mapKey.containsKey(con.Number__c)) {
				con.SF_User__c = mapKey.get(con.Number__c);
			}
		}
		if (lstSFAccountContact.size()>0) {
			System.debug(LoggingLevel.INFO, '*** lstSFAccountContact: ' + lstSFAccountContact);
			Update lstSFAccountContact;
		}
	}
	//组织结构数据映射类
    public class OrganizationData{
    	public String status{get;set;}
    	public String message{get;set;}
    	public List<Organizational__c> Organizationals{get;set;}
    }
    //岗位数据映射类
    public class Job_Title{
    	public String status{get;set;}
    	public String message{get;set;}
    	public List<Organizational__c> Roles{get;set;} 
    }
    //员工数据映射类
    public class StaffsData{
    	public String status{get;set;}
    	public String message{get;set;}
    	public List<Contact> Staffs{get;set;}
    }
}