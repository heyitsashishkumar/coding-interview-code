# Video 3: roll up opportunity amounts to the account

**The question:** keep a custom currency field `Total_Opportunity_Amount__c` on `Account` that always equals the sum of `Amount` across all of that account's opportunities, using an Apex trigger across `after insert, after update, after delete, after undelete`.

| File | What it is |
|---|---|
| [OpportunityAmountFirstTry.trigger](force-app/main/default/triggers/OpportunityAmountFirstTry.trigger) | Priya's first try: bulkified `SUM(Amount)` + `GROUP BY AccountId`, but collects only `Trigger.new` on update and loops over `AggregateResult` rows instead of `accountIds` |
| [OpportunityAmountTrigger.trigger](force-app/main/default/triggers/OpportunityAmountTrigger.trigger) | The fix: collects both new and old `AccountId` when an opportunity moves on update, and loops over `accountIds` so an account with zero opportunities left resets to `0` |
| [OpportunityAmountTriggerTest.cls](force-app/main/default/classes/OpportunityAmountTriggerTest.cls) | Six tests, including 201 opportunities at once, moving an opportunity between accounts, deleting the last opportunity, undeleting, `Amount = null`, and an opportunity with no account |
| [scripts/](scripts/) | The demo steps from the video, and `use.sh` to switch between the two triggers |

## Run it

From the repo's top folder, with your practice org as the default (see the main README):

```bash
sf project deploy start --source-dir 03-opportunity-amounts/force-app
sf org assign permset --name Coding_Videos
```

Then see each version for yourself:

```bash
# Priya's first try
03-opportunity-amounts/scripts/use.sh first-try
sf apex run --file 03-opportunity-amounts/scripts/reset.apex       # Sharma Traders: 80000.00 (50,000 + 30,000), Gupta Stores: 0.00
sf apex run --file 03-opportunity-amounts/scripts/move-one.apex    # Sharma Traders: 80000.00 (wrong!), Gupta Stores: 30000.00
sf apex run --file 03-opportunity-amounts/scripts/delete-all.apex  # Deals left: 0, Total Opportunity Amount: 80000.00 (wrong!)

# The fix
03-opportunity-amounts/scripts/use.sh fix
sf apex run --file 03-opportunity-amounts/scripts/reset.apex       # Sharma Traders: 80000.00, Gupta Stores: 0.00
sf apex run --file 03-opportunity-amounts/scripts/move-one.apex    # Sharma Traders: 50000.00, Gupta Stores: 30000.00
sf apex run --file 03-opportunity-amounts/scripts/delete-all.apex  # Deals left: 0, Total Opportunity Amount: 0.00
sf apex run test --class-names OpportunityAmountTriggerTest --code-coverage --result-format human --wait 10
```

**Homework from the video:** what if the interviewer asks to sum only `Closed Won` opportunities (`IsWon = true`), and a rep changes a deal's stage from `Closed Won` back to `Negotiation/Review` without changing its `Amount`? Does our `after update` trigger still recalculate the account cleanly?
