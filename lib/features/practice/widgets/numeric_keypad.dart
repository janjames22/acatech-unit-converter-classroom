import 'package:flutter/material.dart';

class NumericKeypad extends StatelessWidget {
  const NumericKeypad({
    required this.value,
    required this.onChanged,
    required this.keyPrefix,
    this.enabled = true,
    this.allowDecimal = true,
    this.extraKeys = const <String>[],
    this.maxLength = 64,
    super.key,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final String keyPrefix;
  final bool enabled;
  final bool allowDecimal;
  final List<String> extraKeys;
  final int maxLength;

  @override
  Widget build(BuildContext context) {
    const coreRows = <List<String>>[
      ['7', '8', '9', 'backspace'],
      ['4', '5', '6', 'clear'],
      ['1', '2', '3', '.'],
      ['0'],
    ];
    return Semantics(
      container: true,
      label: 'Educational numeric keypad',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var rowIndex = 0; rowIndex < coreRows.length; rowIndex++) ...[
            Row(
              children: [
                for (var index = 0; index < 4; index++) ...[
                  Expanded(
                    child: index < coreRows[rowIndex].length
                        ? _KeyButton(
                            token: coreRows[rowIndex][index],
                            keyPrefix: keyPrefix,
                            enabled:
                                enabled &&
                                (coreRows[rowIndex][index] != '.' ||
                                    allowDecimal),
                            onPressed: () => _press(coreRows[rowIndex][index]),
                          )
                        : const SizedBox.shrink(),
                  ),
                  if (index < 3) const SizedBox(width: 8),
                ],
              ],
            ),
            if (rowIndex < coreRows.length - 1) const SizedBox(height: 8),
          ],
          if (extraKeys.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              'Math symbols',
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final token in extraKeys)
                  SizedBox(
                    width: 64,
                    child: _KeyButton(
                      token: token,
                      keyPrefix: keyPrefix,
                      enabled: enabled,
                      onPressed: () => _press(token),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _press(String token) {
    if (!enabled) {
      return;
    }
    switch (token) {
      case 'clear':
        onChanged('');
        return;
      case 'backspace':
        if (value.isNotEmpty) {
          onChanged(value.substring(0, value.length - 1));
        }
        return;
      case '.':
        if (allowDecimal && !value.contains('.') && value.length < maxLength) {
          onChanged(value.isEmpty ? '0.' : '$value.');
        }
        return;
      default:
        if (value.length < maxLength) {
          onChanged('$value$token');
        }
    }
  }
}

class _KeyButton extends StatelessWidget {
  const _KeyButton({
    required this.token,
    required this.keyPrefix,
    required this.enabled,
    required this.onPressed,
  });

  final String token;
  final String keyPrefix;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final (label, icon, semantics) = switch (token) {
      'clear' => ('Clear', null, 'Clear answer'),
      'backspace' => ('', Icons.backspace_outlined, 'Backspace'),
      '.' => ('.', null, 'Decimal point'),
      _ => (token, null, token),
    };
    return Semantics(
      button: true,
      label: semantics,
      child: SizedBox(
        height: 48,
        child: OutlinedButton(
          key: ValueKey('$keyPrefix-key-${_tokenId(token)}'),
          onPressed: enabled ? onPressed : null,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 6),
          ),
          child: icon == null ? Text(label) : Icon(icon, size: 20),
        ),
      ),
    );
  }

  static String _tokenId(String token) => switch (token) {
    '.' => 'decimal',
    '^' => 'power',
    '×' => 'multiply',
    ',' => 'comma',
    '(' => 'open-paren',
    ')' => 'close-paren',
    _ => token,
  };
}
