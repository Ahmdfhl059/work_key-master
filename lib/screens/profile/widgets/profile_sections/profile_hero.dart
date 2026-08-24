part of '../profile_sections.dart';

class ProfileHero extends StatelessWidget {
  final ProfileModel profile;
  final String editLabel;
  final VoidCallback edit;
  final VoidCallback uploadAvatar;
  const ProfileHero({
    super.key,
    required this.profile,
    required this.editLabel,
    required this.edit,
    required this.uploadAvatar,
  });
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(21),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF29B148), Color(0xFF0FA348)],
      ),
      borderRadius: BorderRadius.circular(27),
      boxShadow: const [
        BoxShadow(
          color: Color(0x2A18A949),
          blurRadius: 28,
          offset: Offset(0, 13),
        ),
      ],
    ),
    child: Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: uploadAvatar,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 37,
                    backgroundColor: Colors.white,
                    foregroundImage: profile.user.avatarUrl == null
                        ? null
                        : NetworkImage(profile.user.avatarUrl!),
                    onForegroundImageError: profile.user.avatarUrl == null
                        ? null
                        : (_, _) {},
                    child: profile.user.avatarUrl == null
                        ? Text(
                            _initials(profile.user.name),
                            style: const TextStyle(
                              color: HomeColors.purple,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          )
                        : null,
                  ),
                  PositionedDirectional(
                    end: -3,
                    bottom: -3,
                    child: CircleAvatar(
                      radius: 13,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.camera_alt_rounded,
                        size: 15,
                        color: HomeColors.brand,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DefaultText(
                    text: profile.user.name.isEmpty
                        ? context.tr('profile.job_seeker')
                        : profile.user.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      height: 1.25,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  DefaultText(
                    text: profile.headline.isEmpty
                        ? context.tr('profile.add_headline')
                        : profile.headline,
                    style: const TextStyle(
                      color: Color(0xFFE8F7ED),
                      fontSize: 12.5,
                      height: 1.4,
                    ),
                  ),
                  if (profile.location.isNotEmpty) ...[
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: DefaultText(
                            text: profile.location,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 10.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              onPressed: edit,
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: .15),
              ),
              icon: const Icon(
                Icons.edit_rounded,
                color: Colors.white,
                size: 19,
              ),
              tooltip: editLabel,
            ),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: _Metric(
                '${profile.yearsOfExperience}',
                context.tr('profile.years_experience'),
              ),
            ),
            Container(width: 1, height: 35, color: Colors.white24),
            Expanded(
              child: _Metric(
                '${profile.skills.length}',
                context.tr('profile.skills'),
              ),
            ),
            Container(width: 1, height: 35, color: Colors.white24),
            Expanded(
              child: _Metric(
                '${profile.experiences.length}',
                context.tr('profile.roles'),
              ),
            ),
          ],
        ),
      ],
    ),
  );
  static String _initials(String name) {
    final words = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .take(2);
    return words.isEmpty ? 'W' : words.map((e) => e[0].toUpperCase()).join();
  }
}

class _Metric extends StatelessWidget {
  final String value, label;
  const _Metric(this.value, this.label);
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        value,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 17,
          fontWeight: FontWeight.w900,
        ),
      ),
      const SizedBox(height: 3),
      Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white70, fontSize: 9.5),
      ),
    ],
  );
}
