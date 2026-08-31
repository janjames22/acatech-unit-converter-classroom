import '../domain/models/assessment_incident.dart';
import '../domain/models/assessment_session.dart';
import '../domain/models/pending_absence.dart';
import '../domain/repositories/assessment_repository.dart';

/// Deterministic repository for tests, previews, and ephemeral sessions.
final class InMemoryAssessmentRepository implements AssessmentRepository {
  InMemoryAssessmentRepository({
    Iterable<AssessmentSession> sessions = const <AssessmentSession>[],
    Iterable<AssessmentIncident> incidents = const <AssessmentIncident>[],
    PendingAbsence? pendingAbsence,
  }) {
    _pendingAbsence = pendingAbsence;
    for (final session in sessions) {
      _sessions[session.id] = session;
    }
    for (final incident in incidents) {
      _incidents[incident.id] = incident;
    }
  }

  final Map<String, AssessmentSession> _sessions =
      <String, AssessmentSession>{};
  final Map<String, AssessmentIncident> _incidents =
      <String, AssessmentIncident>{};
  PendingAbsence? _pendingAbsence;

  @override
  Future<void> saveSession(AssessmentSession session) async {
    _sessions[session.id] = session;
  }

  @override
  Future<AssessmentSession?> loadSession(String id) async => _sessions[id];

  @override
  Future<AssessmentSession?> loadActiveSession() async {
    final activeSessions = _sessions.values
        .where((session) => session.isActive)
        .toList(growable: false);
    if (activeSessions.length > 1) {
      throw StateError('More than one active assessment session was found.');
    }
    return activeSessions.firstOrNull;
  }

  @override
  Future<List<AssessmentSession>> loadSessions() async {
    final sessions = _sessions.values.toList(growable: false)
      ..sort((a, b) => a.startedAt.compareTo(b.startedAt));
    return sessions;
  }

  @override
  Future<void> saveIncident(AssessmentIncident incident) async {
    _incidents[incident.id] = incident;
  }

  @override
  Future<AssessmentIncident?> loadIncident(String id) async => _incidents[id];

  @override
  Future<List<AssessmentIncident>> loadIncidents(String sessionId) async {
    final incidents =
        _incidents.values
            .where((incident) => incident.sessionId == sessionId)
            .toList(growable: false)
          ..sort((a, b) => a.leftAt.compareTo(b.leftAt));
    return incidents;
  }

  @override
  Future<void> savePendingAbsence(PendingAbsence pendingAbsence) async {
    _pendingAbsence = pendingAbsence;
  }

  @override
  Future<PendingAbsence?> loadPendingAbsence() async => _pendingAbsence;

  @override
  Future<void> clearPendingAbsence(String incidentId) async {
    if (_pendingAbsence?.incidentId == incidentId) {
      _pendingAbsence = null;
    }
  }

  @override
  Future<void> deleteAll() async {
    _sessions.clear();
    _incidents.clear();
    _pendingAbsence = null;
  }
}
