import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/cv_file_model.dart';
import '../../../logic/cv_cubit/cv_cubit.dart';
import '../../../logic/cv_cubit/cv_state.dart';
import '../../../logic/profile_cubit/profile_cubit.dart';
import '../../../shared/components/components.dart';
import '../../../utils/constants.dart';
import '../../../localization/app_localizations.dart';
import '../cv_review_screen.dart';
import 'profile_sections.dart';

class ProfileCvSection extends StatelessWidget {
  const ProfileCvSection({super.key});

  Future<void> _pickAndUpload(BuildContext context) async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'doc', 'docx'],
    );
    final selected = result.single;
    if (selected.path == null || !context.mounted) return;
    final file = await MultipartFile.fromFile(
      selected.path!,
      filename: selected.name,
    );
    if (!context.mounted) return;
    await context.read<CvCubit>().uploadCv(
      FormData.fromMap({'file': file, 'version_label': selected.name}),
    );
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<CvCubit, CvState>(
    builder: (context, state) => ProfileSection(
      title: context.tr('profile.cv_title'),
      icon: Icons.description_outlined,
      actionLabel: context.tr('profile.cv_upload'),
      onAction: state.loading ? null : () => _pickAndUpload(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (state.loading) ...[
            LinearProgressIndicator(
              minHeight: 3,
              color: HomeColors.purple,
              backgroundColor: context.appSoftBrand,
            ),
            const SizedBox(height: 13),
          ],
          if (state.files.isEmpty && !state.loading)
            DefaultText(
              text: context.tr('profile.cv_empty'),
              style: TextStyle(
                color: context.appMuted,
                fontSize: 12.5,
                height: 1.5,
              ),
            )
          else
            ...state.files.map(
              (file) => Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: _CvTile(
                  file: file,
                  busy: state.busyFileId == file.id,
                  onUpload: () => _pickAndUpload(context),
                ),
              ),
            ),
        ],
      ),
    ),
  );
}

class _CvTile extends StatelessWidget {
  final CvFileModel file;
  final bool busy;
  final VoidCallback onUpload;

  const _CvTile({
    required this.file,
    required this.busy,
    required this.onUpload,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
    ),
    child: Column(
      children: [
        Row(
          children: [
            Container(
              width: 43,
              height: 43,
              decoration: BoxDecoration(
                color: context.appSoftBrand,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                file.extension == 'pdf'
                    ? Icons.picture_as_pdf_outlined
                    : Icons.description_outlined,
                color: HomeColors.purple,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DefaultText(
                    text: file.displayName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: context.appInk,
                      fontSize: 12.5,
                      height: 1.3,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  DefaultText(
                    text: file.statusLabel,
                    style: TextStyle(color: context.appMuted, fontSize: 10.5),
                  ),
                ],
              ),
            ),
            if (busy)
              const SizedBox(
                width: 21,
                height: 21,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: HomeColors.purple,
                ),
              )
            else if (file.canCancel)
              IconButton(
                tooltip: context.tr('common.delete'),
                onPressed: () => _confirmDelete(context),
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: Color(0xFFB24A4A),
                ),
              ),
          ],
        ),
        if (!busy && file.nextAction.key.isNotEmpty) ...[
          const SizedBox(height: 11),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _performAction(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: HomeColors.purple,
                side: const BorderSide(color: HomeColors.purple),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: Icon(_actionIcon, size: 18),
              label: Text(context.tr(_actionLabel)),
            ),
          ),
        ],
      ],
    ),
  );

  IconData get _actionIcon => switch (file.nextAction.key) {
    'wait_for_parsing' => Icons.sync_rounded,
    'retry_upload' => Icons.upload_file_rounded,
    'confirm' => Icons.verified_outlined,
    _ => Icons.rate_review_outlined,
  };

  String get _actionLabel => switch (file.nextAction.key) {
    'wait_for_parsing' => 'cv.refresh_processing',
    'retry_upload' => 'cv.upload_another',
    'confirm' => 'cv.review_and_confirm',
    'completed' => 'cv.profile_updated',
    _ =>
      file.nextAction.label.isNotEmpty
          ? file.nextAction.label
          : 'cv.review_action',
  };

  Future<void> _performAction(BuildContext context) async {
    if (file.nextAction.key == 'wait_for_parsing') {
      await context.read<CvCubit>().getCvFiles(showLoading: false);
      return;
    }
    if (file.nextAction.key == 'retry_upload') {
      onUpload();
      return;
    }
    if (file.nextAction.key == 'completed') return;
    final profileUpdated = await navigateTo(
      context,
      CvReviewScreen(cvFile: file),
    );
    if (context.mounted) {
      await context.read<CvCubit>().getCvFiles(showLoading: false);
      if (profileUpdated == true && context.mounted) {
        context.read<ProfileCubit>().getProfile();
      }
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final accepted =
        await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: Color(0xFFB24A4A),
            ),
            title: Text(context.tr('cv.delete_title')),
            content: Text(
              context.tr('cv.delete_body', values: {'name': file.displayName}),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(context.tr('common.cancel')),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFB24A4A),
                ),
                child: Text(context.tr('common.delete')),
              ),
            ],
          ),
        ) ??
        false;
    if (accepted && context.mounted) {
      await context.read<CvCubit>().cancelCv(file.id);
    }
  }
}
