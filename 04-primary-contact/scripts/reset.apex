// Video 4: puts the demo data back.
// Sharma Traders: Ravi Sharma (Primary = true) and Meena Sharma (Primary = false).
// Gupta Stores: Kiran Gupta (Primary = true).
PrimaryContactGuard.isFirstRun = false;
delete [SELECT Id FROM Opportunity WHERE Account.Name IN ('Sharma Traders', 'Gupta Stores')];
delete [SELECT Id FROM Contact WHERE Account.Name IN ('Sharma Traders', 'Gupta Stores')];
delete [SELECT Id FROM Account WHERE Name IN ('Sharma Traders', 'Gupta Stores')];
Account sharma = new Account(Name = 'Sharma Traders', Phone = '0120 455 0101', Industry = 'Retail');
Account gupta = new Account(Name = 'Gupta Stores', Phone = '0120 455 0202', Industry = 'Retail');
insert new List<Account>{ sharma, gupta };
insert new List<Contact>{
    new Contact(FirstName = 'Ravi', LastName = 'Sharma', AccountId = sharma.Id, Title = 'Managing Director', Email = 'ravi@sharmatraders.in', Is_Primary__c = true),
    new Contact(FirstName = 'Meena', LastName = 'Sharma', AccountId = sharma.Id, Title = 'Finance Head', Email = 'meena@sharmatraders.in', Is_Primary__c = false),
    new Contact(FirstName = 'Kiran', LastName = 'Gupta', AccountId = gupta.Id, Title = 'Store Manager', Email = 'kiran@guptastores.in', Is_Primary__c = true)
};
for (Contact c : [SELECT Name, Account.Name, Is_Primary__c FROM Contact WHERE AccountId IN (:sharma.Id, :gupta.Id) ORDER BY Account.Name DESC, Name ASC]) {
    System.debug(c.Account.Name + ' -> ' + c.Name + ': Is_Primary__c = ' + c.Is_Primary__c);
}
