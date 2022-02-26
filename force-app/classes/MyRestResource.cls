@RestResource(urlMapping='/LeadInsert/*')

global with sharing class MyRestResource {
   @HttpGet
     global static String doGet(){
     RestRequest req = RestContext.request;
      String firstname = req.params.get('firstname');
      String lastname = req.params.get('lastname');
      String phone = req.params.get('phone');
      String email = req.params.get('email');
      String company = req.params.get('company');
      Lead ld = new Lead();
      ld.firstname=firstname;
      ld.lastname=lastname;
      ld.phone=phone;
      ld.email=email;
      ld.company=company;
      Insert ld;
      Return ''+ld.Id;
    
    } 
    
}