import 'dart:io';

import 'package:health_connector/health_connector.dart' as hc;

/// Reads the user's body weight from Health Connect so it can prefill the
/// weight field when logging the first meal of the day (Android only).
class HealthConnectWeightReader {
  HealthConnectWeightReader._();

  static final HealthConnectWeightReader instance =
      HealthConnectWeightReader._();

  /// Returns the latest weight (kg) from Health Connect for [date].
  ///
  /// If there is no weight record for that day, and [date] is today, falls
  /// back to the latest weight that is not older than 12 hours. Returns `null`
  /// on non-Android platforms, when read permission is missing, or when no
  /// matching record exists.
  Future<double?> readLatestWeightForPrefill(DateTime date) async {
    if (!Platform.isAndroid) return null;

    try {
      final connector = await hc.HealthConnector.create();
      if (!await _ensureReadAccess(connector)) return null;

      final dayStart = DateTime(date.year, date.month, date.day);
      final dayEnd = dayStart.add(const Duration(days: 1));

      // 1) Latest weight for the selected day.
      final dayRecords = await _readWeightRange(connector, dayStart, dayEnd);
      if (dayRecords.isNotEmpty) return _latestWeight(dayRecords);

      // 2) No weight that day → only accept a weight not older than 12 hours.
      //    This fallback only makes sense when the selected day is today.
      final now = DateTime.now();
      final isToday =
          dayStart.year == now.year &&
          dayStart.month == now.month &&
          dayStart.day == now.day;
      if (!isToday) return null;

      final cutoff = now.subtract(const Duration(hours: 12));
      final recentRecords = await _readWeightRange(connector, cutoff, now);
      if (recentRecords.isNotEmpty) return _latestWeight(recentRecords);

      return null;
    } catch (error) {
      stderr.writeln('[HealthConnect] Weight read failed: $error');
      return null;
    }
  }

  Future<bool> _ensureReadAccess(hc.HealthConnector connector) async {
    final permission = hc.HealthDataType.weight.readPermission;
    final results = await connector.requestPermissions([permission]);
    if (results.any((result) => result.status == hc.PermissionStatus.granted)) {
      return true;
    }
    try {
      return (await connector.getGrantedPermissions()).contains(permission);
    } catch (error) {
      stderr.writeln('[HealthConnect] Weight permission lookup failed: $error');
      return false;
    }
  }

  Future<List<hc.WeightRecord>> _readWeightRange(
    hc.HealthConnector connector,
    DateTime start,
    DateTime end,
  ) async {
    final response = await connector.readRecords(
      hc.HealthDataType.weight.readInTimeRange(startTime: start, endTime: end),
    );
    return response.records;
  }

  double? _latestWeight(List<hc.WeightRecord> records) {
    if (records.isEmpty) return null;
    final sorted = [...records]..sort((a, b) => b.time.compareTo(a.time));
    return sorted.first.weight.inKilograms;
  }
}
