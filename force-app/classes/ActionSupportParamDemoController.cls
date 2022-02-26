public class ActionSupportParamDemoController {
    private Id targetAccountId;
    public Id selectedAccountId { get; set; }

    public List<Account> getAccounts() {
    //IsActive__c
        return [
            SELECT Id, Name, Website
            FROM Account
        ];
    }

    public Id getTargetAccountId() {
        return targetAccountId;
    }

    public PageReference handleAccountCheckboxChange() {
        System.debug('targetAccountId: ' + targetAccountId);
        selectedAccountId = targetAccountId;
        return null;
    }

    public void setTargetAccountId(Id value) {
        targetAccountId = value;
    }
}