import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/module_05_content.dart';
import '../models/module_05_progress.dart';

abstract interface class Module5ProgressRepository {
  Future<Module5Progress> load();
  Future<void> save(Module5Progress progress);
}

final class SharedPreferencesModule5ProgressRepository
    implements Module5ProgressRepository {
  SharedPreferencesModule5ProgressRepository(this._preferences);

  static const storageKey = 'curriculum.module_05.v1.progress';

  final SharedPreferences _preferences;

  @override
  Future<Module5Progress> load() async {
    final raw = _preferences.getString(storageKey);
    if (raw == null || raw.isEmpty) {
      return const Module5Progress();
    }
    final decoded = jsonDecode(raw);
    if (decoded is! Map<Object?, Object?>) {
      throw const FormatException('Stored Module 5 progress is invalid.');
    }
    return Module5Progress.fromJson(
      decoded.map((key, value) => MapEntry(key.toString(), value)),
    );
  }

  @override
  Future<void> save(Module5Progress progress) async {
    await _preferences.setString(
      storageKey,
      jsonEncode(
        progress.toJson(
          lessonCount: Module5Curriculum.lessons.length,
          questionCount: Module5Curriculum.practiceProblems.length,
        ),
      ),
    );
  }
}

final class InMemoryModule5ProgressRepository
    implements Module5ProgressRepository {
  Module5Progress _progress = const Module5Progress();

  @override
  Future<Module5Progress> load() async => _progress;

  @override
  Future<void> save(Module5Progress progress) async {
    _progress = progress;
  }
}
