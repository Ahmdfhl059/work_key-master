import 'dart:async';

import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';

import '../../data/repo/interviews_repo.dart';
import '../../localization/app_localizations.dart';
import '../../services/secure_session_service.dart';

part 'widgets/interview_video/participant_video.dart';
part 'widgets/interview_video/call_header.dart';
part 'widgets/interview_video/call_controls.dart';
part 'widgets/interview_video/video_states.dart';

class InterviewVideoScreen extends StatefulWidget {
  final InterviewVideoSession session;
  final String title;

  const InterviewVideoScreen({
    super.key,
    required this.session,
    required this.title,
  });

  @override
  State<InterviewVideoScreen> createState() => _InterviewVideoScreenState();
}

class _InterviewVideoScreenState extends State<InterviewVideoScreen>
    with WidgetsBindingObserver {
  late final Room _room;
  EventsListener<RoomEvent>? _listener;
  bool _connecting = true;
  bool _microphoneEnabled = true;
  bool _cameraEnabled = true;
  String? _error;
  bool _leftApp = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(SecureSessionService.setSecure(true));
    _room = Room(
      roomOptions: const RoomOptions(adaptiveStream: true, dynacast: true),
    );
    _room.addListener(_onRoomChanged);
    _connect();
  }

  Future<void> _connect() async {
    try {
      await LiveKitClient.initialize();
      _listener = _room.createListener()
        ..on<RoomDisconnectedEvent>((event) {
          if (mounted && Navigator.canPop(context)) Navigator.pop(context);
        });
      await _room.prepareConnection(
        widget.session.serverUrl,
        widget.session.participantToken,
      );
      await _room.connect(
        widget.session.serverUrl,
        widget.session.participantToken,
      );
      try {
        await _room.localParticipant?.setCameraEnabled(true);
      } catch (_) {
        _cameraEnabled = false;
      }
      try {
        await _room.localParticipant?.setMicrophoneEnabled(true);
      } catch (_) {
        _microphoneEnabled = false;
      }
    } catch (_) {
      _error = 'The secure video room could not be opened.';
    } finally {
      if (mounted) setState(() => _connecting = false);
    }
  }

  void _onRoomChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(SecureSessionService.setSecure(false));
    _room.removeListener(_onRoomChanged);
    unawaited(_listener?.dispose());
    unawaited(_room.disconnect());
    unawaited(_room.dispose());
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      if (!_leftApp) {
        _leftApp = true;
        unawaited(_room.disconnect());
      }
    } else if (state == AppLifecycleState.resumed && _leftApp && mounted) {
      Navigator.pop(context, 'left_app');
    }
  }

  @override
  Widget build(BuildContext context) {
    final remote = _room.remoteParticipants.values.isEmpty
        ? null
        : _room.remoteParticipants.values.first;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _leave();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF07101F),
        body: SafeArea(
          child: _connecting
              ? const _VideoLoading()
              : _error != null
              ? _VideoError(message: _error!, leave: _leave)
              : Stack(
                  fit: StackFit.expand,
                  children: [
                    _ParticipantVideo(
                      participant: remote,
                      waitingTitle: 'Waiting for the interviewer',
                      waitingSubtitle:
                          'You are connected. The call will begin when another participant joins.',
                    ),
                    Positioned(
                      top: 14,
                      left: 16,
                      right: 16,
                      child: _CallHeader(
                        title: widget.title,
                        roomName: widget.session.roomName,
                      ),
                    ),
                    PositionedDirectional(
                      top: 88,
                      end: 16,
                      child: SizedBox(
                        width: 112,
                        height: 158,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(19),
                          child: _ParticipantVideo(
                            participant: _room.localParticipant,
                            waitingTitle: 'Camera off',
                            compact: true,
                            mirror: true,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 20,
                      right: 20,
                      bottom: 23,
                      child: _CallControls(
                        microphoneEnabled: _microphoneEnabled,
                        cameraEnabled: _cameraEnabled,
                        toggleMicrophone: _toggleMicrophone,
                        toggleCamera: _toggleCamera,
                        switchCamera: _switchCamera,
                        leave: _leave,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Future<void> _toggleMicrophone() async {
    final next = !_microphoneEnabled;
    await _room.localParticipant?.setMicrophoneEnabled(next);
    if (mounted) setState(() => _microphoneEnabled = next);
  }

  Future<void> _toggleCamera() async {
    final next = !_cameraEnabled;
    await _room.localParticipant?.setCameraEnabled(next);
    if (mounted) setState(() => _cameraEnabled = next);
  }

  Future<void> _switchCamera() async {
    final cameras = await Hardware.instance.enumerateDevices();
    final videoInputs = cameras
        .where((device) => device.kind == 'videoinput')
        .toList();
    if (videoInputs.length < 2) return;
    final track = _room.localParticipant?.videoTrackPublications.first.track;
    if (track is! LocalVideoTrack) return;
    final currentId = track.currentOptions.deviceId;
    final next = videoInputs.firstWhere(
      (device) => device.deviceId != currentId,
      orElse: () => videoInputs.first,
    );
    await track.switchCamera(next.deviceId);
  }

  Future<void> _leave() async {
    await _room.disconnect();
    if (mounted) Navigator.pop(context);
  }
}
