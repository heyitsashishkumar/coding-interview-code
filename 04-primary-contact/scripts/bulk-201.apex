// Video 4: inserts 201 contacts in one DML statement (two 200-record chunks in one transaction).
// Chunk 1 (records 1..200): 1 new primary + 199 non-primary contacts on Sharma Traders.
// Chunk 2 (record 201): Nita Gupta (Primary = true) on Gupta Stores, where Kiran Gupta is already Primary.
Account sharma = [SELECT Id FROM Account WHERE Name = 'Sharma Traders' LIMIT 1];
Account gupta = [SELECT Id FROM Account WHERE Name = 'Gupta Stores' LIMIT 1];
List<Contact> batch = new List<Contact>();
batch.add(new Contact(FirstName = 'Anil', LastName = 'Kumar', AccountId = sharma.Id, Email = 'anil@sharmatraders.in', Is_Primary__c = true));
for (Integer i = 2; i <= 200; i++) {
    batch.add(new Contact(FirstName = 'Staff', LastName = 'Member ' + i, AccountId = sharma.Id, Email = 'staff' + i + '@sharmatraders.in', Is_Primary__c = false));
}
batch.add(new Contact(FirstName = 'Nita', LastName = 'Gupta', AccountId = gupta.Id, Email = 'nita@guptastores.in', Is_Primary__c = true));
insert batch;
Integer sharmaPrimaries = [SELECT COUNT() FROM Contact WHERE AccountId = :sharma.Id AND Is_Primary__c = true];
Integer guptaPrimaries = [SELECT COUNT() FROM Contact WHERE AccountId = :gupta.Id AND Is_Primary__c = true];
System.debug('Sharma Traders primary contacts (chunk 1): ' + sharmaPrimaries);
System.debug('Gupta Stores primary contacts (chunk 2): ' + guptaPrimaries);
for (Contact c : [SELECT Name, Is_Primary__c FROM Contact WHERE AccountId = :gupta.Id ORDER BY Name ASC]) {
    System.debug('Gupta Stores -> ' + c.Name + ': Is_Primary__c = ' + c.Is_Primary__c);
}
