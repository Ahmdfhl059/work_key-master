import '../api/interviews_api.dart';
import '../models/interview_model.dart';

class InterviewsRepo {
  final InterviewsApi _interviewsApi;

  InterviewsRepo({InterviewsApi? interviewsApi})
    : _interviewsApi = interviewsApi ?? InterviewsApi();

  Future<InterviewListResponse> getMyInterviews({
    int page = 1,
    int perPage = 15,
  }) async {
    final response = await _interviewsApi.getMyInterviews(
      page: page,
      perPage: perPage,
    );
    return InterviewListResponse.fromMap(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  Future<InterviewModel> getInterviewDetails(int id) async {
    final response = await _interviewsApi.getInterviewDetails(id);
    final root = Map<String, dynamic>.from(response.data as Map);
    final data = root['data'];
    if (data is! Map) throw const FormatException('Interview data is missing.');
    return InterviewModel.fromMap(Map<String, dynamic>.from(data));
  }

  Future<InterviewModel> confirmInterview(int id) async {
    final response = await _interviewsApi.confirmInterview(id);
    final root = Map<String, dynamic>.from(response.data as Map);
    final data = root['data'];
    if (data is! Map) throw const FormatException('Interview data is missing.');
    return InterviewModel.fromMap(Map<String, dynamic>.from(data));
  }

  Future<InterviewVideoSession> createVideoSession(int id) async {
    final response = await _interviewsApi.createVideoSession(id);
    final root = Map<String, dynamic>.from(response.data as Map);
    final data = root['data'];
    if (data is! Map) {
      throw const FormatException('Interview video session is missing.');
    }
    return InterviewVideoSession.fromMap(Map<String, dynamic>.from(data));
  }
}

class InterviewVideoSession {
  final String provider;
  final String serverUrl;
  final String participantToken;
  final String roomName;
  final String participantName;
  final String participantRole;
  final DateTime? expiresAt;
  final String? fallbackMeetingLink;

  const InterviewVideoSession({
    required this.provider,
    required this.serverUrl,
    required this.participantToken,
    required this.roomName,
    required this.participantName,
    required this.participantRole,
    this.expiresAt,
    this.fallbackMeetingLink,
  });

  factory InterviewVideoSession.fromMap(Map<String, dynamic> map) {
    final room = map['room'] is Map
        ? Map<String, dynamic>.from(map['room'])
        : <String, dynamic>{};
    final participant = map['participant'] is Map
        ? Map<String, dynamic>.from(map['participant'])
        : <String, dynamic>{};
    final serverUrl = _sessionText(map['server_url']);
    final token = _sessionText(map['participant_token']);
    if (serverUrl.isEmpty || token.isEmpty) {
      throw const FormatException('Interview video credentials are missing.');
    }
    return InterviewVideoSession(
      provider: _sessionText(map['provider']),
      serverUrl: serverUrl,
      participantToken: token,
      roomName: _sessionText(room['name']),
      participantName: _sessionText(participant['display_name']),
      participantRole: _sessionText(participant['role']),
      expiresAt: DateTime.tryParse(_sessionText(map['expires_at']))?.toLocal(),
      fallbackMeetingLink: _sessionNullableText(map['fallback_meeting_link']),
    );
  }
}

String _sessionText(dynamic value) {
  final text = value?.toString().trim() ?? '';
  return text == 'null' ? '' : text;
}

String? _sessionNullableText(dynamic value) {
  final text = _sessionText(value);
  return text.isEmpty ? null : text;
}
