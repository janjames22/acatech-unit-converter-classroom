import '../models/assessment_incident.dart';
import '../models/assessment_session.dart';
import '../models/pending_absence.dart';

/// Asynchronous persistence boundary for assessment monitoring.
///
/// Implementations must upsert sessions and incidents by ID. Incident upserts
/// are essential for crash-safe recovery: a finalized incident may be saved
/// again when its pending record survived an interrupted clear operation.
abstract interface class AssessmentRepository {
  Future<void> saveSession(AssessmentSession session);

  Future<AssessmentSession?> loadSession(String id);

  Future<AssessmentSession?> loadActiveSession();

  Future<List<AssessmentSession>> loadSessions();

  Future<void> saveIncident(AssessmentIncident incident);

  Future<AssessmentIncident?> loadIncident(String id);

  Future<List<AssessmentIncident>> loadIncidents(String sessionId);

  Future<void> savePendingAbsence(PendingAbsence pendingAbsence);

  Future<PendingAbsence?> loadPendingAbsence();

  /// Clears only the pending record with [incidentId].
  ///
  /// Matching the ID prevents a delayed operation from deleting a newer
  /// candidate.
  Future<void> clearPendingAbsence(String incidentId);

  Future<void> deleteAll();
}
