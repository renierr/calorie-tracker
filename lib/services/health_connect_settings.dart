import 'dart:io';

import 'package:flutter/services.dart';

class HealthConnectSettings {
  HealthConnectSettings._();

  static const _channel = MethodChannel(
    'de.renier.calorie_tracker/health_connect',
  );

  static Future<bool> open() async {
    if (!Platform.isAndroid) return false;
    final result = await _channel.invokeMapMethod<String, Object?>(
      'openSettings',
    );
    return result?['fallback'] == true;
  }
}
