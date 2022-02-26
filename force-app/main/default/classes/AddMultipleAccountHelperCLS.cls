public class AddMultipleAccountHelperCLS {

    public static List<AddMultipleAccountCLS.WrapperpaAccountList> addNewRowToAccList(List<AddMultipleAccountCLS.WrapperpaAccountList> waAccObjList){
        AddMultipleAccountCLS.WrapperpaAccountList newRecord = new AddMultipleAccountCLS.WrapperpaAccountList();
        Account newAccountRecord = new Account();        
        newRecord.record = newAccountRecord;
        newRecord.index = waAccObjList.size();
        waAccObjList.add(newRecord);
        System.debug('waAccObjList.size ====> '+waAccObjList.size());
        return waAccObjList;
    }
    
    
     public static List<AddMultipleAccountCLS.WrapperpaAccountList> removeRowToAccountList(Integer rowToRemove, List<AddMultipleAccountCLS.WrapperpaAccountList> waAccountList){
        waAccountList.remove(rowToRemove);
        return waAccountList;
    }
    
    public static void save(List<AddMultipleAccountCLS.WrapperpaAccountList> waAccList) {
        system.debug('==waAccList==>'+waAccList.size());
        List<Account> accountRecordsToBeInserted = new List<Account>();
        if(waAccList !=null && !waAccList.isEmpty()){
            for(AddMultipleAccountCLS.WrapperpaAccountList eachRecord : waAccList ){
                Account accTemp = eachRecord.record;
                accountRecordsToBeInserted.add(accTemp);
               
            }
            system.debug('==accountRecordsToBeInserted==>'+accountRecordsToBeInserted.size());
            //in the examle given in site, INSERT was used instead of UPSERT beacse if i use insert then i will get this error:
            //Insert failed. First exception on row 0 with id 001i000002CNlg9AAD; first error: INVALID_FIELD_FOR_INSERT_UPDATE, cannot specify Id in an insert call: [Id]
            //which is caused becauseyou're adding items to list; inserting the list; adding more items to the list; and then trying to insert all the items you've already inserted and the new ones.
            upsert accountRecordsToBeInserted;
            
        }
    }
}