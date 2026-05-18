class UserModel {
  final String id;
  final String name;
  final String email;
  final String role; // 'admin' or 'user'
  final String? token;
  final String? phoneNumber;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.token,
    this.phoneNumber,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, {String? token}) {
    return UserModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name'] ?? json['username'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'user',
      token: token ?? json['token'],
      phoneNumber: json['phoneNumber'] ?? json['phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': name,
      'email': email,
      'role': role,
      'token': token,
      'phoneNumber': phoneNumber,
    };
  }

  bool get isAdmin => role == 'admin';
}
