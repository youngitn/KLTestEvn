global class ApprovalReassignShareSchedule implements Schedulable {
	   public static Boolean isTestMode = false;
    global void execute(SchedulableContext sc) {
    	try
    	{
    		deletePrevTask();

	        Datetime dt10 = Datetime.now().addMinutes(-9);
			List<ProcessInstanceWorkitem> items = [
			        SELECT Id,ActorId,ProcessInstance.TargetObjectId,SystemModstamp,CreatedDate,ProcessInstance.TargetObject.Type
			        FROM ProcessInstanceWorkitem 
			        WHERE IsDeleted = false 
			        AND SystemModstamp>=:dt10];

            if (isTestMode) {
                ProcessInstance testInstance = new ProcessInstance();
		        testInstance.targetObjectId = new Contact(LastName = 'Test').id;
		        ProcessInstanceWorkitem testP = new ProcessInstanceWorkitem(ActorId = UserInfo.getUserId(), 
		                                                                    ProcessInstance = testInstance);
		        items = new List<ProcessInstanceWorkitem>();
		        items.add(testP);
            }
			for(ProcessInstanceWorkitem item : items){
			    String sobjectName = item.ProcessInstance.TargetObject.Type;
			    if(String.isNotBlank(sobjectName) && item.CreatedDate!= item.SystemModstamp){
			        Utils.ManualShareRecordToUsers(new Set<String>{item.ActorId},sobjectName,item.ProcessInstance.TargetObjectId);
			    }
			}


		}catch(Exception ex){
			System.debug('*** 审批人重新分配共享计划任务出错：'+ex.getMessage() + '; ' + ex.getStackTraceString());
		}finally{
			createNewSchedule();
		}
    }
    //生成新的同步任务
    private void createNewSchedule(){
    	ApprovalReassignShareSchedule sc = new ApprovalReassignShareSchedule();
    	Datetime dt = Datetime.now().addMinutes(5);
    	List<String> args = new List<String>();
    	args.add(String.valueOf(dt.second()));
    	args.add(String.valueOf(dt.minute()));
    	args.add(String.valueOf(dt.hour()));
    	args.add(String.valueOf(dt.day()));
    	args.add(String.valueOf(dt.month()));
    	args.add(String.valueOf(dt.year()));
		String fmt = String.format('{0} {1} {2} {3} {4} ? {5}',args);//指定时间执行一次
		System.debug('*** 执行时间：' + fmt);
		Id sid = System.schedule('审批人重新分配共享_'+ dt.format('yyMMddHHmmss.SSS'), fmt, sc);
    }
    //删除2天前不需要执行的定时任务
    private void deletePrevTask(){
    	Datetime dateNow = Date.today().addDays(-2);
        List<CronTrigger> jobs = [SELECT Id,NextFireTime,CronJobDetail.Id FROM CronTrigger WHERE NextFireTime=null AND StartTime < :dateNow Limit 75];
    	if(jobs.size() > 0){
    		for(CronTrigger ct : jobs){
			    System.abortJob(ct.Id);
			}
    	}
    }
}