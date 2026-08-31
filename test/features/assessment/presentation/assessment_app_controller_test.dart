import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unit_converter/features/assessment/application/assessment_monitor.dart';
import 'package:unit_converter/features/assessment/data/in_memory_assessment_repository.dart';
import 'package:unit_converter/features/assessment/domain/models/assessment_session.dart';
import 'package:unit_converter/features/assessment/domain/services/assessment_clock.dart';
import 'package:unit_converter/features/assessment/presentation/assessment_app_controller.dart';

void main() {
  group('AssessmentAppController presence suppression', () {
    test(
      'ignores a trusted prompt departure through its matching resume',
      () async {
        final harness = await _ControllerHarness.active();
        addTearDown(harness.controller.dispose);
        final operationStarted = Completer<void>();
        final closePrompt = Completer<void>();

        final prompt = harness.controller
            .runWithPresenceMonitoringSuppressed<void>(() async {
              operationStarted.complete();
              await closePrompt.future;
            });
        await operationStarted.future;

        expect(harness.controller.isPresenceMonitoringSuppressed, isTrue);
        await harness.controller.handleLifecycleState(AppLifecycleState.hidden);
        harness.clock.advance(const Duration(seconds: 20));
        expect(harness.monitor.pendingAbsence, isNull);
        expect(await harness.repository.loadPendingAbsence(), isNull);

        // Browser prompt futures can resolve just before Flutter reports that
        // the application is visible again.
        closePrompt.complete();
        await prompt;
        expect(harness.controller.isPresenceMonitoringSuppressed, isTrue);

        await harness.controller.handleLifecycleState(
          AppLifecycleState.resumed,
        );

        expect(harness.controller.isPresenceMonitoringSuppressed, isFalse);
        expect(harness.monitor.pendingAbsence, isNull);
        expect(
          await harness.repository.loadIncidents(harness.session.id),
          isEmpty,
        );
      },
    );

    test(
      'ends suppression immediately when no departure was observed',
      () async {
        final harness = await _ControllerHarness.active();
        addTearDown(harness.controller.dispose);

        final result = await harness.controller
            .runWithPresenceMonitoringSuppressed<String>(() async => 'done');

        expect(result, 'done');
        expect(harness.controller.isPresenceMonitoringSuppressed, isFalse);

        await harness.controller.handleLifecycleState(AppLifecycleState.hidden);
        expect(harness.monitor.pendingAbsence, isNotNull);
        expect(await harness.repository.loadPendingAbsence(), isNotNull);
      },
    );

    test('restores monitoring after a trusted operation throws', () async {
      final harness = await _ControllerHarness.active();
      addTearDown(harness.controller.dispose);

      await expectLater(
        harness.controller.runWithPresenceMonitoringSuppressed<void>(
          () => Future<void>.error(StateError('Prompt failed.')),
        ),
        throwsStateError,
      );

      expect(harness.controller.isPresenceMonitoringSuppressed, isFalse);
      await harness.controller.handleLifecycleState(AppLifecycleState.paused);
      expect(harness.monitor.pendingAbsence, isNotNull);
    });
  });
}

final class _ControllerHarness {
  const _ControllerHarness({
    required this.repository,
    required this.clock,
    required this.monitor,
    required this.controller,
    required this.session,
  });

  final InMemoryAssessmentRepository repository;
  final _FakeAssessmentClock clock;
  final AssessmentMonitor monitor;
  final AssessmentAppController controller;
  final AssessmentSession session;

  static Future<_ControllerHarness> active() async {
    final repository = InMemoryAssessmentRepository();
    final clock = _FakeAssessmentClock(DateTime.utc(2026, 8, 31, 8));
    final monitor = AssessmentMonitor(repository: repository, clock: clock);
    final controller = AssessmentAppController(repository, monitor);
    await controller.initialize();
    final session = AssessmentSession(
      id: 'session-1',
      studentName: 'Student',
      assessmentName: 'Quiz',
      startedAt: clock.now(),
      plannedDuration: const Duration(minutes: 30),
    );
    await monitor.startSession(session);
    await controller.refreshReports();
    return _ControllerHarness(
      repository: repository,
      clock: clock,
      monitor: monitor,
      controller: controller,
      session: session,
    );
  }
}

final class _FakeAssessmentClock implements AssessmentClock {
  _FakeAssessmentClock(this._now);

  DateTime _now;

  @override
  DateTime now() => _now;

  void advance(Duration duration) {
    _now = _now.add(duration);
  }
}
