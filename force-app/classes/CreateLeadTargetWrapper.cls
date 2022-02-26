public class CreateLeadTargetWrapper{

public class OAuth2 {
     public String id{get;set;}
     public String issued_at{get;set;}
     public String instance_url{get;set;}
     public String signature{get;set;}
     public String access_token{get;set;}
}

 @future(callout=true)  
    public static void createLeadInTarget(String jsonString){
        
        string LOGIN_DOMAIN='https://trainingorg3-dev-ed.my.salesforce.com'; 
        //string  userName='amergysolarinc.qa@yopmail.com.qa';
        //string  pwd='SunRun100!lEJPfE1O8w40iGenvw3mBFzI';
        
        string  userName='trainingorg3@org.com';
        string  pwd='Salesforce004$Q1t988dycNfV7YtBCpshvJNvL';
        
        // Login via SOAP/XML web service api
        //-----------------------------------
        HttpRequest request = new HttpRequest();
        request.setEndpoint(LOGIN_DOMAIN + '/services/Soap/u/22.0');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'text/xml;charset=UTF-8');
        request.setHeader('SOAPAction', '""');
        //not escaping username and password because we're setting those variables above
        //in other words, this line "trusts" the lines above
        //if username and password were sourced elsewhere, they'd need to be escaped below
        request.setBody('<Envelope xmlns="http://schemas.xmlsoap.org/soap/envelope/"><Header/><Body><login xmlns="urn:partner.soap.sforce.com"><username>' + userName+ '</username><password>' + pwd+ '</password></login></Body></Envelope>');
        system.debug('&&&&&'+request.getBody());
        HttpResponse resp=(new Http()).send(request);
        system.debug('&&&&&'+resp.getBody());
        Dom.XmlNode resultElmt = (new Http()).send(request).getBodyDocument().getRootElement().getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/').getChildElement('loginResponse', 'urn:partner.soap.sforce.com').getChildElement('result', 'urn:partner.soap.sforce.com');
        system.debug('&&&&&'+resultElmt);
        //-------------------------------
        // Grab session id and server url
        //--------------------------------
        final String SERVER_URL = resultElmt.getChildElement('serverUrl', 'urn:partner.soap.sforce.com') .getText().split('/services')[0];
        final String SESSION_ID = resultElmt.getChildElement('sessionId', 'urn:partner.soap.sforce.com') .getText();
        system.debug('&&&&&'+SESSION_ID+'*********'+SERVER_URL);
        
        
       if(SESSION_ID !=null){
          Http h1 = new Http();
          HttpRequest req1 = new HttpRequest();
          req1.setHeader('Authorization','OAuth '+SESSION_ID);
          req1.setHeader('Content-Type','application/json');
          //req1.setHeader('accept','application/json');
          system.debug('***JSONSTRING****'+jsonString);
          jsonString=jsonString.trim();
          List<Lead> leadObj = (List<Lead>)System.JSON.deserialize(jsonString,List<Lead>.class);          
          List<Lead> tempList=new List<Lead>();
          Lead finalLd;
          List<Records> leadWrapperList=new List<Records>();
          Attributes atr;
          Integer count=1;
          for(Lead ld : leadObj ){
                count=count++;
                finalLd=new Lead();
                finalLd.firstname=ld.firstName;
                finalLd.lastName=ld.lastName;
                finalLd.company=ld.company;
                finalLd.status=ld.status;
                tempList.add(finalLd);
                atr=new Attributes('Lead','ref'+count);
                leadWrapperList.add(new Records(ld.firstName,ld.lastName,ld.company,ld.status,atr));
            }
            atr=new Attributes('Lead','ref'+'2');
            leadWrapperList.add(new Records(leadObj[0].firstName,leadObj[0].lastName,leadObj[0].company,leadObj[0].status,atr));            
          JSONGenerator js = JSON.createGenerator(true);
          js.writeStartObject();
          js.writeFieldName('records');
          js.writeStartArray();
                for(Records ld1 : leadWrapperList){
                    js.writeStartObject();
                         js.writeFieldName('attributes');
                         js.writeStartObject();
                             js.writeStringField('type',ld1.attributesValue.type);
                             js.writeStringField('referenceId',ld1.attributesValue.referenceid);
                         js.writeEndObject();              
                     js.writeStringField('FirstName',ld1.firstname);
                     js.writeStringField('lastName',ld1.lastname);
                     js.writeStringField('company',ld1.company);
                     js.writeStringField('status',ld1.status);                     
                     js.writeEndObject();                     
                }          
          js.writeEndArray();
          js.writeEndObject();   
          string jsonString1=js.getAsString();
          //string jsonString2= toJsonString(leadWrapperList);
system.debug('*******'+jsonString1);          
          req1.setBody(jsonString1); 
          req1.setMethod('POST');      
          req1.setEndpoint(SERVER_URL+'/services/data/v37.0/composite/tree/Lead');
          system.debug('***req1.getBody()****'+req1.getBody());         
          HttpResponse res1 = h1.send(req1);
          system.debug('RESPONSE_BODY'+res1.getbody());
        }
       }
       public class Records{
           public string firstname;
           public string lastName;
           public string company;
           public string status;
           public Attributes attributesValue;           
       
           public Records(string firstname,string lastName,string company,string status,Attributes attributesValue){
                this.firstname=firstname;
                this.lastName=lastName;
                this.company=company;
                this.status=status;
                this.attributesValue=attributesValue;
           }
       }
       public class Attributes {
            public String type {get;set;} // in json: type
            public String referenceId {get;set;}
            public Attributes(String type,String referenceId){
                 this.type=type;
                 this.referenceId=referenceId;
            }           
       }
   /* private static String toJsonString(Message m) {
        return JSON.serializePretty(m);
    }*/
}