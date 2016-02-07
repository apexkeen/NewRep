@isTest
public class MPMReleaseDateTriggerTest
{
    static testMethod void testMPMReleaseDateTrigger()
    {
        Test.startTest();
        
        MPM__c mpm = Testutil.createMPM('10001');
        insert mpm;
        
        Title__c title = Testutil.createTitle('Test', '20001');
        title.MPM__c = mpm.Id;
        insert title;
        
        list<Country__c> cList = new list<Country__c>();
        Country__c usa = TestUtil.createCountry('India', 'IN', 'IND');
        cList.add(usa);
        Country__c india = TestUtil.createCountry('India', 'US', 'USA');
        cList.add(india);
        insert cList;
        
        list<Language__c> lList = new list<Language__c>();
        Language__c eng = TestUtil.createLanguage('English', 'EN',1);
        lList.add(eng);
        Language__c hin = TestUtil.createLanguage('Hindi', 'HN',1);
        lList.add(hin);
        insert lList;
        
        list<Local_Title__c> ltList = new list<Local_Title__c>();
        Local_Title__c LT = TestUtil.createLocalData('20001', usa, eng, 'US_EN', title.Id);
        ltList.add(LT);
        Local_Title__c LT1 = TestUtil.createLocalData('20001', india, eng, 'IN_EN', title.Id);
        ltList.add(LT1);
        Local_Title__c LT2 = TestUtil.createLocalData('20001', india, hin, 'IN_HN', title.Id);
        ltList.add(LT2);
        insert ltList;
        
        list<MPM_Release_date__c> mrdList = new list<MPM_Release_date__c>();
        MPM_Release_date__c mrd = TestUtil.createMPMReleaseDate(mpm.Id, usa.Id, Date.today(), Date.today().addDays(7));
        mrdList.add(mrd);
        MPM_Release_date__c mrd1 = TestUtil.createMPMReleaseDate(mpm.Id, india.Id, Date.today(), Date.today().addDays(8));
        mrdList.add(mrd1);
        insert mrdList;
        
        Local_Title__c LTitle = [select id, Local_Theatrical_Release_Date__c, Local_TV_Air_Date__c from Local_Title__c where Id =:LT.Id];
        System.assertEquals(LTitle.Local_Theatrical_Release_Date__c, Date.today());
        System.assertEquals(LTitle.Local_TV_Air_Date__c, Date.today().addDays(7));
        
        Local_Title__c LTitle1 = [select id, Local_Theatrical_Release_Date__c, Local_TV_Air_Date__c from Local_Title__c where Id =:LT2.Id];
        System.assertEquals(LTitle1.Local_Theatrical_Release_Date__c, Date.today());
        System.assertEquals(LTitle1.Local_TV_Air_Date__c, Date.today().addDays(8));
        
        Test.stopTest();
    }
}