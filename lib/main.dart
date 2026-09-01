import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'app/app_settings_controller.dart';
import 'core/security/teacher_pin_service.dart';
import 'features/assessment/application/assessment_monitor.dart';
import 'features/assessment/data/shared_preferences_assessment_repository.dart';
import 'features/assessment/infrastructure/system_presence_bridge.dart';
import 'features/assessment/presentation/assessment_app_controller.dart';
import 'features/module_02/module_02.dart';
import 'features/module_03/module_03.dart';
import 'features/module_04/module_04.dart';
import 'features/module_05/module_05.dart';
import 'features/pwa_install/pwa_install.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final preferences = await SharedPreferences.getInstance();
  final repository = SharedPreferencesAssessmentRepository(preferences);
  final assessmentController = AssessmentAppController(
    repository,
    AssessmentMonitor(repository: repository),
  );
  await assessmentController.initialize();
  final module2ProgressController = Module2ProgressController(
    SharedPreferencesModule2ProgressRepository(preferences),
  );
  await module2ProgressController.initialize();
  final module3ProgressController = Module3ProgressController(
    SharedPreferencesModule3ProgressRepository(preferences),
  );
  await module3ProgressController.initialize();
  final module4ProgressController = Module4ProgressController(
    SharedPreferencesModule4ProgressRepository(preferences),
  );
  await module4ProgressController.initialize();
  final module5ProgressController = Module5ProgressController(
    SharedPreferencesModule5ProgressRepository(preferences),
  );
  await module5ProgressController.initialize();
  final pwaInstallService = PwaInstallService.platform();
  await pwaInstallService.initialize();

  runApp(
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
}
