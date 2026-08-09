import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:work_key/data/models/job_model.dart';
import 'package:work_key/data/repo/jobs_repo.dart';
import 'package:work_key/shared/components/components.dart';
import 'package:work_key/utils/constants.dart';

class JobDetailsScreen extends StatefulWidget {
  final int jobId;
  final JobModel? initialJob;
  const JobDetailsScreen({super.key, required this.jobId, this.initialJob});
  @override State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  late Future<JobModel> future;
  @override void initState() { super.initState(); future = JobsRepo().getJobDetails(widget.jobId); }
  @override Widget build(BuildContext context) => Scaffold(
    backgroundColor: HomeColors.canvas,
    appBar: AppBar(backgroundColor: HomeColors.canvas, surfaceTintColor: Colors.transparent, title: const Text('Job details'), actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.bookmark_border_rounded))]),
    body: FutureBuilder<JobModel>(future: future, initialData: widget.initialJob, builder: (context, snapshot) {
      final job = snapshot.data;
      if (job == null && snapshot.connectionState != ConnectionState.done) return const _JobDetailsSkeleton();
      if (job == null || job.id < 0) return Center(child: DefaultButton(width: 160, background: HomeColors.purple, text: 'Try again', uppercase: false, onPress: () => setState(() => future = JobsRepo().getJobDetails(widget.jobId))));
      return ResponsiveContent(maxWidth: 760, child: ListView(padding: const EdgeInsets.only(top: 12, bottom: 110), children: [
        Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF6554D9), Color(0xFF846FE8)]), borderRadius: BorderRadius.circular(25), boxShadow: const [BoxShadow(color: Color(0x286554D9), blurRadius: 25, offset: Offset(0, 12))]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          CircleAvatar(radius: 29, backgroundColor: Colors.white, foregroundImage: job.company.logo.isNotEmpty ? NetworkImage(job.company.logo) : null, child: const Icon(Icons.business_rounded, color: HomeColors.purple)), const SizedBox(height: 15),
          DefaultText(text: job.title, style: const TextStyle(color: Colors.white, fontSize: 24, height: 1.25, fontWeight: FontWeight.w900)), const SizedBox(height: 6), DefaultText(text: job.company.name.isEmpty ? 'Company' : job.company.name, style: const TextStyle(color: Color(0xFFE8E3FF), fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16), Wrap(spacing: 7, runSpacing: 7, children: [if (job.location.isNotEmpty) _HeroTag(Icons.location_on_outlined, job.location), if (job.workMode.isNotEmpty) _HeroTag(Icons.laptop_rounded, job.workMode), if (job.employmentType.isNotEmpty) _HeroTag(Icons.schedule_rounded, job.employmentType)]),
        ])),
        const SizedBox(height: 16), _Section(title: 'About this role', icon: Icons.subject_rounded, child: DefaultText(text: job.description.isEmpty ? 'Job description will be available soon.' : job.description, style: const TextStyle(color: HomeColors.muted, fontSize: 13.5, height: 1.65))),
        if (job.skills.isNotEmpty) ...[const SizedBox(height: 14), _Section(title: 'Skills', icon: Icons.auto_awesome_rounded, child: Wrap(spacing: 7, runSpacing: 7, children: job.skills.map((skill) => Chip(label: Text(skill.name), backgroundColor: HomeColors.softPurple, side: BorderSide.none)).toList()))],
        if (job.requirements.isNotEmpty) ...[const SizedBox(height: 14), _Section(title: 'Requirements', icon: Icons.checklist_rounded, child: Column(children: job.requirements.map((text) => Padding(padding: const EdgeInsets.only(bottom: 9), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const Padding(padding: EdgeInsets.only(top: 3), child: Icon(Icons.check_circle_rounded, size: 16, color: HomeColors.purple)), const SizedBox(width: 8), Expanded(child: DefaultText(text: text, style: const TextStyle(color: HomeColors.muted, fontSize: 13, height: 1.5)))]))).toList()))],
        if (job.deadline.isNotEmpty) ...[const SizedBox(height: 14), _Section(title: 'Application deadline', icon: Icons.event_available_rounded, child: DefaultText(text: _date(job.deadline), style: const TextStyle(color: HomeColors.ink, fontWeight: FontWeight.w700)))],
      ]));
    }),
    bottomNavigationBar: SafeArea(child: Padding(padding: const EdgeInsets.fromLTRB(18, 8, 18, 12), child: DefaultButton(background: HomeColors.purple, text: 'Apply now', uppercase: false, borderRadius: 16, onPress: () {}))),
  );
  String _date(String raw) { final date = DateTime.tryParse(raw)?.toLocal(); return date == null ? raw : DateFormat('MMMM d, yyyy').format(date); }
}

class _HeroTag extends StatelessWidget { final IconData icon; final String text; const _HeroTag(this.icon, this.text); @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7), decoration: BoxDecoration(color: Colors.white.withValues(alpha: .15), borderRadius: BorderRadius.circular(10)), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, color: Colors.white, size: 14), const SizedBox(width: 5), Text(text, style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w600))])); }
class _Section extends StatelessWidget { final String title; final IconData icon; final Widget child; const _Section({required this.title, required this.icon, required this.child}); @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(21), border: Border.all(color: HomeColors.divider)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Container(width: 34, height: 34, decoration: BoxDecoration(color: HomeColors.softPurple, borderRadius: BorderRadius.circular(10)), child: Icon(icon, size: 18, color: HomeColors.purple)), const SizedBox(width: 9), DefaultText(text: title, style: const TextStyle(color: HomeColors.ink, fontSize: 17, fontWeight: FontWeight.w900))]), const SizedBox(height: 13), child])); }
class _JobDetailsSkeleton extends StatelessWidget { const _JobDetailsSkeleton(); @override Widget build(BuildContext context) => ResponsiveContent(maxWidth: 760, child: ListView(padding: const EdgeInsets.only(top: 12), children: [Container(height: 230, decoration: BoxDecoration(color: HomeColors.softPurple, borderRadius: BorderRadius.circular(25))), const SizedBox(height: 16), ...List.generate(2, (_) => Container(height: 150, margin: const EdgeInsets.only(bottom: 14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(21))))])); }
