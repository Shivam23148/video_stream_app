class TokenModel {
  final String accessToken;
  final String refreshToken;
  final DateTime accessTokenExpiry;
  final DateTime refreshTokenExpiry;

  TokenModel(
    this.accessToken,
    this.refreshToken,
    this.accessTokenExpiry,
    this.refreshTokenExpiry,
  );

  bool get isAccessTokenValid => accessTokenExpiry.isAfter(DateTime.now());
  bool get isRefreshTokenValid => refreshTokenExpiry.isAfter(DateTime.now());

  //Map for secure storage

  Map<String, String> toMap() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'access_token_expiry': accessTokenExpiry.toIso8601String(),
      'refresh_token_expiry': refreshTokenExpiry.toIso8601String(),
    };
  }

  //Create from map (after reading from secure storage)
  factory TokenModel.fromMap(Map<String, String?> map) {
    return TokenModel(
      map['accessToken'] ?? "",
      map['refreshToken'] ?? "",
      DateTime.parse(map['accessTokenExpiry'] ?? ""),
      DateTime.parse(map['refreshTokenExpiry'] ?? ""),
    );
  }
}
