// Tests DuplicateEmailTrigger (video 2) with existing duplicates, upper and
// lower case, two new contacts with the same email in one batch, updates, a
// contact with no email, and a 201-record partial-success import.
@IsTest
private class DuplicateEmailTriggerTest {
  @TestSetup
  static void makeContacts() {
    Account sharma = new Account(Name = 'Sharma Traders');
    insert sharma;
    insert new List<Contact>{
      new Contact(
        FirstName = 'Ravi',
        LastName = 'Sharma',
        Email = 'ravi@sharmatraders.in',
        AccountId = sharma.Id
      ),
      new Contact(
        FirstName = 'Meena',
        LastName = 'Sharma',
        Email = 'meena@sharmatraders.in',
        AccountId = sharma.Id
      )
    };
  }

  @IsTest
  static void blocksExistingEmailIgnoringCase() {
    Database.SaveResult result = Database.insert(
      new Contact(LastName = 'Kiran', Email = 'RAVI@sharmatraders.in'),
      false
    );
    Assert.isFalse(result.isSuccess());
    Assert.areEqual(
      'A contact with this email already exists.',
      result.getErrors()[0].getMessage()
    );
  }

  @IsTest
  static void blocksSecondDuplicateInSameBatch() {
    List<Database.SaveResult> results = Database.insert(
      new List<Contact>{
        new Contact(LastName = 'Kiran', Email = 'kiran@sharmatraders.in'),
        new Contact(LastName = 'Deepak', Email = 'KIRAN@sharmatraders.in')
      },
      false
    );
    Assert.isTrue(results[0].isSuccess());
    Assert.isFalse(results[1].isSuccess());
  }

  @IsTest
  static void blocksUpdateToTakenEmail() {
    Contact meena = [
      SELECT Id, Email
      FROM Contact
      WHERE Email = 'meena@sharmatraders.in'
    ];
    meena.Email = 'ravi@sharmatraders.in';
    Database.SaveResult result = Database.update(meena, false);
    Assert.isFalse(result.isSuccess());
  }

  @IsTest
  static void allowsUpdateWhenEmailUnchanged() {
    Contact ravi = [
      SELECT Id, Phone
      FROM Contact
      WHERE Email = 'ravi@sharmatraders.in'
    ];
    ravi.Phone = '0120 455 0199';
    Database.SaveResult result = Database.update(ravi, false);
    Assert.isTrue(result.isSuccess());
  }

  @IsTest
  static void ignoresContactWithNoEmail() {
    Database.SaveResult result = Database.insert(
      new Contact(LastName = 'No Email'),
      false
    );
    Assert.isTrue(result.isSuccess());
  }

  @IsTest
  static void saves199Of201WhenTwoAreDuplicates() {
    List<Contact> batch = new List<Contact>();
    for (Integer i = 1; i <= 199; i++) {
      batch.add(
        new Contact(
          LastName = 'Imported ' + i,
          Email = 'person' + i + '@sharmatraders.in'
        )
      );
    }
    batch.add(
      new Contact(LastName = 'Existing Dup', Email = 'ravi@sharmatraders.in')
    );
    batch.add(
      new Contact(LastName = 'Batch Dup', Email = 'person1@sharmatraders.in')
    );
    List<Database.SaveResult> results = Database.insert(batch, false);
    Integer saved = 0;
    Integer blocked = 0;
    for (Database.SaveResult r : results) {
      if (r.isSuccess()) {
        saved++;
      } else {
        blocked++;
      }
    }
    Assert.areEqual(199, saved);
    Assert.areEqual(2, blocked);
  }
}
