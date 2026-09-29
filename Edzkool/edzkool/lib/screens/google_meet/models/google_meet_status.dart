class GoogleMeetStatus {
  final bool hasClass;
  final int? schoolClass;
  final String? meetUrl;
  final bool meetConfigured;

  const GoogleMeetStatus({
    required this.hasClass,
    this.schoolClass,
    this.meetUrl,
    required this.meetConfigured,
  });

  factory GoogleMeetStatus.fromJson(Map<String, dynamic> json) {
    return GoogleMeetStatus(
      hasClass: json['has_class'] == true,
      schoolClass: json['school_class'] as int?,
      meetUrl: json['meet_url'] as String?,
      meetConfigured: json['meet_configured'] == true,
    );
  }
}
