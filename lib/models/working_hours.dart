class WorkingHours {
  final int id;
  final int dayOfWeek; // 0=Sun 1=Mon 2=Tue 3=Wed 4=Thu 5=Fri 6=Sat
  final String? openTime;
  final String? closeTime;
  final bool isClosed;

  static const List<String> dayNames = [
    'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'
  ];

  static const List<String> dayShort = [
    'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'
  ];

  WorkingHours({
    required this.id,
    required this.dayOfWeek,
    this.openTime,
    this.closeTime,
    this.isClosed = false,
  });

  String get dayName => dayNames[dayOfWeek];
  String get dayShortName => dayShort[dayOfWeek];

  String get hoursLabel {
    if (isClosed) return 'Closed';
    if (openTime == null && closeTime == null) return 'Open';
    final open = _format(openTime);
    final close = _format(closeTime);
    return '$open – $close';
  }

  String _format(String? time) {
    if (time == null) return '';
    final parts = time.split(':');
    if (parts.length < 2) return time;
    final h = int.tryParse(parts[0]) ?? 0;
    final m = parts[1].padLeft(2, '0');
    final suffix = h >= 12 ? 'PM' : 'AM';
    final hour12 = h % 12 == 0 ? 12 : h % 12;
    return '$hour12:$m $suffix';
  }

  factory WorkingHours.fromJson(Map<String, dynamic> json) {
    return WorkingHours(
      id: json['id'] ?? 0,
      dayOfWeek: json['day_of_week'] ?? 0,
      openTime: json['open_time'],
      closeTime: json['close_time'],
      isClosed: json['is_closed'] == true || json['is_closed'] == 1,
    );
  }

  Map<String, dynamic> toJson() => {
    'day_of_week': dayOfWeek,
    'open_time': openTime,
    'close_time': closeTime,
    'is_closed': isClosed,
  };
}
