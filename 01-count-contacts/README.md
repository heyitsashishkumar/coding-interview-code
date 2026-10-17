# Video 1: count the contacts on an account

**The question:** keep a field on each account that always shows how many contacts it has, with a trigger (a roll-up summary field can't count contacts on an account).

| File | What it is |
|---|---|
| [ContactCountFirstTry.trigger](force-app/main/default/triggers/ContactCountFirstTry.trigger) | Priya's first try: +1 on insert only, with a query and an update inside the loop |
| [ContactCountTrigger.trigger](force-app/main/default/triggers/ContactCountTrigger.trigger) | The fix: collect the accounts, query once, compute, save once |
| [ContactCountTriggerTest.cls](force-app/main/default/classes/ContactCountTriggerTest.cls) | Six tests, including 201 contacts at once, a delete, an undelete and a move |
| [scripts/](scripts/) | The demo steps from the video, and `use.sh` to switch between the two triggers |

## Run it

From the repo's top folder, with your practice org as the default (see the main README):

```bash
sf project deploy start --source-dir 01-count-contacts/force-app
sf org assign permset --name Coding_Videos
```

This adds a **Number of Contacts** field to Account, puts it on the Account page layout, and deploys both triggers with the fix switched on. (The layout is a standard Developer Edition Account layout plus the new field; deploying it replaces your Account layout, which is fine in a practice org.)

Then see each version for yourself:

```bash
# Priya's first try
01-count-contacts/scripts/use.sh first-try
sf apex run --file 01-count-contacts/scripts/reset.apex       # Sharma Traders with 3 contacts → Number of Contacts: 3
sf apex run --file 01-count-contacts/scripts/delete-one.apex  # Contacts: 2, Number of Contacts: 3  (wrong)
sf apex run --file 01-count-contacts/scripts/insert-201.apex  # System.LimitException: Too many SOQL queries: 101

# The fix
01-count-contacts/scripts/use.sh fix
sf apex run --file 01-count-contacts/scripts/reset.apex       # Number of Contacts: 3
sf apex run --file 01-count-contacts/scripts/delete-one.apex  # Contacts: 2, Number of Contacts: 2
sf apex run --file 01-count-contacts/scripts/insert-201.apex  # Number of Contacts: 203
sf apex run test --class-names ContactCountTriggerTest --code-coverage --result-format human --wait 10
```

`reset.apex` deletes and recreates the accounts named Sharma Traders and Gupta Stores, so run it only in a practice org.

**Homework from the video:** move a contact from Sharma Traders to another account. Do both counts change? Why? Try it, then read the test `aMoveUpdatesBothAccounts`.
