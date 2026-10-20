// Video 5, Priya's first try (from Practice_Questions_Solutions.md Scenario 14).
// Queries existing open opportunities once with GROUP BY AccountId, but never
// increments the count inside the Trigger.new loop (so 2 new open deals on an
// account with 4 open both see currentCount = 4 and both pass, making 6), and
// only listens for before insert (missing reopened or reparented deals).
trigger OpportunityLimitFirstTry on Opportunity(before insert) {
  Set<Id> accountIds = new Set<Id>();
  for (Opportunity opp : Trigger.new) {
    if (opp.AccountId != null) {
      accountIds.add(opp.AccountId);
    }
  }
  if (accountIds.isEmpty()) {
    return;
  }

  Map<Id, Integer> openCounts = new Map<Id, Integer>();
  for (AggregateResult row : [
    SELECT AccountId, COUNT(Id) total
    FROM Opportunity
    WHERE AccountId IN :accountIds AND IsClosed = FALSE
    GROUP BY AccountId
  ]) {
    openCounts.put((Id) row.get('AccountId'), (Integer) row.get('total'));
  }

  for (Opportunity opp : Trigger.new) {
    if (opp.AccountId != null) {
      Integer currentCount = openCounts.containsKey(opp.AccountId)
        ? openCounts.get(opp.AccountId)
        : 0;
      // Add 1 for the current record being inserted
      if (currentCount >= 5) {
        opp.addError('An Account can have at most 5 open Opportunities.');
      }
    }
  }
}
