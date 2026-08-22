import '../../utils/media_url.dart';

class ActivityResponse {
  final ActivitySummary summary;
  final List<ActivityItem> upcomingSchedule;
  final List<ActivityItem> requiresAction;
  final ActivityFeed feed;

  const ActivityResponse({
    required this.summary,
    required this.upcomingSchedule,
    required this.requiresAction,
    required this.feed,
  });

  factory ActivityResponse.fromMap(Map<String, dynamic> root) {
    final data = _map(root['data']);
    return ActivityResponse(
      summary: ActivitySummary.fromMap(_map(data['summary'])),
      upcomingSchedule: _items(data['upcoming_schedule']),
      requiresAction: _items(data['requires_action']),
      feed: ActivityFeed.fromMap(_map(data['feed'])),
    );
  }
}

class ActivitySummary {
  final int all,
      requiresAction,
      today,
      thisWeek,
      tests,
      interviews,
      informationRequests,
      statusUpdates,
      unreadNotifications;
  const ActivitySummary({
    this.all = 0,
    this.requiresAction = 0,
    this.today = 0,
    this.thisWeek = 0,
    this.tests = 0,
    this.interviews = 0,
    this.informationRequests = 0,
    this.statusUpdates = 0,
    this.unreadNotifications = 0,
  });
  factory ActivitySummary.fromMap(Map<String, dynamic> map) => ActivitySummary(
    all: _int(map['all']),
    requiresAction: _int(map['requires_action']),
    today: _int(map['today']),
    thisWeek: _int(map['this_week']),
    tests: _int(map['tests']),
    interviews: _int(map['interviews']),
    informationRequests: _int(map['information_requests']),
    statusUpdates: _int(map['status_updates']),
    unreadNotifications: _int(map['unread_notifications']),
  );
  int forGroup(String group) => group == 'requires_action'
      ? requiresAction
      : group == 'today'
      ? today
      : group == 'this_week'
      ? thisWeek
      : all;
  ActivitySummary copyWith({int? unreadNotifications}) => ActivitySummary(
    all: all,
    requiresAction: requiresAction,
    today: today,
    thisWeek: thisWeek,
    tests: tests,
    interviews: interviews,
    informationRequests: informationRequests,
    statusUpdates: statusUpdates,
    unreadNotifications: unreadNotifications ?? this.unreadNotifications,
  );
}

class ActivityItem {
  final String key;
  final LocalizedActivityValue type;
  final String title, description;
  final ActivityApplicationSummary? application;
  final ActivityJobSummary? job;
  final ActivityCompanySummary? company;
  final bool requiresAction, isOverdue, isToday, isThisWeek, isRead;
  final int? notificationId;
  final String? occurredAt, startsAt, dueAt, readAt;
  final ActivityAction? action;

  const ActivityItem({
    required this.key,
    required this.type,
    required this.title,
    required this.description,
    this.application,
    this.job,
    this.company,
    required this.requiresAction,
    required this.isOverdue,
    required this.isToday,
    required this.isThisWeek,
    required this.isRead,
    this.notificationId,
    this.occurredAt,
    this.startsAt,
    this.dueAt,
    this.readAt,
    this.action,
  });
  factory ActivityItem.fromMap(Map<String, dynamic> map) => ActivityItem(
    key: '${map['activity_key'] ?? map['id'] ?? map['notification_id'] ?? ''}',
    type: LocalizedActivityValue.fromDynamic(map['type']),
    title: '${map['title'] ?? ''}',
    description: '${map['description'] ?? map['message'] ?? ''}',
    application: map['application'] is Map
        ? ActivityApplicationSummary.fromMap(_map(map['application']))
        : null,
    job: map['job'] is Map
        ? ActivityJobSummary.fromMap(_map(map['job']))
        : null,
    company: map['company'] is Map
        ? ActivityCompanySummary.fromMap(_map(map['company']))
        : null,
    requiresAction: map['requires_action'] == true,
    isOverdue: map['is_overdue'] == true,
    isToday: map['is_today'] == true,
    isThisWeek: map['is_this_week'] == true,
    isRead: map['is_read'] == true,
    notificationId: int.tryParse('${map['notification_id'] ?? ''}'),
    occurredAt: map['occurred_at']?.toString(),
    startsAt: map['starts_at']?.toString(),
    dueAt: map['due_at']?.toString(),
    readAt: map['read_at']?.toString(),
    action: map['action'] is Map
        ? ActivityAction.fromMap(_map(map['action']))
        : null,
  );
  ActivityItem markRead() => ActivityItem(
    key: key,
    type: type,
    title: title,
    description: description,
    application: application,
    job: job,
    company: company,
    requiresAction: requiresAction,
    isOverdue: isOverdue,
    isToday: isToday,
    isThisWeek: isThisWeek,
    isRead: true,
    notificationId: notificationId,
    occurredAt: occurredAt,
    startsAt: startsAt,
    dueAt: dueAt,
    readAt: DateTime.now().toIso8601String(),
    action: action,
  );
}

