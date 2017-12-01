@isTest
public  class CheckChatterTest
{

    @isTest public  static void CheckChatterTest()
    {
        Test.startTest();
        // Implement test code
        //create and insert post
        Profile p = [SELECT Id FROM Profile WHERE Name = '员工'];
        User u = new User(Alias = 'standt', Email = 'standarduser@testorg.com',
                          EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
                          LocaleSidKey = 'en_US', ProfileId = p.Id,
                          TimeZoneSidKey = 'America/Los_Angeles', UserName = 'tttest@testorg.com');
        insert u;
 




        // The following code runs as user 'u'
        
        FeedItem post = new FeedItem();
        post.Body = 'HelloThere';
        post.ParentId = UserInfo.getUserId();
        post.Title = 'FileName';
        insert post;
        
        FeedComment comment = new FeedComment();
        comment.FeedItemId = post.Id;
        comment.CommentBody = 'test';
        insert comment;
        FeedComment ff = [SELECT Id,FeedItemId,CommentBody FROM FeedComment WHERE FeedItemId=: post.Id].get(0);
        Test.stopTest();
        
        System.assertEquals(ff.CommentBody,comment.CommentBody);

    }


}