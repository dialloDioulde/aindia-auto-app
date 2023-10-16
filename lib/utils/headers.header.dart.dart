class HeadersHeaderDart {
  static Map<String, String> headers() {
    return {
      'Content-Type': 'application/json',
      'loginType': 'MOBILE',
    };
  }

  static Map<String, String> headersWithToken(String token) {
    return {
      'Content-Type': 'application/json',
      'loginType': 'MOBILE',
      'Authorization': "Bearer $token"
    };
  }
}
