// Video 3: the fix. Collects AccountIds from both Trigger.new and Trigger.old
// (so moving an opportunity updates both accounts), stores SUM(Amount) in a
// Map<Id, Decimal> (treating null as 0), and loops over accountIds so an
// account with no opportunities left resets to 0.
trigger OpportunityAmountTrigger on Opportunity(
  after insert,
  after update,
  after delete,
  after undelete
) {
  // COLLECT every account whose total may have changed (new and old)
  Set<Id> accountIds = new Set<Id>();
  if (Trigger.new != null) {
    for (Opportunity opp : Trigger.new) {
      if (opp.AccountId != null) {
        accountIds.add(opp.AccountId);
      }
    }
  }
  if (Trigger.old != null) {
    for (Opportunity opp : Trigger.old) {
      if (opp.AccountId != null) {
        accountIds.add(opp.AccountId);
      }
    }
  }
  if (accountIds.isEmpty()) {
    return;
  }

  // QUERY once: sum the opportunity amounts for each account
  Map<Id, Decimal> totals = new Map<Id, Decimal>();
  for (AggregateResult row : [
    SELECT AccountId, SUM(Amount) total
    FROM Opportunity
    WHERE AccountId IN :accountIds
    GROUP BY AccountId
  ]) {
    Decimal sum = (Decimal) row.get('total');
    totals.put((Id) row.get('AccountId'), sum != null ? sum : 0);
  }

  // COMPUTE each account's total; no row in GROUP BY means 0
  List<Account> accounts = new List<Account>();
  for (Id accountId : accountIds) {
    Decimal total = totals.containsKey(accountId) ? totals.get(accountId) : 0;
    accounts.add(
      new Account(Id = accountId, Total_Opportunity_Amount__c = total)
    );
  }

  // SAVE once
  update accounts;
}
