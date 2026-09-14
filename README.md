# Trackademic

Trackademic is a responsive Flutter and Firebase application for secure classroom attendance and course administration. One verified account can own courses, join other courses, and receive access according to course ownership or enrollment—not a permanent global role.

## Included workflows

- Email/password registration, verification, sign-in, reset, and editable profile
- Course creation, join codes, join requests, approvals, enrollment, and removal
- Teacher/student workspaces with responsive navigation and explicit back navigation
- Timetables with create, update, and delete operations
- Passcode and optional GPS-radius attendance with manual teacher overrides
- Attendance finalization, calculated summaries, and CSV export on web and Android
- Assessment creation, mark entry, and controlled publishing
- Real-time in-app notifications for course, schedule, attendance, and marks events
- Secure Firestore rules, deny-by-default Storage rules, App Check bootstrap, and local emulators
- Layered Material 3 visual system with responsive raised surfaces and ambient depth

## Stack

- Flutter / Dart
- Firebase Authentication
- Cloud Firestore
- Cloud Functions for Firebase (TypeScript, Node.js 24)
- Firebase App Check
- Firebase Emulator Suite

Production targets configured in this repository are Android, iOS, and web.

## Prerequisites

- Flutter stable with Dart 3.12 or newer
- Node.js 24
- Firebase CLI 15 or newer
- Access to Firebase project `trackademic-0`

In Firebase Console, enable Email/Password authentication. Before a production release, also configure Play Integrity for Android, DeviceCheck for iOS, and reCAPTCHA v3 for web under App Check.

## Install

```bash
cd ~/Projects/trackademic
flutter pub get
npm --prefix functions ci
```

The tracked Firebase client configuration contains public app identifiers only. Never commit service-account keys, keystores, passwords, or private API credentials.

## Run locally with Firebase emulators

Terminal 1:

```bash
cd ~/Projects/trackademic
firebase emulators:start --only auth,firestore,functions,storage
```

Terminal 2 (Chrome):

```bash
cd ~/Projects/trackademic
flutter run -d chrome --dart-define=USE_FIREBASE_EMULATORS=true
```

For an Android emulator, use the same `flutter run` flag. Trackademic automatically connects Android emulators through `10.0.2.2` and other debug platforms through `127.0.0.1`.

## Run against production Firebase

Android or iOS:

```bash
cd ~/Projects/trackademic
flutter run
```

Web App Check requires the reCAPTCHA v3 site key (a site key is public and safe to pass at build time):

```bash
cd ~/Projects/trackademic
flutter run -d chrome \
  --dart-define=FIREBASE_WEB_RECAPTCHA_KEY=YOUR_RECAPTCHA_V3_SITE_KEY
```

## Validate everything

```bash
cd ~/Projects/trackademic
./tool/check.sh
```

The script checks formatting, Flutter analysis/tests, Cloud Functions lint/build, JSON syntax, and whitespace errors.

## Deploy backend and web

```bash
cd ~/Projects/trackademic
firebase use trackademic-0
firebase deploy --only firestore:rules,firestore:indexes,storage,functions

flutter build web --release \
  --dart-define=FIREBASE_WEB_RECAPTCHA_KEY=YOUR_RECAPTCHA_V3_SITE_KEY
firebase deploy --only hosting
```

Cloud Functions deployment requires the Firebase project to use the Blaze plan. Emulator development remains local.

## Android release signing

The default generated project still uses debug signing for local release-mode runs. Before publishing, create a private upload keystore and configure `android/key.properties` as described in Flutter's Android deployment guide. Both `key.properties` and keystore files are already ignored by Git.

## Security model

- Firestore access requires a signed-in, email-verified, active user.
- Course ownership and active enrollment determine data access.
- Sensitive attendance passcodes and coordinates are stored in a denied private subcollection.
- All academic writes go through validated callable Cloud Functions.
- Storage is denied until a reviewed upload feature is intentionally added.

Do not weaken the rules for development; use the emulator suite instead.
