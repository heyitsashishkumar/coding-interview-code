// Video 1: 201 contacts arrive at once, as from a Data Loader import.
Account sharma = [SELECT Id FROM Account WHERE Name = 'Sharma Traders'];
List<Contact> contacts = new List<Contact>();
for (Integer i = 1; i <= 201; i++) {
    contacts.add(new Contact(LastName = 'Imported ' + i, AccountId = sharma.Id));
}
insert contacts;
System.debug('Number of Contacts: ' + [SELECT Number_of_Contacts__c FROM Account WHERE Id = :sharma.Id].Number_of_Contacts__c);
