part of '../profile_manage_sheets.dart';

class _ManagerHeader extends StatelessWidget {
  final String title;
  const _ManagerHeader({required this.title});
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: DefaultText(
          text: title,
          style: TextStyle(
            color: context.appInk,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.close_rounded),
      ),
    ],
  );
}

class _ManageItem extends StatelessWidget {
  final String title, subtitle;
  final VoidCallback onEdit, onDelete;
  const _ManageItem({
    required this.title,
    required this.subtitle,
    required this.onEdit,
    required this.onDelete,
  });
  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(title.isEmpty ? context.tr('profile.untitled') : title),
    subtitle: subtitle.isEmpty ? null : Text(subtitle),
    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(onPressed: onEdit, icon: const Icon(Icons.edit_outlined)),
        IconButton(
          onPressed: onDelete,
          color: const Color(0xFFB44343),
          icon: const Icon(Icons.delete_outline_rounded),
        ),
      ],
    ),
  );
}
