/**
 * 單例模式 
 * 查詢 [user,contact]
 * by Id
 * by Num
 */
public class Peoples {
    
    private static final Peoples instance = new Peoples();
    public Map<Id, Contact> KlAllContactMapGetById {get;private set;}
    public Map<String, Contact> KlAllContactMapGetByNum {get;private set;}
    public Map<Id, Contact> KlAllContactMapGetByUserId {get;private set;}
    
    public Map<Id, User> KlAllUserMapGetById {get;private set;}
    public Map<String, User> KlAllUserMapGetByNum {get;private set;}
    public Map<Id, User> KlAllUserMapGetByContactId {get;private set;}
    private Peoples(){
        System.debug('create Peoples instance...');
        KlAllContactMapGetById = new Map<Id, Contact>();
        KlAllContactMapGetByNum = new Map<String, Contact>();
        KlAllUserMapGetById =  new Map<Id, User>();
        KlAllUserMapGetByNum = new Map<String, User>();
        List<Contact> lc = new  List<Contact>();
        if (Test.isRunningTest()){
            lc = [SELECT Id, Phone,SF_User__r.Id,SF_User__r.isActive, Email, Number__c, Name, Is_Manager__c,SF_User__c ,SF_User__r.Is_First_Manager__c ,SF_User__r.Is_Manager__c,Dept_Number__c,Dept_Number__r.Parent_Number__c,Dept_Number__r.Name,Corp_Code__c,Take_Office_Date__c,Job_Title_Level__c,Title,Post_Number__r.Post_Description__c    
                            FROM Contact];
        }else{
            lc = [SELECT Id, Phone,SF_User__r.Id,SF_User__r.isActive, Email, Number__c, Name, Is_Manager__c,SF_User__c ,SF_User__r.Is_First_Manager__c ,SF_User__r.Is_Manager__c,Dept_Number__c,SAP_Dept_Number__c,Dept_Number__r.Parent_Number__c,Dept_Number__r.Name,Corp_Code__c,Take_Office_Date__c,Job_Title_Level__c,Title,Post_Number__r.Post_Description__c    
                            FROM Contact WHERE RecordTypeId = '01228000000XcVmAAK' or RecordTypeId =  '012O0000000DLubIAG'
                            ];
        }
        
        for(Contact c : lc)
        {
            KlAllContactMapGetById.put(c.Id, c);
            KlAllContactMapGetByNum.put(c.Number__c, c);
            
            
        }
        for(User u : [SELECT Id, AboutMe, AccountId, Alias, CompanyName, ContactId, Country, DelegatedApproverId, Department, Dept_Number__c, DigestFrequency, Division, Email, EmployeeNumber, Extension, Fax, FederationIdentifier, FirstName, ForecastEnabled, FullPhotoUrl, Is_First_Manager__c, Is_Manager__c, Is_System_Account__c, IsActive, IsExtIndicatorVisible, IsProfilePhotoActive, Job_Title_Number__c, LastModifiedDate, LastName, Latitude, ManagerId, MobilePhone, Name, Number__c, Phone, ProfileId, ReceivesAdminInfoEmails, ReceivesInfoEmails, SenderEmail, SenderName, Signature, Title, Username, UserRoleId, UserType 
                        FROM User  where isActive = true
                        ])
        {
            KlAllUserMapGetById.put(u.Id, u);
            KlAllUserMapGetByNum.put(u.Number__c, u);
        }
    }
    public static Peoples getInstance(){
        // eager load of the class
        return instance;
    }


}