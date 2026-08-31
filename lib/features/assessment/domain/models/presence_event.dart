enum AssessmentPresenceState { resumed, inactive, hidden, paused }

/// A timestamped observation from a platform lifecycle adapter.
final class PresenceEvent {
  const PresenceEvent({required this.state, required this.observedAt});

  final AssessmentPresenceState state;
  final DateTime observedAt;

  Map<String, Object?> toJson() => <String, Object?>{
    'state': state.name,
    'observedAt': observedAt.toUtc().toIso8601String(),
  };

  factory PresenceEvent.fromJson(Map<String, Object?> json) {
    return PresenceEvent(
      state: AssessmentPresenceState.values.byName(json['state']! as String),
      observedAt: DateTime.parse(json['observedAt']! as String),
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is PresenceEvent &&
            state == other.state &&
            observedAt.microsecondsSinceEpoch ==
                other.observedAt.microsecondsSinceEpoch;
  }

  @override
  int get hashCode => Object.hash(state, observedAt.microsecondsSinceEpoch);

  @override
  String toString() {
    return 'PresenceEvent(state: ${state.name}, observedAt: $observedAt)';
  }
}
