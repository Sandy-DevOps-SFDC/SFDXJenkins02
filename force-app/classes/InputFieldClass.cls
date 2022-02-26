public with sharing class InputFieldClass {
public account acc{get;set;}

    public InputFieldClass() {
          acc=new Account();
    }
    
    public pagereference CreateAccount(){       
       acc.Name='Test10';
       acc.SLA__c=apexpages.currentpage().getparameters().get('paramName');
       insert acc;       
       pagereference p = new pagereference('/' + acc.id);
       p.setRedirect(true);       
       return p;
    }
}