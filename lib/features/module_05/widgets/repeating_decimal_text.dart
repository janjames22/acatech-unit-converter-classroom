import 'package:flutter/material.dart';

class RepeatingDecimalText extends StatelessWidget {
  const RepeatingDecimalText({
    required this.whole,
    required this.nonRepeating,
    required this.repeating,
    this.style,
    super.key,
  });

  final String whole;
  final String nonRepeating;
  final String repeating;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = style ?? Theme.of(context).textTheme.bodyLarge;
    final semantics = repeating.isEmpty
        ? '$whole${nonRepeating.isEmpty ? '' : '.$nonRepeating'}'
        : '$whole point $nonRepeating $repeating repeating';
    return Semantics(
      label: semantics,
      child: ExcludeSemantics(
        child: Text.rich(
          TextSpan(
            style: effectiveStyle,
            children: [
              TextSpan(text: '$whole.'),
              TextSpan(text: nonRepeating),
              TextSpan(
                text: repeating,
                style: const TextStyle(decoration: TextDecoration.overline),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
