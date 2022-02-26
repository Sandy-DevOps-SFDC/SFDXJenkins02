public with sharing class TestRedirectController 
{
    public String inputValue {get; set;}
 
    public TestRedirectController() 
    {
        inputValue = 'Hello';
    }
 
    public PageReference reloadPage() 
    {
        //return null;
        //return Page.TestRedirect;
 
        pageReference pr = Page.TestRedirect;
        pr.getParameters().put('id', '11123434');
        return pr;
    }
}