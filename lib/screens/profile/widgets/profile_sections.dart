import 'package:flutter/material.dart';
import 'package:work_key/data/models/profile_model.dart';
import 'package:work_key/screens/profile/profile_strings.dart';
import 'package:work_key/shared/components/components.dart';
import 'package:work_key/utils/constants.dart';

class ProfileHero extends StatelessWidget {
  final ProfileModel profile;
  final String editLabel;
  final VoidCallback edit;
  final VoidCallback onAvatarTap;
  const ProfileHero({
    super.key,
    required this.profile,
    required this.editLabel,
    required this.edit,
    required this.onAvatarTap,
  });
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(21),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF5946CF), Color(0xFF8874E8)],
      ),
      borderRadius: BorderRadius.circular(27),
      boxShadow: const [
        BoxShadow(
          color: Color(0x2A6554D9),
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
              onTap: onAvatarTap,
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
                        : (_, __) {},
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
                  const PositionedDirectional(
                    end: -2,
                    bottom: -2,
                    child: CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.camera_alt_rounded,
                        color: HomeColors.purple,
                        size: 13,
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
                        ? 'Job seeker'
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
                        ? profile.careerLevel
                        : profile.headline,
                    style: const TextStyle(
                      color: Color(0xFFE9E4FF),
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
                'Years experience',
              ),
            ),
            Container(width: 1, height: 35, color: Colors.white24),
            Expanded(child: _Metric('${profile.skills.length}', 'Skills')),
            Container(width: 1, height: 35, color: Colors.white24),
            Expanded(child: _Metric('${profile.experiences.length}', 'Roles')),
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

class ProfileOverview extends StatelessWidget {
  final ProfileModel profile;
  final VoidCallback onManageSkills, onManageExperience, onManageEducation;
  const ProfileOverview({
    super.key,
    required this.profile,
    required this.onManageSkills,
    required this.onManageExperience,
    required this.onManageEducation,
  });
  @override
  Widget build(BuildContext context) {
    final s = ProfileStrings.of(context);
    return Column(
      children: [
        ProfileSection(
          title: s.about,
          icon: Icons.person_outline_rounded,
          child: DefaultText(
            text: profile.summary.isEmpty ? s.emptySummary : profile.summary,
            style: const TextStyle(
              color: HomeColors.muted,
              fontSize: 13,
              height: 1.65,
            ),
          ),
        ),
        const SizedBox(height: 14),
        ProfileSection(
          title: s.skills,
          icon: Icons.auto_awesome_rounded,
          actionLabel: 'Manage',
          onAction: onManageSkills,
          child: profile.skills.isEmpty
              ? const Text('Add skills to improve your recommendations.')
              : Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: profile.skills
                      .map(
                        (skill) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: HomeColors.softPurple,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            skill.name,
                            style: const TextStyle(
                              color: HomeColors.purple,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
        ),
        const SizedBox(height: 14),
        ProfileSection(
          title: s.experience,
          icon: Icons.work_outline_rounded,
          actionLabel: 'Manage',
          onAction: onManageExperience,
          child: profile.experiences.isEmpty
              ? const Text('Add your work experience.')
              : Column(
                  children: profile.experiences
                      .map(
                        (item) => ProfileTimelineItem(
                          title: item.title,
                          subtitle: item.companyName,
                          detail:
                              '${item.startDate} — ${item.isCurrent ? 'Present' : item.endDate}',
                        ),
                      )
                      .toList(),
                ),
        ),
        const SizedBox(height: 14),
        ProfileSection(
          title: s.education,
          icon: Icons.school_outlined,
          actionLabel: 'Manage',
          onAction: onManageEducation,
          child: profile.education.isEmpty
              ? const Text('Add your education.')
              : Column(
                  children: profile.education
                      .map(
                        (item) => ProfileTimelineItem(
                          title: item.degree,
                          subtitle:
                              '${item.fieldOfStudy}${item.institution.isEmpty ? '' : ' • ${item.institution}'}',
                          detail: '${item.startDate} — ${item.endDate}',
                        ),
                      )
                      .toList(),
                ),
        ),
        const SizedBox(height: 14),
        ProfileSection(
          title: s.preferences,
          icon: Icons.tune_rounded,
          child: Wrap(
            spacing: 7,
            runSpacing: 7,
            children:
                [
                      profile.currentStatus,
                      profile.careerLevel,
                      profile.educationLevel,
                      ...profile.preferredWorkTypes,
                      ...profile.preferredJobFields,
                    ]
                    .where((e) => e.isNotEmpty)
                    .map(
                      (text) => Chip(
                        label: Text(text),
                        backgroundColor: const Color(0xFFF3F5F9),
                        side: BorderSide.none,
                      ),
                    )
                    .toList(),
          ),
        ),
        const SizedBox(height: 14),
        ProfileSection(
          title: s.contact,
          icon: Icons.contact_mail_outlined,
          child: Column(
            children: [
              if (profile.user.email.isNotEmpty)
                ContactRow(Icons.email_outlined, profile.user.email),
              if ((profile.phone.isEmpty ? profile.user.phone : profile.phone)
                  .isNotEmpty)
                ContactRow(
                  Icons.phone_outlined,
                  profile.phone.isEmpty ? profile.user.phone : profile.phone,
                ),
              if (profile.portfolioUrl.isNotEmpty)
                ContactRow(Icons.language_rounded, profile.portfolioUrl),
              if (profile.linkedinUrl.isNotEmpty)
                ContactRow(Icons.link_rounded, profile.linkedinUrl),
              if (profile.githubUrl.isNotEmpty)
                ContactRow(Icons.code_rounded, profile.githubUrl),
            ],
          ),
        ),
      ],
    );
  }
}

class ProfileSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final String? actionLabel;
  final VoidCallback? onAction;
  const ProfileSection({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
    this.actionLabel,
    this.onAction,
  });
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(21),
      border: Border.all(color: HomeColors.divider),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0715213A),
          blurRadius: 15,
          offset: Offset(0, 7),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                color: HomeColors.softPurple,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: HomeColors.purple, size: 18),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: DefaultText(
                text: title,
                style: const TextStyle(
                  color: HomeColors.ink,
                  fontSize: 16.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            if (actionLabel != null)
              DefaultTextButton(
                text: actionLabel!,
                onPressed: onAction,
                textStyle: const TextStyle(
                  color: HomeColors.purple,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
          ],
        ),
        const SizedBox(height: 13),
        child,
      ],
    ),
  );
}

class ProfileTimelineItem extends StatelessWidget {
  final String title, subtitle, detail;
  const ProfileTimelineItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.detail,
  });
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 4),
          width: 10,
          height: 10,
          decoration: const BoxDecoration(
            color: HomeColors.purple,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DefaultText(
                text: title,
                style: const TextStyle(
                  color: HomeColors.ink,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (subtitle.isNotEmpty) ...[
                const SizedBox(height: 3),
                DefaultText(
                  text: subtitle,
                  style: const TextStyle(
                    color: HomeColors.muted,
                    fontSize: 11.5,
                  ),
                ),
              ],
              if (detail.replaceAll('—', '').trim().isNotEmpty) ...[
                const SizedBox(height: 4),
                DefaultText(
                  text: detail,
                  style: const TextStyle(
                    color: HomeColors.purple,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    ),
  );
}

class ContactRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const ContactRow(this.icon, this.text, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      children: [
        Icon(icon, size: 17, color: HomeColors.muted),
        const SizedBox(width: 9),
        Expanded(
          child: DefaultText(
            text: text,
            style: const TextStyle(color: HomeColors.ink, fontSize: 12.5),
          ),
        ),
      ],
    ),
  );
}
