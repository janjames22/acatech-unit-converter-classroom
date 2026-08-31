import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unit_converter/app/app.dart';
import 'package:unit_converter/app/app_settings_controller.dart';
import 'package:unit_converter/core/security/teacher_pin_service.dart';
import 'package:unit_converter/features/assessment/application/assessment_monitor.dart';
import 'package:unit_converter/features/assessment/data/in_memory_assessment_repository.dart';
import 'package:unit_converter/features/assessment/infrastructure/system_presence_bridge.dart';
import 'package:unit_converter/features/assessment/presentation/assessment_app_controller.dart';
import 'package:unit_converter/features/pwa_install/pwa_install.dart';

void main() {
  testWidgets('shows the product home and adaptive navigation', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final preferences = await SharedPreferences.getInstance();
    final repository = InMemoryAssessmentRepository();
    final assessmentController = AssessmentAppController(
      repository,
      AssessmentMonitor(repository: repository),
    );
    await assessmentController.initialize();
    final pwaInstallService = PwaInstallService.platform();
    await pwaInstallService.initialize();

    await tester.pumpWidget(
      UnitConverterApp(
        assessmentController: assessmentController,
        pinService: TeacherPinService(preferences),
        settingsController: AppSettingsController(preferences),
        systemPresenceBridge: SystemPresenceBridge(),
        pwaInstallService: pwaInstallService,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Convert with confidence'), findsOneWidget);
    expect(find.text('Length'), findsOneWidget);
    expect(find.text('Assessment'), findsOneWidget);
    expect(find.text('Reports'), findsOneWidget);
  });
}
