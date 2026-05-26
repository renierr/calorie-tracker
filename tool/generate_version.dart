// ignore_for_file: avoid_print

import 'dart:io';


void main() async {
  print('Generating version.dart...');

  // 1. Get version from pubspec.yaml
  String version = 'unknown';
  try {
    final pubspecFile = File('pubspec.yaml');
    if (await pubspecFile.exists()) {
      final lines = await pubspecFile.readAsLines();
      for (var line in lines) {
        if (line.trim().startsWith('version:')) {
          version = line.split('version:')[1].trim();
          break;
        }
      }
    }
  } catch (e) {
    print('Error reading pubspec.yaml: $e');
  }

  // 2. Get git short hash
  String gitHash = 'unknown';
  try {
    final result = await Process.run('git', ['rev-parse', '--short', 'HEAD']);
    if (result.exitCode == 0) {
      gitHash = result.stdout.toString().trim();
    } else {
      print('Git command failed with code ${result.exitCode}: ${result.stderr}');
    }
  } catch (e) {
    print('Could not retrieve git hash: $e');
  }

  // 3. Write lib/version.g.dart
  try {
    final outputFile = File('lib/version.g.dart');
    // Ensure parent directories exist
    await outputFile.parent.create(recursive: true);
    
    final content = '''// Generated file. Do not edit.
part of 'version.dart';

const String rawVersion = '$version';
const String gitHash = '$gitHash';
''';
    await outputFile.writeAsString(content);
    print('Version generated: $version ($gitHash)');
  } catch (e) {
    print('Failed to write lib/version.g.dart: $e');
    exit(1);
  }
}
