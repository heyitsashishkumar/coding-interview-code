// Video 1, Priya's first try. It only handles inserts, and it queries and saves
// inside the loop, once per contact. Kept to show how it breaks; switched off normally.
trigger ContactCountFirstTry on Contact(after insert) {
  for (Contact c : Trigger.new) {
    Account acc = [
      SELECT Id, Number_of_Contacts__c
      FROM Account
      WHERE Id = :c.AccountId
    ];
    acc.Number_of_Contacts__c = acc.Number_of_Contacts__c + 1;
    update acc;
  }
}
