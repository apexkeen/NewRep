/* Test Class for ClearLogs batch */
@isTest
public class CABatchProcessTest
{
    static testmethod void Positive_testCABatch_1()
    {
        Account a = TestUtil.createAccount('Mera Account');
        insert a;
        
        Language__c  L = TestUtil.createLanguage('English', 'en',1);
        insert L;
        
        Country__c C = TestUtil.createCountry('India', 'IN', 'IN');
        insert C;
        
        Title__c T = TestUtil.createTitle('Mera Title', '123456');
        T.Digital_Planning__c = 'Yes';
        T.Content_Type__c = 'Season';
        insert T;
        
        Local_Title__c LT = TestUtil.createLocalData('123456', C, L, 'IN_en', T.Id);
        LT.Price_Code__c = 'USD';
        insert LT;
        
        Commercial_Avail__c CA = TestUtil.createReleasePlan(T.Id, LT.Id, C.Id, L.Id);
        CA.Channel__c = 'EST';
        CA.Format__c = 'HD';
        CA.Exclusive_Date__c = System.today().addDays(-365);//Avail start date
        CA.Rights_End__c = System.today().addDays(365); //Avail End date
        CA.Start_Date__c = System.today().addDays(-30);
        CA.End_Date__c = System.today().addDays(30);
        CA.Country_Lookup__c = C.Id;
        CA.Local_Title__c = LT.Id;
        insert CA;
        
        Agreement__c StrFrnt = TestUtil.createStoreFront(a.Id, C.Id);
        StrFrnt.Content_Type__c = T.content_Type__c;
        StrFrnt.Format__c = CA.Format__c;
        StrFrnt.Channel_Picklist__c = CA.Channel__c;
        //StrFrnt.Status__c ='Active';
        insert StrFrnt;

        Pricing__c P = TestUtil.createPricing(a.Id, C.Id, StrFrnt.Id);
        P.Content_Type__c = T.content_Type__c;
        P.Name = LT.Price_Code__c;
        P.Account__c = A.Id;
        P.Country__c = C.Id;
        P.Channel__c = CA.Channel__c;
        P.Format__c = CA.Format__c;
        insert P;
        
        list<String> commercialIds = new list<String>();
        commercialIds.add(CA.Id);
        
        list<account> accList = new list<account>();
        accList.add(a);
        System.debug('MYDEBUG CA : ' + CA);
        CABatchProcess BP = new CABatchProcess(commercialIds, accList, 'Draft', 'Initial Release', '1');
        Database.executeBatch(BP);
    }
    
    static testmethod void Positive_testCABatch_2()
    {
        Account a = TestUtil.createAccount('Mera Account');
        insert a;
        
        Language__c  L = TestUtil.createLanguage('English', 'en',1);
        insert L;
        
        Country__c C = TestUtil.createCountry('India', 'IN', 'IN');
        insert C;
        
        Title__c T = TestUtil.createTitle('Mera Title', '123456');
        T.Digital_Planning__c = 'Yes';
        T.Content_Type__c = 'Season';
        insert T;
        
        Local_Title__c LT = TestUtil.createLocalData('123456', C, L, 'IN_en', T.Id);
        LT.Price_Code__c = 'USD';
        insert LT;
        
        Commercial_Avail__c CA = TestUtil.createReleasePlan(T.Id, LT.Id, C.Id, L.Id);
        CA.Channel__c = 'EST';
        CA.Format__c = 'HD';
        CA.Exclusive_Date__c = System.today().addDays(-365);//Avail start date
        CA.Rights_End__c = System.today().addDays(365); //Avail End date
        CA.Start_Date__c = System.today().addDays(-30);
        CA.End_Date__c = System.today().addDays(30);
        CA.Country_Lookup__c = C.Id;
        CA.Local_Title__c = LT.Id;
        insert CA;
        
        Agreement__c StrFrnt = TestUtil.createStoreFront(a.Id, C.Id);
        StrFrnt.Content_Type__c = T.content_Type__c;
        StrFrnt.Format__c = CA.Format__c;
        StrFrnt.Channel_Picklist__c = CA.Channel__c;
        //StrFrnt.Status__c ='Active';
        insert StrFrnt;

        Pricing__c P = TestUtil.createPricing(a.Id, C.Id, StrFrnt.Id);
        P.Content_Type__c = T.content_Type__c;
        P.Name = LT.Price_Code__c;
        P.Account__c = A.Id;
        P.Country__c = C.Id;
        P.Channel__c = CA.Channel__c;
        P.Format__c = 'SD';
        insert P;
        
        list<String> commercialIds = new list<String>();
        commercialIds.add(CA.Id);
        
        list<account> accList = new list<account>();
        accList.add(a);
        System.debug('MYDEBUG CA : ' + CA);
        CABatchProcess BP = new CABatchProcess(commercialIds, accList, 'Draft', 'Initial Release', '1');
        Database.executeBatch(BP);
    }
    
