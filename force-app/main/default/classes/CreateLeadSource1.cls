public class CreateLeadSource1{

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
          //req1.setHeader('accept','application/json');
          system.debug('***JSONSTRING****'+jsonString);
          jsonString=jsonString.trim();
          List<Lead> leadObj = (List<Lead>)System.JSON.deserialize(jsonString,List<Lead>.class);          
          List<Lead> tempList=new List<Lead>();
          Lead finalLd;
          for(Lead ld : leadObj ){
                finalLd=new Lead();
                finalLd.firstname=ld.firstName;
                finalLd.lastName=ld.lastName;
                finalLd.company=ld.company;
                finalLd.status=ld.status;
                tempList.add(finalLd);
            }            
          JSONGenerator js= JSON.createGenerator(true);
          js.writeStartObject();
            for(lead ld1 : templist){
                js.writeStringField('FirstName',ld1.firstname);
                 js.writeStringField('lastName',ld1.lastname);
                  js.writeStringField('company',ld1.company);
                   js.writeStringField('status',ld1.status);
            }          
          js.writeEndObject();
          string jsonString1=js.getAsString();          
          req1.setBody(jsonString1); 
          //req1.setBody('{"FirstName":"Standard Rest URI","LastName":"Lead 15","Company":"ACD","Status":"Open - Not Contacted"}');        
          req1.setMethod('POST');        
           
          req1.setEndpoint('https://trainingorg3-dev-ed.my.salesforce.com/services/data/v37.0/sobjects/Lead');
          system.debug('***req1.getBody()****'+req1.getBody());         
          HttpResponse res1 = h1.send(req1);
          //system.debug('RESPONSE_BODY'+res1.getbody());
        }
    }
}