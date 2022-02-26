public with sharing class CopySelectedDataFromTable{

    public String selected{ get; set; }

    
public List<AccountWrapper> accWrapList{get;set;}

public List<AccountWrapper> accWrapListSelected{get;set;}

   public CopySelectedDataFromTable(){
       accWrapList = new List<AccountWrapper>();
       List<Account> accList=[select id,name,phone from Account LIMIT 10];
       
       for(Account a : accList){
               AccountWrapper  ar=new AccountWrapper(false,a);
               accWrapList.add(ar);
            }
   }
   
   public PageReference copyDataFromTable() {
        accWrapListSelected = new List<AccountWrapper>();
        for(AccountWrapper aa : accWrapList){
            if(aa.accRec.id == selected){
                 accWrapListSelected.add(aa);
            }
        }
        return null;
    }


   public class AccountWrapper{      
      public boolean checkBox{get;set;}
      public Account accRec{get;set;}
      
      public AccountWrapper(){
         checkBox=false;      
      }
      public AccountWrapper(boolean checkBox,Account accRec){      
         this.checkBox=checkBox;
         this.accRec=accRec;      
      }
   
   }
}