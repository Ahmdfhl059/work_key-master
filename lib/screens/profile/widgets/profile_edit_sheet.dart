import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:work_key/data/models/profile_model.dart';
import 'package:work_key/logic/profile_cubit/profile_cubit.dart';
import 'package:work_key/shared/components/components.dart';
import 'package:work_key/utils/constants.dart';

Future<void> showProfileEditSheet(
  BuildContext context,
  ProfileModel profile,
) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider.value(
      value: context.read<ProfileCubit>(),
      child: _ProfileEditSheet(profile),
    ),
  );
}

class _ProfileEditSheet extends StatefulWidget {
  final ProfileModel profile;
  const _ProfileEditSheet(this.profile);
  @override
  State<_ProfileEditSheet> createState() => _ProfileEditSheetState();
}

class _ProfileEditSheetState extends State<_ProfileEditSheet> {
  late final TextEditingController headline,
      summary,
      location,
      phone,
      portfolio,
      linkedin,
      github;
  @override
  void initState() {
    super.initState();
    final p = widget.profile;
    headline = TextEditingController(text: p.headline);
    summary = TextEditingController(text: p.summary);
    location = TextEditingController(text: p.location);
    phone = TextEditingController(
      text: p.phone.isEmpty ? p.user.phone : p.phone,
    );
    portfolio = TextEditingController(text: p.portfolioUrl);
    linkedin = TextEditingController(text: p.linkedinUrl);
    github = TextEditingController(text: p.githubUrl);
  }

  @override
  void dispose() {
    for (final value in [
      headline,
      summary,
      location,
      phone,
      portfolio,
      linkedin,
      github,
    ]) {
      value.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
    child: SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          18,
          20,
          18 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: DefaultText(
                      text: 'Edit profile',
                      style: TextStyle(
                        color: HomeColors.ink,
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _field(
                headline,
                'Professional headline',
                Icons.work_outline_rounded,
              ),
              const SizedBox(height: 11),
              _field(
                summary,
                'Professional summary',
                Icons.subject_rounded,
                lines: 4,
              ),
              const SizedBox(height: 11),
              _field(location, 'Location', Icons.location_on_outlined),
              const SizedBox(height: 11),
              _field(phone, 'Phone', Icons.phone_outlined),
              const SizedBox(height: 11),
              _field(portfolio, 'Portfolio URL', Icons.language_rounded),
              const SizedBox(height: 11),
              _field(linkedin, 'LinkedIn URL', Icons.link_rounded),
              const SizedBox(height: 11),
              _field(github, 'GitHub URL', Icons.code_rounded),
              const SizedBox(height: 20),
              DefaultButton(
                background: HomeColors.purple,
                text: 'Save changes',
                uppercase: false,
                borderRadius: 16,
                onPress: () {
                  context.read<ProfileCubit>().updateProfile({
                    'headline': headline.text.trim(),
                    'summary': summary.text.trim(),
                    'location': location.text.trim(),
                    'phone': phone.text.trim(),
                    'portfolio_url': portfolio.text.trim(),
                    'linkedin_url': linkedin.text.trim(),
                    'github_url': github.text.trim(),
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    ),
  );
  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    int lines = 1,
  }) => TextField(
    controller: controller,
    maxLines: lines,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: const Color(0xFFF7F8FC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    ),
  );
}
