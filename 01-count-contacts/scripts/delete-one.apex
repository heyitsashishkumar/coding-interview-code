delete [SELECT Id FROM Contact WHERE FirstName = 'Arjun' AND Account.Name = 'Sharma Traders'];
Account a = [SELECT Number_of_Contacts__c, (SELECT Id FROM Contacts) FROM Account WHERE Name = 'Sharma Traders'];
System.debug('Contacts: ' + a.Contacts.size() + ', Number of Contacts: ' + a.Number_of_Contacts__c);
