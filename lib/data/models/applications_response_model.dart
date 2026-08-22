import '../../utils/media_url.dart';

class ApplicationListResponse {
  final List<JobApplication> items;
  final ApplicationPaginationMeta meta;
  const ApplicationListResponse({required this.items, required this.meta});

  factory ApplicationListResponse.fromMap(Map<String, dynamic> root) {
    final outer = root['data'] is Map
        ? Map<String, dynamic>.from(root['data'])
        : <String, dynamic>{};
    final list = outer['data'] is List ? outer['data'] as List : const [];
    return ApplicationListResponse(
      items: list
          .whereType<Map>()
          .map(
            (item) => JobApplication.fromMap(Map<String, dynamic>.from(item)),
          )
          .toList(),
      meta: ApplicationPaginationMeta.fromMap(
        outer['meta'] is Map
            ? Map<String, dynamic>.from(outer['meta'])
            : const {},
      ),
    );
  }
}

class ApplicationPaginationMeta {
  final ApplicationCounts counts;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  const ApplicationPaginationMeta({
    required this.counts,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });
  factory ApplicationPaginationMeta.fromMap(Map<String, dynamic> map) =>
      ApplicationPaginationMeta(
        counts: ApplicationCounts.fromMap(
          map['counts'] is Map
              ? Map<String, dynamic>.from(map['counts'])
              : const {},
        ),
        currentPage: _int(map['current_page'], 1),
        lastPage: _int(map['last_page'], 1),
        perPage: _int(map['per_page'], 15),
        total: _int(map['total'], 0),
      );
}

class ApplicationCounts {
  final int all, active, requiresAction, completed;
  const ApplicationCounts({
    this.all = 0,
    this.active = 0,
    this.requiresAction = 0,
    this.completed = 0,
  });
  factory ApplicationCounts.fromMap(Map<String, dynamic> map) =>
      ApplicationCounts(
        all: _int(map['all']),
        active: _int(map['active']),
        requiresAction: _int(map['requires_action']),
        completed: _int(map['completed']),
      );
  int forGroup(String group) => group == 'active'
      ? active
      : group == 'requires_action'
      ? requiresAction
      : group == 'completed'
      ? completed
      : all;
}

class LocalizedValue {
  final String key;
  final String label;
  const LocalizedValue({required this.key, required this.label});
  factory LocalizedValue.fromDynamic(dynamic value) {
    if (value is Map) {
      return LocalizedValue(
        key: '${value['key'] ?? ''}',
        label: '${value['value'] ?? value['label'] ?? value['key'] ?? ''}',
      );
    }
    return LocalizedValue(key: '${value ?? ''}', label: '${value ?? ''}');
  }
}

class JobApplication {
  final int id;
  final String coverLetter;
  final bool consentToShareProfile;
  final List<ApplicationScreeningAnswer> screeningAnswers;
  final LocalizedValue status;
  final bool requiresAction;
  final NextAction? nextAction;
  final List<String> allowedActions;
  final String? lastStatusChangedAt;
  final UpcomingEvent? upcomingEvent;
  final Map<String, dynamic>? currentTest;
  final Map<String, dynamic>? relevantInterview;
  final JobPostingSummary job;
  final List<ApplicationStatusHistory> statusHistory;
  final Map<String, dynamic>? latestInformationRequest;

  const JobApplication({
    required this.id,
    this.coverLetter = '',
    this.consentToShareProfile = false,
    this.screeningAnswers = const [],
    required this.status,
    required this.requiresAction,
    required this.nextAction,
    required this.allowedActions,
    this.lastStatusChangedAt,
    this.upcomingEvent,
    this.currentTest,
    this.relevantInterview,
    required this.job,
    this.statusHistory = const [],
    this.latestInformationRequest,
  });

