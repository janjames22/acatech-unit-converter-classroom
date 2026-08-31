import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../security/teacher_pin_service.dart';

Future<bool> requestTeacherAuthorization(
  BuildContext context, {
  required TeacherPinService pinService,
  required String purpose,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) =>
        TeacherPinDialog(pinService: pinService, purpose: purpose),
  );
  return result ?? false;
}

class TeacherPinDialog extends StatefulWidget {
  const TeacherPinDialog({
    required this.pinService,
    required this.purpose,
    super.key,
  });

  final TeacherPinService pinService;
  final String purpose;

  @override
  State<TeacherPinDialog> createState() => _TeacherPinDialogState();
}

class _TeacherPinDialogState extends State<TeacherPinDialog> {
  final _pinController = TextEditingController();
  final _confirmationController = TextEditingController();
  String? _error;
  bool _submitting = false;

  bool get _isSetup => !widget.pinService.isConfigured;

  @override
  void dispose() {
    _pinController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: Icon(_isSetup ? Icons.key_rounded : Icons.lock_rounded),
      title: Text(_isSetup ? 'Create teacher PIN' : 'Teacher authorization'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: AutofillGroup(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _isSetup
                    ? 'Create a 4–6 digit PIN before you ${widget.purpose}. '
                          'This local PIN is a convenience lock on this device.'
                    : 'Enter the teacher PIN to ${widget.purpose}.',
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _pinController,
                autofocus: true,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 6,
                autofillHints: const [AutofillHints.password],
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: 'Teacher PIN',
                  errorText: _error,
                  counterText: '',
                ),
                onSubmitted: (_) => _submit(),
              ),
              if (_isSetup) ...[
                const SizedBox(height: 12),
                TextField(
                  controller: _confirmationController,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Confirm PIN',
                    counterText: '',
                  ),
                  onSubmitted: (_) => _submit(),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _submitting ? null : () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submitting ? null : _submit,
          child: _submitting
              ? const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(_isSetup ? 'Create PIN' : 'Continue'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (_submitting) {
      return;
    }
    final pin = _pinController.text;
    if (!RegExp(r'^\d{4,6}$').hasMatch(pin)) {
      setState(() => _error = 'Enter 4 to 6 digits.');
      return;
    }
    if (_isSetup && pin != _confirmationController.text) {
      setState(() => _error = 'The PIN entries do not match.');
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    if (_isSetup) {
      await widget.pinService.configure(pin);
      if (mounted) {
        Navigator.pop(context, true);
      }
      return;
    }

    final result = await widget.pinService.verify(pin);
    if (!mounted) {
      return;
    }
    if (result.isAccepted) {
      Navigator.pop(context, true);
      return;
    }
    setState(() {
      _submitting = false;
      _error = result.isLocked
          ? 'Too many attempts. Try again in ${result.lockedFor.inSeconds}s.'
          : 'Incorrect PIN.';
    });
  }
}
