Shim scan and fix instructions

This branch (fix/shim-scan-and-updates) contains tooling and instructions to detect and fix Flutter embedding v1 shim issues that cause Android build failures (ShimPluginRegistry, FlutterNativeView, PluginRegistrantCallback).

Files added:
- tools/scan_shim_issues.sh — shell script to run in CI or locally; it scans ~/.pub-cache for problematic references and emits shim_scan_report.txt.

What I changed already
- Updated alazkar/pubspec.yaml to point android_alarm_manager_plus at the package GitHub main branch so you get the migration fixes immediately.

How to use the scan script (recommended run in CI or on the build machine):
1) Give the script execute permission (if running locally):
   chmod +x tools/scan_shim_issues.sh
2) Run it in the build environment where the Flutter pub-cache is available (CI runner or local dev machine):
   tools/scan_shim_issues.sh

It will write shim_scan_report.txt in the current working directory and print a deduped list of affected packages.

Next automated steps I can perform (pick one by replying):
- I can update additional dependencies in pubspec.yaml to point to the corresponding GitHub main branches if the scan shows they still use shim APIs.
- I can prepare small patches (Java/Kotlin) to migrate a plugin that has no published fix and commit them to this branch.
- I can open a PR for this branch so your CI runs the full Android build with the updated dependency set.

If you want me to proceed automatically, reply "Proceed fixes" and I will:
- Run the scan (note: I cannot run it on your CI machine or local pub-cache from here). Instead I will rely on the report you upload or CI artifact.
- Based on the report, update pubspec.yaml entries or prepare patches and push them to this branch.

If you prefer manual testing first, run the scan in your CI and paste shim_scan_report.txt here and I'll act on it.
