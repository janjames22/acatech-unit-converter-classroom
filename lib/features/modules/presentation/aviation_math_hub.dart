import 'package:flutter/material.dart';

import '../../../app/layout/app_breakpoints.dart';

class AviationMathHub extends StatelessWidget {
  const AviationMathHub({
    required this.onOpenModule2,
    required this.onOpenModule3,
    required this.onOpenModule4,
    required this.onOpenModule5,
    super.key,
  });

  final VoidCallback onOpenModule2;
  final VoidCallback onOpenModule3;
  final VoidCallback onOpenModule4;
  final VoidCallback onOpenModule5;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: const ValueKey('aviation-math-hub-scroll-view'),
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppBreakpoints.contentMaxWidth,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Aviation Mathematics',
                key: const ValueKey('aviation-math-hub-title'),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'AMT 111 lessons, exact learning tools, practice, and local progress.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth >= 760 ? 2 : 1;
                  final width =
                      (constraints.maxWidth - (columns - 1) * 16) / columns;
                  return Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      SizedBox(
                        width: width,
                        child: _ModuleCard(
                          key: const ValueKey('open-module-02'),
                          moduleNumber: '02',
                          title: 'Whole Numbers',
                          summary:
                              'Place value, four operations, factors, multiples, primes, and divisibility.',
                          status: 'Complete module available',
                          icon: Icons.pin_outlined,
                          onTap: onOpenModule2,
                        ),
                      ),
                      SizedBox(
                        width: width,
                        child: _ModuleCard(
                          key: const ValueKey('open-module-03'),
                          moduleNumber: '03',
                          title: 'Fractions',
                          summary:
                              'Equivalent fractions, LCD methods, exact operations, cancellation, and reduction.',
                          status: 'Complete module available',
                          icon: Icons.space_bar_rounded,
                          onTap: onOpenModule3,
                        ),
                      ),
                      SizedBox(
                        width: width,
                        child: _ModuleCard(
                          key: const ValueKey('open-module-04'),
                          moduleNumber: '04',
                          title: 'Mixed Numbers',
                          summary:
                              'Conversions, carrying, borrowing, exact operations, distracters, and cut planning.',
                          status: 'Complete module available',
                          icon: Icons.straighten_rounded,
                          onTap: onOpenModule4,
                        ),
                      ),
                      SizedBox(
                        width: width,
                        child: _ModuleCard(
                          key: const ValueKey('open-module-05'),
                          moduleNumber: '05',
                          title: 'Decimal Number System',
                          summary:
                              'Place value, exact operations, half-up rounding, fraction conversion, repeating decimals, and shop 64ths.',
                          status: 'Complete module available',
                          icon: Icons.exposure_rounded,
                          onTap: onOpenModule5,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              Text(
                'Modules 6–13 are not yet implemented.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({
    required this.moduleNumber,
    required this.title,
    required this.summary,
    required this.status,
    required this.icon,
    required this.onTap,
    super.key,
  });

  final String moduleNumber;
  final String title;
  final String summary;
  final String status;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: colors.secondaryContainer,
                    foregroundColor: colors.onSecondaryContainer,
                    child: Icon(icon),
                  ),
                  const Spacer(),
                  const Icon(Icons.arrow_forward_rounded),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                'MODULE $moduleNumber',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(summary),
              const SizedBox(height: 16),
              Text(
                status,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
