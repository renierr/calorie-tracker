part 'version.g.dart';

class AppVersion {
  const AppVersion._();

  static const String defaultVersion = 'development';
  static const String defaultGitHash = 'unknown';

  /// Returns the version string, omitting the build number (+X) if present.
  static String get version {
    const raw = rawVersion;
    if (raw == 'unknown') {
      return defaultVersion;
    }
    final plusIndex = raw.indexOf('+');
    if (plusIndex != -1) {
      return raw.substring(0, plusIndex);
    }
    return raw;
  }

  /// Returns the git commit hash.
  static String get commitHash {
    const hash = gitHash;
    if (hash == 'unknown') {
      return defaultGitHash;
    }
    return hash;
  }
}
