// Video 5: two new open Opportunities arrive in the same batch for Sharma Traders (which already has 4 open).
Account sharma = [SELECT Id FROM Account WHERE Name = 'Sharma Traders' LIMIT 1];
List<Opportunity> batch = new List<Opportunity>{
    new Opportunity(Name = 'Warehouse Wi-Fi', AccountId = sharma.Id, StageName = 'Prospecting', CloseDate = Date.today().addDays(30), Amount = 35000),
    new Opportunity(Name = 'ERP Renewal', AccountId = sharma.Id, StageName = 'Qualification', CloseDate = Date.today().addDays(45), Amount = 60000)
};
List<Database.SaveResult> results = Database.insert(batch, false);
Integer saved = 0;
Integer blocked = 0;
for (Database.SaveResult r : results) {
    if (r.isSuccess()) {
        saved++;
    } else {
        blocked++;
        System.debug('Blocked: ' + r.getErrors()[0].getMessage());
    }
}
Integer openDeals = [SELECT COUNT() FROM Opportunity WHERE AccountId = :sharma.Id AND IsClosed = false];
System.debug('Saved: ' + saved + ', Blocked: ' + blocked);
System.debug('Sharma Traders open deals now: ' + openDeals);
