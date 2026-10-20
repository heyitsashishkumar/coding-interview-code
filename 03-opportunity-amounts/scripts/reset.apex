// Video 3: puts the demo data back. Sharma Traders with two deals (50,000 + 30,000 = 80,000) and Gupta Stores with 0.
delete [SELECT Id FROM Opportunity WHERE Account.Name IN ('Sharma Traders', 'Gupta Stores')];
delete [SELECT Id FROM Contact WHERE Account.Name IN ('Sharma Traders', 'Gupta Stores')];
delete [SELECT Id FROM Account WHERE Name IN ('Sharma Traders', 'Gupta Stores')];
Account sharma = new Account(Name = 'Sharma Traders', Phone = '0120 455 0101', Industry = 'Retail');
Account gupta = new Account(Name = 'Gupta Stores', Phone = '0120 455 0202', Industry = 'Retail');
insert new List<Account>{ sharma, gupta };
insert new List<Opportunity>{
    new Opportunity(Name = 'Cloud Migration', AccountId = sharma.Id, StageName = 'Qualification', CloseDate = Date.today().addDays(30), Amount = 50000),
    new Opportunity(Name = 'Annual Support', AccountId = sharma.Id, StageName = 'Negotiation/Review', CloseDate = Date.today().addDays(15), Amount = 30000)
};
for (Account a : [SELECT Name, Total_Opportunity_Amount__c FROM Account WHERE Id IN (:sharma.Id, :gupta.Id) ORDER BY Name DESC]) {
    System.debug(a.Name + ': ' + a.Total_Opportunity_Amount__c);
}
