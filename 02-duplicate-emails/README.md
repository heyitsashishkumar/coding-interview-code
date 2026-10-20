# Video 2: stop duplicate emails before they're saved

**The question:** prevent duplicate emails across all contacts, show the error right on the `Email` field before the record is saved, and handle both edits and bulk imports in the same batch.

| File | What it is |
|---|---|
| [DuplicateEmailFirstTry.trigger](force-app/main/default/triggers/DuplicateEmailFirstTry.trigger) | Priya's first try: `before insert` only, checking only the database |
| [DuplicateEmailTrigger.trigger](force-app/main/default/triggers/DuplicateEmailTrigger.trigger) | The fix: `before insert, before update`, skipping unchanged emails on update, lowercasing, and checking both the database and the current batch |
| [DuplicateEmailTriggerTest.cls](force-app/main/default/classes/DuplicateEmailTriggerTest.cls) | Six tests, including an existing DB duplicate, a same-batch duplicate, case-insensitive matching, an update to an taken email, a safe edit when email is unchanged, and 200 unique contacts |
| [scripts/](scripts/) | The demo steps from the video, and `use.sh` to switch between the two triggers |

## Run it

From the repo's top folder, with your practice org as the default (see the main README):

```bash
sf project deploy start --source-dir 02-duplicate-emails/force-app
```

Then see each version for yourself:

```bash
# Priya's first try
02-duplicate-emails/scripts/use.sh first-try
sf apex run --file 02-duplicate-emails/scripts/reset.apex       # Sharma Traders with Ravi (ravi@sharmatraders.in) & Meena (meena@sharmatraders.in)
sf apex run --file 02-duplicate-emails/scripts/same-batch.apex  # Saved: 2, Blocked: 0  (wrong: both Kiran and Deepak saved with kiran@sharmatraders.in)

# The fix
02-duplicate-emails/scripts/use.sh fix
sf apex run --file 02-duplicate-emails/scripts/reset.apex       # Contacts reset
sf apex run --file 02-duplicate-emails/scripts/same-batch.apex  # Saved: 1, Blocked: 1  (Deepak blocked: A contact with this email already exists.)
sf apex run test --class-names DuplicateEmailTriggerTest --code-coverage --result-format human --wait 10
```

**Homework from the video:** what happens when a contact with `ravi@sharmatraders.in` is deleted and then undeleted from the Recycle Bin while another contact already uses `ravi@sharmatraders.in`? Which trigger event do you need to add?
