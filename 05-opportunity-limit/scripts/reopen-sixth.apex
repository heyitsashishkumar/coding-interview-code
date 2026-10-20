// Video 5: inserts the 5th open deal (Warehouse Wi-Fi) and then reopens Old Hardware (Closed Won -> Negotiation/Review).
Account sharma = [SELECT Id FROM Account WHERE Name = 'Sharma Traders' LIMIT 1];
insert new Opportunity(
    Name = 'Warehouse Wi-Fi',
    AccountId = sharma.Id,
    StageName = 'Prospecting',
    CloseDate = Date.today().addDays(30),
    Amount = 35000
);
Opportunity oldHardware = [
    SELECT Id, StageName
    FROM Opportunity
    WHERE Name = 'Old Hardware' AND AccountId = :sharma.Id
    LIMIT 1
];
oldHardware.StageName = 'Negotiation/Review';
Database.SaveResult result = Database.update(oldHardware, false);
System.debug('Reopen Old Hardware success: ' + result.isSuccess());
if (!result.isSuccess()) {
    System.debug('Blocked: ' + result.getErrors()[0].getMessage());
}
Integer openDeals = [SELECT COUNT() FROM Opportunity WHERE AccountId = :sharma.Id AND IsClosed = false];
System.debug('Sharma Traders open deals now: ' + openDeals);
