import 'dart:async';

import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';

import '../../data/repo/interviews_repo.dart';
import '../../localization/app_localizations.dart';
import '../../services/secure_session_service.dart';

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

class _ParticipantVideo extends StatelessWidget {
  final Participant? participant;
  final String waitingTitle;
  final String? waitingSubtitle;
  final bool compact;
  final bool mirror;

  const _ParticipantVideo({
    required this.participant,
    required this.waitingTitle,
    this.waitingSubtitle,
    this.compact = false,
    this.mirror = false,
  });

  @override
  Widget build(BuildContext context) {
    final publication = participant?.videoTrackPublications
        .where((publication) => publication.track is VideoTrack)
        .cast<TrackPublication<VideoTrack>>()
        .firstOrNull;
    final track = publication?.track;
    if (track != null && publication?.muted != true) {
      return VideoTrackRenderer(
        track,
        fit: VideoViewFit.cover,
        mirrorMode: mirror
            ? VideoViewMirrorMode.mirror
            : VideoViewMirrorMode.off,
      );
    }
    return Container(
      color: compact ? const Color(0xFF15233A) : const Color(0xFF091528),
      alignment: Alignment.center,
      padding: EdgeInsets.all(compact ? 10 : 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: compact ? 24 : 42,
            backgroundColor: const Color(0xFF24395E),
            child: Icon(
              Icons.person_rounded,
              color: Colors.white70,
              size: compact ? 27 : 45,
            ),
          ),
          SizedBox(height: compact ? 8 : 17),
          Text(
            participant?.name.isNotEmpty == true
                ? participant!.name
                : waitingTitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: compact ? 10.5 : 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (!compact && waitingSubtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              waitingSubtitle!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CallHeader extends StatelessWidget {
  final String title;
  final String roomName;

  const _CallHeader({required this.title, required this.roomName});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
    decoration: BoxDecoration(
      color: const Color(0xB5121F34),
      borderRadius: BorderRadius.circular(17),
      border: Border.all(color: Colors.white12),
    ),
    child: Row(
      children: [
        const CircleAvatar(
          radius: 18,
          backgroundColor: Color(0xFF18A949),
          child: Icon(Icons.lock_rounded, color: Colors.white, size: 17),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                roomName.isEmpty ? 'Secure Work Key interview' : roomName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white54, fontSize: 9.5),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _CallControls extends StatelessWidget {
  final bool microphoneEnabled;
  final bool cameraEnabled;
  final VoidCallback toggleMicrophone;
  final VoidCallback toggleCamera;
  final VoidCallback switchCamera;
  final VoidCallback leave;

  const _CallControls({
    required this.microphoneEnabled,
    required this.cameraEnabled,
    required this.toggleMicrophone,
    required this.toggleCamera,
    required this.switchCamera,
    required this.leave,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
    decoration: BoxDecoration(
      color: const Color(0xE5121F34),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: Colors.white12),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _ControlButton(
          icon: microphoneEnabled ? Icons.mic_rounded : Icons.mic_off_rounded,
          active: microphoneEnabled,
          onTap: toggleMicrophone,
        ),
        _ControlButton(
          icon: cameraEnabled
              ? Icons.videocam_rounded
              : Icons.videocam_off_rounded,
          active: cameraEnabled,
          onTap: toggleCamera,
        ),
        _ControlButton(
          icon: Icons.cameraswitch_rounded,
          active: true,
          onTap: switchCamera,
        ),
        _ControlButton(
          icon: Icons.call_end_rounded,
          color: const Color(0xFFE84949),
          active: true,
          onTap: leave,
        ),
      ],
    ),
  );
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final bool active;
  final Color? color;
  final VoidCallback onTap;

  const _ControlButton({
    required this.icon,
    required this.active,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) => IconButton.filled(
    onPressed: onTap,
    style: IconButton.styleFrom(
      minimumSize: const Size(50, 50),
      backgroundColor: color ?? (active ? Colors.white : Colors.white12),
      foregroundColor: color == null && active
          ? const Color(0xFF1B2831)
          : Colors.white,
    ),
    icon: Icon(icon),
  );
}

class _VideoLoading extends StatelessWidget {
  const _VideoLoading();

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(color: Colors.white),
        const SizedBox(height: 17),
        Text(
          context.tr('Preparing your secure interview room...'),
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
      ],
    ),
  );
}

class _VideoError extends StatelessWidget {
  final String message;
  final VoidCallback leave;

  const _VideoError({required this.message, required this.leave});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.videocam_off_rounded, color: Colors.white, size: 58),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, height: 1.5),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: leave,
            child: Text(context.tr('common.back')),
          ),
        ],
      ),
    ),
  );
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
