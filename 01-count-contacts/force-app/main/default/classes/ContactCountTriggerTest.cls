// Tests ContactCountTrigger (video 1) with 201 contacts, one more than a trigger's
// 200-record chunk, with deletes, undeletes, a move to another account, and a
// contact with no account.
@IsTest
private class ContactCountTriggerTest {
  @TestSetup
  static void makeAccounts() {
    insert new List<Account>{
      new Account(Name = 'Sharma Traders'),
      new Account(Name = 'Gupta Stores')
    };
  }

  @IsTest
  static void counts201ContactsInsertedAtOnce() {
    Account sharma = account('Sharma Traders');
    insertContacts(sharma.Id, 201);
    Assert.areEqual(201, countOf(sharma.Id));
  }

  @IsTest
  static void countsADelete() {
    Account sharma = account('Sharma Traders');
    List<Contact> contacts = insertContacts(sharma.Id, 3);
    delete contacts[0];
    Assert.areEqual(2, countOf(sharma.Id));
  }

  @IsTest
  static void countsAnUndelete() {
    Account sharma = account('Sharma Traders');
    List<Contact> contacts = insertContacts(sharma.Id, 3);
    delete contacts[0];
    undelete contacts[0];
    Assert.areEqual(3, countOf(sharma.Id));
  }

  @IsTest
  static void aMoveUpdatesBothAccounts() {
    Account sharma = account('Sharma Traders');
    Account gupta = account('Gupta Stores');
    List<Contact> contacts = insertContacts(sharma.Id, 3);
    contacts[0].AccountId = gupta.Id;
    update contacts[0];
    Assert.areEqual(2, countOf(sharma.Id));
    Assert.areEqual(1, countOf(gupta.Id));
  }

  @IsTest
  static void theLastDeleteLeavesZero() {
    Account sharma = account('Sharma Traders');
    delete insertContacts(sharma.Id, 3);
    Assert.areEqual(0, countOf(sharma.Id));
  }

  @IsTest
  static void ignoresAContactWithNoAccount() {
    insert new Contact(LastName = 'No Account');
    Assert.areEqual(0, countOf(account('Sharma Traders').Id));
  }

  private static Account account(String name) {
    return [SELECT Id FROM Account WHERE Name = :name];
  }

  private static List<Contact> insertContacts(Id accountId, Integer howMany) {
    List<Contact> contacts = new List<Contact>();
    for (Integer i = 0; i < howMany; i++) {
      contacts.add(
        new Contact(LastName = 'Contact ' + i, AccountId = accountId)
      );
    }
    insert contacts;
    return contacts;
  }

  private static Decimal countOf(Id accountId) {
    return [SELECT Number_of_Contacts__c FROM Account WHERE Id = :accountId]
    .Number_of_Contacts__c;
  }
}
