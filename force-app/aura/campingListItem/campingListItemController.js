({
    packItem: function(component, event, helper) {
        var a = component.get("v.item",true);
        a.Packed__c = true;
        a.Price__c=10;
        component.set("v.item",a);
        var btnClicked = event.getSource();
        btnClicked.set("v.disabled",true);
    }
})