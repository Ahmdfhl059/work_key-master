import 'job_model.dart';
import 'user_model.dart';

class ApplicationModel {
  String? message;
  final int id;
  String status;
  String appliedAt;
  JobModel job;
  UserModel applicant;
  List<ApplicationHistoryModel> history;

  ApplicationModel({
    this.message,
    required this.id,
    required this.status,
    required this.appliedAt,
    required this.job,
    required this.applicant,
    required this.history,
  });

  factory ApplicationModel.initial() => ApplicationModel(
    id: -1,
    message: '',
    status: '',
    appliedAt: '',
    job: JobModel.initial(),
    applicant: UserModel.initial(),
    history: [],
  );

  factory ApplicationModel.fromMap(Map<String, dynamic> map) {
    return ApplicationModel(
      id: int.tryParse('${map['id'] ?? ''}') ?? -1,
      message: map['message']?.toString() ?? '',
      status: map['status']?.toString() ?? '',
      appliedAt: map['created_at']?.toString() ?? '',
      job: map['job'] is Map
          ? JobModel.fromMap(Map<String, dynamic>.from(map['job']))
          : JobModel.initial(),
      applicant: map['applicant'] is Map
          ? UserModel.fromMap(Map<String, dynamic>.from(map['applicant']))
          : UserModel.initial(),
      history: map['history'] is List
          ? (map['history'] as List)
                .whereType<Map>()
                .map(
                  (i) => ApplicationHistoryModel.fromMap(
                    Map<String, dynamic>.from(i),
                  ),
                )
                .toList()
          : [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'message': message,
      'status': status,
      'applied_at': appliedAt,
      'job': job.toMap(),
      'applicant': applicant.toMap(),
      'history': history.map((e) => e.toMap()).toList(),
    };
  }
}

class ApplicationHistoryModel {
  String fromStatus;
  String toStatus;
  String note;
  String createdAt;

  ApplicationHistoryModel({
    required this.fromStatus,
    required this.toStatus,
    required this.note,
    required this.createdAt,
  });

  factory ApplicationHistoryModel.fromMap(Map<String, dynamic> map) {
    return ApplicationHistoryModel(
      fromStatus: map['from_status']?.toString() ?? '',
      toStatus: map['to_status']?.toString() ?? '',
      note: map['note']?.toString() ?? '',
      createdAt: map['created_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'from_status': fromStatus,
      'to_status': toStatus,
      'note': note,
      'created_at': createdAt,
    };
  }
}
