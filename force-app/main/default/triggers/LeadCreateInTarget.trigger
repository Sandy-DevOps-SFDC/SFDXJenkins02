trigger LeadCreateInTarget on Lead (after Insert) {

String jsonString=JSON.Serialize(Trigger.New);
//CreateLeadSource1.createLeadInTarget(jsonString);

CreateLeadTarget.createLeadInTarget(jsonString);

System.debug('jsonString in LeadCreateInTarget ::>'+jsonString);



}