#!/usr/bin/env bash
set -euo pipefail

# prepare_keystore.sh
# Decode a base64-encoded keystore (from CI secret KEYSTORE_BASE64) and write android/key.properties
# REQUIRED environment variables (set as CI secrets):
# - KEYSTORE_BASE64  (base64 contents of your .jks file)
# - KEYSTORE_PASSWORD
# - KEY_ALIAS
# - KEY_PASSWORD

: "${KEYSTORE_BASE64?Need to set KEYSTORE_BASE64 env secret (base64 of .jks)}"
: "${KEYSTORE_PASSWORD?Need KEYSTORE_PASSWORD}"
: "${KEY_ALIAS?Need KEY_ALIAS}"
: "${KEY_PASSWORD?Need KEY_PASSWORD}"

echo "Preparing Android keystore and key.properties..."

mkdir -p android

# Decode base64. Using printf to avoid issues with leading/trailing newlines.
printf '%s' "$KEYSTORE_BASE64" | base64 --decode > android/my-release-key.jks
chmod 600 android/my-release-key.jks

# Write key.properties reliably without a heredoc (avoids indentation/heredoc EOF issues in CI)
{
  printf 'storePassword=%s\n' "$KEYSTORE_PASSWORD"
  printf 'keyPassword=%s\n' "$KEY_PASSWORD"
  printf 'keyAlias=%s\n' "$KEY_ALIAS"
  printf 'storeFile=%s\n' "my-release-key.jks"
} > android/key.properties

echo "Wrote android/my-release-key.jks and android/key.properties"
