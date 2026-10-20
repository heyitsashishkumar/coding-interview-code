// Video 5: puts the demo data back.
// Sharma Traders: 4 open Opportunities + 1 Closed Won Opportunity (Old Hardware).
// Gupta Stores: 0 Opportunities.
delete [SELECT Id FROM Opportunity WHERE Account.Name IN ('Sharma Traders', 'Gupta Stores')];
delete [SELECT Id FROM Contact WHERE Account.Name IN ('Sharma Traders', 'Gupta Stores')];
delete [SELECT Id FROM Account WHERE Name IN ('Sharma Traders', 'Gupta Stores')];
Account sharma = new Account(Name = 'Sharma Traders', Phone = '0120 455 0101', Industry = 'Retail');
Account gupta = new Account(Name = 'Gupta Stores', Phone = '0120 455 0202', Industry = 'Retail');
insert new List<Account>{ sharma, gupta };
insert new List<Opportunity>{
    new Opportunity(Name = 'Old Hardware', AccountId = sharma.Id, StageName = 'Closed Won', CloseDate = Date.today().addDays(-10), Amount = 20000),
    new Opportunity(Name = 'Cloud Migration', AccountId = sharma.Id, StageName = 'Qualification', CloseDate = Date.today().addDays(30), Amount = 50000),
    new Opportunity(Name = 'Annual Support', AccountId = sharma.Id, StageName = 'Negotiation/Review', CloseDate = Date.today().addDays(25), Amount = 30000),
    new Opportunity(Name = 'POS Upgrade', AccountId = sharma.Id, StageName = 'Proposal/Price Quote', CloseDate = Date.today().addDays(20), Amount = 40000),
    new Opportunity(Name = 'Security Audit', AccountId = sharma.Id, StageName = 'Needs Analysis', CloseDate = Date.today().addDays(15), Amount = 25000)
};
Integer openDeals = [SELECT COUNT() FROM Opportunity WHERE AccountId = :sharma.Id AND IsClosed = false];
Integer totalDeals = [SELECT COUNT() FROM Opportunity WHERE AccountId = :sharma.Id];
System.debug('Sharma Traders open deals: ' + openDeals + ' (total deals: ' + totalDeals + ')');
