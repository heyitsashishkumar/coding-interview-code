#!/bin/bash
# Video 4: switches on one of the two primary-contact triggers and switches off the other,
# in your default org (sf config set target-org <alias> to change it).
# Usage: 04-primary-contact/scripts/use.sh first-try|fix
set -euo pipefail
cd "$(dirname "$0")/.."
dir=force-app/main/default/triggers
case "${1:-}" in
	first-try) on=PrimaryContactFirstTry; off=PrimaryContactTrigger ;;
	fix) on=PrimaryContactTrigger; off=PrimaryContactFirstTry ;;
	*) echo "Usage: $0 first-try|fix"; exit 1 ;;
esac
perl -pi -e 's|<status>.*</status>|<status>Active</status>|' "$dir/$on.trigger-meta.xml"
perl -pi -e 's|<status>.*</status>|<status>Inactive</status>|' "$dir/$off.trigger-meta.xml"
sf project deploy start --source-dir "$dir/$on.trigger" --source-dir "$dir/$off.trigger" >/dev/null
echo "$on is on, $off is off."
