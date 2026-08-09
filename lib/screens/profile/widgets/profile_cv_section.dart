import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:work_key/data/models/cv_file_model.dart';
import 'package:work_key/logic/cv_cubit/cv_cubit.dart';
import 'package:work_key/logic/cv_cubit/cv_state.dart';
import 'package:work_key/screens/profile/widgets/profile_sections.dart';
import 'package:work_key/shared/components/components.dart';
import 'package:work_key/utils/constants.dart';

class ProfileCvSection extends StatelessWidget {
  const ProfileCvSection({super.key});

  Future<void> _pickAndUpload(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'doc', 'docx'],
      allowMultiple: false,
    );
    final path = result?.files.single.path;
    if (path == null || !context.mounted) return;
    final file = await MultipartFile.fromFile(
      path,
      filename: result!.files.single.name,
    );
    if (!context.mounted) return;
    context.read<CvCubit>().uploadCv(FormData.fromMap({'file': file}));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CvCubit, CvStates>(
      builder: (context, state) {
        final files = state is GetCvFilesSuccessState
            ? state.cvFiles
            : const <CvFileModel>[];
        return ProfileSection(
          title: 'CV & resume',
          icon: Icons.description_outlined,
          actionLabel: 'Upload',
          onAction: state is CvLoadingState
              ? null
              : () => _pickAndUpload(context),
          child: state is CvLoadingState && files.isEmpty
              ? const LinearProgressIndicator(color: HomeColors.purple)
              : files.isEmpty
              ? const DefaultText(
                  text:
                      'Upload your CV to continue the review and smart recommendations flow.',
                  style: TextStyle(
                    color: HomeColors.muted,
                    fontSize: 12.5,
                    height: 1.5,
                  ),
                )
              : Column(
                  children: files.map((file) {
                    return _CvTile(file: file);
                  }).toList(),
                ),
        );
      },
    );
  }
}

class _CvTile extends StatelessWidget {
  final CvFileModel file;

  const _CvTile({required this.file});

  @override
  Widget build(BuildContext context) {
    final title = file.versionLabel.trim().isNotEmpty
        ? file.versionLabel
        : file.filePath.split(RegExp(r'[/\\]')).last;
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FC),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        children: [
          const Icon(Icons.picture_as_pdf_outlined, color: HomeColors.purple),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DefaultText(
                  text: title.isEmpty ? 'CV file' : title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: HomeColors.ink,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                DefaultText(
                  text: file.status.isEmpty ? 'Uploaded' : file.status,
                  style: const TextStyle(
                    color: HomeColors.muted,
                    fontSize: 10.5,
                  ),
                ),
              ],
            ),
          ),
          if (file.isPrimary)
            const Chip(
              label: Text('Primary'),
              backgroundColor: HomeColors.softPurple,
              side: BorderSide.none,
            )
          else
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'primary') {
                  context.read<CvCubit>().makePrimary(file.id);
                } else if (value == 'delete') {
                  context.read<CvCubit>().deleteCv(file.id);
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'primary', child: Text('Make primary')),
                PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
        ],
      ),
    );
  }
}
