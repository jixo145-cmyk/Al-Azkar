CI keystore helper

This helper writes a keystore and key.properties file into the android/ directory at build time.

How to create and upload secrets (example, run locally then paste values into your CI secrets):

1) Create a keystore locally (example):
   keytool -genkey -v -keystore my-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias my-key-alias

2) Base64-encode the keystore and copy the result into a CI secret named KEYSTORE_BASE64:
   base64 my-release-key.jks | pbcopy   # macOS
   # or
   base64 my-release-key.jks > keystore.b64
   # then copy the contents of keystore.b64 into the CI secret value

3) Add the following CI secrets (names used by the script):
   - KEYSTORE_BASE64  # the base64 content
   - KEYSTORE_PASSWORD
   - KEY_ALIAS
   - KEY_PASSWORD

4) In your CI pipeline, before building, run:
   chmod +x tools/prepare_keystore.sh
   ./tools/prepare_keystore.sh

This will produce:
   - android/my-release-key.jks
   - android/key.properties

5) Continue your build steps (example):
   flutter pub get
   flutter clean
   flutter build apk --release

Security notes
- Do NOT commit your keystore or key.properties to the repository.
- Store secrets in your CI provider's secure secrets store.
- The script writes files at build time only.

If you want, I can also open a PR that adds a usage example in your CI config file (Bitrise/GitHub Actions) — tell me which CI provider you use and I will add it to the PR.
