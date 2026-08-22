import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:work_key/data/models/job_model.dart';
import 'package:work_key/data/models/skill_model.dart';
import 'package:work_key/data/repo/jobs_repo.dart';
import 'package:work_key/shared/components/components.dart';
import 'package:work_key/shared/components/app_snackbar.dart';
import 'package:work_key/utils/constants.dart';
import 'apply_job_sheet.dart';
import '../../localization/app_localizations.dart';
import '../../shared/components/company_logo.dart';
import '../../utils/shared preferences.dart';
import '../auth/login/login_screen.dart';
import '../applications/widgets/application_details_screen.dart';

class JobDetailsScreen extends StatefulWidget {
  final int jobId;
  final JobModel? initialJob;
  const JobDetailsScreen({super.key, required this.jobId, this.initialJob});
  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  late Future<JobModel> future;
  @override
  void initState() {
    super.initState();
    future = JobsRepo().getJobDetails(widget.jobId);
  }

  void _reload() {
    setState(() => future = JobsRepo().getJobDetails(widget.jobId));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Theme.of(context).colorScheme.surface,
    appBar: AppBar(
      backgroundColor: Theme.of(context).colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      title: Text(context.tr('jobs.details')),
    ),
    body: FutureBuilder<JobModel>(
      future: future,
      initialData: widget.initialJob,
      builder: (context, snapshot) {
        final job = snapshot.data;
        if (job != null && job.id >= 0) {
          return ResponsiveContent(
            maxWidth: 760,
            child: ListView(
              padding: const EdgeInsets.only(top: 12, bottom: 110),
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: AlignmentDirectional.topStart,
                      end: AlignmentDirectional.bottomEnd,
                      colors: [Color(0xFF4D63D2), Color(0xFF7651B5)],
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x244D63D2),
                        blurRadius: 25,
                        offset: Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      if (job.company.coverImage.isNotEmpty)
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Image.network(
                              job.company.coverImage,
                              fit: BoxFit.cover,
                              opacity: const AlwaysStoppedAnimation(.18),
                              errorBuilder: (_, _, _) =>
                                  const SizedBox.shrink(),
                            ),
                          ),
                        ),
                      PositionedDirectional(
                        end: -18,
                        top: 8,
                        child: Transform.rotate(
                          angle: -.35,
                          child: Container(
                            width: 108,
                            height: 108,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.white.withValues(alpha: .16),
                                width: 12,
                              ),
                              borderRadius: BorderRadius.circular(34),
                            ),
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CompanyLogo(
                            size: 58,
                            url: job.company.logo,
                            companyName: job.company.name,
                            backgroundColor: Colors.white,
                          ),
                          const SizedBox(height: 15),
                          DefaultText(
                            text: job.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              height: 1.25,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 6),
                          DefaultText(
                            text: job.company.name.isEmpty
                                ? context.tr('jobs.company')
                                : job.company.name,
                            style: const TextStyle(
                              color: Color(0xFFE8F7ED),
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 7,
                            runSpacing: 7,
                            children: [
                              if (job.hasApplied)
                                _HeroTag(
                                  Icons.check_circle_rounded,
                                  context.tr('jobs.already_applied'),
                                )
                              else if (job.isExpired)
                                _HeroTag(
                                  Icons.event_busy_rounded,
                                  context.tr('jobs.expired'),
                                )
                              else if (job.isNew)
                                _HeroTag(
                                  Icons.fiber_new_rounded,
                                  context.tr('jobs.new'),
                                ),
                              if (job.location.isNotEmpty)
                                _HeroTag(
                                  Icons.location_on_outlined,
                                  job.location,
                                ),
                              if (job.workMode.isNotEmpty)
                                _HeroTag(Icons.laptop_rounded, job.workMode),
                              if (job.employmentType.isNotEmpty)
                                _HeroTag(
                                  Icons.schedule_rounded,
                                  job.employmentType,
                                ),
                              if (job.department.isNotEmpty)
                                _HeroTag(
                                  Icons.account_tree_outlined,
                                  job.department,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _Section(
                  title: context.tr('jobs.about_role'),
                  icon: Icons.subject_rounded,
                  child: DefaultText(
                    text: job.description.isEmpty
                        ? context.tr('jobs.description_unavailable')
                        : job.description,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 13.5,
                      height: 1.65,
                    ),
                  ),
                ),
                if (job.requiredSkills.isNotEmpty ||
                    job.niceToHaveSkills.isNotEmpty ||
                    job.skills.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  _Section(
                    title: context.tr('profile.skills'),
                    icon: Icons.auto_awesome_rounded,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (job.requiredSkills.isNotEmpty) ...[
                          Text(
                            context.tr('jobs.required_skills'),
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _SkillWrap(
                            skills: job.requiredSkills,
                            required: true,
                          ),
                        ],
                        if (job.niceToHaveSkills.isNotEmpty) ...[
                          if (job.requiredSkills.isNotEmpty)
                            const SizedBox(height: 14),
                          Text(
                            context.tr('jobs.nice_to_have_skills'),
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _SkillWrap(skills: job.niceToHaveSkills),
                        ],
                        if (job.requiredSkills.isEmpty &&
                            job.niceToHaveSkills.isEmpty)
                          _SkillWrap(skills: job.skills),
                      ],
                    ),
                  ),
                ],
                if (job.responsibilities.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  _Section(
                    title: context.tr('jobs.responsibilities'),
                    icon: Icons.task_alt_rounded,
                    child: _BulletList(items: job.responsibilities),
                  ),
                ],
                if (job.requirements.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  _Section(
                    title: context.tr('jobs.requirements'),
                    icon: Icons.checklist_rounded,
                    child: _BulletList(items: job.requirements),
                  ),
                ],
                if (job.benefits.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  _Section(
                    title: context.tr('jobs.benefits'),
                    icon: Icons.redeem_rounded,
                    child: _BulletList(items: job.benefits, benefits: true),
                  ),
                ],
                if (job.educationLevel.isNotEmpty ||
                    job.experienceLevel.isNotEmpty ||
                    job.salaryMin > 0 ||
                    job.salaryMax > 0) ...[
                  const SizedBox(height: 14),
                  _Section(
                    title: context.tr('jobs.role_details'),
                    icon: Icons.analytics_outlined,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (job.experienceLevel.isNotEmpty)
                          _FactChip(
                            Icons.workspace_premium_outlined,
                            job.experienceLevel,
                          ),
                        if (job.educationLevel.isNotEmpty)
                          _FactChip(Icons.school_outlined, job.educationLevel),
                        if (job.salaryMin > 0 || job.salaryMax > 0)
                          _FactChip(
                            Icons.payments_outlined,
                            '${job.salaryMin > 0 ? job.salaryMin : ''}${job.salaryMin > 0 && job.salaryMax > 0 ? ' – ' : ''}${job.salaryMax > 0 ? job.salaryMax : ''}',
                          ),
                      ],
                    ),
                  ),
                ],
                if (job.deadline.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  _Section(
                    title: context.tr('jobs.application_deadline'),
                    icon: Icons.event_available_rounded,
                    child: DefaultText(
                      text: _date(job.deadline),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        }
        if (snapshot.connectionState != ConnectionState.done) {
          return const _JobDetailsSkeleton();
        }
        if (snapshot.hasError) {
          return _JobDetailsMessageState(
            icon: Icons.cloud_off_rounded,
            titleKey: 'jobs.load_error_title',
            bodyKey: 'jobs.load_error_body',
            onRetry: _reload,
          );
        }
        return const _JobDetailsMessageState(
          icon: Icons.work_off_outlined,
          titleKey: 'jobs.unavailable_title',
          bodyKey: 'jobs.unavailable_body',
        );
      },
    ),
    bottomNavigationBar: FutureBuilder<JobModel>(
      future: future,
      initialData: widget.initialJob,
      builder: (context, snapshot) {
        final job = snapshot.data;
        if ((job == null || job.id < 0) &&
            snapshot.connectionState == ConnectionState.done) {
          return const SizedBox.shrink();
        }
        final applied = job?.hasApplied == true;
        final canApply = job != null && job.id >= 0 && job.canApply != false;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
            child: FilledButton.icon(
              onPressed: applied || !canApply ? null : _openApply,
              icon: job == null
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2.2),
                    )
                  : Icon(
                      applied
                          ? Icons.check_circle_rounded
                          : canApply
                          ? Icons.send_rounded
                          : Icons.block_rounded,
                    ),
              label: Text(
                job == null
                    ? context.tr('jobs.loading')
                    : applied
                    ? context.tr('jobs.already_applied')
                    : canApply
                    ? context.tr('jobs.apply')
                    : context.tr('jobs.not_accepting'),
              ),
            ),
          ),
        );
      },
    ),
  );
  Future<void> _openApply() async {
    final token = CacheHelper.getData(key: 'token')?.toString().trim() ?? '';
    if (token.isEmpty) {
      await navigateTo(context, const LoginScreen());
      return;
    }
    final initial = widget.initialJob;
    final job = initial != null && initial.id >= 0 ? initial : await future;
    if (!mounted || job.id < 0) return;
    final result = await showModalBottomSheet<ApplyJobResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => ApplyJobSheet(job: job),
    );
    if (result != null && mounted) {
      job.hasApplied = true;
      job.canApply = false;
      widget.initialJob?.hasApplied = true;
      widget.initialJob?.canApply = false;
      setState(() => future = Future.value(job));
      AppSnackBar.success(context, result.message);
      if (result.applicationId != null) {
        await navigateTo(
          context,
          ApplicationDetailsScreen(applicationId: result.applicationId!),
        );
      }
      if (!mounted) return;
      try {
        final refreshed = await JobsRepo().getJobDetails(widget.jobId);
        if (mounted) setState(() => future = Future.value(refreshed));
      } catch (_) {
        // The application already succeeded; keep the optimistic applied state.
      }
    }
  }

  String _date(String raw) {
    final date = DateTime.tryParse(raw)?.toLocal();
    return date == null ? raw : DateFormat('MMMM d, yyyy').format(date);
  }
}

