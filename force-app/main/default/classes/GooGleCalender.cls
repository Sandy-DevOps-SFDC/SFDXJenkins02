public class GooGleCalender{

    public string GOOGLE_API_CLIENT_ID = '84669277096-p11oefns7r8j98h9lr0efv4fmo8pg4is.apps.googleusercontent.com';
    public string GOOGLE_API_CLIENT_SECRET = 'awsyQfWKPthmZEFF_6AFQkF8'; //CLIENT_SECRET
    public string apikey='AIzaSyCk-mkrlqMUc4SFBA4CHtYZhodcqgFny4A';
    public string token_uri = 'https://accounts.google.com/o/oauth2/token';
    public string auth_uri= 'https://accounts.google.com/o/oauth2/auth';
    
    public static final string GRANT_TYPE='grant_type=authorization_code';

    public static String SF_AUTH_PAGE = 'https://-------artdev--c.cs62.visual.force.com/apex/googleAuthorization';
    
    public string GOOGLE_CALENDAR_SCOPE = 'https://www.googleapis.com/auth/calendar';        //read/write access to Calendars
    static String GOOGLE_CALENDAR_BASE_URL = 'https://www.googleapis.com/calendar/v3/calendars/';
    static String GOOGLE_CALENDAR_EVENTS_PATH = '/events';
    
    public void createGoogleEvent(){
          String GRANTTYPE='authorization_code';
           String reqbody = 'grant_type='+GRANTTYPE+'&client_id='+GOOGLE_API_CLIENT_ID;
                  reqbody=reqbody+'&client_secret='+GOOGLE_API_CLIENT_SECRET;
                  reqbody=reqbody+'&scope='+GOOGLE_CALENDAR_SCOPE;
           
            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://accounts.google.com/o/oauth2/token');
            req.setMethod('POST');
            req.setCompressed(false);
            req.setHeader('User-Agent','learnApex API');
            req.setHeader('Encoding','iso-8859-1');
            req.setHeader('Content-Type','application/x-www-form-urlencoded');
            req.setTimeout(120000);
            req.setBody(reqbody);
            req.setHeader('Content-length',string.valueOf(reqbody.length()));
            
            HttpResponse res = new http().send(req);

            system.debug(res.getBody());

    }
    public class OAuth2 {
     public String id{get;set;}
     public String issued_at{get;set;}
     public String instance_url{get;set;}
     public String signature{get;set;}
     public String access_token{get;set;}
    }
    
    /*CalendarService service = new CalendarService();  
                            service.setAuthSubToken(sessionAuthToken);
                
                            GoogleData.Calendar cal = service.getCalendarByTitle('MyCalendar');
                            event newEvent = new Event(
                                                subject = 'Tennis with Beth',
                                                description = 'Meet for a quick lesson.',
                                                ActivityDateTime = system.now(),
                                                DurationInMinutes = 60
                            );
                            
                            xmldom.element entry = service.insertEvents( cal, newEvent); 
                            entry.dumpAll(); */
                            
}