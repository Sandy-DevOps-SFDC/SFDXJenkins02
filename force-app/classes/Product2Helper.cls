public class Product2Helper {

    /**
     * @name COLLABORATION_GROUP
     * @description List of CollaborationGroup used in both business and test logic
    **/
    static List<CollaborationGroup> COLLABORATION_GROUP = [
        SELECT Id
        FROM CollaborationGroup
        WHERE Name =: Constants.INVENTORY_ANNOUNCEMENTS
        OR Name = :('TEST'+Constants.INVENTORY_ANNOUNCEMENTS)
        LIMIT 1
    ];

    /**
     * @name afterUpdate
     * @description called by product2 Trigger on After Update
     * @param List<Product2> newList
     * @param List<Product2> oldList
    **/
    public static void AfterUpdate(List<Product2> newList){
        //ToDo: Declare a List of Product2 records named needsAnnouncement
        list<product2> needsAnnouncement = new list<product2>();
        //ToDo: Declare a Map of Strings to Inventory_Setting__mdt records
        map<string,Inventory_Setting__mdt> invMap = new map<string,Inventory_Setting__mdt>();
        //ToDo: Loop through a query of Inventory_Setting__mdt records and populate the Map with Name as the key
        for(Inventory_Setting__mdt inv : [select Id,DeveloperName,Low_Quantity_Alert__c FROM Inventory_Setting__mdt ]){
            invMap.put(inv.DeveloperName,inv);
        }

        PostAlerts(newList);
    }

    /**
     * @name postAlerts
     * @description called by product2 Trigger on After Update
     * @param List<Product2> productList
    **/
    public static void PostAlerts(List<Product2> productList){
        List<ConnectApi.AnnouncementInput> toPost = new List<ConnectApi.AnnouncementInput>();
        for ( Product2 p : productList ){
            ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
            ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
            ConnectApi.AnnouncementInput announcement = new ConnectApi.AnnouncementInput();
            announcement.parentId = COLLABORATION_GROUP[0].Id;
            announcement.expirationDate = Date.today().addDays(1);
            announcement.sendEmails = false;
            
            textSegmentInput.text = p.Name + ' ' + Constants.INVENTORY_LEVEL_LOW;
            messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
            messageBodyInput.messageSegments.add(textSegmentInput);
            announcement.body = messageBodyInput;
            toPost.add(announcement);
        }
        // ToDo: Create and enqueue an instance of the announcementQueuable class with the list of Products
        AnnouncementQueueable q = new AnnouncementQueueable();
         q.toPost = toPost;
        System.enqueueJob(q);
    }
}