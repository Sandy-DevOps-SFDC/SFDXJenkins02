public class AccountToOpportunityFlow {

 public Account acc{get;set;}
 public Contact con {get;set;}
 public Opportunity opp{get;set;}

 public AccountToOpportunityFlow(){
  acc= new Account();
  con = new Contact();
  opp = new Opportunity();

 }

  public PageReference Cancel() {
    PageReference accOppPage = new PageReference('/apex/accountToOpportunityFlow');
    accOppPage.setRedirect(true);
    return accOppPage; 
  }


    public PageReference Save(){
     try{
      if(acc.Name !=null && acc.Name !=''){
        insert acc;
       }
       if(acc.id !=null && con.LastName !=null && con.lastName !=''){
         con.AccountId = acc.id;
         insert con;
       }
       if(acc.id !=null && opp.name !=null && opp.name !=''){
         opp.AccountId = acc.id;
        insert opp;
       }       
     
     }Catch(Exception e){
      system.debug('Exception occurred...'+e);
     }
      
     return null;
    }


}