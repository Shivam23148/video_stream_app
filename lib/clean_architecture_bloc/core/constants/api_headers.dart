class ApiHeaders {
  static Map<String, String> custom({
    String? csrfToken,
    String? token,
    String? contentType,
    Map<String, String>? extra,
  }) {
    return {
      if (csrfToken != null) 'X-CSRFTOKEN': csrfToken,
      if (token != null) 'Authorization': 'Bearer $token',
      'accept': 'application/json',
      'content-type': contentType ?? 'application/json',
      ...?extra,
    };
  }
}
