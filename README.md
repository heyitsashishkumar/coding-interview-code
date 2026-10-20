# Coding interview code

The code from the **Freestyle Cyber Hub** coding interview videos, one folder per video, ready to run in your own free practice org. Every solution was deployed and tested in a real org before it went into a video.

| Video | The question | Folder |
|---|---|---|
| 1 | Count the contacts on an account, with a trigger | [01-count-contacts](01-count-contacts/) |
| 2 | Stop duplicate contact emails before they're saved | [02-duplicate-emails](02-duplicate-emails/) |
| 3 | Roll up opportunity amounts to the account | [03-opportunity-amounts](03-opportunity-amounts/) |
| 4 | Recursion and the 200-record trap (at most one primary contact per account) | [04-primary-contact](04-primary-contact/) |
| 5 | At most 5 open opportunities per account (counting in bulk) | [05-opportunity-limit](05-opportunity-limit/) |

## Before you start

Use a free practice org, never a work org: a Developer Edition (sign up at `developer.salesforce.com/signup`) or a Trailhead Playground.

1. Install the [Salesforce CLI](https://developer.salesforce.com/tools/salesforcecli) and clone this repo.
2. Log in to your practice org, and make it your default:
   ```bash
   sf org login web --alias practice --set-default
   ```
3. Open a video's folder and follow its README.

## Licence

[MIT](LICENSE): fork it, use it, change it, share it. Keep the licence notice.

---

Salesforce, Trailhead and Apex are trademarks of Salesforce, Inc. This repo and the channel are not affiliated with Salesforce.
