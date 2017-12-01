//留言觸發 查詢投票結果

trigger CheckChatter on FeedComment (after insert)
{

    public String theVoteId;
    public Boolean istrigger = false;
    public String result = ''; //紀錄結果
    public String emailto = ''; //發起人email地址
    public KL_Systems__c kl {GET; SET;}
    public String KL_SystemsName {GET; SET;}
    public String emailtoId {GET; SET;}
    for (FeedComment f : trigger.new)
    {
        String parentId = f.parentId;

        //正式環境投票結果關鍵字參考紀錄
        KL_SystemsName = 'SY-171129-00000018';

        //測試環境投票結果關鍵字參考紀錄
        if([SELECT Id, IsSandbox FROM Organization].get(0).IsSandbox)
        {
            KL_SystemsName = 'SY-171129-00000008';
        }
        List<KL_Systems__c> klList = [select KeyWord__c, Is_To_Chatter__c, Is_To_Mail__c from KL_Systems__c where Name = :KL_SystemsName];

        if (klList.size() < 1)
        {
            kl = new KL_Systems__c();
            kl.KeyWord__c = 'test';
            kl.Is_To_Chatter__c = true;
            kl.Is_To_Mail__c = true;
        }
        else
        {
            kl = klList.get(0);
        }

        if (f.CommentBody == kl.KeyWord__c)//查詢關鍵字
        {

            istrigger = true;
            emailtoId = f.InsertedById;
            theVoteId = f.FeedItemId;


            /*
             *   抓出投票結果:選項值&人員
             */
            Integer countAll = 0; //計算總投票數

            /* for所有選項 */
            for (FeedPollChoice pc : [select Id, ChoiceBody, FeedItemId, Position
                                      from FeedPollChoice where FeedItemId = :theVoteId
                                              order by Position])
            {
                Integer i = 0, count = 0;
                //計算選項票數

                /* for所有結果 */
                for (FeedPollVote vr : [select Id, ChoiceId, FeedItemId, CreatedById
                                        from FeedPollVote where FeedItemId = :theVoteId])
                {

                    // List<String> names = new List<String>();

                    /* if選項='A' */
                    if (i == 0)
                    {
                        /* result += 選項A */
                        result += pc.ChoiceBody + ': ';

                        i++;
                    }
                    if (vr.ChoiceId == pc.Id)
                    {
                        /* result += 選A的人員 */
                        // names.add(n);
                        // result +=  names;
                        result += [select LastName from User where Id = :vr.CreatedById].LastName + ', ';
                        count++;
                        countAll++;

                        //每10筆換行
                        if (count == 10)
                        {
                            result += '\n\r';
                        }

                    }
                }
                //換選項換行
                result += '\n\r' + '票數: ' + count + '\n\r';

            }
            result += '\n\r' + '總投票數: ' + countAll;

            //是否留言到chatter
            if (kl.Is_To_Chatter__c == true)
            {
                //留言結果
                FeedComment post = new FeedComment();
                post.FeedItemId = f.FeedItemId;
                post.CommentBody =  '投票結果: ';
                post.CommentBody += '\n\r';
                post.CommentBody += '\n\r';
                post.CommentBody += result;
                insert post;
            }

            //是否寄email
            if (kl.Is_To_Mail__c == true)
            {
                if (istrigger == true) //控制只觸發email一次
                {
                    List<User> uList = [select Email from User where Id = :emailtoId];

                    if (uList.size() > 0)
                    {
                        emailto = uList.get(0).Email;
                        //email
                        list<Messaging.singleEmailMessage> messages = new list<Messaging.SingleEmailMessage>();
                        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                        /*
                         *  toAddresses地址需再加上變數 emailto，寄給發起人
                         */
                        message.toAddresses = new String[] { emailto };
                        message.optOutPolicy = 'FILTER';
                        message.subject = '投票結果';

                        //印出結果
                        message.plainTextBody = '';
                        message.plainTextBody += result;

                        messages.add(message);
                        Messaging.sendEmail(messages);
                    }

                }
            }
        }
    }



}