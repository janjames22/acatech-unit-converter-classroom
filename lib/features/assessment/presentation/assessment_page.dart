import 'package:flutter/material.dart';

import '../../../app/layout/app_breakpoints.dart';
import '../../../core/security/teacher_pin_service.dart';
import '../../../core/widgets/teacher_pin_dialog.dart';
import '../domain/models/assessment_session.dart';
import 'assessment_app_controller.dart';

class AssessmentPage extends StatefulWidget {
  const AssessmentPage({
    required this.controller,
    required this.pinService,
    required this.onOpenConverter,
    super.key,
  });

  final AssessmentAppController controller;
  final TeacherPinService pinService;
  final VoidCallback onOpenConverter;

  @override
  State<AssessmentPage> createState() => _AssessmentPageState();
}

class _AssessmentPageState extends State<AssessmentPage> {
  final _formKey = GlobalKey<FormState>();
  final _studentController = TextEditingController();
  final _assessmentController = TextEditingController();
  int _durationMinutes = 60;

  @override
  void dispose() {
    _studentController.dispose();
    _assessmentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final session = widget.controller.activeSession;
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppBreakpoints.contentMaxWidth,
              ),
              child: session == null
                  ? _buildSetup(context)
                  : _buildActive(context, session),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSetup(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Assessment Mode',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          'Create a local session and record observable focus or visibility absences.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),
        _PrivacyNotice(compact: false),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Session details',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    key: const ValueKey('student-name'),
                    controller: _studentController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Student name or identifier',
                      prefixIcon: Icon(Icons.person_outline_rounded),
                    ),
                    validator: _requiredField,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    key: const ValueKey('assessment-name'),
                    controller: _assessmentController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Assessment name',
                      prefixIcon: Icon(Icons.assignment_outlined),
                    ),
                    validator: _requiredField,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    key: const ValueKey('assessment-duration'),
                    initialValue: _durationMinutes,
                    decoration: const InputDecoration(
                      labelText: 'Planned duration',
                      prefixIcon: Icon(Icons.timer_outlined),
                    ),
                    items: const [15, 30, 45, 60, 90, 120]
                        .map(
                          (minutes) => DropdownMenuItem(
                            value: minutes,
                            child: Text('$minutes minutes'),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _durationMinutes = value);
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    key: const ValueKey('start-assessment'),
                    onPressed: widget.controller.isBusy ? null : _start,
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('Authorize and start'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActive(BuildContext context, AssessmentSession session) {
    final remaining = widget.controller.remainingTime;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          color: colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Wrap(
              spacing: 24,
              runSpacing: 20,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.radio_button_checked_rounded,
                            color: colorScheme.error,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'ASSESSMENT ACTIVE',
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  color: colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        session.assessmentName,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              color: colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        session.studentName,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: colorScheme.onPrimaryContainer),
                      ),
                    ],
                  ),
                ),
                if (remaining != null)
                  Semantics(
                    label: '${_formatDuration(remaining)} remaining',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'TIME REMAINING',
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(color: colorScheme.onPrimaryContainer),
                        ),
                        Text(
                          _formatDuration(remaining),
                          style: Theme.of(context).textTheme.displaySmall
                              ?.copyWith(
                                color: colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.w800,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _MetricCard(
              label: 'Review events',
              value: widget.controller.reviewCount,
              icon: Icons.visibility_outlined,
            ),
            _MetricCard(
              label: 'Extended absences',
              value: widget.controller.extendedCount,
              icon: Icons.timer_outlined,
            ),
            _MetricCard(
              label: 'Unresolved gaps',
              value: widget.controller.unresolvedCount,
              icon: Icons.help_outline_rounded,
            ),
          ],
        ),
        const SizedBox(height: 20),
        _PrivacyNotice(compact: true),
        const SizedBox(height: 24),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.end,
          children: [
            OutlinedButton.icon(
              onPressed: widget.onOpenConverter,
              icon: const Icon(Icons.calculate_outlined),
              label: const Text('Continue converting'),
            ),
            FilledButton.icon(
              key: const ValueKey('end-assessment'),
              onPressed: widget.controller.isBusy ? null : _end,
              icon: const Icon(Icons.stop_rounded),
              label: const Text('Authorize and end'),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _start() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    final authorized = await requestTeacherAuthorization(
      context,
      pinService: widget.pinService,
      purpose: 'start this assessment',
    );
    if (!authorized || !mounted) {
      return;
    }
    try {
      await widget.controller.startSession(
        studentName: _studentController.text,
        assessmentName: _assessmentController.text,
        plannedDuration: Duration(minutes: _durationMinutes),
      );
    } on Object catch (error) {
      _showError(error);
    }
  }

  Future<void> _end() async {
    final authorized = await requestTeacherAuthorization(
      context,
      pinService: widget.pinService,
      purpose: 'end this assessment',
    );
    if (!authorized || !mounted) {
      return;
    }
    try {
      await widget.controller.endSession();
    } on Object catch (error) {
      _showError(error);
    }
  }

  void _showError(Object error) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Could not update assessment: $error')),
    );
  }

  static String? _requiredField(String? value) {
    return value == null || value.trim().isEmpty
        ? 'This field is required.'
        : null;
  }

  static String _formatDuration(Duration value) {
    final hours = value.inHours;
    final minutes = value.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = value.inSeconds.remainder(60).toString().padLeft(2, '0');
    return hours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final int value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(icon, size: 30),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$value',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    Text(label),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrivacyNotice extends StatelessWidget {
  const _PrivacyNotice({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      color: colorScheme.tertiaryContainer,
      child: Padding(
        padding: EdgeInsets.all(compact ? 18 : 22),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.privacy_tip_outlined,
              color: colorScheme.onTertiaryContainer,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                'This mode records when the app loses observable focus or visibility. '
                'It does not identify another app, read messages, use the camera or microphone, '
                'or determine cheating. Known Android screen-lock signals are excluded; '
                'unsupported causes remain neutral for teacher review.',
                style: TextStyle(color: colorScheme.onTertiaryContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
