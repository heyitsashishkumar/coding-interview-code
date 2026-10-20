// Video 2, Priya's first try. It queries once outside the loop, but it keeps
// emails in their original case, misses two new contacts sharing an email in
// the same batch, and only listens for before insert. Kept to show how it
// breaks; switched off normally.
trigger DuplicateEmailFirstTry on Contact(before insert) {
  Set<String> emails = new Set<String>();
  for (Contact c : Trigger.new) {
    if (c.Email != null) {
      emails.add(c.Email);
    }
  }
  Set<String> taken = new Set<String>();
  for (Contact existing : [
    SELECT Email
    FROM Contact
    WHERE Email IN :emails
  ]) {
    taken.add(existing.Email);
  }
  for (Contact c : Trigger.new) {
    if (taken.contains(c.Email)) {
      c.Email.addError('A contact with this email already exists.');
    }
  }
}
