public with sharing class ProgressBarController {

public List<OpportunityData> oppWrapper{get;Set;}

    public ProgressBarController(ApexPages.StandardController std) {
           oppWrapper=new List<OpportunityData>();
           String sOpportunityId = ApexPages.currentPage().getParameters().get('id') ;           
           Opportunity oOpportunity = [SELECT Id, Name, Scheduled_Start_Date__c, Scheduled_End_Date__c FROM Opportunity where Id =: sOpportunityId];
           OpportunityData opData=new OpportunityData(oOpportunity.Scheduled_Start_Date__c,oOpportunity.Scheduled_End_Date__c );
           oppWrapper.add(opData);
    }
  
  public class OpportunityData{     
     public date scheduledStartDate{get;set;}
     public date scheduledEndDate{get;set;}
     
     public OpportunityData(date scheduledStartDate,date scheduledEndDate){
            this.scheduledStartDate=scheduledStartDate;
            this.scheduledEndDate=scheduledEndDate;
     }     
  }
}