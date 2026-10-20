// Video 2, the fix: collect changed emails in lower case, query existing
// contacts once, then check and add each email to the same set so duplicates
// inside one batch and in different letter cases are both blocked.
trigger DuplicateEmailTrigger on Contact(before insert, before update) {
  // COLLECT the contacts whose email is new or changed
  Set<String> emails = new Set<String>();
  List<Contact> toCheck = new List<Contact>();
  for (Contact c : Trigger.new) {
    if (c.Email == null) {
      continue;
    }
    String oldEmail = Trigger.isUpdate ? Trigger.oldMap.get(c.Id).Email : null;
    if (Trigger.isInsert || !c.Email.equalsIgnoreCase(oldEmail)) {
      emails.add(c.Email.toLowerCase());
      toCheck.add(c);
    }
  }
  if (emails.isEmpty()) {
    return;
  }

  // QUERY once: which of these emails already exist?
  Set<String> taken = new Set<String>();
  for (Contact existing : [
    SELECT Email
    FROM Contact
    WHERE Email IN :emails
  ]) {
    taken.add(existing.Email.toLowerCase());
  }

  // COMPUTE and SAVE: block any email already taken, then mark it taken
  for (Contact c : toCheck) {
    String email = c.Email.toLowerCase();
    if (taken.contains(email)) {
      c.Email.addError('A contact with this email already exists.');
    } else {
      taken.add(email);
    }
  }
}
