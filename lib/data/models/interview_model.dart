class InterviewModel {
  String? message;
  final int id;
  String type;
  String scheduledAt;
  int durationMinutes;
  String mode;
  String meetingLink;
  String location;
  String status;

  InterviewModel({
    this.message,
    required this.id,
    required this.type,
    required this.scheduledAt,
    required this.durationMinutes,
    required this.mode,
    required this.meetingLink,
    required this.location,
    required this.status,
  });

  factory InterviewModel.initial() => InterviewModel(
    id: -1,
    message: '',
    type: '',
    scheduledAt: '',
    durationMinutes: 0,
    mode: '',
    meetingLink: '',
    location: '',
    status: '',
  );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'message': message,
      'interview_type': type,
      'scheduled_at': scheduledAt,
      'duration_minutes': durationMinutes,
      'interview_mode': mode,
      'meeting_link': meetingLink,
      'location': location,
      'status': status,
    };
  }

  factory InterviewModel.fromMap(Map<String, dynamic> map) {
    return InterviewModel(
      id: int.tryParse('${map['id'] ?? ''}') ?? -1,
      message: map['message']?.toString() ?? '',
      type: map['interview_type']?.toString() ?? '',
      scheduledAt: map['scheduled_at']?.toString() ?? '',
      durationMinutes: int.tryParse('${map['duration_minutes'] ?? ''}') ?? 0,
      mode: map['interview_mode']?.toString() ?? '',
      meetingLink: map['meeting_link']?.toString() ?? '',
      location: map['location']?.toString() ?? '',
      status: map['status']?.toString() ?? '',
    );
  }
}
