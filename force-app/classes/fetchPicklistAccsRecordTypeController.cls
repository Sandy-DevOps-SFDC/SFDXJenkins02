public class fetchPicklistAccsRecordTypeController{
 @AuraEnabled
 public static List < String > getselectOptions(Sobject objObject, string fld) {
  List < String > allOpts = new list < String > ();
  if(objObject != null && fld !=null){
            for(Schema.RecordTypeInfo recInfo : Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().values()){
                allOpts.add(recInfo.getName());
            }
        }
       allOpts.sort();
  return allOpts;
 }
}