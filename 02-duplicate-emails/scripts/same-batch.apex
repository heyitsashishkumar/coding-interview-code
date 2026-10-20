// Video 2: two new contacts arrive in the same batch with the same new email.
Account sharma = [SELECT Id FROM Account WHERE Name = 'Sharma Traders'];
List<Contact> batch = new List<Contact>{
    new Contact(FirstName = 'Kiran', LastName = 'Sharma', Email = 'kiran@sharmatraders.in', AccountId = sharma.Id),
    new Contact(FirstName = 'Deepak', LastName = 'Sharma', Email = 'kiran@sharmatraders.in', AccountId = sharma.Id)
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
System.debug('Saved: ' + saved + ', Blocked: ' + blocked);
