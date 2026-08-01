#!/usr/bin/env bash
# Scan pub-cache for deprecated Flutter embedding v1 artifacts that break recent Flutter SDKs.
# Usage: run this in CI or locally on the machine that will run the Flutter build.
# It searches ~/.pub-cache for ShimPluginRegistry, FlutterNativeView, PluginRegistrantCallback

set -euo pipefail
CACHE_DIR=${PUB_CACHE:-"$HOME/.pub-cache"}
REPORT_FILE="shim_scan_report.txt"

echo "Scanning pub-cache at: $CACHE_DIR" > "$REPORT_FILE"

echo "Searching for ShimPluginRegistry..." | tee -a "$REPORT_FILE"
grep -R --line-number --binary-files=without-match "ShimPluginRegistry" "$CACHE_DIR" --include "*.java" --include "*.kt" || true | tee -a "$REPORT_FILE"

echo "\nSearching for FlutterNativeView..." | tee -a "$REPORT_FILE"
grep -R --line-number --binary-files=without-match "FlutterNativeView" "$CACHE_DIR" --include "*.java" --include "*.kt" || true | tee -a "$REPORT_FILE"

echo "\nSearching for PluginRegistrantCallback..." | tee -a "$REPORT_FILE"
grep -R --line-number --binary-files=without-match "PluginRegistrantCallback" "$CACHE_DIR" --include "*.java" --include "*.kt" || true | tee -a "$REPORT_FILE"

# Produce a deduplicated list of affected package directories (hosted pub paths)

echo "\nAffected packages (deduped):" | tee -a "$REPORT_FILE"
(
  grep -R --line-number --binary-files=without-match "ShimPluginRegistry\|FlutterNativeView\|PluginRegistrantCallback" "$CACHE_DIR" --include "*.java" --include "*.kt" || true
) | awk -F'/' '{
  for(i=1;i<=NF;i++){
    if($i == "hosted" && (i+2)<=NF){
      print $(i+2)
    } else if($i ~ /pub-cache/ && NF>=7){
      # fallback: print last 4 parts
      print $(NF-3)"/"$(NF-2)"/"$(NF-1)"/"$NF
    }
  }
}' | sort -u | tee -a "$REPORT_FILE" || true

# Exit status 0 even if nothing found; CI should inspect the report

echo "\nScan complete. Report saved to $REPORT_FILE"

echo "If any packages are listed, update them to newer releases or point the dependency to the package git repo/main branch in pubspec.yaml. Example replacement in pubspec.yaml:\n\nandroid_alarm_manager_plus:\n  git:\n    url: https://github.com/fluttercommunity/android_alarm_manager_plus.git\n    ref: main\n" | tee -a "$REPORT_FILE"

exit 0
