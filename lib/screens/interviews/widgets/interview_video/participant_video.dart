part of '../../interview_video_screen.dart';

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