class LocalizedActivityValue {
  final String key, label;
  const LocalizedActivityValue({required this.key, required this.label});
  factory LocalizedActivityValue.fromDynamic(dynamic value) => value is Map
      ? LocalizedActivityValue(
          key: '${value['key'] ?? ''}',
          label: '${value['value'] ?? value['label'] ?? value['key'] ?? ''}',
        )
      : LocalizedActivityValue(key: '${value ?? ''}', label: '${value ?? ''}');
}

class ActivityAction {
  final LocalizedActivityValue type;
  final String label;
  final ActivityTarget target;
  const ActivityAction({
    required this.type,
    required this.label,
    required this.target,
  });
  factory ActivityAction.fromMap(Map<String, dynamic> map) => ActivityAction(
    type: LocalizedActivityValue.fromDynamic(map['type']),
    label: '${map['label'] ?? ''}',
    target: ActivityTarget.fromMap(_map(map['target'])),
  );
}

class ActivityTarget {
  final String type;
  final int? id;
  const ActivityTarget({required this.type, this.id});
  factory ActivityTarget.fromMap(Map<String, dynamic> map) => ActivityTarget(
    type: '${map['type'] ?? ''}',
    id: int.tryParse('${map['id'] ?? ''}'),
  );
}

class ActivityFeed {
  final List<ActivityItem> items;
  final ActivityFeedMeta meta;
  const ActivityFeed({required this.items, required this.meta});
  factory ActivityFeed.fromMap(Map<String, dynamic> map) => ActivityFeed(
    items: _items(map['data']),
    meta: ActivityFeedMeta.fromMap(_map(map['meta'])),
  );
}

class ActivityFeedMeta {
  final int currentPage, lastPage, perPage, total;
  const ActivityFeedMeta({
    this.currentPage = 1,
    this.lastPage = 1,
    this.perPage = 15,
    this.total = 0,
  });
  factory ActivityFeedMeta.fromMap(Map<String, dynamic> map) =>
      ActivityFeedMeta(
        currentPage: _int(map['current_page'], 1),
        lastPage: _int(map['last_page'], 1),
        perPage: _int(map['per_page'], 15),
        total: _int(map['total']),
      );
}

class ActivityApplicationSummary {
  final int id;
  final String status;
  const ActivityApplicationSummary(this.id, this.status);
  factory ActivityApplicationSummary.fromMap(Map<String, dynamic> map) =>
      ActivityApplicationSummary(
        _int(map['id'], -1),
        LocalizedActivityValue.fromDynamic(map['status']).label,
      );
}

class ActivityJobSummary {
  final int id;
  final String title, location;
  const ActivityJobSummary(this.id, this.title, this.location);
  factory ActivityJobSummary.fromMap(Map<String, dynamic> map) =>
      ActivityJobSummary(
        _int(map['id'], -1),
        '${map['title'] ?? ''}',
        LocalizedActivityValue.fromDynamic(
          map['location'] ?? map['city'],
        ).label,
      );
}

class ActivityCompanySummary {
  final int id;
  final String name;
  final String? logoUrl;
  const ActivityCompanySummary(this.id, this.name, this.logoUrl);
  factory ActivityCompanySummary.fromMap(Map<String, dynamic> map) =>
      ActivityCompanySummary(
        _int(map['id'], -1),
        '${map['name'] ?? ''}',
        resolveMediaUrl(
          map['logo_url'] ??
              map['logo'] ??
              map['company_logo_url'] ??
              map['logo_path'] ??
              map['company_logo'] ??
              (map['media'] is Map ? (map['media'] as Map)['logo'] : null),
        ),
      );
}

Map<String, dynamic> _map(dynamic value) =>
    value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};
List<ActivityItem> _items(dynamic value) => value is List
    ? value
          .whereType<Map>()
          .map((item) => ActivityItem.fromMap(Map<String, dynamic>.from(item)))
          .toList()
    : <ActivityItem>[];
int _int(dynamic value, [int fallback = 0]) =>
    int.tryParse('${value ?? ''}') ?? fallback;
