import 'dart:io';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class SecureStorage {
  Future<String?> readApiKey(String provider);
  Future<void> writeApiKey(String provider, String value);
  Future<void> deleteApiKey(String provider);
  Future<Map<String, String>> readAllApiKeys();
  Future<bool> hasApiKey(String provider);
  Future<void> migrateFromSharedPreferences(SharedPreferences prefs);
}

SecureStorage createSecureStorage() {
  return SecureStorageService();
}

class SecureStorageService implements SecureStorage {
  static const _prefixApiKey = 'secure_ai_api_key_';

  final FlutterSecureStorage _storage;

  SecureStorageService({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  @override
  Future<String?> readApiKey(String provider) async {
    return await _storage.read(key: '$_prefixApiKey${provider.toLowerCase()}');
  }

  @override
  Future<void> writeApiKey(String provider, String value) async {
    await _storage.write(
      key: '$_prefixApiKey${provider.toLowerCase()}',
      value: value,
    );
  }

  @override
  Future<void> deleteApiKey(String provider) async {
    await _storage.delete(key: '$_prefixApiKey${provider.toLowerCase()}');
  }

  @override
  Future<Map<String, String>> readAllApiKeys() async {
    final all = await _storage.readAll();
    final result = <String, String>{};
    for (final entry in all.entries) {
      if (entry.key.startsWith(_prefixApiKey)) {
        final provider = entry.key.substring(_prefixApiKey.length);
        result[provider] = entry.value;
      }
    }
    return result;
  }

  @override
  Future<bool> hasApiKey(String provider) async {
    return (await readApiKey(provider))?.isNotEmpty ?? false;
  }

  @override
  Future<void> migrateFromSharedPreferences(SharedPreferences prefs) async {
    final spKeys = <String>[
      'ai_api_key',
      'ai_api_key_gemini',
      'ai_api_key_openai',
      'ai_api_key_anthropic',
      'ai_api_key_grok',
      'ai_api_key_custom',
      'gemini_api_key',
    ];

    bool didMigrate = false;

    for (final spKey in spKeys) {
      final value = prefs.getString(spKey);
      if (value != null && value.isNotEmpty) {
        final provider = _spKeyToProvider(spKey);
        final existing = await readApiKey(provider);
        if (existing == null || existing.isEmpty) {
          await writeApiKey(provider, value);
        }
        await prefs.remove(spKey);
        didMigrate = true;
      }
    }

    if (didMigrate) {
      await prefs.setBool('_api_keys_migrated', true);
    }
  }

  String _spKeyToProvider(String spKey) {
    switch (spKey) {
      case 'ai_api_key':
        return 'current';
      case 'gemini_api_key':
        return 'gemini';
      default:
        return spKey.replaceFirst('ai_api_key_', '');
    }
  }
}

class FileSecureStorage implements SecureStorage {
  static const _fileName = 'secure_credentials.json';
  Map<String, String>? _cache;

  Future<File> get _file async {
    final dir = await getApplicationSupportDirectory();
    return File('${dir.path}/$_fileName');
  }

  Future<Map<String, String>> _load() async {
    if (_cache != null) return _cache!;
    final file = await _file;
    if (await file.exists()) {
      try {
        final content = await file.readAsString();
        final decoded = json.decode(content) as Map<String, dynamic>;
        _cache = decoded.map((k, v) => MapEntry(k, v.toString()));
        return _cache!;
      } catch (_) {
        _cache = {};
        return _cache!;
      }
    }
    _cache = {};
    return _cache!;
  }

  Future<void> _save() async {
    if (_cache == null) return;
    final file = await _file;
    await file.writeAsString(json.encode(_cache));
  }

  @override
  Future<String?> readApiKey(String provider) async {
    final data = await _load();
    return data['provider:${provider.toLowerCase()}'];
  }

  @override
  Future<void> writeApiKey(String provider, String value) async {
    final data = await _load();
    data['provider:${provider.toLowerCase()}'] = value;
    await _save();
  }

  @override
  Future<void> deleteApiKey(String provider) async {
    final data = await _load();
    data.remove('provider:${provider.toLowerCase()}');
    await _save();
  }

  @override
  Future<Map<String, String>> readAllApiKeys() async {
    final data = await _load();
    final result = <String, String>{};
    for (final entry in data.entries) {
      if (entry.key.startsWith('provider:')) {
        result[entry.key.substring('provider:'.length)] = entry.value;
      }
    }
    return result;
  }

  @override
  Future<bool> hasApiKey(String provider) async {
    final data = await _load();
    return data.containsKey('provider:${provider.toLowerCase()}');
  }

  @override
  Future<void> migrateFromSharedPreferences(SharedPreferences prefs) async {
    final spKeys = <String>[
      'ai_api_key',
      'ai_api_key_gemini',
      'ai_api_key_openai',
      'ai_api_key_anthropic',
      'ai_api_key_grok',
      'ai_api_key_custom',
      'gemini_api_key',
    ];

    bool didMigrate = false;

    for (final spKey in spKeys) {
      final value = prefs.getString(spKey);
      if (value != null && value.isNotEmpty) {
        final provider = _spKeyToProvider(spKey);
        final existing = await readApiKey(provider);
        if (existing == null || existing.isEmpty) {
          await writeApiKey(provider, value);
        }
        await prefs.remove(spKey);
        didMigrate = true;
      }
    }

    if (didMigrate) {
      await prefs.setBool('_api_keys_migrated', true);
    }
  }

  String _spKeyToProvider(String spKey) {
    switch (spKey) {
      case 'ai_api_key':
        return 'current';
      case 'gemini_api_key':
        return 'gemini';
      default:
        return spKey.replaceFirst('ai_api_key_', '');
    }
  }
}

class InMemorySecureStorage implements SecureStorage {
  final _store = <String, String>{};

  @override
  Future<String?> readApiKey(String provider) async {
    return _store['provider:${provider.toLowerCase()}'];
  }

  @override
  Future<void> writeApiKey(String provider, String value) async {
    _store['provider:${provider.toLowerCase()}'] = value;
  }

  @override
  Future<void> deleteApiKey(String provider) async {
    _store.remove('provider:${provider.toLowerCase()}');
  }

  @override
  Future<Map<String, String>> readAllApiKeys() async {
    final result = <String, String>{};
    for (final entry in _store.entries) {
      if (entry.key.startsWith('provider:')) {
        result[entry.key.substring('provider:'.length)] = entry.value;
      }
    }
    return result;
  }

  @override
  Future<bool> hasApiKey(String provider) async {
    return _store.containsKey('provider:${provider.toLowerCase()}');
  }

  @override
  Future<void> migrateFromSharedPreferences(SharedPreferences prefs) async {}
}
