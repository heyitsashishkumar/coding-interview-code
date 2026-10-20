// Coding video 4 — Priya's first try (inactive by default; scripts/coding-04/use.sh switches it on).
// Has two real bugs:
// 1. Queries WHERE Is_Primary__c = true without excluding the new primary's Id, so in an after trigger it
//    fetches the newly saved primary contact too and unchecks it right back.
// 2. Uses a static Boolean guard (PrimaryContactGuard.isFirstRun) that flips to false in chunk 1 (records 1-200),
//    so chunk 2 (records 201+) in the same transaction is silently skipped.
trigger PrimaryContactFirstTry on Contact(after insert, after update) {
  if (!PrimaryContactGuard.isFirstRun) {
    return;
  }
  PrimaryContactGuard.isFirstRun = false;

  Set<Id> accountIds = new Set<Id>();
  for (Contact c : Trigger.new) {
    if (c.Is_Primary__c && c.AccountId != null) {
      accountIds.add(c.AccountId);
    }
  }
  if (accountIds.isEmpty()) {
    return;
  }

  List<Contact> oldPrimaries = [
    SELECT Id, Is_Primary__c
    FROM Contact
    WHERE AccountId IN :accountIds AND Is_Primary__c = TRUE
  ];
  for (Contact other : oldPrimaries) {
    other.Is_Primary__c = false;
  }
  update oldPrimaries;
}
