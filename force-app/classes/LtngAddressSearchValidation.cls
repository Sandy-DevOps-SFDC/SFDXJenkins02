public class LtngAddressSearchValidation{

public List<SelectOption> options {get;set;}

 public LtngAddressSearchValidation(){
        options =new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = Account.RecordTypeID.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry f: ple) {
            options.add(new SelectOption(f.getLabel(),f.getLabel()));
        }    
    }  
}