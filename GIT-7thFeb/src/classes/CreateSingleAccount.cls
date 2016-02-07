@RestResource(URLMapping = '/SingleAccounInsert/*')

 Global class CreateSingleAccount {
 
 /*@httpPost
  Global static string  CreateAcc( string nm, string Descrip, String Type, String Territory){
  Account acc = new Account();
  acc.name = nm ;
  acc.Description = Descrip;
  acc.Type = Type;
  acc.Territory__c= Territory;
  
  insert acc ;
  return acc.Id;
  
  }
  */
  
 @httpPost
  Global static string  CreateAcc(){
  //List<Account> accList = new list<Account>();
  //List<Account> accountsDeserialized = (List<Account>) JSON.deserialize(Jsontext, List<Account>.class);
  
  List<Account> accountsDeserialized= (List<Account>)JSON.deserialize(RestContext.request.requestBody.tostring(), List<Account>.class);
  /* acc.name = nm ;
  acc.Description = Descrip;
  acc.Type = Type;
  acc.Territory__c= Territory;
  
  insert acc ;
  */
    String IDOrErrorMsg = '' ;
    database.saveResult[] results =  database.insert(accountsDeserialized, false) ;
    For ( Database.saveResult sr : results) 
          { 
              if(sr.Issuccess())
              {
                 IDOrErrorMsg = sr.getId() + '\n'; 
              }
             else
             {
               For(Database.Error err :sr.getErrors())
                 {
                   IDOrErrorMsg = IDOrErrorMsg + err.getStatusCode() + ': ' + err.getMessage() + '\n';
                 }
             }
          }
      
     
  system.debug('accountsDeserialized=' + accountsDeserialized);
  return IDOrErrorMsg ;
  
  }
 
 }