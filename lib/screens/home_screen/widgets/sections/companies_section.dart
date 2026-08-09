import 'package:flutter/material.dart';
import 'package:work_key/data/models/home_response_model.dart';
import 'package:work_key/shared/components/components.dart';
import 'package:work_key/utils/constants.dart';

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
            title: 'No featured companies right now',
          )
        else
          SizedBox(
            height: 194,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: visible.length,
              separatorBuilder: (_, __) => const SizedBox(width: 11),
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
    final width = (MediaQuery.sizeOf(context).width * .66)
        .clamp(225.0, 285.0)
        .toDouble();
    return Container(
      width: width,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: HomeColors.divider),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0915213A),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              _CompanyCover(url: company.coverUrl),
              PositionedDirectional(
                start: 14,
                bottom: -25,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: HomeNetworkAvatar(
                    url: company.logoUrl,
                    radius: 24,
                    business: true,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 31),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DefaultText(
                  text: company.name.isEmpty ? 'Company' : company.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: HomeColors.ink,
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
                    style: const TextStyle(
                      color: HomeColors.muted,
                      fontSize: 10.5,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.work_outline_rounded,
                      size: 14,
                      color: HomeColors.purple,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '${company.openJobsCount} open ${company.openJobsCount == 1 ? 'job' : 'jobs'}',
                      style: const TextStyle(
                        color: HomeColors.purple,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CompanyCover extends StatelessWidget {
  final String? url;

  const _CompanyCover({this.url});

  @override
  Widget build(BuildContext context) {
    if (url == null) {
      return Container(
        height: 72,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE7E1FF), Color(0xFFD9E9FF)],
          ),
        ),
        child: const Center(
          child: Icon(
            Icons.apartment_rounded,
            color: HomeColors.purple,
            size: 25,
          ),
        ),
      );
    }
    return Image.network(
      url!,
      height: 72,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const _CompanyCover(),
    );
  }
}
