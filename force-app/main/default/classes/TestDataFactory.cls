/**
 * @name TestDataFactory
 * @description Contains methods to construct and/or validate commonly used records
**/
public with sharing class TestDataFactory {

    /**
     * @name ConstructCollaborationGroup
     * @description
    **/
    public static CollaborationGroup ConstructCollaborationGroup(){
        //ToDo: Ensure this method returns a single Chatter CollaborationGroup
        //    whose Name starts with 'TEST' followed by the INVENTORY_ANNOUNCEMENTS constant
        //    and configured so anyone can join, see and post updates.
        CollaborationGroup cg = new CollaborationGroup();
        cg.Name = 'TEST'+constants.INVENTORY_ANNOUNCEMENTS;
        cg.CollaborationType = 'Public';
        return cg;
        
    }

    /**
     * @name CreateProducts
     * @description Constructs a list of Product2 records for unit tests
    **/
    public static list<product2> ConstructProducts(Integer cnt){
        //ToDo: Ensure this method returns a list, of size cnt, of uniquely named Product2 records
        //  with all the required fields populated
        //  and IsActive = true
        //  an Initial Inventory set to 10
        //  and iterating through the product family picklist values throughout the list.
        list<Product2> prodLst = new list<Product2>();
        for(integer i=0;i<cnt;i++){
            Product2 p = new Product2();
            p.Name = 'Testproduct'+i;
            p.IsActive = true;
            p.Initial_Inventory__c = 10;   
            integer j = i;
            if(j>3){
                j=0;
                p.Family = Constants.PRODUCT_FAMILY[j].getValue();
            }else{
                p.Family = Constants.PRODUCT_FAMILY[j].getValue();
            }         
            
            
            
            prodLst.add(p);
        }
        return prodLst;
    }

    /**
     * @name CreatePricebookEntries
     * @description Constructs a list of PricebookEntry records for unit tests
    **/
    public static list<PricebookEntry> ConstructPricebookEntries(List<Product2> prods){
        //ToDo: Ensure this method returns a corresponding list of PricebookEntries records
        //  related to the provided Products
        //  with all the required fields populated
        //  and IsActive = true
        //  and belonging to the standard Pricebook
        list<PricebookEntry> PricebookEntries = new list<PricebookEntry>();
        for(Product2 p: prods){
            PricebookEntry pb = new PricebookEntry();
            pb.Product2Id = p.Id;
            pb.IsActive = true;
            pb.UnitPrice = 10;
            pb.Pricebook2Id = Constants.STANDARD_PRICEBOOK_ID;
            PricebookEntries.add(pb);
        }
        
        return PricebookEntries;
    }

    /**
     * @name CreateAccounts
     * @description Constructs a list of Account records for unit tests
    **/
    public static list<Account> ConstructAccounts(Integer cnt){
        //ToDo: Ensure this method returns a list of size cnt of uniquely named Account records
        //  with all of the required fields populated.
        list<Account> Accounts = new list<Account>();
        for(integer i=0;i<cnt;i++){
            Account a = new Account();
            a.name = 'Test Account'+i;
            Accounts.add(a);
        }
        return Accounts;
    }

    /**
     * @name CreateContacts
     * @description Constructs a list of Contacxt records for unit tests
    **/
    public static list<Contact> ConstructContacts(Integer cnt, List<Account> accts){
        //ToDo: Ensure this method returns a list, of size cnt, of uniquely named Contact records
        //  related to the provided Accounts
        //  with all of the required fields populated.
        list<Contact> Contacts = new list<Contact>();
        for(integer i=0;i<cnt;i++){
            Contact a = new Contact();
            a.LastName = 'Test Contact'+i;
            Contacts.add(a);
        }
        
        for (integer itr=0; itr<Contacts.size();itr++){
                Contacts[itr].AccountId=accts[itr].id;
         }
        return Contacts;
    }

    /**
     * @name CreateOrders
     * @description Constructs a list of Order records for unit tests
    **/
    public static list<Order> ConstructOrders(Integer cnt, List<Account> accts){
        //ToDo: Ensure this method returns a list of size cnt of uniquely named Order records
        //  related to the provided Accounts
        //  with all of the required fields populated.
        list<Order> Orders = new list<Order>();
        for(integer i=0;i<cnt;i++){
            Order a = new Order();
            a.Name = 'Test Order'+i;
            a.EffectiveDate = system.today();
            a.Status = constants.DRAFT_ORDER_STATUS;
            a.Pricebook2Id = Constants.STANDARD_PRICEBOOK_ID;
            
            Orders.add(a);
        }
        
        for (integer itr=0; itr<Orders.size();itr++){
                Orders[itr].AccountId=accts[itr].id;
         }
        return Orders;
    }

    /**
     * @name CreateOrderItems
     * @description Constructs a list of OrderItem records for unit tests
    **/
    public static list<OrderItem> ConstructOrderItems(integer cnt, list<pricebookentry> pbes, list<order> ords){
        //ToDo: Ensure this method returns a list of size cnt of OrderItem records
        //  related to the provided Pricebook Entries
        //  and related to the provided Orders
        //  with all of the required fields populated.
        //  Hint: Use the DEFAULT_ROWS constant for Quantity as it will be used in the next challenge
        list<OrderItem> OrderItems = new list<OrderItem>();
        for(integer i=0;i<cnt;i++){
            OrderItem a = new OrderItem();
            a.Quantity = constants.DEFAULT_ROWS;   
            a.UnitPrice = 30;
         
            OrderItems.add(a);
        }
        
        for (integer itr=0; itr<OrderItems.size();itr++){
                OrderItems[itr].OrderId=ords[itr].id;
                OrderItems[itr].PricebookEntryId=pbes[itr].id;
        }
        return OrderItems;
    }

    /**
     * @name SetupTestData
     * @description Inserts accounts, contacts, Products, PricebookEntries, Orders, and OrderItems.
    **/
    public static void InsertTestData(Integer cnt){
        //ToDo: Ensure this method calls each of the construct methods
        //  and inserts the results for use as test data.
        CollaborationGroup cg = ConstructCollaborationGroup();
        insert cg;
        list<product2> prods = ConstructProducts(cnt);
        insert prods;
        list<PricebookEntry> pbes = ConstructPricebookEntries(prods);
        insert pbes;
        list<Account> accts = ConstructAccounts(cnt);
        insert accts;
        list<Contact> conts = ConstructContacts(cnt,accts);
        insert conts;
        list<Order> orders = ConstructOrders(cnt,accts);
        insert orders;
        list<OrderItem> ordItems = ConstructOrderItems(cnt,pbes,orders);
        insert ordItems;
        
    }
    
    public static void VerifyQuantityOrdered(Product2 originalProduct, Product2 updatedProduct, Integer qtyOrdered){
        System.assertEquals(
            originalProduct.Quantity_Ordered__c + qtyOrdered,
            updatedProduct.Quantity_Ordered__c,
            'error on Quantity_Ordered__c update'
            );
    }

}