import 'package:flutter/material.dart';

import '../../features/pwa_install/pwa_install.dart';

/// Adaptive app-bar affordance for the browser installation experience.
///
/// The platform service owns capability detection. This widget only maps its
/// observable state to accessible UI and presents iOS's manual flow.
final class InstallAppAction extends StatelessWidget {
  const InstallAppAction({
    required this.service,
    required this.compact,
    required this.onPromptInstall,
    super.key,
  });

  static const compactButtonKey = Key('install-app-compact-button');
  static const labeledButtonKey = Key('install-app-labeled-button');
  static const instructionsKey = Key('ios-install-instructions');

  final PwaInstallService service;
  final bool compact;
  final Future<PwaInstallPromptOutcome> Function() onPromptInstall;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: service,
      builder: (context, _) {
        final presentation = _presentationFor(service.state);
        if (presentation == null) {
          return const SizedBox.shrink();
        }

        final tooltip = compact && service.state == PwaInstallState.available
            ? 'Install App'
            : presentation.tooltip;

        final onPressed = switch (service.state) {
          PwaInstallState.available => () => _requestInstall(context),
          PwaInstallState.iosManualInstall => () => _showIosInstructions(
            context,
          ),
          PwaInstallState.unavailable ||
          PwaInstallState.installing ||
          PwaInstallState.installed => null,
        };
        final icon = service.state == PwaInstallState.installing
            ? const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(presentation.icon, size: 20);

        if (compact) {
          return IconButton(
            key: compactButtonKey,
            tooltip: tooltip,
            onPressed: onPressed,
            icon: icon,
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Tooltip(
            message: tooltip,
            child: FilledButton.tonalIcon(
              key: labeledButtonKey,
              onPressed: onPressed,
              icon: icon,
              label: Text(presentation.label),
            ),
          ),
        );
      },
    );
  }

  Future<void> _requestInstall(BuildContext context) async {
    final outcome = await onPromptInstall();
    if (!context.mounted) {
      return;
    }

    final message = switch (outcome) {
      PwaInstallPromptOutcome.accepted =>
        'Installation accepted. Unit Converter is being added to your device.',
      PwaInstallPromptOutcome.dismissed =>
        'Installation dismissed. You can try again when the prompt is available.',
      PwaInstallPromptOutcome.unavailable =>
        'The browser install prompt is no longer available.',
    };
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _showIosInstructions(BuildContext context) {
    final compactWindow = MediaQuery.sizeOf(context).width < 600;
    if (compactWindow) {
      return showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        useSafeArea: true,
        builder: (sheetContext) => SingleChildScrollView(
          child: _IosInstallInstructions(
            onClose: () => Navigator.of(sheetContext).pop(),
          ),
        ),
      );
    }

    return showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: SingleChildScrollView(
            child: _IosInstallInstructions(
              onClose: () => Navigator.of(dialogContext).pop(),
            ),
          ),
        ),
      ),
    );
  }

  static _InstallActionPresentation? _presentationFor(PwaInstallState state) {
    return switch (state) {
      PwaInstallState.unavailable => null,
      PwaInstallState.available => const _InstallActionPresentation(
        label: 'Install App',
        tooltip: 'Install App',
        icon: Icons.download_rounded,
      ),
      PwaInstallState.installing => const _InstallActionPresentation(
        label: 'Installing…',
        tooltip: 'Installation prompt is open',
        icon: Icons.install_desktop_rounded,
      ),
      PwaInstallState.installed => null,
      PwaInstallState.iosManualInstall => const _InstallActionPresentation(
        label: 'Install App',
        tooltip: 'Install App',
        icon: Icons.install_mobile_rounded,
      ),
    };
  }
}

final class _InstallActionPresentation {
  const _InstallActionPresentation({
    required this.label,
    required this.tooltip,
    required this.icon,
  });

  final String label;
  final String tooltip;
  final IconData icon;
}

final class _IosInstallInstructions extends StatelessWidget {
  const _IosInstallInstructions({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      key: InstallAppAction.instructionsKey,
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Icon(
                    Icons.add_to_home_screen_rounded,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Install Unit Converter',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'The app will then appear on your Home Screen and can launch in its own app window.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Close instructions',
                onPressed: onClose,
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          const SizedBox(height: 22),
          const _InstructionStep(
            number: 1,
            title: 'Tap the Share button',
            detail: 'Find Share in your browser toolbar or menu.',
            icon: Icons.ios_share_rounded,
          ),
          const _InstructionStep(
            number: 2,
            title: 'Choose Add to Home Screen',
            detail:
                'Scroll through the actions if it is not immediately visible.',
            icon: Icons.add_box_outlined,
          ),
          const _InstructionStep(
            number: 3,
            title: 'Confirm by tapping Add',
            detail: 'Tap Add to finish installing Unit Converter.',
            icon: Icons.check_rounded,
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onClose,
              child: const Text('Got it'),
            ),
          ),
        ],
      ),
    );
  }
}

final class _InstructionStep extends StatelessWidget {
  const _InstructionStep({
    required this.number,
    required this.title,
    required this.detail,
    required this.icon,
  });

  final int number;
  final String title;
  final String detail;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: colorScheme.secondaryContainer,
            foregroundColor: colorScheme.onSecondaryContainer,
            child: Text(
              '$number',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  detail,
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(icon, color: colorScheme.primary, size: 22),
        ],
      ),
    );
  }
}
