import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'app/app_settings_controller.dart';
import 'core/security/teacher_pin_service.dart';
import 'features/assessment/application/assessment_monitor.dart';
import 'features/assessment/data/shared_preferences_assessment_repository.dart';
import 'features/assessment/infrastructure/system_presence_bridge.dart';
import 'features/assessment/presentation/assessment_app_controller.dart';
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
  final pwaInstallService = PwaInstallService.platform();
  await pwaInstallService.initialize();

  runApp(
    UnitConverterApp(
      assessmentController: assessmentController,
      pinService: TeacherPinService(preferences),
      settingsController: AppSettingsController(preferences),
      systemPresenceBridge: SystemPresenceBridge(),
      pwaInstallService: pwaInstallService,
    ),
  );
}
