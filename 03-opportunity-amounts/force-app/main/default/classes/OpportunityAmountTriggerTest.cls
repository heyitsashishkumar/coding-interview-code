// Tests OpportunityAmountTrigger (video 3) across 201 opportunities, reparenting
// from Sharma Traders to Gupta Stores, deleting the last opportunity on an account,
// undeleting, blank Amount, and an opportunity with no account.
@IsTest
private class OpportunityAmountTriggerTest {
  @TestSetup
  static void makeAccounts() {
    insert new List<Account>{
      new Account(Name = 'Sharma Traders'),
      new Account(Name = 'Gupta Stores')
    };
  }

  @IsTest
  static void sums201OpportunitiesInsertedAtOnce() {
    Account sharma = account('Sharma Traders');
    List<Opportunity> opps = new List<Opportunity>();
    for (Integer i = 1; i <= 201; i++) {
      Opportunity opp = deal('Deal ' + i, sharma.Id, 1000);
      opp.StageName = 'Closed Won';
      opps.add(opp);
    }
    insert opps;
    Assert.areEqual(201000, totalOf(sharma.Id));
  }

  @IsTest
  static void movingAnOpportunityUpdatesBothAccounts() {
    Account sharma = account('Sharma Traders');
    Account gupta = account('Gupta Stores');
    Opportunity cloud = deal('Cloud Migration', sharma.Id, 50000);
    Opportunity support = deal('Annual Support', sharma.Id, 30000);
    insert new List<Opportunity>{ cloud, support };

    support.AccountId = gupta.Id;
    update support;

    Assert.areEqual(50000, totalOf(sharma.Id));
    Assert.areEqual(30000, totalOf(gupta.Id));
  }

  @IsTest
  static void deletingTheLastOpportunityLeavesZero() {
    Account sharma = account('Sharma Traders');
    Opportunity cloud = deal('Cloud Migration', sharma.Id, 50000);
    insert cloud;
    delete cloud;
    Assert.areEqual(0, totalOf(sharma.Id));
  }

  @IsTest
  static void undeletingRestoresTheTotal() {
    Account sharma = account('Sharma Traders');
    Opportunity cloud = deal('Cloud Migration', sharma.Id, 50000);
    insert cloud;
    delete cloud;
    undelete cloud;
    Assert.areEqual(50000, totalOf(sharma.Id));
  }

  @IsTest
  static void blankAmountCountsAsZero() {
    Account sharma = account('Sharma Traders');
    insert deal('Unpriced Deal', sharma.Id, null);
    Assert.areEqual(0, totalOf(sharma.Id));
  }

  @IsTest
  static void ignoresAnOpportunityWithNoAccount() {
    insert deal('No Account Deal', null, 25000);
    Assert.areEqual(0, totalOf(account('Sharma Traders').Id));
  }

  private static Account account(String name) {
    return [SELECT Id FROM Account WHERE Name = :name];
  }

  private static Opportunity deal(String name, Id accountId, Decimal amount) {
    return new Opportunity(
      Name = name,
      AccountId = accountId,
      StageName = 'Prospecting',
      CloseDate = Date.today().addDays(30),
      Amount = amount
    );
  }

  private static Decimal totalOf(Id accountId) {
    return [
      SELECT Total_Opportunity_Amount__c
      FROM Account
      WHERE Id = :accountId
    ]
    .Total_Opportunity_Amount__c;
  }
}
