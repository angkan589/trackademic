import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';

abstract final class FirebaseAppCheckConfig {
  static const _webSiteKey = String.fromEnvironment(
    'FIREBASE_WEB_RECAPTCHA_KEY',
  );

  static Future<void> activate() async {
    if (kIsWeb) {
      if (_webSiteKey.isEmpty) {
        if (kDebugMode) {
          debugPrint(
            'Firebase App Check is disabled on web. Pass '
            '--dart-define=FIREBASE_WEB_RECAPTCHA_KEY=<site-key> to enable it.',
          );
        }
        return;
      }

      await FirebaseAppCheck.instance.activate(
        webProvider: ReCaptchaV3Provider(_webSiteKey),
      );
      return;
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      await FirebaseAppCheck.instance.activate(
        androidProvider: kDebugMode
            ? AndroidProvider.debug
            : AndroidProvider.playIntegrity,
      );
      return;
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      await FirebaseAppCheck.instance.activate(
        appleProvider: kDebugMode
            ? AppleProvider.debug
            : AppleProvider.deviceCheck,
      );
    }
  }
}
