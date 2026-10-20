// Coding video 4 — Enforce at most one Primary Contact per Account (the fix).
trigger PrimaryContactTrigger on Contact(after insert, after update) {
  Map<Id, Id> primaryByAccount = new Map<Id, Id>();

  for (Contact c : Trigger.new) {
    Boolean becamePrimary = Trigger.isInsert
      ? c.Is_Primary__c
      : (c.Is_Primary__c && !Trigger.oldMap.get(c.Id).Is_Primary__c);
    if (becamePrimary && c.AccountId != null) {
      primaryByAccount.put(c.AccountId, c.Id);
    }
  }

  if (primaryByAccount.isEmpty()) {
    return;
  }

  List<Contact> toDemote = [
    SELECT Id, Is_Primary__c
    FROM Contact
    WHERE
      AccountId IN :primaryByAccount.keySet()
      AND Is_Primary__c = TRUE
      AND Id NOT IN :primaryByAccount.values()
  ];

  for (Contact other : toDemote) {
    other.Is_Primary__c = false;
  }

  if (!toDemote.isEmpty()) {
    update toDemote;
  }
}
