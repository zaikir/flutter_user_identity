# flutter_user_identity

This Flutter package provides an async function apps running on both iOS and Android. It returns an iCloud user identity on iOS and an email on Android.

# Installation

## IOS
1. Add the following to your `Info.Plis` file:
```xml
<key>CK_CONTAINER_IDENTIFIER</key>
<string>iCloud.${bundle_id}</string>
```

2. Add this to ios/Runner/Runner.entitlements (or create and include this file to to project if it doesn't exist):
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
  <dict>
    <key>aps-environment</key>
    <string>development</string>
    <key>com.apple.developer.icloud-container-identifiers</key>
    <array>
      <string>iCloud.${bundle_id}</string>
    </array>
    <key>com.apple.developer.icloud-services</key>
    <array>
      <string>CloudKit</string>
      <string>CloudDocuments</string>
    </array>
    <key>com.apple.developer.ubiquity-container-identifiers</key>
    <array>
      <string>iCloud.${bundle_id}</string>
    </array>
    <key>com.apple.developer.ubiquity-kvstore-identifier</key>
    <string>$(TeamIdentifierPrefix)$(CFBundleIdentifier)</string>
  </dict>
</plist>
```

3. Change ${bundle_id} to your actual bundle id

# Usage

```dart
final userId = await FlutterUserIdentity().getUserIdentity();
```