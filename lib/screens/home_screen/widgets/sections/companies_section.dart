import 'package:flutter/material.dart';
import 'package:work_key/data/models/home_response_model.dart';
import 'package:work_key/localization/app_localizations.dart';
import 'package:work_key/shared/components/components.dart';
import 'package:work_key/utils/constants.dart';
import 'package:work_key/screens/explore_jobs/explore_jobs_screen.dart';

import '../home_shared.dart';

class HomeCompaniesSection extends StatelessWidget {
  final List<HomeCompanyModel> companies;

  const HomeCompaniesSection({super.key, required this.companies});

  @override
  Widget build(BuildContext context) {
    final visible = companies.take(4).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const HomeSectionHeader(title: 'Companies hiring now'),
        const SizedBox(height: 14),
        if (companies.isEmpty)
          const HomeEmptyState(
            icon: Icons.apartment_rounded,
            title: 'home.no_featured_companies',
          )
        else
          SizedBox(
            height: 232,
            child: ListView.separated(
              clipBehavior: Clip.none,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: visible.length,
              separatorBuilder: (_, __) => const SizedBox(width: 15),
              itemBuilder: (context, index) {
                return _CompanyCard(company: visible[index]);
              },
            ),
          ),
      ],
    );
  }
}

class _CompanyCard extends StatelessWidget {
  final HomeCompanyModel company;

  const _CompanyCard({required this.company});

  @override
  Widget build(BuildContext context) {
    final hasCover = company.coverUrl?.isNotEmpty == true;
    final hasLogo = company.logoUrl?.isNotEmpty == true;
    final width = (MediaQuery.sizeOf(context).width * .66)
        .clamp(225.0, 285.0)
        .toDouble();
    final accent = _companyAccent(company);
    return AnimatedPressableCard(
      onTap: company.id == null
          ? null
          : () => navigateTo(
              context,
              ExploreJobsScreen(
                companyId: company.id,
                companyName: company.name,
              ),
            ),
      borderRadius: BorderRadius.circular(26),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Container(
          width: width,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: AlignmentDirectional.topStart,
              end: AlignmentDirectional.bottomEnd,
              colors: [
                Theme.of(context).colorScheme.surfaceContainer,
                Color.lerp(
                  Theme.of(context).colorScheme.surfaceContainer,
                  accent,
                  Theme.of(context).brightness == Brightness.dark ? .10 : .055,
                )!,
              ],
            ),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: accent.withValues(alpha: .28)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  _CompanyCover(
                    url: company.coverUrl,
                    logoUrl: company.logoUrl,
                    companyName: company.name,
                    accent: accent,
                  ),
                  if (hasCover || !hasLogo)
                    PositionedDirectional(
                      start: 14,
                      bottom: -25,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x1A1B2831),
                              blurRadius: 12,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: _CompanyLogo(
                            url: company.logoUrl,
                            companyName: company.name,
                            size: 48,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: hasCover || !hasLogo ? 31 : 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DefaultText(
                      text: company.name.isEmpty
                          ? 'common.company'
                          : company.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (company.specialty != null) ...[
                      const SizedBox(height: 4),
                      DefaultText(
                        text: company.specialty!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 10.5,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.work_outline_rounded,
                          size: 14,
                          color: accent,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          context.tr(
                            'home.open_jobs',
                            values: {'count': company.openJobsCount},
                          ),
                          style: TextStyle(
                            color: accent,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(child: Container(height: 3, color: accent)),
                  Expanded(
                    child: Container(
                      height: 3,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 3,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Color _companyAccent(HomeCompanyModel company) {
  const accents = [
    Color(0xFF5B6FE8),
    Color(0xFF9B5DE5),
    Color(0xFFE58A36),
    Color(0xFF1B9AAA),
  ];
  final seed =
      company.id ?? company.name.codeUnits.fold<int>(0, (a, b) => a + b);
  return accents[seed.abs() % accents.length];
}

class _CompanyCover extends StatelessWidget {
  final String? url;
  final String? logoUrl;
  final String companyName;
  final Color? accent;

  const _CompanyCover({
    this.url,
    this.logoUrl,
    this.companyName = '',
    this.accent,
  });

  @override
  Widget build(BuildContext context) {
    if (url?.isNotEmpty != true) {
      final tone = accent ?? const Color(0xFF5B6FE8);
      return Container(
        height: 92,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: AlignmentDirectional.topStart,
            end: AlignmentDirectional.bottomEnd,
            colors: [
              tone.withValues(alpha: .26),
              Theme.of(context).colorScheme.secondary.withValues(alpha: .13),
            ],
          ),
        ),
        child: Center(
          child: logoUrl?.isNotEmpty == true
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _CompanyLogo(
                    url: logoUrl,
                    companyName: companyName,
                    size: 54,
                  ),
                )
              : _CompanyInitial(name: companyName, size: 54),
        ),
      );
    }
    return Image.network(
      url!,
      height: 92,
      width: double.infinity,
      fit: BoxFit.cover,
      gaplessPlayback: true,
      errorBuilder: (_, __, ___) => _CompanyCover(
        logoUrl: logoUrl,
        companyName: companyName,
        accent: accent,
      ),
    );
  }
}

class _CompanyLogo extends StatelessWidget {
  final String? url;
  final String companyName;
  final double size;

  const _CompanyLogo({this.url, required this.companyName, required this.size});

  @override
  Widget build(BuildContext context) {
    final placeholder = _CompanyInitial(name: companyName, size: size);
    if (url?.isNotEmpty != true) return placeholder;
    return Image.network(
      url!,
      width: size,
      height: size,
      fit: BoxFit.contain,
      gaplessPlayback: true,
      errorBuilder: (_, __, ___) => placeholder,
    );
  }
}

class _CompanyInitial extends StatelessWidget {
  final String name;
  final double size;

  const _CompanyInitial({required this.name, required this.size});

  @override
  Widget build(BuildContext context) {
    final normalized = name.trim();
    final initial = normalized.isEmpty ? 'W' : normalized[0].toUpperCase();
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [HomeColors.brand, HomeColors.purple],
        ),
      ),
      child: Text(
        initial,
        maxLines: 1,
        style: TextStyle(
          color: Colors.white,
          fontSize: size * .42,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
