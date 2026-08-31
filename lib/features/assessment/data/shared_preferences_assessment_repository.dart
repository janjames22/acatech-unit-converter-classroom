import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/models/assessment_incident.dart';
import '../domain/models/assessment_session.dart';
import '../domain/models/pending_absence.dart';
import '../domain/repositories/assessment_repository.dart';

/// Local-only persistence for the first product release.
///
/// The repository contract intentionally does not expose SharedPreferences so
/// a future synchronized repository can decorate or replace this class.
final class SharedPreferencesAssessmentRepository
    implements AssessmentRepository {
  SharedPreferencesAssessmentRepository(this._preferences);

  static const _sessionsKey = 'assessment.v1.sessions';
  static const _incidentsKey = 'assessment.v1.incidents';
  static const _pendingKey = 'assessment.v1.pending_absence';

  final SharedPreferences _preferences;

  @override
  Future<void> saveSession(AssessmentSession session) async {
    final sessions = await loadSessions();
    final index = sessions.indexWhere((item) => item.id == session.id);
    if (index == -1) {
      sessions.add(session);
    } else {
      sessions[index] = session;
    }
    await _preferences.setString(
      _sessionsKey,
      jsonEncode([for (final item in sessions) item.toJson()]),
    );
  }

  @override
  Future<AssessmentSession?> loadSession(String id) async {
    for (final session in await loadSessions()) {
      if (session.id == id) {
        return session;
      }
    }
    return null;
  }

  @override
  Future<AssessmentSession?> loadActiveSession() async {
    final active = (await loadSessions()).where((session) => session.isActive);
    return active.isEmpty ? null : active.first;
  }

  @override
  Future<List<AssessmentSession>> loadSessions() async {
    final raw = _preferences.getString(_sessionsKey);
    if (raw == null || raw.isEmpty) {
      return <AssessmentSession>[];
    }
    final decoded = jsonDecode(raw);
    if (decoded is! List<Object?>) {
      throw const FormatException('Stored assessment sessions are invalid.');
    }
    final sessions = decoded
        .map((item) => AssessmentSession.fromJson(_jsonMap(item)))
        .toList();
    sessions.sort((left, right) => right.startedAt.compareTo(left.startedAt));
    return sessions;
  }

  @override
  Future<void> saveIncident(AssessmentIncident incident) async {
    final incidents = await _loadAllIncidents();
    final index = incidents.indexWhere((item) => item.id == incident.id);
    if (index == -1) {
      incidents.add(incident);
    } else {
      incidents[index] = incident;
    }
    await _preferences.setString(
      _incidentsKey,
      jsonEncode([for (final item in incidents) item.toJson()]),
    );
  }

  @override
  Future<AssessmentIncident?> loadIncident(String id) async {
    for (final incident in await _loadAllIncidents()) {
      if (incident.id == id) {
        return incident;
      }
    }
    return null;
  }

  @override
  Future<List<AssessmentIncident>> loadIncidents(String sessionId) async {
    final incidents = (await _loadAllIncidents())
        .where((incident) => incident.sessionId == sessionId)
        .toList();
    incidents.sort((left, right) => left.leftAt.compareTo(right.leftAt));
    return incidents;
  }

  Future<List<AssessmentIncident>> _loadAllIncidents() async {
    final raw = _preferences.getString(_incidentsKey);
    if (raw == null || raw.isEmpty) {
      return <AssessmentIncident>[];
    }
    final decoded = jsonDecode(raw);
    if (decoded is! List<Object?>) {
      throw const FormatException('Stored assessment incidents are invalid.');
    }
    return decoded
        .map((item) => AssessmentIncident.fromJson(_jsonMap(item)))
        .toList();
  }

  @override
  Future<void> savePendingAbsence(PendingAbsence pendingAbsence) async {
    await _preferences.setString(
      _pendingKey,
      jsonEncode(pendingAbsence.toJson()),
    );
  }

  @override
  Future<PendingAbsence?> loadPendingAbsence() async {
    final raw = _preferences.getString(_pendingKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return PendingAbsence.fromJson(_jsonMap(jsonDecode(raw)));
  }

  @override
  Future<void> clearPendingAbsence(String incidentId) async {
    final current = await loadPendingAbsence();
    if (current?.incidentId == incidentId) {
      await _preferences.remove(_pendingKey);
    }
  }

  @override
  Future<void> deleteAll() async {
    await _preferences.remove(_sessionsKey);
    await _preferences.remove(_incidentsKey);
    await _preferences.remove(_pendingKey);
  }

  static Map<String, Object?> _jsonMap(Object? value) {
    if (value is! Map<Object?, Object?>) {
      throw const FormatException('Stored assessment record is invalid.');
    }
    return value.map((key, item) => MapEntry(key.toString(), item));
  }
}
