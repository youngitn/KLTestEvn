public without sharing class ApprovalManualShareHandler implements Triggers.Handler {
    public void handle() {
        if(Trigger.isAfter){
            Set<String> userIds = new Set<String>();
            List<String> camUserFields = new List<String>();
            camUserFields.add('Approval_User1__c');
            camUserFields.add('Approval_User2__c');
            camUserFields.add('Approval_User3__c');
            camUserFields.add('Approval_User4__c');
            camUserFields.add('Approval_User5__c');
            camUserFields.add('Approval_User6__c');
            camUserFields.add('Approval_User7__c');
            camUserFields.add('Approval_User8__c');
            camUserFields.add('Approval_User9__c');
            camUserFields.add('Approval_User10__c');
            camUserFields.add('Approval_User11__c');
            camUserFields.add('Approval_User12__c');
            camUserFields.add('Approval_User13__c');
            camUserFields.add('Approval_User14__c');
            camUserFields.add('Approval_User15__c');
            camUserFields.add('Approval_User16__c');
            camUserFields.add('Approval_User17__c');
            camUserFields.add('Approval_User18__c');
            camUserFields.add('Approval_User19__c');
            camUserFields.add('Approval_User20__c');
            camUserFields.add('Approval_User21__c');
            camUserFields.add('Approval_User22__c');
            camUserFields.add('Approval_User23__c');
            List<String> amUserFields = new List<String>();
            amUserFields.add('Approval_User1__c');
            amUserFields.add('Approval_User2__c');
            amUserFields.add('Approval_User3__c');
            amUserFields.add('Approval_User4__c');
            amUserFields.add('Approval_User5__c');
            amUserFields.add('Approval_User6__c');
            amUserFields.add('Approval_User7__c');
            amUserFields.add('Approval_User8__c');
            amUserFields.add('Approval_User9__c');
            amUserFields.add('Approval_User10__c');
            amUserFields.add('Approval_User11__c');
            amUserFields.add('Approval_User12__c');
            amUserFields.add('Approval_User13__c');
            amUserFields.add('Approval_User14__c');
            amUserFields.add('Approval_User15__c');
            amUserFields.add('Approval_User16__c');
            amUserFields.add('Approval_User17__c');
            amUserFields.add('Approval_User18__c');
            amUserFields.add('Approval_User19__c');
            amUserFields.add('Approval_User20__c');
            amUserFields.add('Approval_User21__c');
            amUserFields.add('Approval_User22__c');
            amUserFields.add('Approval_User23__c');
            List<String> am1UserFields = new List<String>();
            am1UserFields.add('Approval_User1__c');
            am1UserFields.add('Approval_User2__c');
            am1UserFields.add('Approval_User3__c');
            am1UserFields.add('Approval_User4__c');
            am1UserFields.add('Approval_User5__c');
            am1UserFields.add('Approval_User6__c');
            am1UserFields.add('Approval_User7__c');
            am1UserFields.add('Approval_User8__c');
            am1UserFields.add('Approval_User9__c');
            am1UserFields.add('Approval_User10__c');
            am1UserFields.add('Approval_User11__c');
            am1UserFields.add('Approval_User12__c');
            am1UserFields.add('Approval_User13__c');
            am1UserFields.add('Approval_User14__c');
            am1UserFields.add('Approval_User15__c');
            am1UserFields.add('Approval_User16__c');
            am1UserFields.add('Approval_User17__c');
            am1UserFields.add('Approval_User18__c');
            am1UserFields.add('Approval_User19__c');
            am1UserFields.add('Approval_User20__c');
            List<String> am2UserFields = new List<String>();

            for(SObject obj : Trigger.new){
                String sobjectName = String.valueOf(obj.getSObjectType());
                String ownerId = String.valueOf(obj.get('OwnerId'));
                System.debug(LoggingLevel.INFO, '*** sobjectName: ' + sobjectName);
                userIds.clear();
                if(sobjectName == 'Custom_Approval_Managed__c'){
                    for(String field : camUserFields){
                        String uId = String.valueOf(obj.get(field));
                        System.debug(LoggingLevel.INFO, '*** uId: ' + uId);
                        if(!String.isBlank(uId) && ownerId != uId && !userIds.contains(uId)){
                            userIds.add(uId);
                        }
                    }
                }else if(sobjectName == 'Approval_Managed__c'){
                    for(String field : amUserFields){
                        String uId = String.valueOf(obj.get(field));
                        if(!String.isBlank(uId) && ownerId != uId && !userIds.contains(uId)){
                            userIds.add(uId);
                        }
                    }
                }else if(sobjectName == 'Approval_Managed1__c'){
                    for(String field : am1UserFields){
                        String uId = String.valueOf(obj.get(field));
                        if(!String.isBlank(uId) && ownerId != uId && !userIds.contains(uId)){
                            userIds.add(uId);
                        }
                    }
                }else if(sobjectName == 'Approval_Managed2__c'){
                    for(String field : am2UserFields){
                        String uId = String.valueOf(obj.get(field));
                        if(!String.isBlank(uId) && ownerId != uId && !userIds.contains(uId)){
                            userIds.add(uId);
                        }
                    }
                }
                //共享给相应的批准代理人
                for (User u : [SELECT DelegatedApproverId FROM User WHERE Id IN :userIds AND DelegatedApproverId != null]) {
                    if (u.DelegatedApproverId != ownerId && !userIds.contains(u.DelegatedApproverId)) {
                        userIds.add(u.DelegatedApproverId);
                    }
                }
                //共享记录给审批用户
                if(userIds.size() > 0){
                    Utils.ManualShareRecordToUsers(userIds, sobjectName, String.valueOf(obj.get('Id')));
                }
            }
        }
    }
}