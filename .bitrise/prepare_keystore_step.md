# Bitrise prepare keystore step (example)

# This file contains a ready-to-paste Script step for Bitrise that runs the
# tools/prepare_keystore.sh helper which decodes the KEYSTORE_BASE64 CI secret
# and writes android/my-release-key.jks + android/key.properties.

# HOW TO USE
# 1. In Bitrise Workflow Editor, open the workflow you use to build (e.g., "primary").
# 2. Add a new Step BEFORE the Flutter Build step.
# 3. Choose the "Script" step and copy the YAML below into the step's script area.
# 4. Save the workflow and trigger a build.

# SCRIPT CONTENT (paste into Bitrise Script step):

#!/bin/bash
set -euo pipefail

echo "Preparing Android keystore..."
chmod +x tools/prepare_keystore.sh
./tools/prepare_keystore.sh

echo "Keystore prepared."

# NOTES
# - Ensure the following Secrets are defined in Bitrise: KEYSTORE_BASE64, KEYSTORE_PASSWORD, KEY_ALIAS, KEY_PASSWORD
# - Do NOT enable "Expose for Pull Requests" for these secrets.
# - The script expects tools/prepare_keystore.sh to exist in the checked-out repo (it is present on the fix/shim-scan-and-updates branch).
# - If your Bitrise workflow checks out "main", merge this branch into main or copy the files to main before running.
