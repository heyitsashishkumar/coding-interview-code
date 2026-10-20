// Video 3: moves Annual Support (30,000) from Sharma Traders to Gupta Stores.
Account gupta = [SELECT Id FROM Account WHERE Name = 'Gupta Stores'];
Opportunity support = [SELECT Id, AccountId FROM Opportunity WHERE Name = 'Annual Support' AND Account.Name = 'Sharma Traders'];
support.AccountId = gupta.Id;
update support;
for (Account a : [SELECT Name, Total_Opportunity_Amount__c FROM Account WHERE Name IN ('Sharma Traders', 'Gupta Stores') ORDER BY Name DESC]) {
    System.debug(a.Name + ': ' + a.Total_Opportunity_Amount__c);
}
