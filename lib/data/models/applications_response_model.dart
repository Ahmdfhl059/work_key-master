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
    if (value is Map)
      return LocalizedValue(
        key: '${value['key'] ?? ''}',
        label: '${value['value'] ?? value['label'] ?? value['key'] ?? ''}',
      );
    return LocalizedValue(key: '${value ?? ''}', label: '${value ?? ''}');
  }
}

class JobApplication {
  final int id;
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
    logoUrl: map['logo_url']?.toString() ?? map['logo']?.toString(),
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
