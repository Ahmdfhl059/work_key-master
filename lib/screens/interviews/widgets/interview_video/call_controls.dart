part of '../../interview_video_screen.dart';

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
