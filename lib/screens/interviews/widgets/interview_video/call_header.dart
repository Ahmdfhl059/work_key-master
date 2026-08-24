part of '../../interview_video_screen.dart';

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
