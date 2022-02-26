global class LoginANDCaseInsertFlow{

    String LOGIN_DOMAIN = 'https://login.salesforce.com'; //provide domain name or URL address here , example https://login.salesforce.com
    public String pwd{get;set;}
    public String userName{get;set;}
        
    global void loginSOAP(){
        
        //-----------------------------------
        userName='trainingorg3@org.com';
        pwd='Salesforce005$3ZYBJOodxW0MMLpBjPlEPEsY0';
         //provide username here
          //provide password here along with Security Token

        // Login via SOAP/XML web service api
        //-----------------------------------
        HttpRequest request = new HttpRequest();
        request.setEndpoint(LOGIN_DOMAIN + '/services/Soap/u/22.0');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'text/xml;charset=UTF-8');
        request.setHeader('SOAPAction', '""');            
        request.setBody('<Envelope xmlns="http://schemas.xmlsoap.org/soap/envelope/"><Header/><Body><login xmlns="urn:partner.soap.sforce.com"><username>' + userName+ '</username><password>' + pwd+ '</password></login></Body></Envelope>');
        system.debug('&&req&&&'+request.getBody());
        HttpResponse resp=(new Http()).send(request);
        system.debug('&&res&&&'+resp.getBody());
        
         Dom.XmlNode resultElmt = (new Http()).send(request).getBodyDocument().getRootElement().getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/').getChildElement('loginResponse', 'urn:partner.soap.sforce.com').getChildElement('result', 'urn:partner.soap.sforce.com');
         system.debug('&&&&&'+resultElmt);
        //-------------------------------

        // Grab session id and server url
        //--------------------------------
        final String SERVER_URL = resultElmt.getChildElement('serverUrl', 'urn:partner.soap.sforce.com') .getText().split('/services')[0];
        final String SESSION_ID = resultElmt.getChildElement('sessionId', 'urn:partner.soap.sforce.com') .getText();
        
        if(SESSION_ID !=null && SESSION_ID !=''){
            request = new HttpRequest();
            request.setEndpoint('https://trainingorg3-dev-ed.my.salesforce.com/services/apexrest/InsertCaseRec/'); // This is the Custom Rest Service Sample Class we have written 
            request.setHeader('Content-Type','application/json');
            request.setHeader('Authorization', 'OAuth ' + SESSION_ID);
             String JSONString='{ '+
                                  '  "records" :[{ '+
                                  '              "attributes" : {"type" : "Case", "referenceId" : "ref1"}, '+
                                  '              "Status" : "New", '+
                                   '             "Origin" : "Web"} '+
                                   '             ,{ '+
                                    '            "attributes" :  {"type" : "Case", "referenceId" : "ref4"}, '+
                                     '           "Status" : "New", '+
                                      '          "Origin" : "Web" '+
                                      '       }] '+
                                    ' }';                
            request.setbody(JSONString); // Place to pass JSON
            request.setMethod('POST');
            string reqbody=request.getbody();
            String body = (new Http()).send(request).getBody();
            system.debug('##'+body);
            system.debug('##'+reqbody);
        }
    }
}