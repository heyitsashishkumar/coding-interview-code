// Tests OpportunityLimitTrigger (video 5) across the 6th open deal in the same
// batch, a 201-record partial-success import across two accounts, reopening a
// Closed Won deal onto a full account, moving an open deal onto a full account,
// editing an already-open deal on a full account, and a deal with no account.
@IsTest
private class OpportunityLimitTriggerTest {
  @TestSetup
  static void makeAccountsAndFourOpenDeals() {
    Account sharma = new Account(Name = 'Sharma Traders');
    Account gupta = new Account(Name = 'Gupta Stores');
    insert new List<Account>{ sharma, gupta };

    insert new List<Opportunity>{
      openDeal('Cloud Migration', sharma.Id),
      openDeal('Annual Support', sharma.Id),
      openDeal('POS Upgrade', sharma.Id),
      openDeal('Security Audit', sharma.Id)
    };
  }

  @IsTest
  static void allowsFifthOpenDealAndBlocksSixthInSameBatch() {
    Account sharma = account('Sharma Traders');
    List<Database.SaveResult> results = Database.insert(
      new List<Opportunity>{
        openDeal('Warehouse Wi-Fi', sharma.Id),
        openDeal('ERP Renewal', sharma.Id)
      },
      false
    );
    Assert.isTrue(results[0].isSuccess());
    Assert.isFalse(results[1].isSuccess());
    Assert.areEqual(
      'An Account can have at most 5 open Opportunities.',
      results[1].getErrors()[0].getMessage()
    );
    Assert.areEqual(5, openCount(sharma.Id));
  }

  @IsTest
  static void capsEachAccountAtFiveAcross201Records() {
    Account sharma = account('Sharma Traders');
    Account gupta = account('Gupta Stores');
    List<Opportunity> batch = new List<Opportunity>();
    for (Integer i = 1; i <= 198; i++) {
      batch.add(openDeal('Sharma Bulk ' + i, sharma.Id));
    }
    for (Integer i = 1; i <= 3; i++) {
      batch.add(openDeal('Gupta Bulk ' + i, gupta.Id));
    }
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
    // Sharma starts with 4 open (1 more allowed); Gupta starts with 0 open (all 3 allowed).
    Assert.areEqual(4, saved);
    Assert.areEqual(197, blocked);
    Assert.areEqual(5, openCount(sharma.Id));
    Assert.areEqual(3, openCount(gupta.Id));
  }

  @IsTest
  static void blocksReopeningClosedDealWhenAccountAlreadyHasFiveOpen() {
    Account sharma = account('Sharma Traders');
    Opportunity fifth = openDeal('Warehouse Wi-Fi', sharma.Id);
    Opportunity closedDeal = new Opportunity(
      Name = 'Old Hardware',
      AccountId = sharma.Id,
      StageName = 'Closed Won',
      CloseDate = Date.today(),
      Amount = 20000
    );
    insert new List<Opportunity>{ fifth, closedDeal };

    closedDeal.StageName = 'Negotiation/Review';
    Database.SaveResult result = Database.update(closedDeal, false);
    Assert.isFalse(result.isSuccess());
    Assert.areEqual(5, openCount(sharma.Id));
  }

  @IsTest
  static void blocksMovingOpenDealToAccountWithFiveOpen() {
    Account sharma = account('Sharma Traders');
    Account gupta = account('Gupta Stores');
    Opportunity fifth = openDeal('Warehouse Wi-Fi', sharma.Id);
    Opportunity guptaDeal = openDeal('Billing Portal', gupta.Id);
    insert new List<Opportunity>{ fifth, guptaDeal };

    guptaDeal.AccountId = sharma.Id;
    Database.SaveResult result = Database.update(guptaDeal, false);
    Assert.isFalse(result.isSuccess());
    Assert.areEqual(5, openCount(sharma.Id));
  }

  @IsTest
  static void allowsEditingExistingOpenDealWhenAccountHasFiveOpen() {
    Account sharma = account('Sharma Traders');
    Opportunity fifth = openDeal('Warehouse Wi-Fi', sharma.Id);
    insert fifth;

    fifth.Amount = 75000;
    Database.SaveResult result = Database.update(fifth, false);
    Assert.isTrue(result.isSuccess());
  }

  @IsTest
  static void ignoresDealWithNoAccountOrClosedStage() {
    Database.SaveResult noAccount = Database.insert(
      openDeal('Unassigned Deal', null),
      false
    );
    Assert.isTrue(noAccount.isSuccess());
  }

  private static Account account(String name) {
    return [SELECT Id FROM Account WHERE Name = :name];
  }

  private static Opportunity openDeal(String name, Id accountId) {
    return new Opportunity(
      Name = name,
      AccountId = accountId,
      StageName = 'Qualification',
      CloseDate = Date.today().addDays(30),
      Amount = 25000
    );
  }

  private static Integer openCount(Id accountId) {
    return [
      SELECT COUNT()
      FROM Opportunity
      WHERE AccountId = :accountId AND IsClosed = FALSE
    ];
  }
}
