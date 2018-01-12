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
    
    public Map<Id, User> KlAllUserMapGetById {get;private set;}
    public Map<String, User> KlAllUserMapGetByNum {get;private set;}

    private Peoples(){
        System.debug('create Peoples instance...');
        KlAllContactMapGetById = new Map<Id, Contact>();
        KlAllContactMapGetByNum = new Map<String, Contact>();
        KlAllUserMapGetById =  new Map<Id, User>();
        KlAllUserMapGetByNum = new Map<String, User>();
        for(Contact c : [SELECT Id, Email, Number__c, Name, Is_Manager__c,SF_User__c ,SF_User__r.Is_First_Manager__c ,SF_User__r.Is_Manager__c,Dept_Number__c,Dept_Number__r.Parent_Number__c,Dept_Number__r.Name,Corp_Code__c,Take_Office_Date__c,Job_Title_Level__c,Title,Post_Number__r.Post_Description__c    
                            FROM Contact 
                            WHERE SF_User__r.IsActive = true AND RecordType.DeveloperName = 'Staff'
                            ])
        {
            KlAllContactMapGetById.put(c.Id, c);
            KlAllContactMapGetByNum.put(c.Number__c, c);
        }
        for(User u : [SELECT Id, AboutMe, AccountId, Address, Alias, BadgeText, BannerPhotoUrl, CallCenterId, City, CommunityNickname, CompanyName, ContactId, Country, CreatedById, CreatedDate, DefaultGroupNotificationFrequency, DelegatedApproverId, Department, Dept_Number__c, DigestFrequency, Division, Email, EmailEncodingKey, EmailPreferencesAutoBcc, EmailPreferencesAutoBccStayInTouch, EmailPreferencesStayInTouchReminder, EmployeeNumber, Extension, Fax, FederationIdentifier, FirstName, ForecastEnabled, FullPhotoUrl, GeocodeAccuracy, Is_First_Manager__c, Is_Manager__c, Is_System_Account__c, IsActive, IsExtIndicatorVisible, IsProfilePhotoActive, Job_Title_Number__c, LanguageLocaleKey, LastLoginDate, LastModifiedById, LastModifiedDate, LastName, LastPasswordChangeDate, LastReferencedDate, LastViewedDate, Latitude, LocaleSidKey, Longitude, ManagerId, MediumBannerPhotoUrl, MediumPhotoUrl, MobilePhone, Name, Number__c, OfflinePdaTrialExpirationDate, OfflineTrialExpirationDate, OutOfOfficeMessage, Phone, PostalCode, ProfileId, ReceivesAdminInfoEmails, ReceivesInfoEmails, SenderEmail, SenderName, Signature, SmallBannerPhotoUrl, SmallPhotoUrl, State, StayInTouchNote, StayInTouchSignature, StayInTouchSubject, Street, SystemModstamp, TimeZoneSidKey, Title, Username, UserPermissionsAvantgoUser, UserPermissionsCallCenterAutoLogin, UserPermissionsInteractionUser, UserPermissionsMarketingUser, UserPermissionsMobileUser, UserPermissionsOfflineUser, UserPermissionsSFContentUser, UserPermissionsSupportUser, UserPreferencesActivityRemindersPopup, UserPreferencesApexPagesDeveloperMode, UserPreferencesCacheDiagnostics, UserPreferencesContentEmailAsAndWhen, UserPreferencesContentNoEmail, UserPreferencesCreateLEXAppsWTShown, UserPreferencesDisableAllFeedsEmail, UserPreferencesDisableBookmarkEmail, UserPreferencesDisableChangeCommentEmail, UserPreferencesDisableEndorsementEmail, UserPreferencesDisableFileShareNotificationsForApi, UserPreferencesDisableFollowersEmail, UserPreferencesDisableLaterCommentEmail, UserPreferencesDisableLikeEmail, UserPreferencesDisableMentionsPostEmail, UserPreferencesDisableMessageEmail, UserPreferencesDisableProfilePostEmail, UserPreferencesDisableSharePostEmail, UserPreferencesDisCommentAfterLikeEmail, UserPreferencesDisMentionsCommentEmail, UserPreferencesDisProfPostCommentEmail, UserPreferencesEnableAutoSubForFeeds, UserPreferencesEventRemindersCheckboxDefault, UserPreferencesExcludeMailAppAttachments, UserPreferencesFavoritesShowTopFavorites, UserPreferencesFavoritesWTShown, UserPreferencesGlobalNavBarWTShown, UserPreferencesGlobalNavGridMenuWTShown, UserPreferencesHideBiggerPhotoCallout, UserPreferencesHideChatterOnboardingSplash, UserPreferencesHideCSNDesktopTask, UserPreferencesHideCSNGetChatterMobileTask, UserPreferencesHideEndUserOnboardingAssistantModal, UserPreferencesHideLightningMigrationModal, UserPreferencesHideS1BrowserUI, UserPreferencesHideSecondChatterOnboardingSplash, UserPreferencesHideSfxWelcomeMat, UserPreferencesLightningExperiencePreferred, UserPreferencesPathAssistantCollapsed, UserPreferencesPreviewLightning, UserPreferencesRecordHomeReservedWTShown, UserPreferencesRecordHomeSectionCollapseWTShown, UserPreferencesReminderSoundOff, UserPreferencesShowCityToExternalUsers, UserPreferencesShowCityToGuestUsers, UserPreferencesShowCountryToExternalUsers, UserPreferencesShowCountryToGuestUsers, UserPreferencesShowEmailToExternalUsers, UserPreferencesShowEmailToGuestUsers, UserPreferencesShowFaxToExternalUsers, UserPreferencesShowFaxToGuestUsers, UserPreferencesShowManagerToExternalUsers, UserPreferencesShowManagerToGuestUsers, UserPreferencesShowMobilePhoneToExternalUsers, UserPreferencesShowMobilePhoneToGuestUsers, UserPreferencesShowPostalCodeToExternalUsers, UserPreferencesShowPostalCodeToGuestUsers, UserPreferencesShowProfilePicToGuestUsers, UserPreferencesShowStateToExternalUsers, UserPreferencesShowStateToGuestUsers, UserPreferencesShowStreetAddressToExternalUsers, UserPreferencesShowStreetAddressToGuestUsers, UserPreferencesShowTitleToExternalUsers, UserPreferencesShowTitleToGuestUsers, UserPreferencesShowWorkPhoneToExternalUsers, UserPreferencesShowWorkPhoneToGuestUsers, UserPreferencesSortFeedByComment, UserPreferencesTaskRemindersCheckboxDefault, UserRoleId, UserType 
                        FROM User
                        WHERE IsActive = true
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