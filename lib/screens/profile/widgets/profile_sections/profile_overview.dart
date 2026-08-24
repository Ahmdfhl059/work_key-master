part of '../profile_sections.dart';

class ProfileOverview extends StatelessWidget {
  final ProfileModel profile;
  final VoidCallback onEditProfile;
  final VoidCallback onManageSkills, onManageExperience, onManageEducation;
  const ProfileOverview({
    super.key,
    required this.profile,
    required this.onEditProfile,
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
          actionLabel: s.edit,
          onAction: onEditProfile,
          child: DefaultText(
            text: profile.summary.isEmpty ? s.emptySummary : profile.summary,
            style: TextStyle(
              color: context.appMuted,
              fontSize: 13,
              height: 1.65,
            ),
          ),
        ),
        const SizedBox(height: 14),
        ProfileSection(
          title: s.skills,
          icon: Icons.auto_awesome_rounded,
          actionLabel: context.tr('profile.manage'),
          onAction: onManageSkills,
          child: profile.skills.isEmpty
              ? Text(context.tr('profile.empty_skills'))
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
                            color: context.appSoftBrand,
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
          actionLabel: context.tr('profile.manage'),
          onAction: onManageExperience,
          child: profile.experiences.isEmpty
              ? Text(context.tr('profile.empty_experience'))
              : Column(
                  children: profile.experiences
                      .map(
                        (item) => ProfileTimelineItem(
                          title: item.title,
                          subtitle: item.companyName,
                          detail:
                              '${item.startDate} — ${item.isCurrent ? context.tr('profile.present') : item.endDate}',
                        ),
                      )
                      .toList(),
                ),
        ),
        const SizedBox(height: 14),
        ProfileSection(
          title: s.education,
          icon: Icons.school_outlined,
          actionLabel: context.tr('profile.manage'),
          onAction: onManageEducation,
          child: profile.education.isEmpty
              ? Text(context.tr('profile.empty_education'))
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
          actionLabel: s.edit,
          onAction: onEditProfile,
          child: Column(
            children: [
              _ProfileValueRow(
                icon: Icons.location_city_outlined,
                label: context.tr('profile.city'),
                value: profile.cityName,
              ),
              _ProfileValueRow(
                icon: Icons.location_on_outlined,
                label: context.tr('profile.location_details'),
                value: profile.location,
              ),
              _ProfileValueRow(
                icon: Icons.event_available_outlined,
                label: context.tr('profile.availability'),
                value: _availabilityLabel(context, profile),
                isLast: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        ProfileSection(
          title: s.contact,
          icon: Icons.contact_mail_outlined,
          actionLabel: s.edit,
          onAction: onEditProfile,
          child: Column(
            children: [
              _ProfileValueRow(
                icon: Icons.email_outlined,
                label: context.tr('profile.account_email'),
                value: profile.user.email,
                locked: true,
              ),
              _ProfileValueRow(
                icon: Icons.phone_outlined,
                label: context.tr('profile.phone'),
                value: profile.phone.isEmpty
                    ? profile.user.phone
                    : profile.phone,
              ),
              _ProfileValueRow(
                icon: Icons.language_rounded,
                label: context.tr('profile.portfolio_url'),
                value: profile.portfolioUrl,
              ),
              _ProfileValueRow(
                icon: Icons.link_rounded,
                label: context.tr('profile.linkedin_url'),
                value: profile.linkedinUrl,
              ),
              _ProfileValueRow(
                icon: Icons.code_rounded,
                label: context.tr('profile.github_url'),
                value: profile.githubUrl,
                isLast: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  static String _availabilityLabel(BuildContext context, ProfileModel profile) {
    final label = switch (profile.availabilityStatus) {
      'available_now' => context.tr('profile.available_now'),
      'available_from_date' => context.tr('profile.available_from_date'),
      'not_available' => context.tr('profile.not_available'),
      _ => context.tr('profile.not_specified'),
    };
    if (profile.availabilityStatus == 'available_from_date' &&
        profile.availableFrom.isNotEmpty) {
      return '$label · ${profile.availableFrom}';
    }
    return label;
  }
}

class _ProfileValueRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool locked;
  final bool isLast;

  const _ProfileValueRow({
    required this.icon,
    required this.label,
    required this.value,
    this.locked = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shownValue = value.trim().isEmpty
        ? context.tr('profile.tap_edit_to_add')
        : value;
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 19, color: scheme.primary),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  shownValue,
                  style: TextStyle(
                    color: value.trim().isEmpty
                        ? scheme.onSurfaceVariant
                        : scheme.onSurface,
                    fontSize: 12.5,
                    fontWeight: value.trim().isEmpty
                        ? FontWeight.w400
                        : FontWeight.w700,
                    fontStyle: value.trim().isEmpty
                        ? FontStyle.italic
                        : FontStyle.normal,
                  ),
                ),
              ],
            ),
          ),
          if (locked) ...[
            const SizedBox(width: 8),
            Tooltip(
              message: context.tr('profile.email_managed_by_account'),
              child: Icon(
                Icons.lock_outline_rounded,
                size: 16,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
