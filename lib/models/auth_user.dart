class AuthUser {
  final int userId;
  final String fullName;
  final String email;
  final String role;

  AuthUser({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.role,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      userId: json["userId"] ?? 0,
      fullName: json["fullName"] ?? "",
      email: json["email"] ?? "",
      role: json["role"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
        "userId": userId,
        "fullName": fullName,
        "email": email,
        "role": role,
      };
}
