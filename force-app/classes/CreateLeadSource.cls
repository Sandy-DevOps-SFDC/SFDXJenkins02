public class CreateLeadSource{

public class OAuth2 {
     public String id{get;set;}
     public String issued_at{get;set;}
     public String instance_url{get;set;}
     public String signature{get;set;}
     public String access_token{get;set;}
}

 @future(callout=true)  
    public static void createLeadInTarget(String jsonString){
        String clientId = '3MVG9YDQS5WtC11q8ZaYuoGuRjB25ugsIuj3XQpZXf4nbLNk9bMnn2FUO0IX.YY0Dc9eIuy5bGfl5VsJXPe9.';
        String clientSecret = '2203565722242696234';
        String username='trainingorg3@org.com';
        String password='Salesforce004$Q1t988dycNfV7YtBCpshvJNvL';
        String reqbody = 'grant_type=password&client_id='+clientId+'&client_secret='
                         +clientSecret+'&username='+username+'&password='+password;

        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setBody(reqbody);
        req.setMethod('GET');
        //Note if my domain is set up use the proper domain name else use login.salesforce.com 
        //for prod or developer or test.salesforce.com for sandbox instance
        req.setEndpoint('https://login.salesforce.com/services/oauth2/token');
        HttpResponse res = h.send(req);
        OAuth2 objAuthenticationInfo = (OAuth2)JSON.deserialize(res.getbody(), OAuth2.class);
       
        if(objAuthenticationInfo.access_token!=null){
          Http h1 = new Http();
          HttpRequest req1 = new HttpRequest();
          req1.setHeader('Authorization','Bearer '+objAuthenticationInfo.access_token);
          req1.setHeader('Content-Type','application/json');
          req1.setHeader('accept','application/json');
          system.debug('***JSONSTRING****'+jsonString);
          req1.setBody(jsonString);         
          req1.setMethod('POST');
          //String jsonString=JSON.serialize(listLeads);
          //URL will be your Salesforce REST API end point where you will do POST,PUT,DELETE orGET
          req1.setEndpoint('https://ap4.salesforce.com/services/apexrest/V1/LeadCreate/');
          system.debug('***req1.getBody()****'+req1.getBody());         
          system.debug('***req1****'+req1);
          HttpResponse res1 = h1.send(req1);
          system.debug('RESPONSE_BODY'+res1.getbody());
        }
    }
}