/**********************************************************************
 名    称：从SAP同步组织架构数据到SF,从SF同步简档和角色到SAP
 目    的：从SAP中同步(部门、岗位、员工)信息到SF,并且更新SF用户信息,
 		   从SF同步简档和角色到SAP
 作    者：刘文俊(liuwenjun@bluelinksys.com)
 创建日期：2017-05-12
 修 改 人：zhonghui
 修改日期：5-20
 修改原因：处理同步来的数据
 备    注：

 执行脚本：
 SyncOrgFromSapSchedule sc = new SyncOrgFromSapSchedule();
 String fmt = '10 5 4 1-31 1-12 ? 2017-2049';//指定时间执行一次(2017-05-20 04:05:10)执行
 System.schedule('SF同步组织架构；'+ Datetime.now().format('yyyyMMddHHmmss'), fmt, sc);
 
 脚本执行步骤：
  1、同步简档到SAP
  2、同步角色到SAP
  3、同步部门
  4、同步岗位
  5、同步员工
  6、更新SF用户信息
 **********************************************************************/
global class SyncOrgFromSapSchedule implements Schedulable {
    global void execute(SchedulableContext sc) {
        //1、同步简档到SAP
        syncProfileToSap();
        //2、同步角色到SAP
        syncRoleToSap();
        //3、同步部门
        syncDeptFromSap();
        //4、同步岗位
        syncJobFromSap();
        //5、同步员工
        syncStaffFromSap();
        //6、新建一个运行同步用户数据计划任务，因为需要等员工数据同步完成后才能同步用户
        SyncUserSchedule scSyncUser = new SyncUserSchedule();
        Datetime dt = Datetime.now().addMinutes(10);
        List<String> args = new List<String>();
        args.add(String.valueOf(dt.second()));
        args.add(String.valueOf(dt.minute()));
        args.add(String.valueOf(dt.hour()));
        args.add(String.valueOf(dt.day()));
        args.add(String.valueOf(dt.month()));
        args.add(String.valueOf(dt.year()));
        String fmt = String.format('{0} {1} {2} {3} {4} ? {5}',args);//指定时间执行一次
        System.debug('*** 执行时间：' + fmt);
        Id sid = System.schedule('同步用户数据_'+ dt.format('yyMMddHHmmss.SSS'), fmt, scSyncUser);
    }
    @Future(callout=true) 
    public static void syncProfileToSap(){
        Utils.postToSAP(SapInputArgCreate.createSapProfileInputArgs());
    }
    @Future(callout=true) 
    public static void syncRoleToSap(){
        Utils.postToSAP(SapInputArgCreate.createSapRoleInputArgs());
    }
    @Future(callout=true) 
    public static void syncDeptFromSap(){
    	try{
            String str1 = Utils.postToSAP(SapQueryArgCreate.createSapOrganizationalQueryArgs());
            SynchronousOrganization.actionDMLOrganiztaion(str1);
        }catch(Exception ex){
            System.debug('' + ex.getMessage() + '\n' + ex.getStackTraceString());
        }
    }
    @Future(callout=true) 
    public static void syncJobFromSap(){
    	try{
            String str2 = Utils.postToSAP(SapQueryArgCreate.createSapRoleQueryArgs());
            SynchronousOrganization.actionDMLJob(str2);
        }catch(Exception ex){
            System.debug('' + ex.getMessage() + '\n' + ex.getStackTraceString());
        }
    }
    @Future(callout=true) 
    public static void syncStaffFromSap(){
        try{
            //5、同步员工
            String str3 = Utils.postToSAP(SapQueryArgCreate.createSapStaffQueryArgs());
            SynchronousOrganization.actionDMLStaff(str3);
        }catch(Exception ex){
            System.debug('' + ex.getMessage() + '\n' + ex.getStackTraceString());
        }
    }
}