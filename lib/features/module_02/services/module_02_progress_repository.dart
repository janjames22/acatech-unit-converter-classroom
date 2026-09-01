import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/module_02_content.dart';
import '../models/module_02_progress.dart';

abstract interface class Module2ProgressRepository {
  Future<Module2Progress> load();

  Future<void> save(Module2Progress progress);
}

final class SharedPreferencesModule2ProgressRepository
    implements Module2ProgressRepository {
  SharedPreferencesModule2ProgressRepository(this._preferences);

  static const storageKey = 'curriculum.module_02.v1.progress';

  final SharedPreferences _preferences;

  @override
  Future<Module2Progress> load() async {
    final raw = _preferences.getString(storageKey);
    if (raw == null || raw.isEmpty) {
      return const Module2Progress();
    }
    final decoded = jsonDecode(raw);
    if (decoded is! Map<Object?, Object?>) {
      throw const FormatException('Stored Module 2 progress is invalid.');
    }
    return Module2Progress.fromJson(
      decoded.map((key, value) => MapEntry(key.toString(), value)),
    );
  }

  @override
  Future<void> save(Module2Progress progress) async {
    await _preferences.setString(
      storageKey,
      jsonEncode(
        progress.toJson(
          lessonCount: Module2Curriculum.lessons.length,
          questionCount: Module2Curriculum.practiceProblems.length,
        ),
      ),
    );
  }
}

final class InMemoryModule2ProgressRepository
    implements Module2ProgressRepository {
  Module2Progress _progress = const Module2Progress();

  @override
  Future<Module2Progress> load() async => _progress;

  @override
  Future<void> save(Module2Progress progress) async {
    _progress = progress;
  }
}
