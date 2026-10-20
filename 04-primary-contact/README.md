# Video 4: recursion and the 200-record trap (one primary contact per account)

**The question:** enforce at most one Primary Contact (`Is_Primary__c = true`) per Account — when a contact is inserted or updated with `Primary Contact` checked, automatically uncheck any previous primary contact on that account without hitting infinite recursion or skipping records past 200.

| File | What it is |
|---|---|
| [PrimaryContactGuard.cls](force-app/main/default/classes/PrimaryContactGuard.cls) | The `public static Boolean isFirstRun = true;` helper class used by the first try |
| [PrimaryContactFirstTry.trigger](force-app/main/default/triggers/PrimaryContactFirstTry.trigger) | Priya's first try: uses `PrimaryContactGuard.isFirstRun` (which skips chunk 2 in a 201-record DML) and queries `WHERE Is_Primary__c = true` without `Id NOT IN` (which unchecks the newly promoted contact too) |
| [PrimaryContactTrigger.trigger](force-app/main/default/triggers/PrimaryContactTrigger.trigger) | The fix: checks the state transition (`false -> true`), excludes the newly promoted contact IDs with `Id NOT IN :primaryByAccount.values()`, and needs no `static Boolean` so all 200-record chunks run |
| [PrimaryContactTriggerTest.cls](force-app/main/default/classes/PrimaryContactTriggerTest.cls) | Six tests, including promoting a second contact, inserting a new primary contact, 201 records across two chunks, two contacts promoted on the same account in one batch, and no-account/non-primary edits |
| [scripts/](scripts/) | The demo steps from the video, and `use.sh` to switch between the two triggers |

## Run it

From the repo's top folder, with your practice org as the default (see the main README):

```bash
sf project deploy start --source-dir 04-primary-contact/force-app
sf org assign permset --name Coding_Videos
```

Then see each version for yourself:

```bash
# Priya's first try
04-primary-contact/scripts/use.sh first-try
sf apex run --file 04-primary-contact/scripts/reset.apex          # Sharma Traders: Ravi (true), Meena (false); Gupta Stores: Kiran (true), Nita (false)
sf apex run --file 04-primary-contact/scripts/promote-meena.apex  # Sharma Traders primary contacts: 0 (wrong: both Ravi and Meena unchecked!)
sf apex run --file 04-primary-contact/scripts/reset.apex
sf apex run --file 04-primary-contact/scripts/bulk-201.apex       # Chunk 1: 0, Chunk 2 (Gupta Stores): 2 (wrong: isFirstRun=false skipped record 201!)

# The fix
04-primary-contact/scripts/use.sh fix
sf apex run --file 04-primary-contact/scripts/reset.apex
sf apex run --file 04-primary-contact/scripts/promote-meena.apex  # Sharma Traders primary contacts: 1 (Meena = true, Ravi = false)
sf apex run --file 04-primary-contact/scripts/reset.apex
sf apex run --file 04-primary-contact/scripts/bulk-201.apex       # Chunk 1: 1, Chunk 2 (Gupta Stores): 1 (Nita = true, Kiran = false)
sf apex run test --class-names PrimaryContactTriggerTest --code-coverage --result-format human --wait 10
```

**Homework from the video:** what if two triggers update each other (`Account` -> `Contact` -> `Account`) where checking `Trigger.oldMap` on one field isn't enough? How do you build a recursion guard with a `Set<Id>` of processed record IDs that still lets records 201 to 400 run in chunk 2?
