part of 'app_state.dart';

mixin _SyncState on ChangeNotifier {
  AppState get _state => this as AppState;

  Future<void> _trySyncIfAvailable() async {
    if (!_state._syncEnabled || _state._syncServerUrl.isEmpty) return;
    try {
      final available = await SyncService.isBackendAvailable(
        _state._syncServerUrl,
      );
      if (available) {
        await syncWithBackend();
      }
    } catch (e) {
      debugPrint('[AppState] Background sync skipped: $e');
    }
  }

  Future<void> saveSyncSettings({
    required String serverUrl,
    required String userId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    _state._syncServerUrl = serverUrl.trim();
    _state._syncUserId = userId.trim();

    await prefs.setString(AppState._keySyncServerUrl, _state._syncServerUrl);
    await prefs.setString(AppState._keySyncUserId, _state._syncUserId);
    notifyListeners();
  }

  Future<void> setSyncEnabled(bool enabled) async {
    _state._syncEnabled = enabled;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppState._keySyncEnabled, enabled);

    if (_state._syncEnabled && _state._syncServerUrl.isNotEmpty) {
      _trySyncIfAvailable();
    }
  }

  Future<Map<String, int>?> syncWithBackend({bool manual = false}) async {
    if (!_state._syncEnabled || _state._syncServerUrl.isEmpty) return null;

    _state._isSyncing = true;
    notifyListeners();

    try {
      final results = await SyncService.sync(
        baseUrl: _state._syncServerUrl,
        userId: _state._syncUserId,
      );

      _state._lastSyncedTime = DateTime.now().millisecondsSinceEpoch;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(AppState._keyLastSyncedTime, _state._lastSyncedTime!);

      await _state.loadMeals();
      return results;
    } catch (e) {
      debugPrint('[AppState] Sync failed: $e');
      rethrow;
    } finally {
      _state._isSyncing = false;
      notifyListeners();
    }
  }
}
