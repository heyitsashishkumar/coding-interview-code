// Video 3: Priya's first try. Bulkified with SUM(Amount) and GROUP BY,
// but only collects from Trigger.new on updates (missing the old account
// when an opportunity moves) and only updates accounts returned by GROUP BY
// (leaving an account stuck at its old total when its last deal is deleted).
trigger OpportunityAmountFirstTry on Opportunity(
  after insert,
  after update,
  after delete,
  after undelete
) {
  Set<Id> accountIds = new Set<Id>();
  for (Opportunity opp : Trigger.isDelete ? Trigger.old : Trigger.new) {
    if (opp.AccountId != null) {
      accountIds.add(opp.AccountId);
    }
  }
  if (accountIds.isEmpty()) {
    return;
  }

  List<Account> accounts = new List<Account>();
  for (AggregateResult row : [
    SELECT AccountId, SUM(Amount) total
    FROM Opportunity
    WHERE AccountId IN :accountIds
    GROUP BY AccountId
  ]) {
    accounts.add(
      new Account(
        Id = (Id) row.get('AccountId'),
        Total_Opportunity_Amount__c = (Decimal) row.get('total')
      )
    );
  }
  update accounts;
}
