// Video 2: puts the demo data back. Sharma Traders with three contacts and their emails.
delete [SELECT Id FROM Contact WHERE Account.Name IN ('Sharma Traders', 'Gupta Stores')];
delete [SELECT Id FROM Account WHERE Name IN ('Sharma Traders', 'Gupta Stores')];
Account sharma = new Account(Name = 'Sharma Traders', Phone = '0120 455 0101', Industry = 'Retail');
insert sharma;
insert new List<Contact>{
    new Contact(FirstName = 'Ravi', LastName = 'Sharma', Email = 'ravi@sharmatraders.in', AccountId = sharma.Id),
    new Contact(FirstName = 'Meena', LastName = 'Sharma', Email = 'meena@sharmatraders.in', AccountId = sharma.Id),
    new Contact(FirstName = 'Arjun', LastName = 'Sharma', Email = 'arjun@sharmatraders.in', AccountId = sharma.Id)
};
System.debug('Contacts: ' + [SELECT COUNT() FROM Contact WHERE AccountId = :sharma.Id]);
