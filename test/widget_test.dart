import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unit_converter/app/app.dart';
import 'package:unit_converter/app/app_settings_controller.dart';
import 'package:unit_converter/core/security/teacher_pin_service.dart';
import 'package:unit_converter/features/assessment/application/assessment_monitor.dart';
import 'package:unit_converter/features/assessment/data/in_memory_assessment_repository.dart';
import 'package:unit_converter/features/assessment/infrastructure/system_presence_bridge.dart';
import 'package:unit_converter/features/assessment/presentation/assessment_app_controller.dart';
import 'package:unit_converter/features/module_02/module_02.dart';
import 'package:unit_converter/features/module_03/module_03.dart';
import 'package:unit_converter/features/module_04/module_04.dart';
import 'package:unit_converter/features/module_05/module_05.dart';
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
    final module2ProgressController = Module2ProgressController(
      InMemoryModule2ProgressRepository(),
    );
    await module2ProgressController.initialize();
    final module3ProgressController = Module3ProgressController(
      InMemoryModule3ProgressRepository(),
    );
    await module3ProgressController.initialize();
    final module4ProgressController = Module4ProgressController(
      InMemoryModule4ProgressRepository(),
    );
    await module4ProgressController.initialize();
    final module5ProgressController = Module5ProgressController(
      InMemoryModule5ProgressRepository(),
    );
    await module5ProgressController.initialize();
    final pwaInstallService = PwaInstallService.platform();
    await pwaInstallService.initialize();

    await tester.pumpWidget(
      UnitConverterApp(
        assessmentController: assessmentController,
        module2ProgressController: module2ProgressController,
        module3ProgressController: module3ProgressController,
        module4ProgressController: module4ProgressController,
        module5ProgressController: module5ProgressController,
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
    expect(find.text('Calculator'), findsOneWidget);
    expect(find.text('Reports'), findsOneWidget);
  });
}