    static testmethod void Positive_testCABatch_3()
    {
        Account a = TestUtil.createAccount('Mera Account');
        insert a;
        
        Account a1 = TestUtil.createAccount('Mera Account');
        insert a1;
        
        Language__c  L = TestUtil.createLanguage('English', 'en',1);
        insert L;
        
        Country__c C = TestUtil.createCountry('India', 'IN', 'IN');
        insert C;
        
        Country__c C1 = TestUtil.createCountry('USA', 'US', 'US');
        insert C1;
        
        Title__c T = TestUtil.createTitle('Mera Title', '123456');
        T.Digital_Planning__c = 'Yes';
        T.Content_Type__c = 'Season';
        insert T;
        
        Local_Title__c LT = TestUtil.createLocalData('123456', C, L, 'IN_en', T.Id);
        LT.Price_Code__c = 'USD';
        insert LT;
        
        Commercial_Avail__c CA = TestUtil.createReleasePlan(T.Id, LT.Id, C.Id, L.Id);
        CA.Channel__c = 'EST';
        CA.Format__c = 'HD';
        CA.Exclusive_Date__c = System.today().addDays(-365);//Avail start date
        CA.Rights_End__c = System.today().addDays(365); //Avail End date
        CA.Start_Date__c = System.today().addDays(-30);
        CA.End_Date__c = System.today().addDays(30);
        CA.Country_Lookup__c = C.Id;
        CA.Local_Title__c = LT.Id;
        insert CA;
        
        Agreement__c StrFrnt = TestUtil.createStoreFront(a.Id, C.Id);
        StrFrnt.Content_Type__c = T.content_Type__c;
        StrFrnt.Format__c = CA.Format__c;
        StrFrnt.Channel_Picklist__c = CA.Channel__c;
        //StrFrnt.Status__c ='Active';
        insert StrFrnt;
        
        Agreement__c StrFrnt1 = TestUtil.createStoreFront(a1.Id, C.Id);
        StrFrnt1.Content_Type__c = T.content_Type__c;
        StrFrnt1.Format__c = CA.Format__c;
        StrFrnt1.Channel_Picklist__c = CA.Channel__c;
        //StrFrnt.Status__c ='Active';
        insert StrFrnt1;
        
        Pricing__c P = TestUtil.createPricing(a.Id, C.Id, StrFrnt.Id);
        P.Content_Type__c = T.content_Type__c;
        P.Name = LT.Price_Code__c;
        P.Account__c = A.Id;
        P.Country__c = C.Id;
        P.Channel__c = CA.Channel__c;
        P.Format__c = CA.Format__c;
        insert P;
        
        list<String> commercialIds = new list<String>();
        commercialIds.add(CA.Id);
        
        list<account> accList = new list<account>();
        accList.add(a);
        accList.add(a1);
        System.debug('MYDEBUG CA : ' + CA);
        CABatchProcess BP = new CABatchProcess(commercialIds, accList, 'Draft', 'Initial Release', '1');
        Database.executeBatch(BP);
    }
    
    static testmethod void Negative_testCABatch_1()
    {
        Account a = TestUtil.createAccount('Mera Account');
        insert a;
        
        Account a1 = TestUtil.createAccount('Tera Account');
        insert a1;
        
        Language__c  L = TestUtil.createLanguage('English', 'en',1);
        insert L;
        
        Country__c C = TestUtil.createCountry('India', 'IN', 'IN');
        insert C;
        
        Title__c T = TestUtil.createTitle('Mera Title', '123456');
        T.Digital_Planning__c = 'Yes';
        T.Content_Type__c = 'Season';
        insert T;
        
        Local_Title__c LT = TestUtil.createLocalData('123456', C, L, 'IN_en', T.Id);
        LT.Price_Code__c = 'USD';
        insert LT;
        
        Commercial_Avail__c CA = TestUtil.createReleasePlan(T.Id, LT.Id, C.Id, L.Id);
        CA.Channel__c = 'EST';
        CA.Format__c = 'HD';
        CA.Exclusive_Date__c = System.today().addDays(-365);//Avail start date
        CA.Rights_End__c = System.today().addDays(365); //Avail End date
        CA.Start_Date__c = System.today().addDays(-30);
        CA.End_Date__c = System.today().addDays(30);
        CA.Country_Lookup__c = C.Id;
        CA.Local_Title__c = LT.Id;
        insert CA;
        
        Agreement__c StrFrnt = TestUtil.createStoreFront(a1.Id, C.Id);
        StrFrnt.Content_Type__c = T.content_Type__c;
        StrFrnt.Channel_Picklist__c = CA.Channel__c;
        //StrFrnt.Status__c ='Active';
        insert StrFrnt;
        
        Pricing__c P = TestUtil.createPricing(a.Id, C.Id, StrFrnt.Id);
        P.Content_Type__c = T.content_Type__c;
        P.Name = LT.Price_Code__c;
        P.Account__c = A.Id;
        P.Country__c = C.Id;
        P.Channel__c = CA.Channel__c;
        P.Format__c = CA.Format__c;
        insert P;
        
        list<String> commercialIds = new list<String>();
        commercialIds.add(CA.Id);
        
        list<account> accList = new list<account>();
        accList.add(a);
        accList.add(a1);
        
        System.debug('MYDEBUG CA : ' + CA);
        CABatchProcess BP = new CABatchProcess(commercialIds, accList, 'Draft', 'Initial Release', '1');
        Database.executeBatch(BP);
    }
}