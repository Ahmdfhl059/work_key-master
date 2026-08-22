import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:work_key/data/models/city_model.dart';
import 'package:work_key/data/models/profile_model.dart';
import 'package:work_key/data/repo/reference_repo.dart';
import 'package:work_key/localization/app_localizations.dart';
import 'package:work_key/logic/profile_cubit/profile_cubit.dart';
import 'package:work_key/logic/profile_cubit/profile_state.dart';
import 'package:work_key/shared/components/app_snackbar.dart';
import 'package:work_key/shared/components/components.dart';
import 'package:work_key/utils/constants.dart';

Future<void> showProfileEditSheet(
  BuildContext context,
  ProfileModel profile,
) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
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
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController name;
  late final TextEditingController headline;
  late final TextEditingController summary;
  late final TextEditingController location;
  late final TextEditingController phone;
  late final TextEditingController portfolio;
  late final TextEditingController linkedin;
  late final TextEditingController github;
  late final TextEditingController availableFrom;
  late final Future<List<CityModel>> cities;

  String? availabilityStatus;
  int? cityId;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    final profile = widget.profile;
    name = TextEditingController(text: profile.user.name);
    headline = TextEditingController(text: profile.headline);
    summary = TextEditingController(text: profile.summary);
    location = TextEditingController(text: profile.location);
    phone = TextEditingController(
      text: profile.phone.isEmpty ? profile.user.phone : profile.phone,
    );
    portfolio = TextEditingController(text: profile.portfolioUrl);
    linkedin = TextEditingController(text: profile.linkedinUrl);
    github = TextEditingController(text: profile.githubUrl);
    availableFrom = TextEditingController(text: profile.availableFrom);
    availabilityStatus = profile.availabilityStatus.isEmpty
        ? null
        : profile.availabilityStatus;
    cityId = profile.cityId;
    cities = ReferenceRepo().getCities();
  }

  @override
  void dispose() {
    for (final controller in [
      name,
      headline,
      summary,
      location,
      phone,
      portfolio,
      linkedin,
      github,
      availableFrom,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            12,
            20,
            18 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: scheme.outlineVariant,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DefaultText(
                          text: context.tr('profile.edit'),
                          style: TextStyle(
                            color: scheme.onSurface,
                            fontSize: 21,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: saving ? null : () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _sectionTitle(
                    context.tr('profile.personal_details'),
                    Icons.badge_outlined,
                  ),
                  _field(
                    name,
                    context.tr('profile.full_name'),
                    Icons.person_outline_rounded,
                    textInputAction: TextInputAction.next,
                    validator: (value) => value == null || value.trim().isEmpty
                        ? context.tr('profile.name_required')
                        : null,
                  ),
                  const SizedBox(height: 11),
                  TextFormField(
                    initialValue: widget.profile.user.email,
                    readOnly: true,
                    enableInteractiveSelection: true,
                    style: TextStyle(color: scheme.onSurfaceVariant),
                    decoration: InputDecoration(
                      labelText: context.tr('profile.account_email'),
                      helperText: context.tr(
                        'profile.email_managed_by_account',
                      ),
                      helperMaxLines: 2,
                      prefixIcon: const Icon(Icons.email_outlined),
                      suffixIcon: const Icon(Icons.lock_outline_rounded),
                      filled: true,
                      fillColor: scheme.surfaceContainerHighest,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _sectionTitle(
                    context.tr('profile.professional_details'),
                    Icons.work_outline_rounded,
                  ),
                  _field(
                    headline,
                    context.tr('profile.professional_headline'),
                    Icons.work_outline_rounded,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 11),
                  _field(
                    summary,
                    context.tr('profile.professional_summary'),
                    Icons.subject_rounded,
                    lines: 4,
                    textInputAction: TextInputAction.newline,
                  ),
                  const SizedBox(height: 11),
                  _field(
                    phone,
                    context.tr('profile.phone'),
                    Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 20),
                  _sectionTitle(
                    context.tr('profile.preferences'),
                    Icons.location_on_outlined,
                  ),
                  FutureBuilder<List<CityModel>>(
                    future: cities,
                    builder: (context, snapshot) {
                      final options = snapshot.data ?? const <CityModel>[];
                      final selectedExists = options.any(
                        (city) => city.id == cityId,
                      );
                      return DropdownButtonFormField<int?>(
                        key: ValueKey('profile-city-$cityId-${options.length}'),
                        initialValue: selectedExists ? cityId : null,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: context.tr('profile.city'),
                          prefixIcon: const Icon(Icons.location_city_rounded),
                          suffixIcon:
                              snapshot.connectionState ==
                                  ConnectionState.waiting
                              ? const Padding(
                                  padding: EdgeInsets.all(14),
                                  child: SizedBox.square(
                                    dimension: 17,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                        items: [
                          DropdownMenuItem<int?>(
                            value: null,
                            child: Text(context.tr('profile.clear_city')),
                          ),
                          ...options.map(
                            (city) => DropdownMenuItem<int?>(
                              value: city.id,
                              child: Text(city.name),
                            ),
                          ),
                        ],
                        onChanged:
                            snapshot.connectionState == ConnectionState.waiting
                            ? null
                            : (value) => setState(() => cityId = value),
                      );
                    },
                  ),
                  const SizedBox(height: 11),
                  _field(
                    location,
                    context.tr('profile.location_details'),
                    Icons.location_on_outlined,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 20),
                  _sectionTitle(
                    context.tr('profile.work_availability'),
                    Icons.event_available_outlined,
                  ),
                  DropdownButtonFormField<String?>(
                    initialValue: availabilityStatus,
                    decoration: InputDecoration(
                      labelText: context.tr('profile.availability'),
                      prefixIcon: const Icon(Icons.event_available_outlined),
                    ),
                    items: [
                      DropdownMenuItem<String?>(
                        value: null,
                        child: Text(context.tr('profile.not_specified')),
                      ),
                      DropdownMenuItem<String?>(
                        value: 'available_now',
                        child: Text(context.tr('profile.available_now')),
                      ),
                      DropdownMenuItem<String?>(
                        value: 'available_from_date',
                        child: Text(context.tr('profile.available_from_date')),
                      ),
                      DropdownMenuItem<String?>(
                        value: 'not_available',
                        child: Text(context.tr('profile.not_available')),
                      ),
                    ],
                    onChanged: (value) => setState(() {
                      availabilityStatus = value;
                      if (value != 'available_from_date') {
                        availableFrom.clear();
                      }
                    }),
                  ),
                  if (availabilityStatus == 'available_from_date') ...[
                    const SizedBox(height: 11),
                    _field(
                      availableFrom,
                      context.tr('profile.available_from'),
                      Icons.calendar_month_outlined,
                      readOnly: true,
                      onTap: _pickAvailableFrom,
                      validator: (value) => value == null || value.isEmpty
                          ? context.tr('profile.available_from_date')
                          : null,
                    ),
                  ],
                  const SizedBox(height: 20),
                  _sectionTitle(
                    context.tr('profile.professional_links'),
                    Icons.link_rounded,
                  ),
                  _field(
                    portfolio,
                    context.tr('profile.portfolio_url'),
                    Icons.language_rounded,
                    keyboardType: TextInputType.url,
                    textInputAction: TextInputAction.next,
                    validator: _urlValidator,
                  ),
                  const SizedBox(height: 11),
                  _field(
                    linkedin,
                    context.tr('profile.linkedin_url'),
                    Icons.link_rounded,
                    keyboardType: TextInputType.url,
                    textInputAction: TextInputAction.next,
                    validator: _urlValidator,
                  ),
                  const SizedBox(height: 11),
                  _field(
                    github,
                    context.tr('profile.github_url'),
                    Icons.code_rounded,
                    keyboardType: TextInputType.url,
                    textInputAction: TextInputAction.done,
                    validator: _urlValidator,
                  ),
                  const SizedBox(height: 22),
                  DefaultButton(
                    background: HomeColors.purple,
                    text: saving
                        ? context.tr('common.saving')
                        : context.tr('profile.save_changes'),
                    uppercase: false,
                    borderRadius: 16,
                    onPress: saving ? () {} : _save,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text, IconData icon) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: scheme.primary),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: scheme.onSurface,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    int lines = 1,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    bool readOnly = false,
    VoidCallback? onTap,
    String? Function(String?)? validator,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return TextFormField(
      controller: controller,
      maxLines: lines,
      readOnly: readOnly,
      onTap: onTap,
      validator: validator,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  String? _urlValidator(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    final uri = Uri.tryParse(text);
    if (uri == null ||
        !uri.hasScheme ||
        !uri.hasAuthority ||
        (uri.scheme != 'http' && uri.scheme != 'https')) {
      return context.tr('profile.invalid_url');
    }
    return null;
  }

  Future<void> _pickAvailableFrom() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final parsed = DateTime.tryParse(availableFrom.text);
    final selected = await showDatePicker(
      context: context,
      initialDate: parsed != null && !parsed.isBefore(today) ? parsed : today,
      firstDate: today,
      lastDate: DateTime(today.year + 10, today.month, today.day),
    );
    if (selected == null) return;
    availableFrom.text =
        '${selected.year.toString().padLeft(4, '0')}-'
        '${selected.month.toString().padLeft(2, '0')}-'
        '${selected.day.toString().padLeft(2, '0')}';
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => saving = true);
    final saved = await context.read<ProfileCubit>().updateProfile({
      'name': name.text.trim(),
      'headline': _nullable(headline.text),
      'summary': _nullable(summary.text),
      'city_id': cityId,
      'location': _nullable(location.text),
      'phone': _nullable(phone.text),
      'portfolio_url': _nullable(portfolio.text),
      'linkedin_url': _nullable(linkedin.text),
      'github_url': _nullable(github.text),
      'availability_status': availabilityStatus,
      'available_from': availabilityStatus == 'available_from_date'
          ? _nullable(availableFrom.text)
          : null,
    });
    if (!mounted) return;
    setState(() => saving = false);
    if (saved) {
      Navigator.pop(context);
      AppSnackBar.success(context, context.tr('profile.update_success'));
      return;
    }
    final state = context.read<ProfileCubit>().state;
    final message = state is ProfileErrorState
        ? state.error
        : context.tr('profile.update_error');
    AppSnackBar.error(context, message);
  }

  String? _nullable(String value) {
    final text = value.trim();
    return text.isEmpty ? null : text;
  }
}
