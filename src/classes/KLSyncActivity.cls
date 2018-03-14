/**********************************************************************
 * 
 *
 * @url: /services/apexrest/KL/SyncActivity
 * @data:
 *  {
        
    }
*************************************************************************/
@RestResource(urlMapping='/KL/SyncActivity')
global with sharing class KLSyncActivity {
    
    global static String doPost() {

        test1();
        test2();
        test3();
        test4();
        test5();
        test6();
        test7();
        test8();
        test9();
        test10();
        test11();
        test12();
        test13();
        test14();
        test15();
        test16();
        test17();
        test18();
        test19();
        test20();
        test21();
        test22();
        test23();
        test24();
        test25();
        test26();
        test27();
        test28();
        test29();
 
        //Integer year = Integer.valueOf(strDate.substring(0,4));
        //Integer mon = Integer.valueOf(strDate.substring(5, 7));
        //KLSyncReiAmountReturn klreturn = new KLSyncReiAmountReturn();
        
        /*
         List<Approval_Managed__c> amlist = [
        		SELECT Amount_of_Total__c
        		FROM Approval_Managed__c 
        		WHERE RecordType.DeveloperName = 'ExpenseReimburse'
        		AND CALENDAR_YEAR(Bill_Date__c) = :year
        		AND CALENDAR_MONTH(Bill_Date__c) = :mon
        		AND Employee_Code__c = :strPernr
        		]; 
        */

        List<Approval_Managed__c> amlist = [
        		SELECT Id
        		FROM Approval_Managed__c 
        		WHERE RecordType.DeveloperName = 'ExpenseReimburse'
        		AND Approval_Status__c = 'A'
        		]; 

       String str='';
       //Integer lims=Integer.valueOf(lim);
       Integer num=0;
       for(Approval_Managed__c ami:amlist)
       {
            num=num+1;
            if(num>0 && num<=1000)
            {
            List<Approval_Managed_Item__c> list1= new List<Approval_Managed_Item__c>();
            List<Approval_Managed_Item__c> list2= new List<Approval_Managed_Item__c>();
            list1 = [SELECT TaskID__c
                 FROM Approval_Managed_Item__c WHERE Purchase_Info_Inquiry__c = :ami.Id AND RecordType.DeveloperName = 'Payment_Detail'];
            boolean flag=false;
            String taId='';
            for (Approval_Managed_Item__c am : list1)
            {
                if(am.TaskID__c !=null && am.TaskID__c != '')
                {
                    flag=true;
                    taId=am.TaskID__c;
                    break;
                }
            }
            if(flag)
            {
                list2 = [SELECT Amount__c
                 FROM Approval_Managed_Item__c Where Voucher_Info__c = :ami.Id AND RecordType.DeveloperName = 'Payment_Certificate'];
                Decimal amount=0;
                for (Approval_Managed_Item__c am : list2)
                {
                    amount = amount + am.Amount__c;
                }
                str = str + taId+ ',' +amount + ';';

            }
            }
       		
       }


        /*AggregateResult[] groupedResults  = [
            SELECT SUM(Amount_of_Total__c)mysum
            FROM Approval_Managed__c 
        		WHERE RecordType.DeveloperName like '%ExpenseReimburse%'
        		AND Approval_Status__c = 'A'
        		AND CALENDAR_YEAR(Bill_Date__c) = :year
        		AND CALENDAR_MONTH(Bill_Date__c) = :mon
        		AND Employee_Code__c = :strPernr
            ];*/

         //Object sumAmount = groupedResults[0].get('mysum');

        //klreturn.sMoney = str;
        return str;
    }


    @HttpPost
    global static String doPost(String st,String ed) { 
        //Integer year = Integer.valueOf(strDate.substring(0,4));
        //Integer mon = Integer.valueOf(strDate.substring(5, 7));
        //KLSyncReiAmountReturn klreturn = new KLSyncReiAmountReturn();
        
        /*
         List<Approval_Managed__c> amlist = [
                SELECT Amount_of_Total__c
                FROM Approval_Managed__c 
                WHERE RecordType.DeveloperName = 'ExpenseReimburse'
                AND CALENDAR_YEAR(Bill_Date__c) = :year
                AND CALENDAR_MONTH(Bill_Date__c) = :mon
                AND Employee_Code__c = :strPernr
                ]; 
        */

        List<Approval_Managed__c> amlist = [
                SELECT Id
                FROM Approval_Managed__c 
                WHERE RecordType.DeveloperName = 'ExpenseReimburse'
                AND Approval_Status__c = 'A'
                ]; 

        if(st == '520')
        {
            return ''+amlist.size();
        }

       String str='';
       Integer start=Integer.valueOf(st);
       Integer endNum=Integer.valueOf(ed);
       Integer num=0;
       for(Approval_Managed__c ami:amlist)
       {
            if(num>=start && num<endNum)
            {
            List<Approval_Managed_Item__c> list1= new List<Approval_Managed_Item__c>();
            List<Approval_Managed_Item__c> list2= new List<Approval_Managed_Item__c>();
            list1 = [SELECT TaskID__c
                 FROM Approval_Managed_Item__c WHERE Purchase_Info_Inquiry__c = :ami.Id AND RecordType.DeveloperName = 'Payment_Detail'];
            boolean flag=false;
            String taId='';
            for (Approval_Managed_Item__c am : list1)
            {
                if(am.TaskID__c !=null && am.TaskID__c != '')
                {
                    flag=true;
                    taId=am.TaskID__c;
                    break;
                }
            }
            if(flag)
            {
                list2 = [SELECT Amount__c
                 FROM Approval_Managed_Item__c Where Voucher_Info__c = :ami.Id AND RecordType.DeveloperName = 'Payment_Certificate'];
                Decimal amount=0;
                for (Approval_Managed_Item__c am : list2)
                {
                    amount = amount + am.Amount__c;
                }
                str = str + taId+ ',' +amount + ';';

            }
            }
            num=num+1;
            
       }


        /*AggregateResult[] groupedResults  = [
            SELECT SUM(Amount_of_Total__c)mysum
            FROM Approval_Managed__c 
                WHERE RecordType.DeveloperName like '%ExpenseReimburse%'
                AND Approval_Status__c = 'A'
                AND CALENDAR_YEAR(Bill_Date__c) = :year
                AND CALENDAR_MONTH(Bill_Date__c) = :mon
                AND Employee_Code__c = :strPernr
            ];*/

         //Object sumAmount = groupedResults[0].get('mysum');

        //klreturn.sMoney = str;
        return str;
    }

    public static void test1()
    {
        Integer a=0;
        Integer b=0;
        for(Integer i=0;i<80;i++)
        {
            a=a+1;
            b=b+2;
        }
        System.debug('test1');
    }

    public static void test2()
    {
        Integer a=0;
        Integer b=0;
        for(Integer i=0;i<80;i++)
        {
            a=a+1;
            b=b+2;
        }
        System.debug('test1');
    }

    public static void test3()
    {
        Integer a=0;
        Integer b=0;
        for(Integer i=0;i<80;i++)
        {
            a=a+1;
            b=b+2;
        }
        System.debug('test1');
    }

    public static void test4()
    {
        Integer a=0;
        Integer b=0;
        for(Integer i=0;i<80;i++)
        {
            a=a+1;
            b=b+2;
        }
        System.debug('test1');
    }

    public static void test5()
    {
        Integer a=0;
        Integer b=0;
        for(Integer i=0;i<80;i++)
        {
            a=a+1;
            b=b+2;
        }
        System.debug('test1');
    }

    public static void test6()
    {
        Integer a=0;
        Integer b=0;
        for(Integer i=0;i<80;i++)
        {
            a=a+1;
            b=b+2;
        }
        System.debug('test1');
    }

    public static void test7()
    {
        Integer a=0;
        Integer b=0;
        for(Integer i=0;i<80;i++)
        {
            a=a+1;
            b=b+2;
        }
        System.debug('test1');
    }

    public static void test8()
    {
        Integer a=0;
        Integer b=0;
        for(Integer i=0;i<80;i++)
        {
            a=a+1;
            b=b+2;
        }
        System.debug('test1');
    }

    public static void test9()
    {
        Integer a=0;
        Integer b=0;
        for(Integer i=0;i<80;i++)
        {
            a=a+1;
            b=b+2;
        }
        System.debug('test1');
    }

    public static void test10()
    {
        Integer a=0;
        Integer b=0;
        for(Integer i=0;i<80;i++)
        {
            a=a+1;
            b=b+2;
        }
        System.debug('test1');
    }
    public static void test11()
    {
        Integer a=0;
        Integer b=0;
        for(Integer i=0;i<80;i++)
        {
            a=a+1;
            b=b+2;
        }
        System.debug('test1');
    }
    public static void test12()
    {
        Integer a=0;
        Integer b=0;
        for(Integer i=0;i<80;i++)
        {
            a=a+1;
            b=b+2;
        }
        System.debug('test1');
    }
    public static void test13()
    {
        Integer a=0;
        Integer b=0;
        for(Integer i=0;i<80;i++)
        {
            a=a+1;
            b=b+2;
        }
        System.debug('test1');
    }
    public static void test14()
    {
        Integer a=0;
        Integer b=0;
        for(Integer i=0;i<80;i++)
        {
            a=a+1;
            b=b+2;
        }
        System.debug('test1');
    }
    public static void test15()
    {
        Integer a=0;
        Integer b=0;
        for(Integer i=0;i<80;i++)
        {
            a=a+1;
            b=b+2;
        }
        System.debug('test1');
    }
    public static void test16()
    {
        Integer a=0;
        Integer b=0;
        for(Integer i=0;i<80;i++)
        {
            a=a+1;
            b=b+2;
        }
        System.debug('test1');
    }

    public static void test17()
    {
        Integer a=0;
        Integer b=0;
        for(Integer i=0;i<80;i++)
        {
            a=a+1;
            b=b+2;
        }
        System.debug('test1');
    }

    public static void test18()
    {
        Integer a=0;
        Integer b=0;
        for(Integer i=0;i<80;i++)
        {
            a=a+1;
            b=b+2;
        }
        System.debug('test1');
    }

    public static void test19()
    {
        Integer a=0;
        Integer b=0;
        for(Integer i=0;i<80;i++)
        {
            a=a+1;
            b=b+2;
        }
        System.debug('test1');
    }

    public static void test20()
    {
        Integer a=0;
        Integer b=0;
        for(Integer i=0;i<80;i++)
        {
            a=a+1;
            b=b+2;
        }
        System.debug('test1');
    }

    public static void test21()
    {
        Integer a=0;
        Integer b=0;
        for(Integer i=0;i<80;i++)
        {
            a=a+1;
            b=b+2;
        }
        System.debug('test1');
    }

    public static void test22()
    {
        Integer a=0;
        Integer b=0;
        for(Integer i=0;i<80;i++)
        {
            a=a+1;
            b=b+2;
        }
        System.debug('test1');
    }

    public static void test23()
    {
        Integer a=0;
        Integer b=0;
        for(Integer i=0;i<80;i++)
        {
            a=a+1;
            b=b+2;
        }
        System.debug('test1');
    }

    public static void test24()
    {
        Integer a=0;
        Integer b=0;
        for(Integer i=0;i<80;i++)
        {
            a=a+1;
            b=b+2;
        }
        System.debug('test1');
    }

    public static void test25()
    {
        Integer a=0;
        Integer b=0;
        for(Integer i=0;i<80;i++)
        {
            a=a+1;
            b=b+2;
        }
        System.debug('test1');
    }

    public static void test26()
    {
        Integer a=0;
        Integer b=0;
        for(Integer i=0;i<80;i++)
        {
            a=a+1;
            b=b+2;
        }
        System.debug('test1');
    }

    public static void test27()
    {
        Integer a=0;
        Integer b=0;
        for(Integer i=0;i<80;i++)
        {
            a=a+1;
            b=b+2;
        }
        System.debug('test1');
    }

    public static void test28()
    {
        Integer a=0;
        Integer b=0;
        for(Integer i=0;i<80;i++)
        {
            a=a+1;
            b=b+2;
        }
        System.debug('test1');
    }

    public static void test29()
    {
        Integer a=0;
        Integer b=0;
        for(Integer i=0;i<80;i++)
        {
            a=a+1;
            b=b+2;
        }
        System.debug('test1');
    }

}