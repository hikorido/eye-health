class SessionState {
  final int? startTimestamp;
  final int breaksTakenToday;
  final String breaksDate;

  const SessionState({
    required this.startTimestamp,
    required this.breaksTakenToday,
    required this.breaksDate,
  });

  bool get isActive => startTimestamp != null;

  SessionState copyWith({
    int? startTimestamp,
    bool clearStartTimestamp = false,
    int? breaksTakenToday,
    String? breaksDate,
  }) {
    return SessionState(
      startTimestamp: clearStartTimestamp
          ? null
          : (startTimestamp ?? this.startTimestamp),
      breaksTakenToday: breaksTakenToday ?? this.breaksTakenToday,
      breaksDate: breaksDate ?? this.breaksDate,
    );
  }
}
