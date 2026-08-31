import 'dart:async';

import 'package:flutter/material.dart';

import '../core/security/teacher_pin_service.dart';
import '../core/widgets/teacher_pin_dialog.dart';
import '../features/assessment/infrastructure/system_presence_bridge.dart';
import '../features/assessment/presentation/assessment_app_controller.dart';
import '../features/assessment/presentation/assessment_page.dart';
import '../features/converter/converter.dart';
import '../features/converter/presentation/converter_home_page.dart';
import '../features/converter/presentation/converter_page.dart';
import '../features/pwa_install/pwa_install.dart';
import '../features/reports/presentation/reports_page.dart';
import 'app_settings_controller.dart';
import 'layout/adaptive_scaffold.dart';
import 'layout/app_breakpoints.dart';
import 'presentation/install_app_action.dart';
import 'theme/app_theme.dart';

class UnitConverterApp extends StatefulWidget {
  const UnitConverterApp({
    required this.assessmentController,
    required this.pinService,
    required this.settingsController,
    required this.systemPresenceBridge,
    required this.pwaInstallService,
    super.key,
  });

  final AssessmentAppController assessmentController;
  final TeacherPinService pinService;
  final AppSettingsController settingsController;
  final SystemPresenceBridge systemPresenceBridge;
  final PwaInstallService pwaInstallService;

  @override
  State<UnitConverterApp> createState() => _UnitConverterAppState();
}

class _UnitConverterAppState extends State<UnitConverterApp> {
  late final AppLifecycleListener _lifecycleListener;
  StreamSubscription<SystemPresenceSignal>? _systemSignalSubscription;

  @override
  void initState() {
    super.initState();
    // This listener is deliberately owned above MaterialApp and every route.
    _lifecycleListener = AppLifecycleListener(
      onStateChange: widget.assessmentController.handleLifecycleState,
    );
    _startSystemBridge();
  }

  Future<void> _startSystemBridge() async {
    _systemSignalSubscription = widget.systemPresenceBridge.signals.listen(
      widget.assessmentController.handleSystemPresenceSignal,
    );
    await widget.systemPresenceBridge.start();
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    unawaited(_systemSignalSubscription?.cancel());
    unawaited(widget.systemPresenceBridge.dispose());
    widget.pwaInstallService.dispose();
    widget.assessmentController.dispose();
    widget.settingsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.settingsController,
      builder: (context, _) => MaterialApp(
        title: 'Unit Converter Classroom',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: widget.settingsController.themeMode,
        home: UnitConverterShell(
          assessmentController: widget.assessmentController,
          pinService: widget.pinService,
          settingsController: widget.settingsController,
          pwaInstallService: widget.pwaInstallService,
        ),
      ),
    );
  }
}

class UnitConverterShell extends StatefulWidget {
  const UnitConverterShell({
    required this.assessmentController,
    required this.pinService,
    required this.settingsController,
    required this.pwaInstallService,
    super.key,
  });

  final AssessmentAppController assessmentController;
  final TeacherPinService pinService;
  final AppSettingsController settingsController;
  final PwaInstallService pwaInstallService;

  @override
  State<UnitConverterShell> createState() => _UnitConverterShellState();
}

class _UnitConverterShellState extends State<UnitConverterShell> {
  static const _destinations = <AppDestination>[
    AppDestination(
      label: 'Home',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
    ),
    AppDestination(
      label: 'Assessment',
      icon: Icons.fact_check_outlined,
      selectedIcon: Icons.fact_check_rounded,
    ),
    AppDestination(
      label: 'Reports',
      icon: Icons.summarize_outlined,
      selectedIcon: Icons.summarize_rounded,
    ),
  ];

  int _selectedIndex = 0;
  UnitCategory? _selectedCategory;
  UnitDefinition? _initialUnit;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.assessmentController,
      builder: (context, _) {
        final activeSession = widget.assessmentController.activeSession;
        final compact =
            AppBreakpoints.sizeClassFor(MediaQuery.sizeOf(context).width) ==
            WindowSizeClass.compact;
        return AdaptiveScaffold(
          title: 'Unit Converter',
          destinations: _destinations,
          selectedIndex: _selectedIndex,
          onDestinationSelected: _selectDestination,
          actions: [
            InstallAppAction(
              service: widget.pwaInstallService,
              compact: compact,
              onPromptInstall: _promptInstall,
            ),
            IconButton(
              tooltip: 'Toggle light or dark theme',
              onPressed: () => widget.settingsController.toggle(
                Theme.of(context).brightness,
              ),
              icon: Icon(
                Theme.of(context).brightness == Brightness.dark
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined,
              ),
            ),
            const SizedBox(width: 8),
          ],
          banner: activeSession == null
              ? null
              : _ActiveAssessmentBanner(
                  assessmentName: activeSession.assessmentName,
                  reviewCount: widget.assessmentController.reviewCount,
                  extendedCount: widget.assessmentController.extendedCount,
                  onTap: () => setState(() => _selectedIndex = 1),
                ),
          body: IndexedStack(
            index: _selectedIndex,
            children: [
              _selectedCategory == null
                  ? ConverterHomePage(
                      catalog: builtInUnitCatalog,
                      onSelection: _openConverter,
                    )
                  : ConverterPage(
                      key: ValueKey(
                        '${_selectedCategory!.id}-${_initialUnit?.id ?? 'default'}',
                      ),
                      category: _selectedCategory!,
                      initialUnit: _initialUnit,
                      onBack: () => setState(() {
                        _selectedCategory = null;
                        _initialUnit = null;
                      }),
                    ),
              AssessmentPage(
                controller: widget.assessmentController,
                pinService: widget.pinService,
                onOpenConverter: () => setState(() => _selectedIndex = 0),
              ),
              ReportsPage(
                controller: widget.assessmentController,
                pinService: widget.pinService,
              ),
            ],
          ),
        );
      },
    );
  }

  void _openConverter(UnitCategory category, UnitDefinition? initialUnit) {
    setState(() {
      _selectedCategory = category;
      _initialUnit = initialUnit;
    });
  }

  Future<PwaInstallPromptOutcome> _promptInstall() {
    return widget.assessmentController
        .runWithPresenceMonitoringSuppressed<PwaInstallPromptOutcome>(
          widget.pwaInstallService.promptInstall,
        );
  }

  Future<void> _selectDestination(int index) async {
    if (index == _selectedIndex) {
      return;
    }
    if (index == 2) {
      final authorized = await requestTeacherAuthorization(
        context,
        pinService: widget.pinService,
        purpose: 'view local assessment reports',
      );
      if (!authorized || !mounted) {
        return;
      }
      await widget.assessmentController.refreshReports();
    }
    if (mounted) {
      setState(() => _selectedIndex = index);
    }
  }
}

class _ActiveAssessmentBanner extends StatelessWidget {
  const _ActiveAssessmentBanner({
    required this.assessmentName,
    required this.reviewCount,
    required this.extendedCount,
    required this.onTap,
  });

  final String assessmentName;
  final int reviewCount;
  final int extendedCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) => Material(
        color: colorScheme.tertiaryContainer,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            child: Row(
              children: [
                Icon(
                  Icons.radio_button_checked_rounded,
                  color: colorScheme.error,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '$assessmentName is active',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                Semantics(
                  label:
                      '$reviewCount review events and $extendedCount extended absences',
                  child: Text(
                    constraints.maxWidth < 480
                        ? '$reviewCount · $extendedCount'
                        : '$reviewCount review · $extendedCount extended',
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right_rounded),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
