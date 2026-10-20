// Coding video 4 — Tests for PrimaryContactTrigger.
@IsTest
private class PrimaryContactTriggerTest {
  @IsTest
  static void markingAContactPrimaryUnchecksTheOldPrimary() {
    Account sharma = new Account(Name = 'Sharma Traders');
    insert sharma;

    Contact ravi = new Contact(
      FirstName = 'Ravi',
      LastName = 'Sharma',
      AccountId = sharma.Id,
      Is_Primary__c = true
    );
    Contact meena = new Contact(
      FirstName = 'Meena',
      LastName = 'Sharma',
      AccountId = sharma.Id,
      Is_Primary__c = false
    );
    insert new List<Contact>{ ravi, meena };

    meena.Is_Primary__c = true;
    update meena;

    ravi = [SELECT Is_Primary__c FROM Contact WHERE Id = :ravi.Id];
    meena = [SELECT Is_Primary__c FROM Contact WHERE Id = :meena.Id];
    System.assertEquals(false, ravi.Is_Primary__c);
    System.assertEquals(true, meena.Is_Primary__c);
  }

  @IsTest
  static void insertingANewPrimaryContactDemotesTheOldOne() {
    Account sharma = new Account(Name = 'Sharma Traders');
    insert sharma;

    Contact ravi = new Contact(
      FirstName = 'Ravi',
      LastName = 'Sharma',
      AccountId = sharma.Id,
      Is_Primary__c = true
    );
    insert ravi;

    Contact anil = new Contact(
      FirstName = 'Anil',
      LastName = 'Kumar',
      AccountId = sharma.Id,
      Is_Primary__c = true
    );
    insert anil;

    ravi = [SELECT Is_Primary__c FROM Contact WHERE Id = :ravi.Id];
    anil = [SELECT Is_Primary__c FROM Contact WHERE Id = :anil.Id];
    System.assertEquals(false, ravi.Is_Primary__c);
    System.assertEquals(true, anil.Is_Primary__c);
  }

  @IsTest
  static void editingAnExistingPrimaryContactKeepsItPrimary() {
    Account sharma = new Account(Name = 'Sharma Traders');
    insert sharma;

    Contact ravi = new Contact(
      FirstName = 'Ravi',
      LastName = 'Sharma',
      AccountId = sharma.Id,
      Is_Primary__c = true
    );
    insert ravi;

    ravi.Title = 'Managing Director';
    update ravi;

    ravi = [SELECT Is_Primary__c FROM Contact WHERE Id = :ravi.Id];
    System.assertEquals(true, ravi.Is_Primary__c);
  }

  @IsTest
  static void handles201ContactsAcrossTwoTriggerChunks() {
    Account sharma = new Account(Name = 'Sharma Traders');
    Account verma = new Account(Name = 'Verma Logistics');
    insert new List<Account>{ sharma, verma };

    Contact ravi = new Contact(
      FirstName = 'Ravi',
      LastName = 'Sharma',
      AccountId = sharma.Id,
      Is_Primary__c = true
    );
    Contact karan = new Contact(
      FirstName = 'Karan',
      LastName = 'Verma',
      AccountId = verma.Id,
      Is_Primary__c = true
    );
    insert new List<Contact>{ ravi, karan };

    List<Contact> batch = new List<Contact>();
    batch.add(
      new Contact(
        FirstName = 'Meena',
        LastName = 'Sharma',
        AccountId = sharma.Id,
        Is_Primary__c = true
      )
    );
    for (Integer i = 2; i <= 200; i++) {
      batch.add(
        new Contact(
          FirstName = 'Staff',
          LastName = 'Member ' + i,
          AccountId = sharma.Id,
          Is_Primary__c = false
        )
      );
    }
    batch.add(
      new Contact(
        FirstName = 'Nita',
        LastName = 'Verma',
        AccountId = verma.Id,
        Is_Primary__c = true
      )
    );
    insert batch;

    Integer sharmaPrimaries = [
      SELECT COUNT()
      FROM Contact
      WHERE AccountId = :sharma.Id AND Is_Primary__c = TRUE
    ];
    Integer vermaPrimaries = [
      SELECT COUNT()
      FROM Contact
      WHERE AccountId = :verma.Id AND Is_Primary__c = TRUE
    ];
    System.assertEquals(1, sharmaPrimaries);
    System.assertEquals(1, vermaPrimaries);
  }

  @IsTest
  static void twoPrimaryContactsInOneBatchLeavesOnlyOne() {
    Account sharma = new Account(Name = 'Sharma Traders');
    insert sharma;

    insert new List<Contact>{
      new Contact(
        FirstName = 'Meena',
        LastName = 'Sharma',
        AccountId = sharma.Id,
        Is_Primary__c = true
      ),
      new Contact(
        FirstName = 'Anil',
        LastName = 'Kumar',
        AccountId = sharma.Id,
        Is_Primary__c = true
      )
    };

    Integer primaries = [
      SELECT COUNT()
      FROM Contact
      WHERE AccountId = :sharma.Id AND Is_Primary__c = TRUE
    ];
    System.assertEquals(1, primaries);
  }

  @IsTest
  static void ignoresAContactWithNoAccount() {
    Contact solo = new Contact(LastName = 'Solo', Is_Primary__c = true);
    insert solo;
    System.assertNotEquals(null, solo.Id);
  }
}
