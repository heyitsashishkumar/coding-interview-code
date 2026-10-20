# Video 5: at most 5 open opportunities per account

**The question:** prevent any Account from having more than 5 open Opportunities (`IsClosed = false`) at the same time — including when multiple new open deals are inserted in a single batch, when a `Closed Won` or `Closed Lost` deal is reopened, or when an open deal is moved to another Account.

| File | What it is |
|---|---|
| [OpportunityLimitFirstTry.trigger](force-app/main/default/triggers/OpportunityLimitFirstTry.trigger) | Priya's first try: `before insert` only, queries `COUNT(Id)` into a map before the loop, but never increments the map inside the loop as deals pass |
| [OpportunityLimitTrigger.trigger](force-app/main/default/triggers/OpportunityLimitTrigger.trigger) | The fix: `before insert, before update`, filters only newly-open slots (`Trigger.isInsert \|\| !wasOpen \|\| opp.AccountId != oldOpp.AccountId`), queries `COUNT(Id) ... WHERE IsClosed = FALSE GROUP BY AccountId`, and increments `openCounts.put(opp.AccountId, count + 1)` as each deal passes |
| [OpportunityLimitTriggerTest.cls](force-app/main/default/classes/OpportunityLimitTriggerTest.cls) | Six tests, including same-batch 5th and 6th open deals, reopening a `Closed Won` deal at the limit, moving an open deal onto an account at the limit, editing an already-open deal's `Amount` at 5 open deals, inserting a `Closed Won` deal at 5 open deals, and 201 deals in bulk |
| [scripts/](scripts/) | The demo steps from the video, and `use.sh` to switch between the two triggers |

## Run it

From the repo's top folder, with your practice org as the default (see the main README):

```bash
sf project deploy start --source-dir 05-opportunity-limit/force-app
```

Then see each version for yourself:

```bash
# Priya's first try
05-opportunity-limit/scripts/use.sh first-try
sf apex run --file 05-opportunity-limit/scripts/reset.apex         # Sharma Traders: 4 open deals + 1 Closed Won deal (Old Hardware)
sf apex run --file 05-opportunity-limit/scripts/same-batch.apex    # Saved: 2, Blocked: 0 -> Open deals on Sharma Traders: 6 (wrong!)
sf apex run --file 05-opportunity-limit/scripts/reset.apex
sf apex run --file 05-opportunity-limit/scripts/reopen-sixth.apex  # Reopen Old Hardware success: true -> Open deals on Sharma Traders: 6 (wrong!)

# The fix
05-opportunity-limit/scripts/use.sh fix
sf apex run --file 05-opportunity-limit/scripts/reset.apex         # Sharma Traders: 4 open deals + 1 Closed Won deal
sf apex run --file 05-opportunity-limit/scripts/same-batch.apex    # Saved: 1, Blocked: 1 -> Open deals on Sharma Traders: 5
sf apex run --file 05-opportunity-limit/scripts/reopen-sixth.apex  # Reopen Old Hardware success: false -> Open deals on Sharma Traders: 5
sf apex run test --class-names OpportunityLimitTriggerTest --code-coverage --result-format human --wait 10
```

**Homework from the video:** what happens when a sales rep deletes an open Opportunity and later restores it from the Recycle Bin (`undelete`) when the Account already has 5 open Opportunities? Why can't `before undelete` exists in Apex, and how does `after undelete` block the restore with `addError`?
