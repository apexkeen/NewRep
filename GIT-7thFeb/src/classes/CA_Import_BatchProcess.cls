global class CA_Import_BatchProcess implements Database.Batchable<sObject>,Database.Stateful{
   // Save 1 Git 1
   //save 2 git 2
  
   global String Query;    
   global Id cauIdForBatch;
   global integer noOfRecordsProcessed = 0;
   global integer noOfRecordsSuccessful = 0;
   global integer noOfRecordsFailed = 0;
   global Map<Client_Avail__c,String> insertResult = new Map<Client_Avail__c,String>();
    
   global CA_Import_BatchProcess (Id idForBatch){
       cauIdForBatch = idForBatch;
   }

   global Database.QueryLocator start(Database.BatchableContext BC){
       Query = 'SELECT id,Account_Name__c,Category__c,CA_Upload__c,Channel__c,Country__c,End_Date__c,Episode_Price_Tier__c,Episode_SR_Price__c,Episode_WS_Cost__c,Format__c,Language__c,Language_Type__c,Local_Data_No_Of_Episodes__c,Local_Data_Rating__c,Local_Edit_Required__c,Notes__c,Pre_Order_Date__c,Price_Tier__c,SR_Price__c,Start_Date__c,Status__c,Suppression_Date__c,Title_Name__c,Video_Version__c,WS_Cost__c FROM CA_Upload_Record__c WHERE CA_Upload__c = :idForBatch';
       return Database.getQueryLocator(Query);
   }

   global void execute(Database.BatchableContext BC, List<CA_Upload_Record__c> scope){
       Set<String> titles = new Set<String>();
       Set<String> videoVersions = new Set<String>();
       Set<String> countries = new Set<String>();
       Set<String> languages = new Set<String>();
       Set<String> channels = new Set<String>();
       Set<String> formats = new Set<String>();
       Set<String> accounts = new Set<String>();
       String errorMessage = '';
       Map<String,Account> allAccounts = new Map<String,Account>();
       Map<id,CA_Upload_Record__c> mapCAUploadRecords = new Map<id,CA_Upload_Record__c>();
       MAP<String,Commercial_Avail__c> mapReleasePlans = new Map<String,Commercial_Avail__c>();
       Map<String,Agreement__c> mapStoreFronts = new Map<String,Agreement__c>();
       Map<String,Local_Title__c> mapLocalData = new Map<String,Local_Title__c>();
       List<Commercial_Avail__c> releasePlans = new List<Commercial_Avail__c>();
       List<Agreement__c> storeFronts = new List<Agreement__c>();
       List<Local_Title__c> localData = new List<Local_Title__c>();
       List<Client_Avail__c> insertClientAvail = new List<Client_Avail__c>();
              
       for(Account acc : [SELECT Id,Name FROM Account])
           allAccounts.put(acc.name,acc);
       
       for(CA_Upload_Record__c selCAUR : scope){
           titles.add(selCAUR.Title_Name__c);
           videoVersions.add(selCAUR.Video_Version__c);
           countries.add(selCAUR.Country__c);
           languages.add(selCAUR.Language__c);
           channels.add(selCAUR.Channel__c);
           formats.add(selCAUR.Format__c);    
           accounts.add(selCAUR.Account_Name__c);
           mapCAUploadRecords.put(selCAUR.id,selCAUR);
       }
       
       releasePlans = [SELECT Id,Name,Channel__c,Clear_to_Avail__c,
                              Country_Formula__c,Format__c,
                              Title_Alias__c,Language_Formula__c,
                              Language_Type__c,Local_Title__c,
                              End_Date__c,Start_Date__c,
                              Status__c,Title_Formula__c,Title_Video_Version__c 
                         FROM Commercial_Avail__c
                        WHERE Title_Video_Version__c IN :videoVersions
                          AND Country_Formula__c IN :countries
                          AND Language_Formula__c IN :languages
                          AND Channel__c IN :channels
                          AND Format__c IN :formats
                      ];
       
       for(Commercial_Avail__c rp : releasePlans)
           mapReleasePlans.put(rp.Title_Video_Version__c+rp.Country_Formula__c+rp.Language_Formula__c+rp.Channel__c+rp.Format__c,rp);
           
       storeFronts =  [SELECT Id,Name,Storefront_Acc_Cntry__c,
                              Account__c,Active__c,
                              Channel_Picklist__c,Content_Type__c,
                              Country__c,CountryName__c,
                              Effective_Date__c,Format__c,
                              Status__c,zAccount__c,Territory__c 
                         FROM Agreement__c
                        WHERE zAccount__c IN :accounts
                          AND CountryName__c IN :countries
                      ];
       
       for(Agreement__c sf : storeFronts)
           mapStoreFronts.put(sf.zAccount__c+sf.CountryName__c,sf);
           
       localData =  [SELECT Id,Name,Country__c,CountryF__c,
                              Language__c,LanguageF__c,Title__c,
                              Title_VV_F__c,TitleF__c
                         FROM Local_Title__c
                        WHERE Title_VV_F__c IN :videoVersions
                          AND CountryF__c IN :countries
                          AND LanguageF__c IN :languages
                      ];
       
       for(Local_Title__c ld : localData)
           mapLocalData.put(ld.Title_VV_F__c+ld.CountryF__c+ld.LanguageF__c,ld);     
           
       for(CA_Upload_Record__c ur : scope){
           Client_Avail__c clientAvail = new Client_Avail__c();
           clientAvail.Client__c = allAccounts.get(ur.Account_Name__c).Id;
           clientAvail.Status__c = ur.Status__c;
           clientAvail.End_Date__c = ur.End_Date__c;
           clientAvail.Start_Date__c = ur.Start_Date__c;
           //clientAvail.Comments_large__c = ur.Notes__c;
           clientAvail.Episode_Price__c = Decimal.valueOf(ur.Episode_SR_Price__c);
           clientAvail.Episode_Price_Tier__c = ur.Episode_Price_Tier__c;
           clientAvail.Local_Title__c = mapLocalData.get(ur.Video_Version__c+ur.Country__c+ur.Language__c).Id;
           clientAvail.Comments__c = ur.Notes__c;
           clientAvail.APO_Date__c = ur.Pre_Order_Date__c;
           clientAvail.Price_Tier_Text__c = ur.Price_Tier__c;
           clientAvail.Commercial_Avail__c = mapReleasePlans.get(ur.Video_Version__c+ur.Country__c+ur.Language__c+ur.Channel__c+ur.Format__c).Id;
           clientAvail.SR_Per_Episode__c = Decimal.valueOf(ur.Episode_SR_Price__c);
           clientAvail.SR_Price__c = Decimal.valueOf(ur.SR_Price__c);
           clientAvail.Storefront__c = mapStoreFronts.get(ur.Account_Name__c+ur.Country__c).Id;
           clientAvail.Announce_Date__c = ur.Suppression_Date__c;
           clientAvail.Local_Data_Category_Picklist__c = ur.Category__c;
           clientAvail.Price__c = Decimal.valueOf(ur.WS_Cost__c);
           insertClientAvail.add(clientAvail);
           noOfRecordsProcessed++;
       }
       
       database.saveresult[] results = database.insert(insertClientAvail, false);
       for(integer idx = 0; idx < results.size(); idx++){
            if(results[idx].isSuccess()) {
                insertResult.put(insertClientAvail[idx],'Successful');
                noOfRecordsSuccessful++;
                //Trigger.new[indices.get(idx)].AccountId = accounts[idx].Id;
            } else {
                errorMessage = '';
                for(Database.Error err : results[idx].getErrors()) 
                    errorMessage = err.getMessage()+';'+errorMessage;
                insertResult.put(insertClientAvail[idx],errorMessage);
                noOfRecordsFailed++;
                system.debug('failed...'+insertClientAvail[idx]+' due to '+errorMessage);
                //Trigger.new[indices.get(idx)].AccountId.addError('Failed to create account for this contact: '
                //    + results[idx].getErrors()[0].getMessage());
            }
       }
    
                    
   }

   global void finish(Database.BatchableContext BC){
   }
   
    
}