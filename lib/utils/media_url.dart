import 'constants.dart';

String? resolveMediaUrl(dynamic value) {
  dynamic raw = value;
  if (raw is Map) {
    raw =
        raw['url'] ??
        raw['full_url'] ??
        raw['path'] ??
        raw['src'] ??
        raw['original_url'] ??
        raw['public_url'] ??
        raw['secure_url'] ??
        raw['media_url'];
  }
  final text = raw?.toString().trim() ?? '';
  if (text.isEmpty || text.toLowerCase() == 'null') return null;

  final parsed = Uri.tryParse(text);
  if (parsed != null && parsed.hasScheme) return parsed.toString();

  final api = Uri.parse(baseURL);
  final origin = Uri(
    scheme: api.scheme,
    host: api.host,
    port: api.hasPort ? api.port : null,
  );
  final path = text.replaceAll('\\', '/');
  return origin.resolve(path.startsWith('/') ? path : '/$path').toString();
}
