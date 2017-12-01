//CheckChatterPostsOnOpportunity 發文觸發

trigger CheckChatterPostsOnOpportunity on FeedItem (after insert) {

    for (FeedItem f: trigger.new)
    {
      
        if (f.Body == '<p>123</p>')   
        {           
            //Add business logic here
            //FeedItem post = new FeedItem();
            //post.ParentId = parentId; //eg. Opportunity id, custom object id..
            //post.Body = 'Enter post text here'; //增加新發言
            //insert post;
            
            FeedComment post1 = new FeedComment();
            post1.FeedItemId = f.Id;
            post1.CommentBody = 'post success'; //增加新留言
            insert post1;
            
         System.debug(f.Id);
        }
    }
}