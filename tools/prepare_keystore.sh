#!/usr/bin/env bash
set -euo pipefail

# prepare_keystore.sh
# Decode a base64-encoded keystore (from CI secret KEYSTORE_BASE64) and write android/key.properties
# REQUIRED environment variables (set as CI secrets for signing):
# - KEYSTORE_BASE64  (base64 contents of your .jks file)
# - KEYSTORE_PASSWORD
# - KEY_ALIAS
# - KEY_PASSWORD

# Locate the Flutter project directory (the directory that contains pubspec.yaml)
PROJECT_DIR="$(dirname "$(find . -maxdepth 4 -name pubspec.yaml -print | head -n1 || true)")"
if [ -z "$PROJECT_DIR" ] || [ "$PROJECT_DIR" = "." ]; then
  PROJECT_DIR="."
fi

# If KEYSTORE_BASE64 is not set or empty, skip creating a keystore (produce an unsigned build)
if [ -z "${KEYSTORE_BASE64:-}" ]; then
  echo "No KEYSTORE_BASE64 provided — skipping keystore creation. Build will be unsigned."
  exit 0
fi

: "${KEYSTORE_PASSWORD?Need KEYSTORE_PASSWORD when providing KEYSTORE_BASE64}"
: "${KEY_ALIAS?Need KEY_ALIAS when providing KEYSTORE_BASE64}"
: "${KEY_PASSWORD?Need KEY_PASSWORD when providing KEYSTORE_BASE64}"

echo "Preparing Android keystore and key.properties in project dir: $PROJECT_DIR"

mkdir -p "$PROJECT_DIR/android"

# Decode base64. Using printf to avoid issues with leading/trailing newlines.
printf '%s' "$KEYSTORE_BASE64" | base64 --decode > "$PROJECT_DIR/android/my-release-key.jks"
chmod 600 "$PROJECT_DIR/android/my-release-key.jks"

# Write key.properties reliably without a heredoc (avoids indentation/heredoc EOF issues in CI)
{
  printf 'storePassword=%s\n' "$KEYSTORE_PASSWORD"
  printf 'keyPassword=%s\n' "$KEY_PASSWORD"
  printf 'keyAlias=%s\n' "$KEY_ALIAS"
  printf 'storeFile=%s\n' "my-release-key.jks"
} > "$PROJECT_DIR/android/key.properties"

echo "Wrote $PROJECT_DIR/android/my-release-key.jks and $PROJECT_DIR/android/key.properties"
