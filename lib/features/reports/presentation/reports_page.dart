import 'package:flutter/material.dart';

import '../../../app/layout/app_breakpoints.dart';
import '../../../core/security/teacher_pin_service.dart';
import '../../../core/widgets/teacher_pin_dialog.dart';
import '../../assessment/domain/models/assessment_incident.dart';
import '../../assessment/domain/models/assessment_session.dart';
import '../../assessment/presentation/assessment_app_controller.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({
    required this.controller,
    required this.pinService,
    super.key,
  });

  final AssessmentAppController controller;
  final TeacherPinService pinService;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppBreakpoints.contentMaxWidth,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Local assessment reports',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Stored only on this device. Events describe observed focus and visibility changes.',
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Delete report history',
                          onPressed: controller.sessions.isEmpty
                              ? null
                              : () => _deleteHistory(context),
                          icon: const Icon(Icons.delete_outline_rounded),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (controller.sessions.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: _EmptyReports(),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
                sliver: SliverLayoutBuilder(
                  builder: (context, constraints) {
                    final margin =
                        ((constraints.crossAxisExtent -
                                        AppBreakpoints.contentMaxWidth)
                                    .clamp(0.0, double.infinity) /
                                2)
                            .toDouble();
                    return SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: margin),
                      sliver: SliverList.separated(
                        itemCount: controller.sessions.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          final session = controller.sessions[index];
                          return _ReportCard(
                            session: session,
                            incidents: controller.incidentsFor(session.id),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  Future<void> _deleteHistory(BuildContext context) async {
    if (controller.hasActiveSession) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('End the active assessment before deleting history.'),
        ),
      );
      return;
    }
    final authorized = await requestTeacherAuthorization(
      context,
      pinService: pinService,
      purpose: 'delete all local report history',
    );
    if (!authorized || !context.mounted) {
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete all reports?'),
        content: const Text(
          'This permanently removes assessment sessions and incidents stored on this device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await controller.deleteHistory();
    }
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({required this.session, required this.incidents});

  final AssessmentSession session;
  final List<AssessmentIncident> incidents;

  @override
  Widget build(BuildContext context) {
    final review = _count(AssessmentIncidentClassification.review);
    final extended = _count(AssessmentIncidentClassification.extendedAbsence);
    final unresolved = _count(AssessmentIncidentClassification.unresolved);
    final excluded = _count(AssessmentIncidentClassification.excluded);
    final includedDuration = incidents
        .where(
          (incident) =>
              incident.classification ==
                  AssessmentIncidentClassification.review ||
              incident.classification ==
                  AssessmentIncidentClassification.extendedAbsence,
        )
        .fold<Duration>(
          Duration.zero,
          (total, incident) => total + (incident.duration ?? Duration.zero),
        );

    return Card(
      child: ExpansionTile(
        leading: CircleAvatar(
          child: Icon(
            session.isActive
                ? Icons.timer_rounded
                : Icons.assignment_turned_in_outlined,
          ),
        ),
        title: Text(
          session.assessmentName,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          '${session.studentName} · ${_formatDateTime(session.startedAt)}',
        ),
        trailing: Chip(label: Text(session.isActive ? 'Active' : 'Ended')),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Divider(),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Chip(label: Text('$review review')),
                    Chip(label: Text('$extended extended')),
                    Chip(label: Text('$unresolved unresolved')),
                    Chip(label: Text('$excluded excluded')),
                    Chip(
                      avatar: const Icon(Icons.schedule_rounded, size: 18),
                      label: Text('${includedDuration.inSeconds}s outside'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (incidents.isEmpty)
                  const Text('No reportable focus or visibility events.')
                else
                  for (var index = 0; index < incidents.length; index++)
                    _IncidentRow(index: index + 1, incident: incidents[index]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _count(AssessmentIncidentClassification classification) => incidents
      .where((incident) => incident.classification == classification)
      .length;
}

class _IncidentRow extends StatelessWidget {
  const _IncidentRow({required this.index, required this.incident});

  final int index;
  final AssessmentIncident incident;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(radius: 16, child: Text('$index')),
      title: Text(_classificationLabel(incident.classification)),
      subtitle: Text(
        '${_formatDateTime(incident.leftAt)} · ${incident.duration?.inSeconds ?? 'unknown'}s\n${incident.reason}',
      ),
      isThreeLine: true,
    );
  }
}

class _EmptyReports extends StatelessWidget {
  const _EmptyReports();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.folder_open_rounded, size: 60),
            const SizedBox(height: 16),
            Text(
              'No reports yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'Completed and active assessment sessions will appear here.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

String _classificationLabel(AssessmentIncidentClassification value) =>
    switch (value) {
      AssessmentIncidentClassification.ignored => 'Ignored transient',
      AssessmentIncidentClassification.review => 'Review event',
      AssessmentIncidentClassification.extendedAbsence => 'Extended absence',
      AssessmentIncidentClassification.unresolved => 'Unresolved process gap',
      AssessmentIncidentClassification.excluded => 'Known excluded event',
    };

String _formatDateTime(DateTime value) {
  final local = value.toLocal();
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '${local.year}-$month-$day $hour:$minute';
}
