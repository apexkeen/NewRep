global class CABatchProcess implements Database.Batchable<sObject>,Database.Stateful{
   global String Query;   
   global list<string> lstCommercialIds;
   global list<account> selected_accountslist;
   global string selectedstatus;
   //added by shalini for ER-323
   global String selectedChangeContext;
   global string myWizardLastRunId;
   global list<Client_Avail_Exception__c> clientAvailException_list = new list<Client_Avail_Exception__c>();
   global integer countExcpetionRec;
   list<Client_Avail__c> finalclientavail_lst = new list<Client_Avail__c>();
   public list<User> userDetail = new list<User>();
   
    
   global CABatchProcess ( list<string> commercialIds, list<account> accList,string status,string changeContext,string lastRunId){
        
             lstCommercialIds = commercialIds;
             selected_accountslist = accList;
             selectedstatus=status;
             //added by shalini for ER-323
             selectedChangeContext= changeContext;
             myWizardLastRunId=lastRunId;
             userDetail =[  SELECT id,Name,ProfileId,Profile.Name,UserType,Territory__c,CA_Batch_Id__c,Email   from User where id =: Userinfo.getUserId() ];                                                  
             countExcpetionRec = 0;
    }

   global Database.QueryLocator start(Database.BatchableContext BC){
       //added Local_Title__r.Local_Category__c in below query for ER-356 by shalini
       Query = ' SELECT  id, name,Format__c,Channel__c,Country_Lookup__c,Country_Lookup__r.Name,Languages__c,Languages__r.Name,Language_Type__c,Country_Group__c,Title__c,Start_Date__c,End_Date__c,Status__c,Title__r.Content_Type__c,Title__r.Name,Local_Title__r.Price_Code__c,Local_Title__r.Category__c,Title__r.Territory__c,Local_Title__r.Local_Category__c from commercial_avail__c where Id IN :lstCommercialIds';
      return Database.getQueryLocator(Query);
   }

   global void execute(Database.BatchableContext BC, List<commercial_avail__c> scope){       
        set<string> TitleContentType = new set<string>();
        set<string> commercialCountry= new set<string>();
        set<string> releaseLocalPriceCod = new set<string>(); 
        set<string> releasePlanChannel = new set<string>();
        set<string> releasePlanFormat = new set<string>();
        list<Agreement__c> selectedStorefronts = new list<Agreement__c>();
        list<Pricing__c> listPricingTable =new list<Pricing__c>();
        list<Client_Avail__c> clientavail_lst = new list<Client_Avail__c>();
         map<id,set<string>> mapStorefrontChannels = new  map<id,set<string>>();//Map for distinguish which channel is for which storefront
         map<id,set<string>> mapstorefrontFormats = new  map<id,set<string>>();
         map<id,set<string>> mapstorefrontContentTypes = new  map<id,set<string>>();
         
         list<releaseplanwrapper2> notMatchedCommercialWrap_list2 = new list<releaseplanwrapper2>(); 
         set<string> commercialAvailIds = new set<string>();  
         finalclientavail_lst = new list<Client_Avail__c>();
         
       for(commercial_avail__c selCommAvails : scope){          
            TitleContentType.add(selCommAvails .Title__r.Content_Type__c);
            commercialCountry.add(selCommAvails .Country_Lookup__c);
            releaseLocalPriceCod.add(selCommAvails .Local_Title__r.Price_Code__c);
            releasePlanChannel.add(selCommAvails .Channel__c);
            releasePlanFormat.add(selCommAvails.Format__c); 
          
      } 
      selectedStorefronts = [SELECT Id,Name,Account__c,Status__c,Account__r.Name,Pricing_Currency__c,Country__c,Channel_Picklist__c,Format__c,Content_Type__c FROM Agreement__c WHERE Account__c IN:selected_accountslist AND Country__c IN:commercialCountry];
      //added Local_Title__r.Local_Category__c in below query for ER-356 by shalini
      list<client_avail__c> DateList=[select id,Name,client__r.name,Commercial_Avail__r.Name,End_Date__c,Start_Date__c,Commercial_Avail__r.Start_Date__c,Commercial_Avail__r.End_Date__c,Release_Plan_Channel__c,
                                        Release_Plan_Format__c,Release_Plan_Language__c,Release_Plan_Country__c,Release_Plan_Title__c,Local_Title__r.Local_Category__c,Client__c,Storefront__c from client_avail__c where 
                                        Commercial_Avail__c IN:lstCommercialIds AND Client__c IN :selected_accountslist];
                                        
      listPricingTable = [SELECT id,Name,Account__c,Channel__c,Content_Type__c,Country__c,Effective_Date__c,Episode_Price__c,Episode_Price_Tier__c,Format__c,Price_Tier__c,SR_Per_Episode__c,SR_Price__c,WS_Price__c
                        from Pricing__c where Account__c IN: selected_accountslist and Content_Type__c IN:TitleContentType and Country__c IN: commercialCountry and Name IN:releaseLocalPriceCod
                        and Channel__c IN:releasePlanChannel and Format__c IN:releasePlanFormat ];  
     
                              
      for(Agreement__c strfrnt : selectedStorefronts ){
        
        set<string> storefrontChannels = new set<string>();//intialize here otherwise it will have old channel valuw for previous storefront
        list<string> storefrontChannels2 = new list<string>();//For Split
        set<string> storefrontFormats = new set<string>();
        list<string> storefrontFormats2 = new list<string>();
        set<string> storefrontContentTypes = new set<string>();
        list<string> storefrontContentTypes2 = new list<string>();
        
        if(strfrnt.Channel_Picklist__c!=null){
            storefrontChannels2=strfrnt.Channel_Picklist__c.toLowerCase().split(';');         
            storefrontChannels.addAll(storefrontChannels2);
            mapStorefrontChannels.put(strfrnt.Id,storefrontChannels);
        }
        if(strfrnt.Format__c!=null){
            storefrontFormats2=strfrnt.Format__c.toLowerCase().split(';');
            storefrontFormats.addAll(storefrontFormats2);
            mapstorefrontFormats.put(strfrnt.Id,storefrontFormats);
        }
        if(strfrnt.Content_Type__c!=null){
           
            storefrontContentTypes2=strfrnt.Content_Type__c.toLowerCase().split(';');
            storefrontContentTypes.addAll(storefrontContentTypes2);
            mapstorefrontContentTypes.put(strfrnt.Id,storefrontContentTypes);
        }
      
        
    } // storefront map ended
    for(Commercial_Avail__c vCommercialAvails : scope){
        for(account acc:selected_accountslist){
            integer countStorefronts=0;
            for(Agreement__c selectStrfront : selectedStorefronts ){ 
                if(vCommercialAvails.Country_Lookup__c == selectStrfront.Country__c && acc.id==selectStrfront.Account__c){
                    countStorefronts++;
                    if(selectStrfront.Status__c == 'Active'){
                    if( mapStorefrontChannels.size() != 0 && mapstorefrontFormats.size()!= 0 && mapstorefrontContentTypes.size()!= 0){
                        if(mapStorefrontChannels.get(selectStrfront.Id)!= Null && mapstorefrontFormats.get(selectStrfront.Id)!=Null && mapstorefrontContentTypes.get(selectStrfront.Id)!= Null && vCommercialAvails.Channel__c!=null && vCommercialAvails.Format__c!=null && vCommercialAvails.Title__r.Content_Type__c!=null){ 
                            if(mapStorefrontChannels.get(selectStrfront.Id).contains(vCommercialAvails.Channel__c.toLowerCase()) && mapstorefrontFormats.get(selectStrfront.Id).contains(vCommercialAvails.Format__c.toLowerCase())
                            && mapstorefrontContentTypes.get(selectStrfront.Id).contains(vCommercialAvails.Title__r.Content_Type__c.toLowerCase())){
                               
                                integer countOverlap=0;
                                for(client_avail__c CAOverlapRec :DateList) {
                                  
                                    if(vCommercialAvails.id== CAOverlapRec.commercial_avail__c && acc.Id== CAOverlapRec.client__c){                                     
                                        if(!((vCommercialAvails.Start_Date__c >= CAOverlapRec.End_Date__c)||(vCommercialAvails.End_Date__c <=CAOverlapRec.Start_Date__c ))){
                                        //imran 27 jan
                                        //if(vCommercialAvails.Start_Date__c==CAOverlapRec.Start_Date__c || //vCommercialAvails.End_Date__c==CAOverlapRec.End_Date__c){
                                        
                                            countOverlap++;
                                        }
                                    }
                                    
                                    
                                }
                                if(countOverlap>0){
                                    countExcpetionRec++;
                                    releaseplanwrapper2 real= new releaseplanwrapper2();    
                                    string str =  vCommercialAvails.Id+string.valueof(countExcpetionRec);     
                                    real.releaseplan = vCommercialAvails;            
                                    //real.accountName = clientavail_lst[n].client__c;
                                    real.accountName = selectStrfront.Account__r.Name;
                                    real.reasonMsg ='Client avail is present with selected dates';
                                    real.uniqueName = str;
                                    notMatchedCommercialWrap_list2.add(real);
                                    
                                }else{
                                    Client_avail__c ClientAvail = new client_avail__c();
                                    if(listPricingTable.size()!= 0){
                                        integer priceCounter=0;
                                        for(Pricing__c pricetb :listPricingTable){
                                            if(pricetb.Content_Type__c == vCommercialAvails.Title__r.Content_Type__c && pricetb.Country__c== vCommercialAvails.Country_Lookup__c &&
                                                pricetb.Account__c == selectStrfront.Account__c && pricetb.Name == vCommercialAvails.Local_Title__r.Price_Code__c 
                                                && pricetb.Format__c== vCommercialAvails.Format__c && pricetb.Channel__c== vCommercialAvails.Channel__c){  
                                                    ClientAvail.Batch_Id__c=myWizardLastRunId;
                                                    ClientAvail.Start_Date__c = vCommercialAvails.Start_Date__c; 
                                                    ClientAvail.End_Date__c = vCommercialAvails.End_Date__c;  
                                                    ClientAvail.status__c = selectedstatus;                       
                                                    ClientAvail.client__c = selectStrfront.Account__c;
                                                    ClientAvail.Storefront__c= selectStrfront.Id;
                                                    ClientAvail.Price_Tier_Text__c= pricetb.Price_Tier__c;
                                                    ClientAvail.Price__c= pricetb.WS_Price__c;
                                                    ClientAvail.SR_Price__c= pricetb.SR_Price__c;
                                                    //added by shalini -- ER-323
                                                    ClientAvail.Change_Context__c=selectedChangeContext;  
                                                    //ClientAvail.Local_Data_Category_Picklist__c= vCommercialAvails.Local_Title__r.Category__c; // Added by 23 Dec
                                                    //modified by shalini for ER-356        
                                                    if(vCommercialAvails.Local_Title__r.Local_Category__c != null && vCommercialAvails.Local_Title__r.Local_Category__c!='')        
                                                        ClientAvail.Local_Data_Category_Picklist__c= vCommercialAvails.Local_Title__r.Local_Category__c;
                                                    else
                                                        ClientAvail.Local_Data_Category_Picklist__c='-';
                                                    System.debug('In CA Wizard-----'+ClientAvail.Local_Data_Category_Picklist__c);  
                                                    ClientAvail.Commercial_Avail__c = vCommercialAvails.id;
                                                    if(vCommercialAvails.Title__r.Content_Type__c == 'Season'){
                                                        ClientAvail.Episode_Price__c= pricetb.Episode_Price__c;
                                                        ClientAvail.SR_Per_Episode__c= pricetb.SR_Per_Episode__c;
                                                        ClientAvail.Episode_Price_Tier__c= pricetb.Episode_Price_Tier__c;
                                                    }
                                                    if(pricetb.Price_Tier__c == Null && pricetb.WS_Price__c == Null){
                                                        ClientAvail.Price_Tier_Text__c= 'TBD';
                                                    }                                            


                                                    clientavail_lst.add(ClientAvail);
                                                    priceCounter++;
                                                    
                                                }
                                        }
                                        if(priceCounter==0){
                                                ClientAvail.Batch_Id__c=myWizardLastRunId;
                                                ClientAvail.Start_Date__c = vCommercialAvails.Start_Date__c; 
                                                ClientAvail.End_Date__c = vCommercialAvails.End_Date__c;
                                                if(selectedstatus == 'Confirmed'){
                                                    ClientAvail.status__c = 'Tentative'; 
                                                }else ClientAvail.status__c = selectedstatus;
                                                ClientAvail.client__c = selectStrfront.Account__c;
                                                //added by shalini -- ER-323
                                                ClientAvail.Change_Context__c=selectedChangeContext;
                                                ClientAvail.Storefront__c = selectStrfront.Id;
                                                ClientAvail.Commercial_Avail__c = vCommercialAvails.id;
                                                ClientAvail.Price_Tier_Text__c ='TBD';
                                                clientavail_lst.add(ClientAvail);
                                            }
                                    }
                                    else{
                                           
                                            ClientAvail.Batch_Id__c=myWizardLastRunId;
                                            ClientAvail.Start_Date__c = vCommercialAvails.Start_Date__c; 
                                            ClientAvail.End_Date__c = vCommercialAvails.End_Date__c; 
                                            if(selectedstatus == 'Confirmed'){
                                                ClientAvail.status__c = 'Tentative'; 
                                            }else ClientAvail.status__c = selectedstatus;
                                            ClientAvail.client__c = selectStrfront.Account__c;
                                            ClientAvail.Storefront__c= selectStrfront.Id;
                                            //added by shalini -- ER-323
                                            ClientAvail.Change_Context__c=selectedChangeContext;
                                            ClientAvail.Price_Tier_Text__c ='TBD';

                                            //ClientAvail.Local_Data_Category_Picklist__c= vCommercialAvails.Local_Title__r.Category__c; // Added by 23 Dec
                                            //modified by shalini for ER-356        
                                            if(vCommercialAvails.Local_Title__r.Local_Category__c != null && vCommercialAvails.Local_Title__r.Local_Category__c!='')        
                                                ClientAvail.Local_Data_Category_Picklist__c= vCommercialAvails.Local_Title__r.Local_Category__c;
                                            else
                                                ClientAvail.Local_Data_Category_Picklist__c='-';
                                            System.debug('In CA Wizard-----'+ClientAvail.Local_Data_Category_Picklist__c);  

                                            ClientAvail.Commercial_Avail__c = vCommercialAvails.id;

                                            clientavail_lst.add(ClientAvail);

                                        }
                                }
                            }
                            else{
                             
                                countExcpetionRec++;
                                releaseplanwrapper2 real= new releaseplanwrapper2();    
                                string str = vCommercialAvails.Id+string.valueof(countExcpetionRec);     
                                real.releaseplan =vCommercialAvails;            
                                real.accountName = acc.name;
                                real.reasonMsg ='Storefront doesnot contain the channel,format or content type';
                                real.uniqueName = str;
                                notMatchedCommercialWrap_list2.add(real);
                               
                              }
                        }
                        else{
                            
                                countExcpetionRec++;
                                releaseplanwrapper2 real= new releaseplanwrapper2();    
                                string str = vCommercialAvails.Id+string.valueof(countExcpetionRec);     
                                real.releaseplan =vCommercialAvails;            
                                real.accountName = acc.name;
                                real.reasonMsg ='Storefront doesnot contain the channel,format or content type';
                                real.uniqueName = str;
                                notMatchedCommercialWrap_list2.add(real);
                            }
                        
                        }
                        }else{
                        countExcpetionRec++;
                        releaseplanwrapper2 real= new releaseplanwrapper2();    
                        string str = vCommercialAvails.Id+string.valueof(countExcpetionRec);     
                        real.releaseplan =vCommercialAvails;            
                        real.accountName = acc.name;
                        real.reasonMsg ='Storefront status is Inactive';
                        real.uniqueName = str;
                        notMatchedCommercialWrap_list2.add(real);
                        
                        }
                    }
                }
                if(countStorefronts==0){
                    countExcpetionRec++;
                    releaseplanwrapper2 real= new releaseplanwrapper2();    
                    string str = vCommercialAvails.Id+string.valueof(countExcpetionRec);     
                    real.releaseplan =vCommercialAvails;            
                    real.accountName = acc.name;
                    real.reasonMsg ='Storefront is not present';
                    real.uniqueName = str;
                    notMatchedCommercialWrap_list2.add(real);
                }
    
        }
        commercialAvailIds.add(vCommercialAvails.Id);
    }    
        finalclientavail_lst.addAll(clientavail_lst);
       
        for(releaseplanwrapper2 relwrap :notMatchedCommercialWrap_list2){
            Client_Avail_Exception__c clientExcep = new Client_Avail_Exception__c();
            clientExcep.Name = relwrap.uniqueName;
            clientExcep.Account__c = relwrap.accountName;
            clientExcep.User_Detail__c = userDetail[0].Id;                       
            clientExcep.Release_Plan_Number__c = relwrap.releaseplan.Name;
            clientExcep.Title__c = relwrap.releaseplan.Title__r.Name;
            clientExcep.Content_Type__c = relwrap.releaseplan.Title__r.Content_Type__c;
            clientExcep.Country__c = relwrap.releaseplan.Country_Lookup__r.Name;
            clientExcep.Language__c = relwrap.releaseplan.Languages__r.Name;
            clientExcep.Language_Type__c = relwrap.releaseplan.Language_Type__c;
            clientExcep.Channel__c = relwrap.releaseplan.channel__c;
            clientExcep.Format__c = relwrap.releaseplan.format__c;
            clientExcep.Avail_Start__c = relwrap.releaseplan.Start_Date__c;
            clientExcep.Avail_End__c = relwrap.releaseplan.End_Date__c;
            clientExcep.Status__c = relwrap.releaseplan.Status__c;
            clientExcep.Reason__c = relwrap.reasonMsg;
            clientAvailException_list.Add(clientExcep);
         
        } 
     
      try {
        if(finalclientavail_lst != null && finalclientavail_lst.size() > 0) {               
            
            Database.Saveresult[] saveResult  = Database.insert(finalclientavail_lst, false);
                      
        }
        
      }catch(Exception e){
        System.debug('The following exception has occurred: ' + e.getMessage());
      }
      try{
        if(clientAvailException_list.size()!=0){
            Database.Saveresult[] saveExceptionResult  = Database.insert(clientAvailException_list, false);
       
        }
      }catch(Exception e){
            System.debug('The following exception has occurred in exception list insertion: ' + e.getMessage());        
      }
   }

   global void finish(Database.BatchableContext BC){
    
    integer totalExpectedCA = lstCommercialIds.size()*selected_accountslist.size();  
    integer clientExceptionCount = [SELECT count() FROM Client_Avail_Exception__c];   
    if(clientExceptionCount > 0){
        //List<Client_Avail_Exception__c> existing = [SELECT Id From Client_Avail_Exception__c where User_Detail__c =:userDetail[0].Id];
        //delete existing;
        //system.debug('existing  ' + existing);
    }
  
    string header = 'Release Plan Number, Title , Account, Content Type, Country, Language, Language Type, Channel, Format, Client Start, Client End, Status, Reason  \n';
    string finalstr = header ;
    for(Client_Avail_Exception__c caExceptionOut_lst: clientAvailException_list)
    {
    
           //string recordString = '"'+caExceptionOut_lst.Release_Plan_Number__c+'","'+caExceptionOut_lst.Title__c+'","'+caExceptionOut_lst.Account__c+'","'+caExceptionOut_lst.Content_Type__c +'"\n';
           string recordString = '"'+caExceptionOut_lst.Release_Plan_Number__c+'","'
                                    +caExceptionOut_lst.Title__c+'","'
                                     +caExceptionOut_lst.Account__c+'","'
                                     +caExceptionOut_lst.Content_Type__c+'","'
                                     +caExceptionOut_lst.Country__c+'","'
                                     +caExceptionOut_lst.Language__c+'","'
                                     +caExceptionOut_lst.Language_Type__c+'","'
                                     +caExceptionOut_lst.Channel__c+'","'
                                     +caExceptionOut_lst.Format__c+'","'
                                     +caExceptionOut_lst.Avail_Start__c+'","'
                                     +caExceptionOut_lst.Avail_End__c+'","'
                                     +caExceptionOut_lst.Status__c+'","'
                                     +caExceptionOut_lst.Reason__c+'","'
                                     +'"\n';
           finalstr = finalstr +recordString;
    }
    Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
    blob csvBlob = Blob.valueOf(finalstr);
    string csvname= 'CA.csv';
    csvAttc.setFileName(csvname);
    csvAttc.setBody(csvBlob);
    Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
    AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed,  
    TotalJobItems, CreatedBy.Email, ExtendedStatus  
    from AsyncApexJob where Id = :BC.getJobId()];  
    // Email the Batch Job's submitter that the Job is finished.
    String[] toAddresses = new String[] {a.CreatedBy.Email}; 

    String subject ='Client Avail Exception out CSV';
    email.setSubject(subject);
    email.setToAddresses( toAddresses );
    
    if(totalExpectedCA == finalclientavail_lst.size()){
        email.setPlainTextBody('If you’ve not run the Wizard since you initiated this run, you should be able to see records created by clicking on the link \n'+ System.Label.My_Latest_Wizard_Run + '\n If, however, you’ve created more records since you ran the wizard which initiated this batch process,those records won’t be available. You can see this batch’s records by filtering on batch id < ' + myWizardLastRunId + ' > in a Client Avail view');
    }
    else if(totalExpectedCA == clientAvailException_list.size()){      
        email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
        email.setPlainTextBody('Those records which could not be created (exceptions) are included in an attachment to this message for the user to review.');
    }
    else{
        email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
        email.setPlainTextBody('Those records which could not be created (exceptions) are included in an attachment to this message for the user to review. Few records are created successfully, you can see records by clicking on the link \n'+ System.Label.My_Latest_Wizard_Run + '\n If, however, you’ve created more records since you ran the wizard which initiated this batch process,those records won’t be available. You can see this batch’s records by filtering on batch id < ' + myWizardLastRunId + ' > in a Client Avail view');
    }
   
    Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
    
   
   }
   
    public class releaseplanwrapper2{
        public commercial_avail__c releaseplan{get; set;}
        public Agreement__c storefront{get; set;}
        public string reasonMsg{get;set;}
        public string uniqueName{get;set;}
        public string accountName{get; set;}
        
        
   }
   
    
}