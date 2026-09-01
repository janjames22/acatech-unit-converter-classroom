import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/module_04_content.dart';
import '../models/module_04_progress.dart';

abstract interface class Module4ProgressRepository {
  Future<Module4Progress> load();
  Future<void> save(Module4Progress progress);
}

final class SharedPreferencesModule4ProgressRepository
    implements Module4ProgressRepository {
  SharedPreferencesModule4ProgressRepository(this._preferences);

  static const storageKey = 'curriculum.module_04.v1.progress';

  final SharedPreferences _preferences;

  @override
  Future<Module4Progress> load() async {
    final raw = _preferences.getString(storageKey);
    if (raw == null || raw.isEmpty) {
      return const Module4Progress();
    }
    final decoded = jsonDecode(raw);
    if (decoded is! Map<Object?, Object?>) {
      throw const FormatException('Stored Module 4 progress is invalid.');
    }
    return Module4Progress.fromJson(
      decoded.map((key, value) => MapEntry(key.toString(), value)),
    );
  }

  @override
  Future<void> save(Module4Progress progress) async {
    await _preferences.setString(
      storageKey,
      jsonEncode(
        progress.toJson(
          lessonCount: Module4Curriculum.lessons.length,
          questionCount: Module4Curriculum.practiceProblems.length,
        ),
      ),
    );
  }
}

final class InMemoryModule4ProgressRepository
    implements Module4ProgressRepository {
  Module4Progress _progress = const Module4Progress();

  @override
  Future<Module4Progress> load() async => _progress;

  @override
  Future<void> save(Module4Progress progress) async {
    _progress = progress;
  }
}
