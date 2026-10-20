// Video 5, the fix: collect every deal that is newly adding an open slot on
// its Account (inserted open, reopened from Closed Won/Lost, or moved to a
// different Account while open), query existing open counts once, and increment
// the map as each deal passes so the 6th open deal in the same batch is blocked.
trigger OpportunityLimitTrigger on Opportunity(before insert, before update) {
  // COLLECT deals that are newly taking an open slot on their Account
  Set<Id> accountIds = new Set<Id>();
  List<Opportunity> toCheck = new List<Opportunity>();
  for (Opportunity opp : Trigger.new) {
    Boolean isOpen =
      opp.StageName != 'Closed Won' &&
      opp.StageName != 'Closed Lost';
    if (opp.AccountId == null || !isOpen) {
      continue;
    }
    Opportunity oldOpp = Trigger.isUpdate ? Trigger.oldMap.get(opp.Id) : null;
    Boolean wasOpen =
      oldOpp != null &&
      oldOpp.StageName != 'Closed Won' &&
      oldOpp.StageName != 'Closed Lost';
    if (Trigger.isInsert || !wasOpen || opp.AccountId != oldOpp.AccountId) {
      accountIds.add(opp.AccountId);
      toCheck.add(opp);
    }
  }
  if (accountIds.isEmpty()) {
    return;
  }

  // QUERY once: how many open Opportunities does each Account already have?
  Map<Id, Integer> openCounts = new Map<Id, Integer>();
  for (AggregateResult row : [
    SELECT AccountId, COUNT(Id) total
    FROM Opportunity
    WHERE AccountId IN :accountIds AND IsClosed = FALSE
    GROUP BY AccountId
  ]) {
    openCounts.put((Id) row.get('AccountId'), (Integer) row.get('total'));
  }

  // COMPUTE and SAVE: block at 5, or reserve the next slot in the map
  for (Opportunity opp : toCheck) {
    Integer count = openCounts.containsKey(opp.AccountId)
      ? openCounts.get(opp.AccountId)
      : 0;
    if (count >= 5) {
      opp.addError('An Account can have at most 5 open Opportunities.');
    } else {
      openCounts.put(opp.AccountId, count + 1);
    }
  }
}