class _HeroTag extends StatelessWidget {
  final IconData icon;
  final String text;
  const _HeroTag(this.icon, this.text);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .15),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 14),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

class _SkillWrap extends StatelessWidget {
  final List<SkillModel> skills;
  final bool required;

  const _SkillWrap({required this.skills, this.required = false});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final accent = required ? colors.primary : colors.tertiary;
    return Wrap(
      spacing: 7,
      runSpacing: 7,
      children: skills
          .map(
            (skill) => Chip(
              avatar: Icon(
                required ? Icons.bolt_rounded : Icons.add_rounded,
                size: 15,
                color: accent,
              ),
              label: Text(skill.name),
              backgroundColor: accent.withValues(alpha: .10),
              side: BorderSide(color: accent.withValues(alpha: .22)),
            ),
          )
          .toList(),
    );
  }
}

class _BulletList extends StatelessWidget {
  final List<String> items;
  final bool benefits;

  const _BulletList({required this.items, this.benefits = false});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final accent = benefits ? colors.tertiary : colors.primary;
    return Column(
      children: items
          .map(
            (text) => Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Icon(
                      benefits
                          ? Icons.stars_rounded
                          : Icons.check_circle_rounded,
                      size: 16,
                      color: accent,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DefaultText(
                      text: text,
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _FactChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FactChip(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
      decoration: BoxDecoration(
        color: colors.secondaryContainer.withValues(alpha: .45),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: colors.secondary.withValues(alpha: .18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colors.secondary),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  const _Section({
    required this.title,
    required this.icon,
    required this.child,
  });
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(21),
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: context.appSoftBrand,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: HomeColors.purple),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: DefaultText(
                text: title,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
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

class _JobDetailsSkeleton extends StatelessWidget {
  const _JobDetailsSkeleton();
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ResponsiveContent(
      maxWidth: 760,
      child: ListView(
        padding: const EdgeInsets.only(top: 12),
        children: [
          Container(
            height: 230,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: AlignmentDirectional.topStart,
                end: AlignmentDirectional.bottomEnd,
                colors: [colors.primaryContainer, colors.secondaryContainer],
              ),
              borderRadius: BorderRadius.circular(25),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: 58, height: 58, radius: 18),
                SizedBox(height: 18),
                SkeletonBox(width: 250, height: 22, radius: 8),
                SizedBox(height: 10),
                SkeletonBox(width: 150, height: 13, radius: 6),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(
            2,
            (_) => Container(
              height: 150,
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: colors.surfaceContainer,
                borderRadius: BorderRadius.circular(21),
                border: Border.all(color: colors.outlineVariant),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(width: 175, height: 18, radius: 7),
                  SizedBox(height: 18),
                  SkeletonBox(width: double.infinity, height: 12),
                  SizedBox(height: 10),
                  SkeletonBox(width: double.infinity, height: 12),
                  SizedBox(height: 10),
                  SkeletonBox(width: 210, height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _JobDetailsMessageState extends StatelessWidget {
  final IconData icon;
  final String titleKey;
  final String bodyKey;
  final VoidCallback? onRetry;

  const _JobDetailsMessageState({
    required this.icon,
    required this.titleKey,
    required this.bodyKey,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ResponsiveContent(
      maxWidth: 520,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 86),
        children: [
          Center(
            child: Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 38, color: colors.primary),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            context.tr(titleKey),
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            context.tr(bodyKey),
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.onSurfaceVariant, height: 1.5),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 22),
            Center(child: ModernRetryButton(onRetry: onRetry!)),
          ],
        ],
      ),
    );
  }
}
