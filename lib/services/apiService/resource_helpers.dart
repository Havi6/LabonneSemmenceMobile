List<Map<String, dynamic>> readApiList(dynamic data) {
  final raw = data is List
      ? data
      : data is Map<String, dynamic>
      ? data['data'] ?? data['items'] ?? data['results']
      : null;
  return raw is List ? raw.whereType<Map<String, dynamic>>().toList() : const [];
}

Map<String, dynamic> readApiEntity(dynamic data) {
  if (data is! Map<String, dynamic>) return const {};
  final entity = data['data'] ?? data['item'] ?? data['result'];
  return entity is Map<String, dynamic> ? entity : data;
}
