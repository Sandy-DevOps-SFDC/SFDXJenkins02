trigger leadInsertInTerget on Lead (After Insert){

   String jsonString=JSON.serialize(Trigger.New);
   //CreateLeadSource.createLeadInTarget(jsonString);
   
   //standard rest api URI call 
   //CreateLeadSource1.createLeadInTarget(jsonString);
   
   //CreateLeadTarget.createLeadInTarget(jsonString);
   CreateLeadTargetWrapper.createLeadInTarget(jsonString);
}