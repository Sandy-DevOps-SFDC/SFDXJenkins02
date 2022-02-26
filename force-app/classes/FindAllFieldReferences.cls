public class FindAllFieldReferences{
       
        public List<SelectOption> objects {get; set;}
        public List<SelectOption> fieldNames{get;set;}
        public List<SelectOption> fieldUsageType{get;set;}
        
        private List<ApexClass> lstClasses = new List<ApexClass>();
        private List<ApexTrigger> lstTrigger = new List<ApexTrigger>();
        
        public boolean displayFieldDropdown{get;set;}
        public boolean displayFieldUsage{get;set;}
        
        public string choosenObject {get; set;}
        public string choosenField {get; set;}
        public string choosenType {get; set;}
        
        public Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        public Map <String, String> fieldMap{get;set;}
        
        public map<string,string> usageMap{get;set;}
        public Set<String> keyValues{get;set;}
        
        public FindAllFieldReferences(){
               objects = new List<SelectOption>();
               displayFieldDropdown=false;
               displayFieldUsage=false;
               Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
               List<String> objectList = new List<String>();
               objectList.addAll(gd.keyset());
               Schema.DescribeSobjectResult[] results = Schema.describeSObjects(objectList);
               for(Schema.DescribeSobjectResult res : results) { 
                    //if(!res.isCustom()) 
                          objects.add(new selectOption(res.getName() ,res.getLabel())); 
               }
               
               objects.sort();

        }

        public pagereference showFields() {
            displayFieldDropdown=true;
            displayFieldUsage=true;
            fieldMap=new Map<String,String>();
            fieldNames = new List<SelectOption>();
            fieldUsageType=new List<SelectOption>();
            SObjectType objType = Schema.getGlobalDescribe().get(choosenObject);
            Map<String,Schema.SObjectField> fieldMap = objType.getDescribe().fields.getMap();
            for(String fieldName: fieldMap.keySet())
                {                   
                   String fName = fieldMap.get(fieldName).getDescribe().getLabel();                   
                   fieldNames.add(new SelectOption(fieldName, fieldName));
                }
              fieldUsageType.add(new selectoption('ApexClass','ApexClass'));
              fieldUsageType.add(new selectoption('ApexTrigger','ApexTrigger'));
                fieldNames.sort();
                return null;
        }
        public pagereference showFieldUsage() {
               usageMap=new Map<string,string>();
               keyValues = new Set<string>();
               system.debug('*********'+choosenField);
               if(choosenType=='ApexClass'){
                       lstClasses = [select Name, Body from ApexClass where name='AccountDeleteWrapperCLs'];
                   }
                for(ApexClass cls:lstClasses){
                    if(cls.Body.contains('AccountNumber')){
                       system.debug('*********');
                       usageMap.put('AccountNumber',string.valueof(cls.Name).remove('='));
                    }
                } 
                keyValues = usageMap.keyset();
                system.debug('*********'+lstClasses );  
                system.debug('*********'+keyValues );  
                system.debug('*********'+usageMap.values());  
               return null;
        }
}