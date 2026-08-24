part of '../profile_manage_sheets.dart';

class _SkillSearch extends SearchDelegate<int?> {
  final List<dynamic> skills;
  _SkillSearch(this.skills);
  @override
  List<Widget> buildActions(BuildContext context) => [
    IconButton(
      onPressed: () => query = '',
      icon: const Icon(Icons.clear_rounded),
    ),
  ];
  @override
  Widget buildLeading(BuildContext context) => IconButton(
    onPressed: () => close(context, null),
    icon: const Icon(Icons.arrow_back_rounded),
  );
  @override
  Widget buildResults(BuildContext context) => _results(context);
  @override
  Widget buildSuggestions(BuildContext context) => _results(context);
  Widget _results(BuildContext context) {
    final filtered = skills.where(
      (skill) => skill.name.toLowerCase().contains(query.toLowerCase()),
    );
    return ListView(
      children: filtered
          .map<Widget>(
            (skill) => ListTile(
              title: Text(skill.name),
              onTap: () => close(context, skill.id as int),
            ),
          )
          .toList(),
    );
  }
}
