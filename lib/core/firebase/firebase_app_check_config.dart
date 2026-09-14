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
        providerWeb: ReCaptchaV3Provider(_webSiteKey),
      );
      return;
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      await FirebaseAppCheck.instance.activate(
        providerAndroid: kDebugMode
            ? const AndroidDebugProvider()
            : const AndroidPlayIntegrityProvider(),
      );
      return;
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      await FirebaseAppCheck.instance.activate(
        providerApple: kDebugMode
            ? const AppleDebugProvider()
            : const AppleDeviceCheckProvider(),
      );
    }
  }
}
