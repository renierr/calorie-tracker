import 'dart:io';

import 'package:flutter/services.dart';

class AndroidDatabaseRestorePicker {
  AndroidDatabaseRestorePicker._();

  static const _channel = MethodChannel(
    'de.renier.calorie_tracker/database_restore',
  );

  /// The Android side copies the selected document into app cache so the large
  /// database never crosses Flutter's platform channel as a byte array.
  static Future<String?> pick() async {
    if (!Platform.isAndroid) return null;
    return _channel.invokeMethod<String>('pickDatabase');
  }
}
