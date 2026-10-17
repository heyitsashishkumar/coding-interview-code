// Video 1: puts the demo data back. Sharma Traders with three contacts, added one by one.
delete [SELECT Id FROM Contact WHERE Account.Name IN ('Sharma Traders', 'Gupta Stores')];
delete [SELECT Id FROM Account WHERE Name IN ('Sharma Traders', 'Gupta Stores')];
Account sharma = new Account(Name = 'Sharma Traders', Phone = '0120 455 0101', Industry = 'Retail');
insert sharma;
for (String name : new List<String>{ 'Ravi', 'Meena', 'Arjun' }) {
    insert new Contact(FirstName = name, LastName = 'Sharma', AccountId = sharma.Id);
}
System.debug('Number of Contacts: ' + [SELECT Number_of_Contacts__c FROM Account WHERE Id = :sharma.Id].Number_of_Contacts__c);
