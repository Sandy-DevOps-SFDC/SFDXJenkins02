public class ContactListController{
   public List<Contact> contacts{get;set;}
   public string contactId{get;set;}
   public ContactListController(){   
      contacts =[select id,firstname,lastname from contact limit 10];
   }
   
   public pageReference gotoContactDetailPage(){
         return new pageReference('/'+contactid);
   }
   
}