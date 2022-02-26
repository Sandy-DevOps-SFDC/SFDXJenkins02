public with sharing class GoogleConnect {
    public string valueToShow{get;set;} 
    private final string googleClientID = '84669277096-p11oefns7r8j98h9lr0efv4fmo8pg4is.apps.googleusercontent.com';
    private final string googleSecretCode = 'awsyQfWKPthmZEFF_6AFQkF8';
    private final string redirectURI = 'https://c.na9.visual.force.com/apex/googleconnect';
    private final string ENTRY = 'entry';
    private final string SPREADSHEET_UPDATE = 'SpreadsheetUpdate';
    private final string CREATE_CONTACT = 'CreateContact';
    private final string UPDATE_CALENDAR = 'UpdateCalendar';
    private string authorizationCode = '';
    private string state = '';
    private string accessToken;
    private string refreshToken;
    private string expiresIn;
    private string tokenType;
        
    public GoogleConnect(){
        valueToShow = '<Press Button To Try>';
        //Check if we received the authorization code from Google because the redirectUI
        authorizationCode = System.currentPageReference().getParameters().get('code');
        if(authorizationCode == null || authorizationCode == ''){
            valueToShow = '<Press Button To Try - No Authorization Code Yet>';          
        }else{
            state = System.currentPageReference().getParameters().get('state');
            valueToShow = '<We have an Authorization Code>';
            accessToken = '';
            if(state == SPREADSHEET_UPDATE){
                retrieveGoogleAccessToken();
                if(accessToken <> ''){
                    setGoogleSpreadSheetCellValue();
                }
                valueToShow = '<Update Google Spreadsheet Complete>';
            }else if(state == CREATE_CONTACT){
                retrieveGoogleAccessToken();
                if(accessToken <> ''){
                    addContact();
                }
                //valueToShow = '<Add Contact Complete>';
            }else if(state == UPDATE_CALENDAR){
                retrieveGoogleAccessToken();
                if(accessToken <> ''){
                    addCalendarEntry();
                }
                //valueToShow = '<Add Calendar Entry Complete>';
            }else{
                valueToShow = '<We have an Authorization Code, but the state value is not valid>';
            }
                        
        }
    }
    
    public pageReference updateSpreadsheet(){ //Called from Button      
        return DoGoogleConnectCall(SPREADSHEET_UPDATE);
    }   
    
    public pageReference createContact(){ //Called from Button      
        return DoGoogleConnectCall(CREATE_CONTACT);
    }
    
    public pageReference updateCalendar(){ //Called from Button     
        return DoGoogleConnectCall(UPDATE_CALENDAR);
    }
    
    //This call must be done before all Google API actions to get the authorization code
    //This will prompt the user to log into Google and it will also prompt for permissions as needed
    private pageReference DoGoogleConnectCall(string stateValue){
       
        PageReference pr = new PageReference('https://accounts.google.com/o/oauth2/auth' +
            '?response_type=code' +
            '&client_id=' + googleClientID + 
            '&redirect_uri=' + redirectURI +
            '&scope=https%3A%2F%2Fspreadsheets.google.com%2Ffeeds+https%3A%2F%2Fdocs.google.com%2Ffeeds+https%3A%2F%2Fwww.google.com%2Fm8%2Ffeeds+https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fcalendar' +
            '&state=' + stateValue + 
            '&access_type=online' +
            '&approval_prompt=auto' +  //auto, force
            '&login_hint=santoshmohanty1@gmail.com');
        return pr;
    }
    
    private void retrieveGoogleAccessToken(){
       
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        string endPointValue = 'https://accounts.google.com/o/oauth2/token';    
        req.setEndpoint(endPointValue);
        
        string bodyRequest = '';
        bodyRequest = 'code=' + EncodingUtil.urlEncode(authorizationCode, 'UTF-8');
        bodyRequest += '&client_id=' + EncodingUtil.urlEncode(googleClientID, 'UTF-8');
        bodyRequest += '&client_secret=' + EncodingUtil.urlEncode(googleSecretCode, 'UTF-8');
        bodyRequest += '&redirect_uri=' + EncodingUtil.urlEncode(redirectURI, 'UTF-8');
        bodyRequest += '&grant_type=authorization_code';
        req.setBody(bodyRequest);       
        req.setHeader('Content-length', string.ValueOf(bodyRequest.length()));  
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setMethod('POST');
        req.setTimeout(10000);
        HttpResponse res = h.send(req);     
        map<string, string> jsonValues = new map<string, string>();
        valueToShow = res.getBody();

        jsonValues = parseJSONToMap(res.getBody());
        if(jsonValues.containsKey('error')){
            //Just some debug lines to see the request and response
            valuetoShow = 'Get Access Token Error: ' + res.getBody() + ' end point value: ' + endPointValue + 'request: ' +
                req.toString() + 'request headers: ' + req.getHeader('Content-Type') + '; ' + req.getHeader('charset') + 
                'request body: ' + req.getBody();           
        }else{
            //Try to get a cell value in the Google Spreadsheet
            accessToken = jsonValues.get('access_token');
            refreshToken = jsonValues.get('refresh_token');
            expiresIn = jsonValues.get('expires_in');
            tokenType = jsonValues.get('token_type');           
        }       
    }
    
    //Appendix 2 - SECTION START: The routines below here relate to setting the value of a cell in a Google Spreadsheet
    private void setGoogleSpreadSheetCellValue(){
        SpreadSheetEntry ssEItem;
        //First get the information about the spreadsheet we want to update
        ssEItem = getGoogleSpreadSheetEntry('Salesforce Opportunity Report');
        
        string cellsFeedEdit = '';
        cellsFeedEdit = getGoogleSpreadSheetWorksheetFeed(ssEItem.worksheetsFeed);
        //These values like Worksheet Name, New Value, Column and Row should be saved in a custom setting
        string maxValue = getMaxOpportunityValue();
        setGoogleSpreadSheetValue(cellsFeedEdit, ssEItem.IDValue, ssEItem.WorksheetID, ssEItem.KeyValue, maxValue, 'R1C2', '1', '2');           
    }
    
    private string getMaxOpportunityValue(){
        string maxValue = '';
        list<AggregateResult> arList = new list<AggregateResult>();
        arList = [SELECT MAX(Amount)
                    FROM Opportunity];
        for (AggregateResult ar : arList)  {
            maxValue = string.ValueOf(ar.get('expr0'));
        }
        return maxValue;
    }
    
    private SpreadSheetEntry getGoogleSpreadSheetEntry(string spreadSheetName){     
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        string endPointValue = 'https://spreadsheets.google.com/feeds/spreadsheets/private/full';       
        req.setEndpoint(endPointValue); 
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setMethod('GET');
        req.setTimeout(10000);
        HttpResponse res = h.send(req);
        
        //Now we could parse through the XML and get the values that we want
        string tempID = '';
        XmlStreamReader reader = new XmlStreamReader(res.getBody());
        list<SpreadSheetEntry> ssEList = parseSpreadSheetEntry(reader);
        SpreadSheetEntry ssEItemReturn;
        for(SpreadSheetEntry ssEItem : ssEList){
            if(ssEItem.Title == spreadSheetName){
                ssEItemReturn = ssEItem;
            }
        }
        return ssEItemReturn;
                    
    }
    
           
    private string getGoogleSpreadSheetWorksheetFeed(string worksheetFeedURL){  
        //This is only needed to get the URL for the cells feed 
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        string endPointValue = worksheetFeedURL;        
        req.setEndpoint(endPointValue); 
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setMethod('GET');
        req.setTimeout(10000);
        HttpResponse res = h.send(req); 
        
        XmlStreamReader reader = new XmlStreamReader(res.getBody());
        list<SpreadSheetEntry> ssEList = parseSpreadSheetEntry(reader);
        string cellsFeed;
        for(SpreadSheetEntry ssEItem : ssEList){
            cellsFeed = ssEItem.cellsFeed;
        }
        string cellsFeedEdit;
        if(cellsFeed <> null){
            if(cellsFeed.length() > 0){
                cellsFeedEdit = getGoogleSpreadSheetCellFeed(cellsFeed);
            }
        }
        return cellsFeedEdit;
    }
    
       
        
    private string getGoogleSpreadSheetCellFeed(string cellFeedURL){        
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        //System.LimitException: Apex heap size too large: 6155590 (Got this error with return-empty=true and no range parameter);
        //Without the return-empty=true any blank cells will not be returned.   This range could be saved in a custom setting.
        string endPointValue = cellFeedURL + '?return-empty=true&range=R1C1:R3C3';      
        req.setEndpoint(endPointValue); 
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setMethod('GET');
        req.setTimeout(10000);
        HttpResponse res = h.send(req);
        valueToShow = 'Cell Feed Values: ' + res.getBody(); 
        
        XmlStreamReader reader = new XmlStreamReader(res.getBody());
        list<SpreadSheetEntry> ssEList = parseSpreadSheetEntry(reader);
        string cellsFeedEdit;
        for(SpreadSheetEntry ssEItem : ssEList){
            //The cell to fill could be saved in a custom setting for more control
            if(ssEItem.Title == 'B1'){          
            //Another way to find the cell to update would be to place some specific text like '-FILL_HERE-' in it.
            //if(ssEItem.currentContent == '-FILL_HERE-'){
                valueToShow += 'Cell Feed Values editURL: ' + ssEItem.editURL;  
                cellsFeedEdit = ssEItem.editURL;
            }           
        }
        return cellsFeedEdit;
        
    }
   
    
    //Finally set the new value in the spreadsheet
    private void setGoogleSpreadSheetValue(string cellsFeedEdit, string IDValue, string worksheetID, 
        string keyValue, string newValue, string cellName, string row, string column){
        //cellsFeedEdit is like: https://spreadsheets.google.com/feeds/cells/key/worksheetId/private/full/R2C4
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        string endPointValue = cellsFeedEdit;
        req.setEndpoint(endPointValue);     
        string bodyRequest = '';
        bodyRequest = '<entry xmlns="http://www.w3.org/2005/Atom" xmlns:gs="http://schemas.google.com/spreadsheets/2006">';
        bodyRequest += '<id>' + endPointValue + '</id>';
        bodyRequest += '<link rel="edit" type="application/atom+xml" href="' + endPointValue + '"/>';
        bodyRequest += '<gs:cell row="' + row + '" col="' + column + '" inputValue="' + newValue + '"/>';
        bodyRequest += '</entry>';
        req.setBody(bodyRequest);       
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setHeader('Content-length', string.ValueOf(bodyRequest.length()));  
        req.setHeader('Content-Type', 'application/atom+xml');
        req.setMethod('PUT');
        req.setTimeout(10000);
        HttpResponse res = h.send(req);
    }
    
    //Appendix 3 - SECTION START: Below here is all the code to interact with the Contact API
    private void addContact(){
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        string endPointValue = 'https://www.google.com/m8/feeds/contacts/terryluschen@gmail.com/full';
        req.setEndpoint(endPointValue);     
        string bodyRequest = '';
        
        bodyRequest = '<atom:entry xmlns:atom="http://www.w3.org/2005/Atom" xmlns:gd="http://schemas.google.com/g/2005">';
        bodyRequest += '<atom:category scheme="http://schemas.google.com/g/2005#kind" term="http://schemas.google.com/contact/2008#contact"/>';
        bodyRequest += '<gd:name>';
        bodyRequest += '<gd:givenName>NewFirstAPI</gd:givenName>';
        bodyRequest += '<gd:familyName>NewLastAPI</gd:familyName>';
        bodyRequest += '<gd:fullName>NewFirstAPI NewLastAPI</gd:fullName>';
        bodyRequest += '</gd:name>';
        bodyRequest += '<atom:content type="text">This is for the Notes field</atom:content>';
        bodyRequest += '<gd:email rel="http://schemas.google.com/g/2005#work" primary="true" address="workEmail@gmail.com" displayName="N. New"/>';
        bodyRequest += '<gd:email rel="http://schemas.google.com/g/2005#home" address="homeEmail@example.org"/>';
        bodyRequest += '<gd:phoneNumber rel="http://schemas.google.com/g/2005#work" primary="true">(222)222-2222</gd:phoneNumber>';
        bodyRequest += '<gd:phoneNumber rel="http://schemas.google.com/g/2005#home">(333)333-3333</gd:phoneNumber>';
        bodyRequest += '<gd:im address="workEmail@gmail.com" protocol="http://schemas.google.com/g/2005#GOOGLE_TALK" primary="true" rel="http://schemas.google.com/g/2005#home"/>';
        bodyRequest += '<gd:structuredPostalAddress rel="http://schemas.google.com/g/2005#work" primary="true">';
        bodyRequest += '<gd:city>Fargo</gd:city>';
        bodyRequest += '<gd:street>1800 1st Street South</gd:street>';
        bodyRequest += '<gd:region>ND</gd:region>';
        bodyRequest += '<gd:postcode>58103</gd:postcode>';
        bodyRequest += '<gd:country>United States</gd:country>';
        bodyRequest += '<gd:formattedAddress>1800 1st Street South Fargo</gd:formattedAddress>';
        bodyRequest += '</gd:structuredPostalAddress>';
        bodyRequest += '</atom:entry>';
                    //</pre>
        req.setBody(bodyRequest);       
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setHeader('Content-length', string.ValueOf(bodyRequest.length()));  
        req.setHeader('Content-Type', 'application/atom+xml');
        req.setHeader('GData-Version', '3.0');
        req.setMethod('POST');
        req.setTimeout(10000);
        HttpResponse res = h.send(req);
        valueToShow += 'Create Contact Response: ' + res.getBody(); 
    }
    
   
    //Appendix 4 - SECTION START: Below here is all the code to interact with the Calendar API
    private void addCalendarEntry(){
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        string endPointValue = 'https://www.googleapis.com/calendar/v3/calendars/primary/events';
        //This end point does seem to work, but it is not creating an event, just creating a new calendar
        //endPointValue = 'https://www.googleapis.com/calendar/v3/calendars?key=' + googleClientID;
        req.setEndpoint(endPointValue);     
        string bodyRequest = '';
        bodyRequest = '{';
        bodyRequest += '\r\n';
        bodyRequest += '"summary": "Sales Call",';
        bodyRequest += '\r\n';
        bodyRequest += '"location": "Conference Room A",';
        bodyRequest += '\r\n';
        bodyRequest += '"start": {';
        bodyRequest += '\r\n';
        bodyRequest += '"dateTime": "2017-06-01T11:00:00.000-07:00",';
        bodyRequest += '\r\n';
        bodyRequest += '"timeZone": "America/Los_Angeles"';
        bodyRequest += '\r\n';
        bodyRequest += '},';
        bodyRequest += '\r\n';
        bodyRequest += '"end": {';
        bodyRequest += '\r\n';
        bodyRequest += '"dateTime": "2017-06-01T11:30:00.000-07:00",';
        bodyRequest += '\r\n';
        bodyRequest += '"timeZone": "America/Los_Angeles"';
        bodyRequest += '\r\n';
        bodyRequest += '},'; 
        bodyRequest += '\r\n';
        bodyRequest += '"recurrence": [';
        bodyRequest += '\r\n';
        bodyRequest += '"RRULE:FREQ=WEEKLY;UNTIL=20131226T000000Z"';
        bodyRequest += '\r\n';
        bodyRequest += '],';        
        bodyRequest += '\r\n';
        bodyRequest += '"attendees": [';
        bodyRequest += '\r\n';
        bodyRequest += '{';
        bodyRequest += '\r\n';
        bodyRequest += '"email": "santoshmohanty1@gmail.com"';
        bodyRequest += '\r\n';
        bodyRequest += '}';
        bodyRequest += '\r\n';
        bodyRequest += ']'; 
        bodyRequest += '}';
        
        req.setBody(bodyRequest);       
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setHeader('Content-length', string.ValueOf(bodyRequest.length()));  
        req.setHeader('Content-Type', 'application/json; charset=UTF-8');
        req.setMethod('POST');
        req.setTimeout(10000);
        HttpResponse res = h.send(req);
        valueToShow = 'Create Calendar Body Request: ' + bodyRequest;
        valueToShow += 'Create Calendar Response: ' + res.getBody();    
    }
    
    
    
    //SECTION START: Below here is all the code to parse JSON and XML
    //Parse JSON
    private map<string, string> parseJSONToMap(string JSONValue){
        JSONParser parser = JSON.createParser(JSONValue);
        map<string, string> jsonMap = new map<string, string>();
        string keyValue = '';
        string tempValue = '';
        while (parser.nextToken() != null) {
            if(parser.getCurrentToken() == JSONToken.FIELD_NAME){
                keyValue = parser.getText();
                parser.nextToken();
                tempValue = parser.getText();
                jsonMap.put(keyValue, tempValue);               
            }
        }
        return jsonMap;
    }
        
    //Parse XML
    list<SpreadSheetEntry> parseSpreadSheetEntry(XmlStreamReader reader) {
         list<SpreadSheetEntry> spreadSheetEntryList = new list<SpreadSheetEntry>();
         while(reader.hasNext()) {    
             if (reader.getEventType() == XmlTag.START_ELEMENT) {
                if (ENTRY == reader.getLocalName()) {
                    SpreadSheetEntry ssE = parseEntry(reader);
                    spreadSheetEntryList.add(ssE);
                }
             }
            reader.next();
         }
        return spreadSheetEntryList;
    }
   
    SpreadSheetEntry parseEntry(XmlStreamReader reader) {
         string typeValue = '';
         string hrefValue = '';
         string relValue = '';
         SpreadSheetEntry ssE = new SpreadSheetEntry();
         integer index;
         
         while(reader.hasNext()) {
            if (reader.getEventType() == XmlTag.END_ELEMENT) {
                if (ENTRY == reader.getLocalName()) {
                    break;  
                }   
            }
            if (reader.getEventType() == XmlTag.START_ELEMENT) {
                if ('ID' == reader.getLocalName()) {
                    reader.next();
                    if (reader.getEventType() == XmlTag.CHARACTERS) {
                        ssE.IDValue = reader.getText();
                        index = ssE.IDValue.indexOf('full/');
                        if(index > 0){
                            ssE.WorksheetID = ssE.IDValue.substring(index + 5);
                        }
                    }
                }   
                if ('content' == reader.getLocalName()) {
                    reader.next();
                    if (reader.getEventType() == XmlTag.CHARACTERS) {
                        ssE.currentContent = reader.getText();
                    }
                }   
                if ('title' == reader.getLocalName()) {
                    reader.next();
                    if (reader.getEventType() == XmlTag.CHARACTERS) {
                        ssE.Title = reader.getText();
                    }
                }   
                if ('link' == reader.getLocalName()) {
                    typeValue = reader.getAttributeValue(null, 'type');
                    relValue = reader.getAttributeValue(null, 'rel');
                    if(typeValue == 'text/html' && relValue == 'alternate'){
                        hrefValue = reader.getAttributeValue(null, 'href');
                        index = hrefValue.indexOf('key=');
                        if(index > 0){
                            ssE.KeyValue = hrefValue.substring(index + 4);
                        }
                    }               
                }   
                if ('link' == reader.getLocalName()) {
                    typeValue = reader.getAttributeValue(null, 'type');
                    relValue = reader.getAttributeValue(null, 'rel');
                    if(typeValue == 'application/atom+xml' && relValue == 'http://schemas.google.com/spreadsheets/2006#worksheetsfeed'){
                        hrefValue = reader.getAttributeValue(null, 'href');
                        ssE.worksheetsFeed = hrefValue;                 
                    }               
                }   
                if ('link' == reader.getLocalName()) {
                    typeValue = reader.getAttributeValue(null, 'type');
                    relValue = reader.getAttributeValue(null, 'rel');
                    if(typeValue == 'application/atom+xml' && relValue == 'http://schemas.google.com/spreadsheets/2006#cellsfeed'){
                        hrefValue = reader.getAttributeValue(null, 'href');
                        ssE.cellsFeed = hrefValue;                  
                    }               
                }   
                if ('link' == reader.getLocalName()) {
                    typeValue = reader.getAttributeValue(null, 'type');
                    relValue = reader.getAttributeValue(null, 'rel');
                    if(typeValue == 'application/atom+xml' && relValue == 'self'){
                        hrefValue = reader.getAttributeValue(null, 'href');
                        ssE.selfURL = hrefValue;                    
                    }               
                }   
                if ('link' == reader.getLocalName()) {
                    typeValue = reader.getAttributeValue(null, 'type');
                    relValue = reader.getAttributeValue(null, 'rel');
                    if(typeValue == 'application/atom+xml' && relValue == 'edit'){
                        hrefValue = reader.getAttributeValue(null, 'href');
                        ssE.editURL = hrefValue;                    
                    }               
                }   
            }
            reader.next();
         }
         return ssE;
    }
    
    //Class used when parsing XML from Google API calls
    public class SpreadSheetEntry {
         String IDValue;
         String KeyValue;
         String Title;
         String WorksheetID;
         String worksheetsFeed;
         String cellsFeed;
         String editURL;
         String selfURL;
         String currentContent;
    }
                
}