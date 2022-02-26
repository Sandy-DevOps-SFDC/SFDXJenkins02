public class CreateLeadTargetYathi{


 @future(callout=true)  
    public static void createLeadInTarget(String jsonString){
        
        final String SERVER_URL;
        final String SESSION_ID;
        string LOGIN_DOMAIN='cs3.salesforce.com';               
         string  userName='amergysolarinc.qa@yopmail.com.qa';
        string  pwd='SunRun100!lEJPfE1O8w40iGenvw3mBFzI';
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://' + LOGIN_DOMAIN + '/services/Soap/u/22.0');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'text/xml;charset=UTF-8');
        request.setHeader('SOAPAction', '""');
        request.setBody('<Envelope xmlns="http://schemas.xmlsoap.org/soap/envelope/"><Header/><Body><login xmlns="urn:partner.soap.sforce.com"><username>' + userName+ '</username><password>' + pwd+ '</password></login></Body></Envelope>');
        system.debug('&&&&&'+request.getBody());
        Http h = new Http();
        HttpResponse resp=new HttpResponse();
            resp=h.send(request);        
        system.debug('&&&response23&&&&'+resp.getBody());
        Dom.XmlNode resultElmt = (new Http()).send(request).getBodyDocument().getRootElement().getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/').getChildElement('loginResponse', 'urn:partner.soap.sforce.com').getChildElement('result', 'urn:partner.soap.sforce.com');
        system.debug('&&&&&'+resultElmt);
        SERVER_URL = resultElmt.getChildElement('serverUrl', 'urn:partner.soap.sforce.com') .getText().split('/services')[0];
        SESSION_ID = resultElmt.getChildElement('sessionId', 'urn:partner.soap.sforce.com') .getText();
        system.debug('&&&&&'+SESSION_ID);
        
        
       if(SESSION_ID !=null){
          Http h1 = new Http();
          HttpRequest req1 = new HttpRequest();
          req1.setHeader('Authorization','OAuth '+SESSION_ID);
          req1.setHeader('Content-Type','application/json');
          req1.setHeader('accept','application/json');
          system.debug('***JSONSTRING****'+jsonString);
          jsonString=jsonString.trim();
          List<Lead> leadObj = (List<Lead>)System.JSON.deserialize(jsonString,List<Lead>.class);          
          List<Lead> tempList=new List<Lead>();
          Lead finalLd;
          for(Lead ld : leadObj ){
                finalLd=new Lead();
                finalLd.firstname=ld.firstName;
                finalLd.lastName=ld.lastName;
                finalLd.street=ld.street;
                finalLd.city=ld.city;
                finalLd.State=ld.State; 
                finalLd.PostalCode=ld.PostalCode;
                finalld.phone=ld.phone;
                finalld.email=ld.email;
                /*finalld.ID=ld.ID;
                finalLd.Home_Type__c=ld.Home_Type__c;
                finalLd.ExternalSource__c=ld.ExternalSource__c;
                finalLd.SalesRep__c=ld.SalesRep__c;
                finalld.LeadSource=ld.LeadSource;
                finalld.Lead_Channel__c=ld.Lead_Channel__c;
                finalld.Sales_Rep_Email__c= ld.Sales_Rep_Email__c;*/
              
                finalLd.company=ld.company;
              
             
                tempList.add(finalLd);
            }            
          JSONGenerator js= JSON.createGenerator(true);
          js.writeStartObject();
            for(lead ld1 : templist){
                js.writeStringField('customerFirstName',ld1.firstname);
                 js.writeStringField('customerLastName',ld1.lastname);
                  js.writeStringField('customerStreet',ld1.street);
                   js.writeStringField('customerCity',ld1.city);
                    js.writeStringField('customerState',ld1.State);
                     js.writeStringField('customerZipCode',ld1.PostalCode);
                      js.writeStringField('customerPrimayPhone',ld1.phone);
                       js.writeStringField('customerEmail',ld1.email);
                        /*js.writeStringField('externalLeadId',ld1.ID);
                         js.writeStringField('homeType',ld1.Home_Type__c);
                          js.writeStringField('externalSource',ld1.ExternalSource__c);
                           js.writeStringField('salesRep',ld1.SalesRep__c); 
                            js.writeStringField('LeadSource',ld1.LeadSource);
                             js.writeStringField('Lead_Channel__c',ld1.Lead_Channel__c);
                              js.writeStringField('salesRepEmail',ld1.Sales_Rep_Email__c);*/
                             
                        js.writeStringField('company',ld1.company); 
                  
            }          
          js.writeEndObject();
          string jsonString1=js.getAsString();
          system.debug('***jsonString1**'+jsonString1);          
          req1.setBody(jsonString1); 
          
          req1.setMethod('POST');        
          
          req1.setEndpoint('https://cs3.salesforce.com/services/apexrest/v2/leads');
          system.debug('***req1.getBody()****'+req1.getBody());
          HttpResponse res1 = new HttpResponse();
          if ( !Test.isRunningTest() ) {
               res1 = h1.send(req1);
          }
          system.debug('RESPONSE_BODY'+res1.getbody());  
        }
            
}
}