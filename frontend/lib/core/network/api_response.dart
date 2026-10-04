abstract final class ApiResponse {
  static Map<String, dynamic> object(Object? data) {
    if (data is Map<String, dynamic>) return data;
    throw const FormatException('Expected an API object');
  }

  static List<Map<String, dynamic>> objects(Object? data) {
    if (data is! List<dynamic>) {
      throw const FormatException('Expected an API list');
    }
    return data.map(object).toList(growable: false);
  }
}