  factory JobApplication.fromMap(Map<String, dynamic> map) => JobApplication(
    id: _int(map['id'], -1),
    coverLetter: '${map['cover_letter'] ?? ''}',
    consentToShareProfile: map['consent_to_share_profile'] == true,
    screeningAnswers:
        (map['screening_answers'] is List
                ? map['screening_answers'] as List
                : const [])
            .whereType<Map>()
            .map(
              (item) => ApplicationScreeningAnswer.fromMap(
                Map<String, dynamic>.from(item),
              ),
            )
            .where((item) => item.question.isNotEmpty)
            .toList(),
    status: LocalizedValue.fromDynamic(map['status']),
    requiresAction: map['requires_action'] == true,
    nextAction: map['next_action'] is Map
        ? NextAction.fromMap(Map<String, dynamic>.from(map['next_action']))
        : null,
    allowedActions:
        (map['allowed_actions'] is List
                ? map['allowed_actions'] as List
                : const [])
            .map((item) => LocalizedValue.fromDynamic(item).key)
            .where((item) => item.isNotEmpty)
            .toList(),
    lastStatusChangedAt:
        map['last_status_changed_at']?.toString() ??
        map['updated_at']?.toString(),
    upcomingEvent: map['upcoming_event'] is Map
        ? UpcomingEvent.fromMap(
            Map<String, dynamic>.from(map['upcoming_event']),
          )
        : null,
    currentTest: map['current_test'] is Map
        ? Map<String, dynamic>.from(map['current_test'])
        : null,
    relevantInterview: map['relevant_interview'] is Map
        ? Map<String, dynamic>.from(map['relevant_interview'])
        : null,
    job: JobPostingSummary.fromMap(
      map['job_posting'] is Map
          ? Map<String, dynamic>.from(map['job_posting'])
          : map['job'] is Map
          ? Map<String, dynamic>.from(map['job'])
          : const {},
    ),
    statusHistory:
        (map['status_history'] is List
                ? map['status_history'] as List
                : map['history'] is List
                ? map['history'] as List
                : const [])
            .whereType<Map>()
            .map(
              (item) => ApplicationStatusHistory.fromMap(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList(),
    latestInformationRequest: map['latest_information_request'] is Map
        ? Map<String, dynamic>.from(map['latest_information_request'])
        : null,
  );
}

class ApplicationScreeningAnswer {
  final String question;
  final String type;
  final bool required;
  final String answer;

  const ApplicationScreeningAnswer({
    required this.question,
    required this.type,
    required this.required,
    required this.answer,
  });

  factory ApplicationScreeningAnswer.fromMap(Map<String, dynamic> map) {
    final rawAnswer = map['answer'];
    final answerMap = rawAnswer is Map
        ? Map<String, dynamic>.from(rawAnswer)
        : <String, dynamic>{};
    final options = answerMap['selected_options'] is List
        ? (answerMap['selected_options'] as List)
              .map(
                (item) =>
                    item is Map ? '${item['option_text'] ?? ''}' : '$item',
              )
              .where((item) => item.isNotEmpty)
              .join(', ')
        : '';
    final value = answerMap['value'] ?? rawAnswer ?? map['value'];
    return ApplicationScreeningAnswer(
      question: '${map['question_text'] ?? map['question'] ?? ''}',
      type: LocalizedValue.fromDynamic(map['question_type']).label,
      required: map['is_required'] == true,
      answer: options.isNotEmpty ? options : _answerLabel(value),
    );
  }

  static String _answerLabel(dynamic value) {
    if (value == true) return 'Yes';
    if (value == false) return 'No';
    if (value is List) return value.map((item) => '$item').join(', ');
    return '${value ?? ''}';
  }
}

class NextAction {
  final LocalizedValue type;
  final String label;
  final int? resourceId;
  final String? deadline;
  const NextAction({
    required this.type,
    required this.label,
    this.resourceId,
    this.deadline,
  });
  factory NextAction.fromMap(Map<String, dynamic> map) => NextAction(
    type: LocalizedValue.fromDynamic(map['type']),
    label: '${map['label'] ?? map['title'] ?? ''}',
    resourceId: int.tryParse('${map['resource_id'] ?? ''}'),
    deadline: map['deadline']?.toString(),
  );
}

class UpcomingEvent {
  final String label;
  final String? dateTime;
  const UpcomingEvent({required this.label, this.dateTime});
  factory UpcomingEvent.fromMap(Map<String, dynamic> map) => UpcomingEvent(
    label: '${map['label'] ?? map['title'] ?? ''}',
    dateTime: map['date_time']?.toString() ?? map['starts_at']?.toString(),
  );
}

class JobPostingSummary {
  final int id;
  final String title, location, workMode, employmentType;
  final CompanySummary company;
  const JobPostingSummary({
    required this.id,
    required this.title,
    required this.location,
    required this.workMode,
    required this.employmentType,
    required this.company,
  });
  factory JobPostingSummary.fromMap(Map<String, dynamic> map) =>
      JobPostingSummary(
        id: _int(map['id'], -1),
        title: '${map['title'] ?? ''}',
        location: _label(map['location'] ?? map['city']),
        workMode: _label(map['work_mode']),
        employmentType: _label(map['employment_type']),
        company: CompanySummary.fromMap(
          map['company'] is Map
              ? Map<String, dynamic>.from(map['company'])
              : const {},
        ),
      );
}

class CompanySummary {
  final int id;
  final String name;
  final String? logoUrl;
  const CompanySummary({required this.id, required this.name, this.logoUrl});
  factory CompanySummary.fromMap(Map<String, dynamic> map) => CompanySummary(
    id: _int(map['id'], -1),
    name: '${map['name'] ?? ''}',
    logoUrl: resolveMediaUrl(
      map['logo_url'] ??
          map['logo'] ??
          map['company_logo_url'] ??
          map['logo_path'] ??
          map['company_logo'] ??
          (map['media'] is Map ? (map['media'] as Map)['logo'] : null),
    ),
  );
}

class ApplicationStatusHistory {
  final LocalizedValue status;
  final String? note, createdAt;
  const ApplicationStatusHistory({
    required this.status,
    this.note,
    this.createdAt,
  });
  factory ApplicationStatusHistory.fromMap(Map<String, dynamic> map) =>
      ApplicationStatusHistory(
        status: LocalizedValue.fromDynamic(map['status'] ?? map['to_status']),
        note: map['note']?.toString(),
        createdAt: map['created_at']?.toString(),
      );
}

int _int(dynamic value, [int fallback = 0]) =>
    int.tryParse('${value ?? ''}') ?? fallback;
String _label(dynamic value) => LocalizedValue.fromDynamic(value).label;
