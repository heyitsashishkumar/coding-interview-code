// Video 4: marks Meena Sharma as Primary Contact on Sharma Traders.
Contact meena = [
    SELECT Id, Is_Primary__c
    FROM Contact
    WHERE LastName = 'Sharma' AND FirstName = 'Meena' AND Account.Name = 'Sharma Traders'
    LIMIT 1
];
meena.Is_Primary__c = true;
update meena;
for (Contact c : [SELECT Name, Is_Primary__c FROM Contact WHERE Account.Name = 'Sharma Traders' ORDER BY Name ASC]) {
    System.debug(c.Name + ': Is_Primary__c = ' + c.Is_Primary__c);
}
