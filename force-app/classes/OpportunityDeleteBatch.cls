global class OpportunityDeleteBatch implements Database.Batchable<sObject>
{
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        String query = 'SELECT Id,Name FROM Opportunity where isdeleted__c=true';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Opportunity> scope)
    {
        delete scope;
    }  
    global void finish(Database.BatchableContext BC)
    {
       
    }
}