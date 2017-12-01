global class ApprovalsPendingController{
    public static boolean runningInTestMode = false;
    public List<PendingApproval> lstPending{get;set;}
    global class PendingApproval{
        public Id recordId {get;set;}
        public String recordName {get;set;}
        public String approvalInstanceId {get;set;}
        public String approvalStepId {get;set;}
        public String sObjectLabel {get;set;}
        public String sObjectName {get;set;}
        public String submiterName {get;set;}
        public String submiterPhotoUrl {get;set;}
        public String submitDate {get;set;}
        public boolean firstOfSObjectType {get;set;}
        public Id workItemId{get;set;}
        public String approvalRecordName{get;set;}
        public String applicantName{get;set;}
        public String approvalinfo {GET; SET;}
        public String approver {GET; SET;}

        public PendingApproval(ProcessInstanceWorkitem p){
            recordId = p.ProcessInstance.TargetObjectId;
            recordName = p.ProcessInstance.TargetObject.Name;
            approvalInstanceId = p.ProcessInstanceId;
            sObjectName = p.ProcessInstance.TargetObject.Type;
            submiterName = p.ProcessInstance.CreatedBy.Name;      
            submiterPhotoUrl = p.ProcessInstance.CreatedBy.SmallPhotoUrl;   
            workItemId = p.Id;
            approver = p.Actor.Name;

        }
    }
    
    public ApprovalsPendingController(){
        lstPending = getPendingApprovals();
        System.debug(LoggingLevel.INFO, '*** lstPending: ' + lstPending);
    }
    
    public static List<PendingApproval> getPendingApprovals(){
        List<PendingApproval> pendingApprovals = new List<PendingApproval>();
        Set<Id> processInstanceIds = new Set<Id>();
        Map<String, String> sObjectName2Label = new Map<String, String>();

        
        Set<Id> memberOfQueueIds = new Set<Id>();
        String prevSObjectType;
        //相关批准代理人也可以看到的记录
        for (User u:[select Id from User where DelegatedApproverId = :UserInfo.getUserId()]) {
            memberOfQueueIds.add(u.Id);
        }
        memberOfQueueIds.add(UserInfo.getUserId());
        for (GroupMember m : [  select GroupId from GroupMember where 
                                UserOrGroupId= :UserInfo.getUserId() 
                                and Group.Type = 'Queue']){
            memberOfQueueIds.add(m.GroupId);                    
        }
        
        List<ProcessInstanceWorkitem> approvals;
        if (runningInTestMode){
            ProcessInstance testInstance = new ProcessInstance();
            testInstance.targetObjectId = new Contact(LastName = 'Test').id;
            ProcessInstanceWorkitem testP = new ProcessInstanceWorkitem(ActorId = UserInfo.getUserId(), 
                                                                        ProcessInstance = testInstance);
            approvals = new List<ProcessInstanceWorkitem>();
            approvals.add(testP);
        }else{
            approvals = [select Id, ProcessInstanceId, ProcessInstance.TargetObjectId, 
                                         ProcessInstance.TargetObject.Name,Actor.Name,
                                         ProcessInstance.TargetObject.Type, ProcessInstance.CreatedBy.Name,
                                         ProcessInstance.CreatedDate, ProcessInstance.CreatedBy.SmallPhotoUrl
                                         from ProcessInstanceWorkitem 
                                         where isDeleted=false and ActorId IN :memberOfQueueIds and 
                                         ProcessInstance.status='Pending' order by 
                                         ProcessInstance.TargetObject.Type, SystemModstamp desc];
        }
        Map<String,Set<Id>>  mapRecordId= new Map<String,Set<Id>>();
        mapRecordId.put('Approval_Managed__c', new Set<Id>());
        mapRecordId.put('Custom_Approval_Managed__c', new Set<Id>());
        mapRecordId.put('Approval_Managed1__c', new Set<Id>());
        mapRecordId.put('Approval_Managed2__c', new Set<Id>());
        Map<Id,SObject>  mapAssoRecord= new Map<Id,SObject>();                	              
        for(ProcessInstanceWorkitem p : approvals){
            PendingApproval pa = new PendingApproval(p);
            
            if (p.ProcessInstance.CreatedDate != null){
                pa.submitDate = p.ProcessInstance.CreatedDate.format('yyyy/MM/dd HH:mm:ss a');
            }
            
            if (p.ProcessInstance.TargetObject.Type != prevSObjectType){
                pa.firstOfSObjectType = true;
            }else{
                pa.firstOfSObjectType = false;
            }

                        
            prevSObjectType = p.ProcessInstance.TargetObject.Type;
            pa.sObjectLabel = sObjectName2Label.get(p.ProcessInstance.TargetObject.Type);

            if (pa.sObjectLabel == null){
                String sObjectType = p.ProcessInstance.TargetObject.Type;
                if (sObjectType != null){
                    if (sObjectType.endsWith('__kav')){
                        sObjectType = sObjectType.left(sObjectType.length()-1);
                    }
    
                    pa.sObjectLabel = Schema.describeSObjects(new String[]{sObjectType})[0].getLabelPlural();
                    sObjectName2Label.put(p.ProcessInstance.TargetObject.Type, pa.sObjectLabel);
                }
            }
            if (pa.sObjectName == '') {
                
            }
            if (mapRecordId.containsKey(pa.sObjectName)) {
                mapRecordId.get(pa.sObjectName).add(pa.recordId);
            }

            pendingApprovals.add(pa);
            processInstanceIds.add(p.ProcessInstanceId);
        }
        Map<Id,SObject>  mapSobject= new Map<Id,SObject>([SELECT Id, Approval_Name__c, Applicant_Name__c,SAPID__c FROM Approval_Managed__c 
        													WHERE Id IN :mapRecordId.get('Approval_Managed__c')]);
        mapSobject.putAll(new Map<Id,SObject>([SELECT Id, Approval_Name__c, Applicant_Name__c,SAPID__c FROM Custom_Approval_Managed__c 
        													WHERE Id IN :mapRecordId.get('Custom_Approval_Managed__c')]));
        mapSobject.putAll(new Map<Id,SObject>([SELECT Id, Approval_Name__c, Applicant_Name__c,SAPID__c FROM approval_Managed1__c 
        													WHERE Id IN :mapRecordId.get('Approval_Managed1__c')]));
        Map<Id, Id> processInstance2Step = new Map<Id, Id>();
        for(ProcessInstanceStep step : [select id, ProcessInstanceId, Actor.Name, 
                                        StepStatus from ProcessInstanceStep 
                                        where ProcessInstanceId in :processInstanceIds]){
            processInstance2Step.put(step.ProcessInstanceId, step.Id);
        }
        
        List<PendingApproval> finalPendingApprovals = new List<PendingApproval>();
        for (PendingApproval p : pendingApprovals){
            p.approvalStepId = processInstance2Step.get(p.approvalInstanceId);
            if (mapSobject.containsKey(p.recordId)) {
                p.approvalRecordName = String.valueOf(mapSobject.get(p.recordId).get('Approval_Name__c')) ;
                p.applicantName = String.valueOf(mapSobject.get(p.recordId).get('Applicant_Name__c'));
                //p.approvalinfo = String.valueOf(mapSobject.get(p.recordId).get('SAPID__c')) +  Stirng .xxx
                p.approvalinfo = String.valueOf(mapSobject.get(p.recordId).get('SAPID__c'));
            }
            if (p.approvalStepId != null) {
                finalPendingApprovals.add(p);
            }
          }

        return finalPendingApprovals;
    }
}