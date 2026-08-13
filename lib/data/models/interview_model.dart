import 'applications_response_model.dart';

class InterviewListResponse {
  final List<InterviewModel> items;
  final InterviewPaginationMeta meta;

  const InterviewListResponse({required this.items, required this.meta});

  factory InterviewListResponse.fromMap(Map<String, dynamic> root) {
    final payload = _map(root['data']);
    final rawItems = payload['data'] is List
        ? payload['data'] as List
        : root['data'] is List
        ? root['data'] as List
        : const [];

    return InterviewListResponse(
      items: rawItems
          .whereType<Map>()
          .map(
            (item) => InterviewModel.fromMap(Map<String, dynamic>.from(item)),
          )
          .where((item) => item.id >= 0)
          .toList(),
      meta: InterviewPaginationMeta.fromMap(_map(payload['meta'])),
    );
  }
}

class InterviewPaginationMeta {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  const InterviewPaginationMeta({
    this.currentPage = 1,
    this.lastPage = 1,
    this.perPage = 15,
    this.total = 0,
  });

  factory InterviewPaginationMeta.fromMap(Map<String, dynamic> map) =>
      InterviewPaginationMeta(
        currentPage: _int(map['current_page'], 1),
        lastPage: _int(map['last_page'], 1),
        perPage: _int(map['per_page'], 15),
        total: _int(map['total']),
      );
}

class InterviewModel {
  final int id;
  final int? jobApplicationId;
  final LocalizedValue type;
  final LocalizedValue mode;
  final LocalizedValue status;
  final LocalizedValue confirmationStatus;
  final LocalizedValue attendanceStatus;
  final DateTime? scheduledStartAt;
  final DateTime? scheduledEndAt;
  final int durationMinutes;
  final String? meetingLink;
  final String? location;
  final String? candidateMessage;
  final String? cancellationMessage;
  final String? videoProvider;
  final bool embeddedVideoAvailable;
  final DateTime? confirmedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final JobApplication? jobApplication;

  const InterviewModel({
    required this.id,
    this.jobApplicationId,
    required this.type,
    required this.mode,
    required this.status,
    required this.confirmationStatus,
    required this.attendanceStatus,
    this.scheduledStartAt,
    this.scheduledEndAt,
    this.durationMinutes = 0,
    this.meetingLink,
    this.location,
    this.candidateMessage,
    this.cancellationMessage,
    this.videoProvider,
    this.embeddedVideoAvailable = false,
    this.confirmedAt,
    this.completedAt,
    this.cancelledAt,
    this.createdAt,
    this.updatedAt,
    this.jobApplication,
  });

  factory InterviewModel.initial() => InterviewModel(
    id: -1,
    type: LocalizedValue.fromDynamic(null),
    mode: LocalizedValue.fromDynamic(null),
    status: LocalizedValue.fromDynamic(null),
    confirmationStatus: LocalizedValue.fromDynamic(null),
    attendanceStatus: LocalizedValue.fromDynamic(null),
  );

  factory InterviewModel.fromMap(Map<String, dynamic> map) {
    final applicationMap = _map(map['job_application']);
    return InterviewModel(
      id: _int(map['id'], -1),
      jobApplicationId: _nullableInt(
        map['job_application_id'] ?? applicationMap['id'],
      ),
      type: LocalizedValue.fromDynamic(map['type'] ?? map['interview_type']),
      mode: LocalizedValue.fromDynamic(map['mode'] ?? map['interview_mode']),
      status: LocalizedValue.fromDynamic(map['status'] ?? map['state']),
      confirmationStatus: LocalizedValue.fromDynamic(
        map['candidate_confirmation_status'],
      ),
      attendanceStatus: LocalizedValue.fromDynamic(
        map['candidate_attendance_status'],
      ),
      scheduledStartAt: _date(map['scheduled_start_at'] ?? map['scheduled_at']),
      scheduledEndAt: _date(map['scheduled_end_at'] ?? map['ends_at']),
      durationMinutes: _int(map['duration_minutes']),
      meetingLink: _nullableText(map['meeting_link']),
      location: _nullableText(map['location_text'] ?? map['location']),
      candidateMessage: _nullableText(map['candidate_message']),
      cancellationMessage: _nullableText(map['cancellation_message']),
      videoProvider: _nullableText(map['video_provider']),
      embeddedVideoAvailable: map['embedded_video_available'] == true,
      confirmedAt: _date(map['confirmed_at']),
      completedAt: _date(map['completed_at']),
      cancelledAt: _date(map['cancelled_at']),
      createdAt: _date(map['created_at']),
      updatedAt: _date(map['updated_at']),
      jobApplication: applicationMap.isEmpty
          ? null
          : JobApplication.fromMap(applicationMap),
    );
  }

  bool get needsConfirmation =>
      confirmationStatus.key == 'pending' &&
      (status.key == 'scheduled' || status.key == 'rescheduled');

  bool get isOnline => mode.key == 'online';

  bool get canOpenMeeting =>
      isOnline && meetingLink != null && status.key != 'cancelled';

  String get jobTitle {
    final value = jobApplication?.job.title.trim() ?? '';
    return value.isEmpty ? 'Interview' : value;
  }

  String get companyName {
    final value = jobApplication?.job.company.name.trim() ?? '';
    return value.isEmpty ? 'Hiring company' : value;
  }

  String? get companyLogoUrl => jobApplication?.job.company.logoUrl;

  InterviewModel copyWith({
    LocalizedValue? status,
    LocalizedValue? confirmationStatus,
    DateTime? confirmedAt,
  }) => InterviewModel(
    id: id,
    jobApplicationId: jobApplicationId,
    type: type,
    mode: mode,
    status: status ?? this.status,
    confirmationStatus: confirmationStatus ?? this.confirmationStatus,
    attendanceStatus: attendanceStatus,
    scheduledStartAt: scheduledStartAt,
    scheduledEndAt: scheduledEndAt,
    durationMinutes: durationMinutes,
    meetingLink: meetingLink,
    location: location,
    candidateMessage: candidateMessage,
    cancellationMessage: cancellationMessage,
    videoProvider: videoProvider,
    embeddedVideoAvailable: embeddedVideoAvailable,
    confirmedAt: confirmedAt ?? this.confirmedAt,
    completedAt: completedAt,
    cancelledAt: cancelledAt,
    createdAt: createdAt,
    updatedAt: updatedAt,
    jobApplication: jobApplication,
  );
}

Map<String, dynamic> _map(dynamic value) =>
    value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};

int _int(dynamic value, [int fallback = 0]) =>
    int.tryParse('${value ?? ''}') ?? fallback;

int? _nullableInt(dynamic value) => int.tryParse('${value ?? ''}');

DateTime? _date(dynamic value) =>
    DateTime.tryParse('${value ?? ''}')?.toLocal();

String? _nullableText(dynamic value) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty || text == 'null' ? null : text;
}
