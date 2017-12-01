public with sharing class ApprovalInterfaceLogController {
	//查询参数(流程名称)
	//查询参数(推送方向)
	public Metadata__c meta{GET;SET;}
	//查询结果
	public List<Metadata__c> lstLog{GET;SET;}
	//查询参数(开始日期)
	public String startDate{GET;SET;}
	//查询参数(结束日期)
	public String endDate{GET;SET;}
	//查询参数(推送成功?)
	public String successed{GET;SET;}

	//当前流程记录总数
    public Integer totalCount{GET;SET;}
    //每页显示记录条数
    public Integer pageSize{GET;SET;}
    //当前页
    public Integer pageCurr{GET;SET;}
    //总页数
    public Integer pageCount{GET;SET;}

    public ApprovalInterfaceLogController() {
    	totalCount = 0;
        pageCurr = 1;
        pageCount = 1;
        pageSize  = 20;

    	meta = new Metadata__c();
    	lstLog = new List<Metadata__c>();
    	Datetime dt = Datetime.newInstance(Date.today().addDays(1),Time.newInstance(0,0,0,0));
    	endDate = dt.format('yyyy-MM-dd HH:mm:ss');
    	startDate = dt.addDays(-7).format('yyyy-MM-dd HH:mm:ss');
    }
    public PageReference QueryInterface(){
    	String condition = '';
    	if(!String.isBlank(startDate)){
    		try{
    			Datetime dt = Datetime.valueOf(startDate);
    			startDate = dt.format('yyyy-MM-dd HH:mm:ss', 'British/London');
    			startDate = startDate.replace(' ','T');
    			startDate = startDate + 'Z';
    			condition += ' AND Send_DateTime__c >= '+ startDate;
    		}catch(Exception ex){
    			addPageMessage('开始日期错误，请重新输入！');
    			return null;
    		}
    	}
    	if(!String.isBlank(endDate)){
    		try{
    			Datetime dt = Datetime.valueOf(endDate);
    			endDate = dt.format('yyyy-MM-dd HH:mm:ss', 'British/London');
    			endDate = endDate.replace(' ','T');
    			endDate = endDate + 'Z';
    			condition += ' AND Send_DateTime__c <= '+ endDate;
    		}catch(Exception ex){
    			addPageMessage('结束日期错误，请重新输入！');
    			return null;
    		}
    	}
    	if(!String.isBlank(meta.Approval_Name__c)){
    		condition += ' AND Approval_Name__c = \'' + meta.Approval_Name__c + '\'';
    	}
        if(!String.isBlank(meta.ApprovalID__c)){
            condition += ' AND ApprovalID__c = \'' + meta.ApprovalID__c + '\'';
        }
    	if(!String.isBlank(meta.Send_Direction__c)){
    		condition += ' AND Send_Direction__c = \'' + meta.Send_Direction__c + '\'';
    	}
    	if(!String.isBlank(successed)){
    		condition += ' AND Is_Send_Succeed__c = ' + successed + ' ';
    	}
    	String sql = 'SELECT COUNT(Id) iCount FROM Metadata__c WHERE RecordType.DeveloperName = \'SF_To_SAP_Queue\'' + condition;
    	AggregateResult ar = Database.query(sql);
    	totalCount = Integer.valueOf(ar.get('iCount'));
        pageCount = (Integer)Math.ceil((Decimal)totalCount/(Decimal)pageSize);
        Integer offset = (pageCurr - 1 ) * pageSize;

    	sql = 'SELECT Approval_Name__c,Is_Send_Succeed__c,Send_Error_Message__c,ApprovalID__c,Send_Count__c,Send_Direction__c,Send_DateTime__c ';
    	sql = sql + ' FROM Metadata__c ';
    	sql = sql + ' WHERE RecordType.DeveloperName = \'SF_To_SAP_Queue\' ';
    	sql = sql + condition;
    	sql = sql + ' ORDER BY CreatedDate DESC LIMIT ' + pageSize + ' ';
    	sql = sql + ' OFFSET ' + offset;

    	System.debug(sql);
    	lstLog = Database.query(sql);
    	return null;
    }
    public PageReference NextPage(){
        if(pageCurr < pageCount){
            pageCurr = pageCurr + 1;
        }
        return QueryInterface();
    }
    public PageReference PrevPage(){
        if(pageCurr > 1){
            pageCurr = pageCurr - 1;
        }
        return QueryInterface();
    }
    public PageReference GotoPage(){
        if(pageCurr > pageCount){
            pageCurr = pageCount;
        }else if(pageCurr < 1){
            pageCurr = 1;
        }
        return QueryInterface();
    }
    public PageReference reSyncUserData(){
        try {
            System.debug(LoggingLevel.INFO, '*** 开始更新用户数据: ');
            //6、更新SF用户信息
            SynchronousOrganization.actionDMLUser();
        }
        catch (Exception e) {
            ApexPages.addMessages(e);
            return null;
        }
        return null;
        
    }
    //从SAP手动同步部门
    @RemoteAction
    public static Object syncDeptFromSap(){
        String status = '1';
        try{
            String str1 = Utils.postToSAP(SapQueryArgCreate.createSapOrganizationalQueryArgs());
            SynchronousOrganization.actionDMLOrganiztaion(str1);
        }catch(Exception ex){
            status = '0';
            System.debug('' + ex.getMessage() + '\n' + ex.getStackTraceString());
        }
        Map<String,String> result = new Map<String,String>();
        result.put('status',status);
        return result;
    }
    //从SAP手动同步岗位
    @RemoteAction
    public static Object syncJobFromSap(){
        String status = '1';
        try{
            String str2 = Utils.postToSAP(SapQueryArgCreate.createSapRoleQueryArgs());
            SynchronousOrganization.actionDMLJob(str2);
        }catch(Exception ex){
            status = '0';
            System.debug('' + ex.getMessage() + '\n' + ex.getStackTraceString());
        }
        Map<String,String> result = new Map<String,String>();
        result.put('status',status);
        return result;
    }
    //从SAP手动同步员工
    @RemoteAction
    public static Object syncStaffFromSap(){
        String status = '1';
        try{
            //5、同步员工
            String str3 = Utils.postToSAP(SapQueryArgCreate.createSapStaffQueryArgs());
            SynchronousOrganization.actionDMLStaff(str3);
        }catch(Exception ex){
            status = '0';
            System.debug('' + ex.getMessage() + '\n' + ex.getStackTraceString());
        }
        Map<String,String> result = new Map<String,String>();
        result.put('status',status);
        return result;
    }
    @RemoteAction
    public static Object reSyncData(String mID,String sapKeyno,String direction){
    	Boolean bl = true;
    	if(direction == 'SF_TO_SAP'){
    		bl = SyncFromSfToSapSchedule.syncToSAP(mID,true);
    	}else if(direction == 'SAP_TO_SF'){
    		bl = SyncFromSapToSfSchedule.syncFromSAP(sapKeyno);
    	}
    	Map<String,String> result = new Map<String,String>();
    	result.put('status', bl?'1':'0');
    	return result;
    }
    private void addPageMessage(String message){
        ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.INFO,message));
    }
}