// Video 1, the fix: collect the accounts, query once, compute, save once.
// It counts again from the database each time, so inserts, deletes, undeletes
// and contacts moving to another account all come out right.
trigger ContactCountTrigger on Contact(
  after insert,
  after update,
  after delete,
  after undelete
) {
  // COLLECT the accounts whose count may have changed
  Set<Id> accountIds = new Set<Id>();
  if (Trigger.new != null) {
    for (Contact c : Trigger.new) {
      if (c.AccountId != null) {
        accountIds.add(c.AccountId);
      }
    }
  }
  if (Trigger.old != null) {
    for (Contact c : Trigger.old) {
      if (c.AccountId != null) {
        accountIds.add(c.AccountId);
      }
    }
  }
  if (accountIds.isEmpty()) {
    return;
  }

  // QUERY once: count every account's contacts together
  Map<Id, Integer> counts = new Map<Id, Integer>();
  for (AggregateResult row : [
    SELECT AccountId, COUNT(Id) total
    FROM Contact
    WHERE AccountId IN :accountIds
    GROUP BY AccountId
  ]) {
    counts.put((Id) row.get('AccountId'), (Integer) row.get('total'));
  }

  // COMPUTE each account's number; no row means no contacts left
  List<Account> accounts = new List<Account>();
  for (Id accountId : accountIds) {
    Integer total = counts.containsKey(accountId) ? counts.get(accountId) : 0;
    accounts.add(new Account(Id = accountId, Number_of_Contacts__c = total));
  }

  // SAVE once
  update accounts;
}
