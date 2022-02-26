public class Constants {
   public static final Integer DEFAULT_ROWS = 5;
   public static final string SELECT_ONE = 'Select one'; 
   public static final string INVENTORY_LEVEL_LOW = 'Has a low inventory'; 
   public static final string DRAFT_ORDER_STATUS = 'Draft'; 
   public static final string ACTIVATED_ORDER_STATUS = 'Activated'; 
   public static final string INVENTORY_ANNOUNCEMENTS = 'Inventory Announcements'; 
   public static final string ERROR_MESSAGE = 'An error has occurred, please take a screenshot with the URL and send it to IT'; 
   public static final Id STANDARD_PRICEBOOK_ID = '01s6F0000096gxQ';
   public static final Schema.DescribeFieldResult F = Product2.Family.getDescribe();
   public static final list<Schema.PicklistEntry> PRODUCT_FAMILY = F.getPicklistValues();
  
}