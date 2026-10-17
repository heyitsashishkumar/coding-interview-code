#!/bin/bash
# Video 1: switches on one of the two count triggers and switches off the other,
# in your default org (sf config set target-org <alias> to change it).
# Usage: 01-count-contacts/scripts/use.sh first-try|fix
set -euo pipefail
cd "$(dirname "$0")/.."
dir=force-app/main/default/triggers
case "${1:-}" in
	first-try) on=ContactCountFirstTry; off=ContactCountTrigger ;;
	fix) on=ContactCountTrigger; off=ContactCountFirstTry ;;
	*) echo "Usage: $0 first-try|fix"; exit 1 ;;
esac
# perl -pi works the same on macOS, Linux and Git Bash (sed -i doesn't).
perl -pi -e 's|<status>.*</status>|<status>Active</status>|' "$dir/$on.trigger-meta.xml"
perl -pi -e 's|<status>.*</status>|<status>Inactive</status>|' "$dir/$off.trigger-meta.xml"
sf project deploy start --source-dir "$dir/$on.trigger" --source-dir "$dir/$off.trigger" >/dev/null
echo "$on is on, $off is off."
