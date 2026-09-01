import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/module_03_content.dart';
import '../models/module_03_progress.dart';

abstract interface class Module3ProgressRepository {
  Future<Module3Progress> load();
  Future<void> save(Module3Progress progress);
}

final class SharedPreferencesModule3ProgressRepository
    implements Module3ProgressRepository {
  SharedPreferencesModule3ProgressRepository(this._preferences);

  static const storageKey = 'curriculum.module_03.v1.progress';

  final SharedPreferences _preferences;

  @override
  Future<Module3Progress> load() async {
    final raw = _preferences.getString(storageKey);
    if (raw == null || raw.isEmpty) {
      return const Module3Progress();
    }
    final decoded = jsonDecode(raw);
    if (decoded is! Map<Object?, Object?>) {
      throw const FormatException('Stored Module 3 progress is invalid.');
    }
    return Module3Progress.fromJson(
      decoded.map((key, value) => MapEntry(key.toString(), value)),
    );
  }

  @override
  Future<void> save(Module3Progress progress) async {
    await _preferences.setString(
      storageKey,
      jsonEncode(
        progress.toJson(
          lessonCount: Module3Curriculum.lessons.length,
          questionCount: Module3Curriculum.practiceProblems.length,
        ),
      ),
    );
  }
}

final class InMemoryModule3ProgressRepository
    implements Module3ProgressRepository {
  Module3Progress _progress = const Module3Progress();

  @override
  Future<Module3Progress> load() async => _progress;

  @override
  Future<void> save(Module3Progress progress) async {
    _progress = progress;
  }
}
